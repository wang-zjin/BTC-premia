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

# for (f in 1:nrow(files)){

trading_type = trading_type_set$type[1]
####### Long strategies #######
# Read and Process Data
longStraddle_by_m = read_csv(paste0("S03_trading_returns/simple_",trading_type,"Straddle_by_M_",files$weight[1],"_ttm",
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

dat_by_m_EW <- longStraddle_by_m

longStraddle_by_m = read_csv(paste0("S03_trading_returns/simple_",trading_type,"Straddle_by_M_",files$weight[2],"_ttm",
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

dat_by_m_VW <- longStraddle_by_m

partition_points <- list(
  Cluster0 = c(-0.7, -0.15, 0.15, 0.7),
  Cluster1 = c(-0.5, -0.15, 0.05, 0.45),
  Overall = c(-0.6, -0.2, 0.2, 0.6)
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
    mutate(Group = cut(Moneyness_minus_one, breaks = full_points, labels = labels)) %>%
    group_by(Group) %>%
    summarise(
      Equally_Average = round(mean(mean_return, na.rm = TRUE), 2),
      Weighted_Average = round(weighted.mean(mean_return, value_t, na.rm = TRUE), 2),
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
summaries_longStraddle_cluster0_EW <- calculate_summaries(dat_by_m_EW, "Long Straddle simple", "Cluster0", partition_points$Cluster0)
summaries_longStraddle_cluster0_VW <- calculate_summaries(dat_by_m_VW, "Long Straddle simple", "Cluster0", partition_points$Cluster0)
summaries_longStraddle_cluster1_EW <- calculate_summaries(dat_by_m_EW, "Long Straddle simple", "Cluster1", partition_points$Cluster1)
summaries_longStraddle_cluster1_VW <- calculate_summaries(dat_by_m_VW, "Long Straddle simple", "Cluster1", partition_points$Cluster1)
summaries_longStraddle_overall_EW <- calculate_summaries(dat_by_m_EW, "Long Straddle simple", "Overall", partition_points$Overall)
summaries_longStraddle_overall_VW <- calculate_summaries(dat_by_m_VW, "Long Straddle simple", "Overall", partition_points$Overall)

# View or save the summaries
summaries_longStraddle_cluster0_EW
summaries_longStraddle_cluster0_VW
summaries_longStraddle_cluster1_EW
summaries_longStraddle_cluster1_VW
summaries_longStraddle_overall_EW
summaries_longStraddle_overall_VW

library(knitr)

# Convert summaries to LaTeX and print
print_latex_table <- function(summary_table, title) {
  cat("\\begin{table}[H]\n\\centering\n")
  cat(sprintf("\\caption{%s}\n", title))
  print(kable(summary_table, format = "latex", booktabs = TRUE))
  cat("\\end{table}\n")
}

# Apply the function to your summary tables
print_latex_table(t(summaries_longStraddle_cluster0_EW), "Long Straddle Strategy Summary for EW Cluster 0")
print_latex_table(t(summaries_longStraddle_cluster0_VW), "Long Straddle Strategy Summary for VW Cluster 1")
print_latex_table(t(summaries_longStraddle_cluster1_EW), "Long Straddle Strategy Summary for EW Cluster 0")
print_latex_table(t(summaries_longStraddle_cluster1_VW), "Long Straddle Strategy Summary for VW Cluster 1")
print_latex_table(t(summaries_longStraddle_overall_EW), "Long Straddle Strategy Summary for EW Overall")
print_latex_table(t(summaries_longStraddle_overall_VW), "Long Straddle Strategy Summary for VW Overall")
