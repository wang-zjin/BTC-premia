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

setwd("~/同步空间/Pricing_Kernel/EPK/BTC option return/BTC_option_return_3_0_0_tau27_untilTTM/")
new_dir = "S0507_trading_result_by_m/"
dir.create(paste0(new_dir), showWarnings = FALSE)

# trading_type = "Long" # Short or Long

###### Trading strategies by m ###### 
# f=1

files = tibble(weight = c("EW","VW"))
trading_type_set = tibble(type = c("Long","Short"))

for (tt in 1:nrow(files)){


####### Long strategies #######
t=1
trading_type = trading_type_set$type[t]
# tt = 1
weight_type = files$weight[tt]

longStraddle_by_m = read_csv(paste0("S03_trading_returns/simple_",trading_type,"Straddle_by_M_",weight_type,"_ttm",
                                as.character(ttm),".csv"))
copy <- longStraddle_by_m %>%
  mutate(Cluster = 3)
longStraddle_by_m <- rbind(longStraddle_by_m, copy) %>%
  mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                          ifelse(Cluster==1,"Cluster1","Overall")))
longStraddle_by_m = longStraddle_by_m %>% 
  mutate(mean_return = R_t*100,
         strategy = paste0(trading_type," Straddle simple")) %>%
  mutate(Moneyness_minus_one = Moneyness - 1)

dat_by_m <- longStraddle_by_m %>%
  mutate(M_fine = cut(Moneyness_minus_one, breaks = seq(-1, 1, by = 0.1), include.lowest = TRUE),
         M_fine_group = as.character(M_fine))

clusters <- c("Cluster0", "Cluster1", "Overall")

#### HV Cluster ####
cluster = "Cluster0"
dat_cluster <- filter(dat_by_m, Cluster == cluster)
# Define colors based on the cluster
cluster_colors <- c("Long Call simple" = "blue", "Long Put simple" = "blue", "Long Straddle simple" = "blue")

plt_HV <- dat_cluster %>%
  ggplot(aes(x=Moneyness_minus_one, y=mean_return, color = strategy, fill = strategy)) +
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
  scale_x_continuous(breaks = c(-1, -0.7, -0.15, 0, 0.15, 0.7, 1),
                     labels = c("-1", "-0.7", "-0.15", "0", "0.15", "0.7", "1"),
                     limits = c(-1, 1), expand = c(0, 0))  +
  scale_y_continuous(limits = c(-120, 250), expand = c(0, 0)) +
  # scale_y_continuous(expand = c(0, 0))+
  # Adding dashed lines to highlight specific regions
  geom_vline(xintercept = c(-0.7, -0.15, 0.15, 0.7), linetype = "dashed", color = "black", size = 1) # Adjust color and size as needed

# Save the plot
ggsave(filename = paste0(new_dir,trading_type,"simple_",weight_type,"_ttm",as.character(ttm),"_",as.character(cluster),".png"), plot = plt_HV, bg = "transparent", width = 14, height = 7, dpi = 300)

#### LV Cluster ####
cluster = "Cluster1"
dat_cluster <- filter(dat_by_m, Cluster == cluster)
# Define colors based on the cluster
cluster_colors <- c("Long Call simple" = "red", "Long Put simple" = "red", "Long Straddle simple" = "red")

plt_LV <- dat_cluster %>%
  ggplot(aes(x=Moneyness_minus_one, y=mean_return, color = strategy, fill = strategy)) +
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
  scale_x_continuous(breaks = c(-1, -0.5, -0.15, 0, 0.05, 0.45, 1),
                     labels = c("-1", "-0.5", "-0.15", "0", "0.05", "0.45", "1"),
                     limits = c(-1, 1), expand = c(0, 0))  +
  scale_y_continuous(limits = c(-120, 250), expand = c(0, 0))+
  # scale_y_continuous(expand = c(0, 0))+
  # Adding dashed lines to highlight specific regions
  geom_vline(xintercept = c(-0.5, -0.15, 0.05, 0.45), linetype = "dashed", color = "black", size = 1) # Adjust color and size as needed


# Save the plot
ggsave(filename = paste0(new_dir,trading_type,"simple_",weight_type,"_ttm",as.character(ttm),"_",as.character(cluster),".png"), plot = plt_LV, bg = "transparent", width = 14, height = 7, dpi = 300)

#### Overall ####
cluster = "Overall"
dat_cluster <- filter(dat_by_m, Cluster == cluster)

# Define colors based on the cluster
cluster_colors <- c("Long Call simple" = "black", "Long Put simple" = "black", "Long Straddle simple" = "black")


plt_OA <- dat_cluster %>%
  ggplot(aes(x=Moneyness_minus_one, y=mean_return, color = strategy, fill = strategy)) +
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
  scale_y_continuous(limits = c(-120, 250), expand = c(0, 0))+
  # scale_y_continuous(expand = c(0, 0))+
  # Adding dashed lines to highlight specific regions
  geom_vline(xintercept = c(-0.6, -0.2, 0.2, 0.6), linetype = "dashed", color = "black", size = 1) # Adjust color and size as needed


# Save the plot
ggsave(filename = paste0(new_dir,trading_type,"simple_",weight_type,"_ttm",as.character(ttm),"_",as.character(cluster),".png"), plot = plt_OA, bg = "transparent", width = 14, height = 7, dpi = 300)

# install.packages("patchwork")
library(patchwork)

# Combine the plots into a 3-by-2 grid
combined_plot <- plt_HV /
  plt_LV /
  plt_OA &
  plot_layout(ncol = 1)

# Save the combined plot
ggsave(filename = paste0(new_dir, trading_type, "_simple_",weight_type,"_combined_ttm", as.character(ttm), ".png"), plot = combined_plot, width = 14, height = 21, dpi = 300)

}
