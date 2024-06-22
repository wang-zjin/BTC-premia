rm(list = ls())
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

#### Basic  ######

setwd("~/Documents/GitHub/BTC-premia/Project1_draft_version/BTC option returns/delta-hedge strategy/delta-neutral strategy_4_0_1_tau27/")
new_dir = "S0508_trading_result_by_m/"
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

longCall_by_m = read_csv(paste0("S03_trading_returns/",trading_type,"CallDH_by_M_ttm",
                                as.character(ttm),".csv"))
copy <- longCall_by_m %>%
  mutate(Cluster = 3)
longCall_by_m <- rbind(longCall_by_m, copy) %>%
  mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                          ifelse(Cluster==1,"Cluster1","Overall")))
longCall_by_m = longCall_by_m %>% 
  mutate(mean_return = R_t*100,
         strategy = paste0(trading_type," Call DH")) 

longPut_by_m = read_csv(paste0("S03_trading_returns/",trading_type,"PutDH_by_M_ttm",
                               as.character(ttm),".csv"))
copy <- longPut_by_m %>%
  mutate(Cluster = 3)
longPut_by_m <- rbind(longPut_by_m, copy) %>%
  mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                          ifelse(Cluster==1,"Cluster1","Overall")))
longPut_by_m = longPut_by_m %>% 
  mutate(mean_return = R_t*100,
         strategy = paste0(trading_type," Put DH")) 


dat_by_m <- bind_rows(longCall_by_m,longPut_by_m) %>%
  mutate(M_fine = cut(Return_t, breaks = seq(-1, 1, by = 0.1), include.lowest = TRUE),
         M_fine_group = as.character(M_fine))

# Define a function to create 2-D histogram plots
create_2d_histogram_plot <- function(data, cluster_name, cluster_colors, title_prefix) {
  plt <- data %>%
    filter(Cluster == cluster_name) %>%
    ggplot(aes(x = Return_t, y = mean_return)) +
    geom_bin2d(bins = 30) + # You can adjust the number of bins
    scale_fill_viridis_c() + # Use a color scale for the fill
    facet_wrap(~ strategy, nrow = 1, scales = "free_y") +
    labs(title = "",
         x = "Market Return",
         y = "Option Return",
         fill = "Frequency") +
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5),
          # axis.line = element_line(colour = "black"),
          legend.position = "none",
          axis.title = element_text(size = 20),
          legend.title = element_text(size = 15),
          panel.background = element_rect(fill="white",color = "black",size=1),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          strip.text.x = element_text(size = 20,face = "bold"),
          strip.text.y = element_text(size = 20,face = "bold")) +
    scale_x_continuous(breaks = c(-1, -0.6, -0.2, 0, 0.2, 0.6, 1),
                       labels = c("-1", "-0.6", "-0.2", "0", "0.2", "0.6", "1"),
                       limits = c(-1, 1), expand = c(0, 0))  +
    scale_y_continuous(limits = c(-100, 100), expand = c(0, 0)) +
    scale_color_manual(values = cluster_colors)
  
  return(plt)
}

# Apply the function to create plots for each cluster
plt_HV <- create_2d_histogram_plot(dat_by_m, "Cluster0", c("Long Call simple" = "blue", "Long Put simple" = "blue"), "High Volatility") + 
  theme(legend.position = "none")
plt_LV <- create_2d_histogram_plot(dat_by_m, "Cluster1", c("Long Call simple" = "red", "Long Put simple" = "red"), "Low Volatility") +
  theme(legend.position = "right")
plt_OA <- create_2d_histogram_plot(dat_by_m, "Overall", c("Long Call simple" = "black", "Long Put simple" = "black"), "Overall") +
  theme(legend.position = "none")

# Use patchwork to combine the plots into a 3-by-2 grid
library(patchwork)
combined_plot <- plt_OA / plt_HV / plt_LV  & plot_layout(ncol = 1)

# Save the combined plot
ggsave(filename = paste0(new_dir, trading_type, "_DH_combined_2d_histogram_ttm", as.character(ttm), ".png"), plot = combined_plot, width = 14, height = 21, dpi = 300)

