# We use the same segmentation for OA, HV, LV to asign DITM, ITM, ATM, OTM, DOTM
# Instead of return, we use delta to asign these groups

# In this file, we calculate DH strategy ATM straddle returns
# ATM is delta obsolute values in [0.45, 0.55]

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

files = tibble(weight = c("EW","QW","VW"))
trading_type_set = tibble(type = c("Long","Short"))

# for (f in 1:nrow(files)){


####### Long strategies #######
t=1
trading_type = trading_type_set$type[t]

longStraddle_by_m = read_csv(paste0("S03_trading_returns/DH_",trading_type,"Straddle_by_M_",files$weight[1],"_ttm",
                                    as.character(ttm),".csv"))
copy <- longStraddle_by_m %>%
  mutate(Cluster = 3)
longStraddle_by_m <- rbind(longStraddle_by_m, copy) %>%
  mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                          ifelse(Cluster==1,"Cluster1","Overall")))
longStraddle_by_m = longStraddle_by_m %>% 
  mutate(mean_return = R_t*100,
         strategy = paste0(trading_type," Straddle DH")) %>%
  mutate(Moneyness_minus_one = Moneyness - 1)

dat_by_m_EW <- longStraddle_by_m

longStraddle_by_m = read_csv(paste0("S03_trading_returns/DH_",trading_type,"Straddle_by_M_",files$weight[2],"_ttm",
                                    as.character(ttm),".csv"))
copy <- longStraddle_by_m %>%
  mutate(Cluster = 3)
longStraddle_by_m <- rbind(longStraddle_by_m, copy) %>%
  mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                          ifelse(Cluster==1,"Cluster1","Overall")))
longStraddle_by_m = longStraddle_by_m %>% 
  mutate(mean_return = R_t*100,
         strategy = paste0(trading_type," Straddle DH")) %>%
  mutate(Moneyness_minus_one = Moneyness - 1)

dat_by_m_VW <- longStraddle_by_m

partition_points <- list(
  Cluster0 = c(0.2,  0.45, 0.55, 0.8),
  Cluster1 = c(0.2, 0.45, 0.55, 0.8),
  Overall = c(0.2, 0.45, 0.55, 0.8)
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
    mutate(Group = cut(abs(Delta_call), breaks = full_points, labels = labels)) %>%
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
summaries_longStraddle_cluster0_EW <- calculate_summaries(dat_by_m_EW, "Long Straddle DH", "Cluster0", partition_points$Cluster0)
summaries_longStraddle_cluster0_VW <- calculate_summaries(dat_by_m_VW, "Long Straddle DH", "Cluster0", partition_points$Cluster0)
summaries_longStraddle_cluster1_EW <- calculate_summaries(dat_by_m_EW, "Long Straddle DH", "Cluster1", partition_points$Cluster1)
summaries_longStraddle_cluster1_VW <- calculate_summaries(dat_by_m_VW, "Long Straddle DH", "Cluster1", partition_points$Cluster1)
summaries_longStraddle_overall_EW <- calculate_summaries(dat_by_m_EW, "Long Straddle DH", "Overall", partition_points$Overall)
summaries_longStraddle_overall_VW <- calculate_summaries(dat_by_m_VW, "Long Straddle DH", "Overall", partition_points$Overall)

# View or save the summaries
summaries_longStraddle_cluster0_EW
summaries_longStraddle_cluster0_VW
summaries_longStraddle_cluster1_EW
summaries_longStraddle_cluster1_VW
summaries_longStraddle_overall_EW
summaries_longStraddle_overall_VW

write_csv(summaries_longStraddle_cluster0_EW,paste0(new_dir,"longstraddle_cluster0_EW_0d45_0d55.csv"))
write_csv(summaries_longStraddle_cluster0_VW,paste0(new_dir,"longstraddle_cluster0_VW_0d45_0d55.csv"))
write_csv(summaries_longStraddle_cluster1_EW,paste0(new_dir,"longstraddle_cluster1_EW_0d45_0d55.csv"))
write_csv(summaries_longStraddle_cluster1_VW,paste0(new_dir,"longstraddle_cluster1_VW_0d45_0d55.csv"))
write_csv(summaries_longStraddle_overall_EW,paste0(new_dir,"longstraddle_overall_EW_0d45_0d55.csv"))
write_csv(summaries_longStraddle_overall_VW,paste0(new_dir,"longstraddle_overall_VW_0d45_0d55.csv"))

library(knitr)

# Convert summaries to LaTeX and print
print_latex_table <- function(summary_table, title) {
  cat("\\begin{table}[H]\n\\centering\n")
  cat(sprintf("\\caption{%s}\n", title))
  print(kable(summary_table, format = "latex", booktabs = TRUE))
  cat("\\end{table}\n")
}

# ATM option returns, value-weighted (VW)
print(summaries_longStraddle_overall_VW$Weighted_Average[3])
print(summaries_longStraddle_cluster0_VW$Weighted_Average[3])
print(summaries_longStraddle_cluster1_VW$Weighted_Average[3])

# ATM option returns, equally-weighted (EW)
print(summaries_longStraddle_overall_EW$Equally_Average[3])
print(summaries_longStraddle_cluster0_EW$Equally_Average[3])
print(summaries_longStraddle_cluster1_EW$Equally_Average[3])