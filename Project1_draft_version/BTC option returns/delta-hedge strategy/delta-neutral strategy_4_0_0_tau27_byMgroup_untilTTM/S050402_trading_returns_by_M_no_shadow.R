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

setwd("~/同步空间/Pricing_Kernel/EPK/delta-neutral strategy/delta-neutral strategy_4_0_0_tau27_byMgroup_untilTTM/")
new_dir = "S050402_trading_result_by_m/"
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

clusters <- c("Cluster0", "Cluster1", "Overall")

#### HV Cluster ####
cluster = "Cluster0"
dat_cluster <- filter(dat_by_m, Cluster == cluster)
# Define colors based on the cluster
cluster_colors <- c("Long Call DH" = "blue", "Long Put DH" = "blue")

plt_HV <- dat_cluster %>%
  ggplot(aes(x=Return_t, y=mean_return, color = strategy, fill = strategy)) +
  facet_wrap(~ strategy, nrow = 1, scales = "free_y") +
  # geom_rect(aes(xmin = -0.7, xmax = -0.15, ymin = -Inf, ymax = Inf, fill = "blue"), alpha = 0.01, color = NA, inherit.aes = FALSE) +  # Shaded background
  # geom_rect(aes(xmin = 0.15, xmax = 0.7, ymin = -Inf, ymax = Inf, fill = "blue"), alpha = 0.01, color = NA, inherit.aes = FALSE) +  # Shaded background
  geom_point(alpha=0.7, size=1.5) +
  # geom_smooth(method="loess", span=0.3, se=TRUE) +
  scale_color_manual(values = cluster_colors) +
  scale_fill_manual(values = cluster_colors) +
  xlab("") + ylab("") +
  ggtitle("") +
  theme(aspect.ratio = 2/3, 
        plot.title = element_text(hjust = 0.5),
        legend.position = "none",
        panel.grid.major = element_blank(),  # Remove major grid lines
        panel.grid.minor = element_blank(),  # Remove minor grid lines
        panel.background = element_rect(fill = "white", colour = "black")) + # Optional: set panel background to white and add border
  scale_x_continuous(breaks = c(-1, -0.6, -0.2, 0, 0.2, 0.6, 1),
                     labels = c("-1", "-0.6", "-0.2", "0", "0.2", "0.6", "1"),
                     limits = c(-1, 1), expand = c(0, 0))  +
  scale_y_continuous(limits = c(-100, 100), expand = c(0, 0)) 

# Save the plot
ggsave(filename = paste0(new_dir,trading_type,"DH_by_m_ttm",as.character(ttm),"_",as.character(cluster),".png"), plot = plt_HV, bg = "transparent", width = 14, height = 7, dpi = 300)

#### LV Cluster ####
cluster = "Cluster1"
dat_cluster <- filter(dat_by_m, Cluster == cluster)
# Define colors based on the cluster
cluster_colors <- c("Long Call DH" = "red", "Long Put DH" = "red")

plt_LV <- dat_cluster %>%
  ggplot(aes(x=Return_t, y=mean_return, color = strategy, fill = strategy)) +
  facet_wrap(~ strategy, nrow = 1, scales = "free_y") +
  # geom_rect(aes(xmin = -0.5, xmax = -0.15, ymin = -Inf, ymax = Inf, fill = "red"), alpha = 0.1, color = NA, inherit.aes = FALSE) +  # Shaded background
  # geom_rect(aes(xmin = 0.05, xmax = 0.45, ymin = -Inf, ymax = Inf, fill = "red"), alpha = 0.1, color = NA, inherit.aes = FALSE) +  # Shaded background
  geom_point(alpha=0.7, size=1.5) +
  # geom_smooth(method='lm', se=TRUE) +
  # geom_smooth(method="loess", span=0.3, se=TRUE) +
  # geom_smooth(method='lm', color="#6c757d", se=TRUE) +
  # geom_smooth(method="loess", fill="blue", span=0.3, se=TRUE) +
  scale_color_manual(values = cluster_colors) +
  scale_fill_manual(values = cluster_colors) +
  xlab("") + ylab("") +
  ggtitle("") +
  theme(aspect.ratio = 2/3, 
        plot.title = element_text(hjust = 0.5),
        legend.position = "none",
        panel.grid.major = element_blank(),  # Remove major grid lines
        panel.grid.minor = element_blank(),  # Remove minor grid lines
        panel.background = element_rect(fill = "white", colour = "black")) + # Optional: set panel background to white and add border
  scale_x_continuous(breaks = c(-1, -0.6, -0.2, 0, 0.2, 0.6, 1),
                     labels = c("-1", "-0.6", "-0.2", "0", "0.2", "0.6", "1"),
                     limits = c(-1, 1), expand = c(0, 0))  +
  scale_y_continuous(limits = c(-100, 100), expand = c(0, 0))


# Save the plot
ggsave(filename = paste0(new_dir,trading_type,"DH_by_m_ttm",as.character(ttm),"_",as.character(cluster),".png"), plot = plt_LV, bg = "transparent", width = 14, height = 7, dpi = 300)

#### Overall ####
cluster = "Overall"
dat_cluster <- filter(dat_by_m, Cluster == cluster)

# Define colors based on the cluster
cluster_colors <- c("Long Call DH" = "black", "Long Put DH" = "black")


plt_OA <- dat_cluster %>%
  ggplot(aes(x=Return_t, y=mean_return, color = strategy, fill = strategy)) +
  facet_wrap(~ strategy, nrow = 1, scales = "free_y") +
  # geom_rect(aes(xmin = -0.6, xmax = -0.2, ymin = -Inf, ymax = Inf, fill = "black"), alpha = 0.1, color = NA, inherit.aes = FALSE) +  # Shaded background
  # geom_rect(aes(xmin = 0.2, xmax = 0.6, ymin = -Inf, ymax = Inf, fill = "black"), alpha = 0.1, color = NA, inherit.aes = FALSE) +  # Shaded background
  geom_point(alpha=0.7, size=1.5) +
  # geom_smooth(method='lm', se=TRUE) +
  # geom_smooth(method="loess", span=0.3, se=TRUE) +
  # geom_smooth(method='lm', color="#6c757d", se=TRUE) +
  # geom_smooth(method="loess", fill="blue", span=0.3, se=TRUE) +
  scale_color_manual(values = cluster_colors) +
  scale_fill_manual(values = cluster_colors) +
  xlab("") + ylab("") +
  ggtitle("") +
  theme(aspect.ratio = 2/3, 
        plot.title = element_text(hjust = 0.5),
        legend.position = "none",
        panel.grid.major = element_blank(),  # Remove major grid lines
        panel.grid.minor = element_blank(),  # Remove minor grid lines
        panel.background = element_rect(fill = "white", colour = "black")) + # Optional: set panel background to white and add border
  scale_x_continuous(breaks = c(-1, -0.6, -0.2, 0, 0.2, 0.6, 1),
                     labels = c("-1", "-0.6", "-0.2", "0", "0.2", "0.6", "1"),
                     limits = c(-1, 1), expand = c(0, 0))  +
  scale_y_continuous(limits = c(-100, 100), expand = c(0, 0))


# Save the plot
ggsave(filename = paste0(new_dir,trading_type,"DH_by_m_ttm",as.character(ttm),"_",as.character(cluster),".png"), plot = plt_OA, bg = "transparent", width = 14, height = 7, dpi = 300)

# install.packages("patchwork")
library(patchwork)

# Combine the plots into a 3-by-2 grid
combined_plot <- plt_HV /
  plt_LV /
  plt_OA &
  plot_layout(ncol = 1)

# Save the combined plot
ggsave(filename = paste0(new_dir, trading_type, "_DH_combined_ttm", as.character(ttm), ".png"), plot = combined_plot, width = 14, height = 21, dpi = 300)

