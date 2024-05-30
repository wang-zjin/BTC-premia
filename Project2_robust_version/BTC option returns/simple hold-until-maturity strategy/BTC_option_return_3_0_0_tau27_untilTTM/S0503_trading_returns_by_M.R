library(tidyverse)
library(ggplot2)
library(ggpubr)

theme_set(theme_bw() +
            theme(text = element_text(size=15),
                  axis.line = element_line(colour = "black"),
                  # panel.border = element_blank(),
                  aspect.ratio = 1,
                  legend.title=element_blank()
            ))

ttm = 27
all_steps_ahead = ttm

###### ######

setwd("~/同步空间/Pricing_Kernel/EPK/BTC option return/BTC_option_return_3_0_0_tau27_untilTTM/")
new_dir = "S0503_trading_result_by_m/"
dir.create(paste0(new_dir), showWarnings = FALSE)

# trading_type = "Long" # Short or Long

###### Trading strategies by m ###### 
# f=1

# files = tibble(weight = c("EW","QW","VW"))
trading_type_set = tibble(type = c("Long","Short"))

# for (f in 1:nrow(files)){


####### Long strategies #######
t=1
trading_type = trading_type_set$type[t]

longCall_by_m = read_csv(paste0("S03_trading_returns/",trading_type,"Callsimple_by_M_ttm",
                                as.character(ttm),".csv"))
copy <- longCall_by_m %>%
  mutate(Cluster = 3)
longCall_by_m <- rbind(longCall_by_m, copy) %>%
  mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                          ifelse(Cluster==1,"Cluster1","Overall")))
longCall_by_m = longCall_by_m %>% 
  mutate(mean_return = R_t*100,
         strategy = paste0(trading_type," Call simple")) 

longPut_by_m = read_csv(paste0("S03_trading_returns/",trading_type,"Putsimple_by_M_ttm",
                               as.character(ttm),".csv"))
copy <- longPut_by_m %>%
  mutate(Cluster = 3)
longPut_by_m <- rbind(longPut_by_m, copy) %>%
  mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                          ifelse(Cluster==1,"Cluster1","Overall")))
longPut_by_m = longPut_by_m %>% 
  mutate(mean_return = R_t*100,
         strategy = paste0(trading_type," Put simple")) 


dat_by_m <- dat_by_m = bind_rows(longCall_by_m,longPut_by_m) %>%
  mutate(M_fine = cut(Return_t, breaks = seq(-1, 1, by = 0.1), include.lowest = TRUE),
         M_fine_group = as.character(M_fine))

clusters <- c("Cluster0", "Cluster1", "Overall")

for (cluster in clusters) {
  dat_cluster <- filter(dat_by_m, Cluster == cluster)
  
  # Define colors based on the cluster
  cluster_colors <- if (cluster == "Cluster0") {
    c("Long Call simple" = "blue", "Long Put simple" = "blue")
  } else if (cluster == "Cluster1") {
    c("Long Call simple" = "red", "Long Put simple" = "red")
  } else {
    c("Long Call simple" = "black", "Long Put simple" = "black")
  }
  
  plot_cluster <- ggplot(dat_cluster, aes(x = M_fine_group, y = mean_return, fill = strategy)) +
    geom_boxplot(alpha = 0.5) +
    facet_wrap(~ strategy, nrow = 1, scales = "free_y") +
    scale_fill_manual(values = cluster_colors) +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1),
          axis.title.y = element_text(face = "bold", size = 12),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank()) +
    labs(title = paste("Option Returns for", cluster, "Cluster"), x = "Return", y = "Mean Return (%)") +
    ylim(-100, 200)
  
  # Display the plot
  print(plot_cluster)
  
  plot_cluster = annotate_figure(plot_cluster,
                                  top = text_grob(paste0("simple option returns, tau = ",ttm),
                                                  size = 30, face = "bold"))
  
  ggsave(filename = paste0(new_dir,trading_type,"simple_by_m_ttm",as.character(ttm),as.character(cluster),".png"), plot = plot_cluster, bg = "transparent", width = 22, height = 10, dpi = 300)
  
  
}

# Simplify the labels for readability


# Adjusting plot code to incorporate simplified labels
for (cluster in clusters) {
  dat_cluster <- filter(dat_by_m, Cluster == cluster)
  
  plot_cluster <- ggplot(dat_cluster, aes(x = M_fine_group, y = mean_return, fill = strategy)) +
    geom_boxplot(alpha = 0.5) +
    facet_wrap(~ strategy, nrow = 1, scales = "free_y") +
    scale_fill_manual(values = cluster_colors) +
    scale_x_discrete(labels = function(x) simplified_labels) + # Apply simplified labels
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1, size = 8), # Adjust size as needed
          axis.title.y = element_text(face = "bold", size = 12),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank()) +
    labs(title = paste("Option Returns for", cluster, "Cluster"), x = "Return", y = "Mean Return (%)") +
    ylim(-100, 200)
  
  print(plot_cluster)
  
  ggsave(filename = paste0(new_dir, trading_type, "_", cluster, "_by_m_fine_ttm", as.character(ttm), ".png"), plot = plot_cluster, bg = "transparent", width = 22, height = 10, dpi = 300)
  
  break
}
