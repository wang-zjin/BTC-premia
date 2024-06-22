# We use the same segmentation for OA, HV, LV to asign DITM, ITM, ATM, OTM, DOTM
# Instead of return, we use delta to asign these groups

# In this file, we calculate DH strategy ATM call and put returns
# ATM is delta obsolute values in [0.4, 0.6]

rm(list = ls())
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
            ))

ttm = 27
all_steps_ahead = ttm

#### Basic  ######

setwd("~/Documents/GitHub/BTC-premia/Project1_draft_version/BTC option returns/delta-hedge strategy/delta-neutral strategy_4_0_1_tau27/")
new_dir = "S0701_ATM_result/"
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

dat_by_m <- bind_rows(longCall_by_m,longPut_by_m)

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
      Median_Return = round(median(mean_return, na.rm = TRUE), 2),
      Std_Dev = round(sd(mean_return, na.rm = TRUE), 2),
      Max = round(max(mean_return, na.rm = TRUE), 2),
      Min = round(min(mean_return, na.rm = TRUE), 2),
      Num_obs = n(),
      .groups = 'drop'  # Drop grouping structure after summarising
    )
  
  # Ensure all groups are represented, filling missing ones with NA
  complete_summary <- left_join(all_groups, summary_data, by = "Group") %>%
    mutate(Cluster = paste(strategy_type, cluster_name, sep = " "), .before = 1)  # Add cluster column
  
  return(complete_summary)
}



# Generate summaries for each cluster
summaries_longcall_cluster0 <- calculate_summaries(dat_by_m, "Long Call DH", "Cluster0", partition_points$Cluster0)
summaries_longput_cluster0 <- calculate_summaries(dat_by_m, "Long Put DH", "Cluster0", partition_points$Cluster0)
summaries_longcall_cluster1 <- calculate_summaries(dat_by_m, "Long Call DH", "Cluster1", partition_points$Cluster1)
summaries_longput_cluster1 <- calculate_summaries(dat_by_m, "Long Put DH", "Cluster1", partition_points$Cluster1)
summaries_longcall_overall <- calculate_summaries(dat_by_m, "Long Call DH", "Overall", partition_points$Overall)
summaries_longput_overall <- calculate_summaries(dat_by_m, "Long Put DH", "Overall", partition_points$Overall)

# View or save the summaries
# In the report table, we want to view call option from DITM to DOTM, so reverse the sort
summaries_longcall_overall[dim(summaries_longcall_overall)[1]:-1:1,]
summaries_longput_overall
summaries_longcall_cluster0[dim(summaries_longcall_cluster0)[1]:-1:1,]
summaries_longput_cluster0
summaries_longcall_cluster1[dim(summaries_longcall_cluster1)[1]:-1:1,]
summaries_longput_cluster1

write_csv(summaries_longcall_cluster0[dim(summaries_longcall_overall)[1]:-1:1,],paste0(new_dir,"longcall_cluster0_0d4_0d6.csv"))
write_csv(summaries_longput_cluster0,paste0(new_dir,"longput_cluster0_0d4_0d6.csv"))
write_csv(summaries_longcall_cluster1[dim(summaries_longcall_overall)[1]:-1:1,],paste0(new_dir,"longcall_cluster1_0d4_0d6.csv"))
write_csv(summaries_longput_cluster1,paste0(new_dir,"longput_cluster1_0d4_0d6.csv"))
write_csv(summaries_longcall_overall[dim(summaries_longcall_overall)[1]:-1:1,],paste0(new_dir,"longcall_overall_0d4_0d6.csv"))
write_csv(summaries_longput_overall,paste0(new_dir,"longput_overall_0d4_0d6.csv"))

library(knitr)

# Convert summaries to LaTeX and print
print_latex_table <- function(summary_table, title) {
  cat("\\begin{table}[H]\n\\centering\n")
  cat(sprintf("\\caption{%s}\n", title))
  print(kable(summary_table, format = "latex", booktabs = TRUE))
  cat("\\end{table}\n")
}

# ATM option returns, value-weighted (VW)
print(paste(summaries_longcall_overall$Weighted_Average[3],summaries_longput_overall$Weighted_Average[3]))
print(paste(summaries_longcall_cluster0$Weighted_Average[3],summaries_longput_cluster0$Weighted_Average[3]))
print(paste(summaries_longcall_cluster1$Weighted_Average[3],summaries_longput_cluster1$Weighted_Average[3]))

# ATM option returns, equally-weighted (EW)
print(paste(summaries_longcall_overall$Equally_Average[3],summaries_longput_overall$Equally_Average[3]))
print(paste(summaries_longcall_cluster0$Equally_Average[3],summaries_longput_cluster0$Equally_Average[3]))
print(paste(summaries_longcall_cluster1$Equally_Average[3],summaries_longput_cluster1$Equally_Average[3]))