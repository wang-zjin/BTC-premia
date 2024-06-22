# We use the same segmentation for OA, HV, LV to asign DITM, ITM, ATM, OTM, DOTM
# Instead of return, we use delta to asign these groups

rm(list=ls())
library(tidyverse)
library(ggplot2)
library(ggpubr)
library(dplyr)
library(tidyr)
library(tibble)

theme_set(theme_bw() +
            theme(text = element_text(size=15),
                  axis.line = element_line(colour = "black"),
                  # panel.border = element_blank(),
                  aspect.ratio = 1,
                  legend.title=element_blank()
            )
)

ttm = 27
all_steps_ahead = ttm

#### Basic  ######

setwd("~/同步空间/Pricing_Kernel/EPK/BTC option return/BTC_option_return_3_0_1_tau27_untilTTM/")
new_dir = "S0700_trading_result_by_m/"
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

dat_by_m <- bind_rows(longCall_by_m,longPut_by_m) %>%
  mutate(Delta_t = ifelse(PC_type == -1, - Delta_t, Delta_t)) 

# Display summary statistics for the variable "Delta_t"
summary(dat_by_m$Delta_t)
summary(dat_by_m[dat_by_m$PC_type==1,]$Delta_t)
summary(dat_by_m[dat_by_m$PC_type==-1,]$Delta_t)
# Display histogram of the variable "Delta_t"
plt_hist <- ggplot(dat_by_m, aes(x = Delta_t)) +
  geom_histogram(fill = "blue", color = "black", bins = 30) +
  labs(title = "Histogram of Delta", x = "Delta", y = "Count") +
  theme_minimal()+
  theme(plot.title = element_text(hjust = 0.5, size = 20),
        axis.title.x = element_text(size = 15),  # X axis title size
        axis.title.y = element_text(size = 15),  # Y axis title size
        axis.text.x = element_text(size = 12),   # X axis text size
        axis.text.y = element_text(size = 12)    # Y axis text size
        )
ggsave(filename = paste0(new_dir,"/histogram_Delta",".png"), plot = plt_hist, bg = "transparent", width = 14, height = 7, dpi = 300)

# Display histogram of the variable "Return_t"
plt_hist <- ggplot(dat_by_m, aes(x = Return_t)) +
  geom_histogram(fill = "blue", color = "black", bins = 30) +
  labs(title = "Histogram of Return", x = "Return", y = "Count") +
  theme_minimal()+
  theme(plot.title = element_text(hjust = 0.5, size = 20),
        axis.title.x = element_text(size = 15),  # X axis title size
        axis.title.y = element_text(size = 15),  # Y axis title size
        axis.text.x = element_text(size = 12),   # X axis text size
        axis.text.y = element_text(size = 12)    # Y axis text size
  )
ggsave(filename = paste0(new_dir,"/histogram_Return",".png"), plot = plt_hist, bg = "transparent", width = 14, height = 7, dpi = 300)



partition_points <- list(
  Cluster0 = c(0.2,  0.4, 0.6, 0.8),
  Cluster1 = c(0.2, 0.4, 0.6, 0.8),
  Overall = c(0.2, 0.4, 0.6, 0.8)
)

calculate_summaries <- function(data, strategy_type, cluster_name, points) {
  # Extend points to cover the full range of Return_t
  full_points <- c(-Inf, points, Inf)
  
  # Create interval labels based on points
  
  labels <- c(paste("(-Inf,", points[1], "]", sep=""),
              paste("(", head(points, -1), ",", tail(points, -1), "]", sep=""),
              paste("(", points[length(points)], ", Inf)", sep=""))
  
  # Generate a tibble with all possible groups to ensure completeness
  all_groups <- tibble(Group = factor(labels, levels = labels))
  
  summary_data <- data %>%
    filter(Cluster == cluster_name, strategy == strategy_type) %>%
    mutate(Group = cut(abs(Delta_t), breaks = full_points, labels = labels)) %>%
    group_by(Group) %>%
    summarise(
      Equally_Average = round(mean(mean_return, na.rm = TRUE), 2),
      Weighted_Average = round(weighted.mean(mean_return, value_t, na.rm = TRUE), 2),
      # Std_Dev = round(sd(mean_return, na.rm = TRUE), 2),
      # Max = round(max(mean_return, na.rm = TRUE), 2),
      # Min = round(min(mean_return, na.rm = TRUE), 2),
      Num_obs = n(),
      .groups = 'drop'  # Drop grouping structure after summarising
    )
  
  # Ensure all groups are represented, filling missing ones with NA
  complete_summary <- left_join(all_groups, summary_data, by = "Group") %>%
    mutate(Cluster = paste(strategy_type, cluster_name, sep = " "), .before = 1)  # Add cluster column
  
  return(complete_summary)
}


# Generate summaries for each cluster
summaries_longcall_overall <- calculate_summaries(dat_by_m, "Long Call simple", "Overall", partition_points$Overall)
summaries_longput_overall <- calculate_summaries(dat_by_m, "Long Put simple", "Overall", partition_points$Overall)
summaries_longcall_cluster0 <- calculate_summaries(dat_by_m, "Long Call simple", "Cluster0", partition_points$Cluster0)
summaries_longput_cluster0 <- calculate_summaries(dat_by_m, "Long Put simple", "Cluster0", partition_points$Cluster0)
summaries_longcall_cluster1 <- calculate_summaries(dat_by_m, "Long Call simple", "Cluster1", partition_points$Cluster1)
summaries_longput_cluster1 <- calculate_summaries(dat_by_m, "Long Put simple", "Cluster1", partition_points$Cluster1)

# View or save the summaries
# In the report table, we want to view call option from DITM to DOTM, so reverse the sort 
summaries_longcall_overall[dim(summaries_longcall_overall)[1]:-1:1,]
summaries_longput_overall
summaries_longcall_cluster0[dim(summaries_longcall_cluster0)[1]:-1:1,]
summaries_longput_cluster0
summaries_longcall_cluster1[dim(summaries_longcall_cluster1)[1]:-1:1,]
summaries_longput_cluster1

library(knitr)

# Convert summaries to LaTeX and print
print_latex_table <- function(summary_table, title) {
  cat("\\begin{table}[H]\n\\centering\n")
  cat(sprintf("\\caption{%s}\n", title))
  print(kable(summary_table, format = "latex", booktabs = TRUE))
  cat("\\end{table}\n")
}

# Apply the function to your summary tables
print_latex_table(t(summaries_longcall_overall[dim(summaries_longcall_overall)[1]:-1:1,]), "Long Call Strategy Summary for Overall")
print_latex_table(t(summaries_longput_overall), "Long Put Strategy Summary for Overall")
print_latex_table(t(summaries_longcall_cluster0[dim(summaries_longcall_cluster0)[1]:-1:1,]), "Long Call Strategy Summary for Cluster 0")
print_latex_table(t(summaries_longput_cluster0), "Long Put Strategy Summary for Cluster 0")
print_latex_table(t(summaries_longcall_cluster1[dim(summaries_longcall_cluster1)[1]:-1:1,]), "Long Call Strategy Summary for Cluster 1")
print_latex_table(t(summaries_longput_cluster1), "Long Put Strategy Summary for Cluster 1")

