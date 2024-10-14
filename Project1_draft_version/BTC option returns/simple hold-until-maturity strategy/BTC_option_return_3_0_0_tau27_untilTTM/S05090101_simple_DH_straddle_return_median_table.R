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

setwd("~/同步空间/Pricing_Kernel/EPK/")
simple_straddle_dir = "BTC option return/BTC_option_return_3_0_0_tau27_untilTTM/S050701_ATM_result/"
DH_straddle_dir = "delta-neutral strategy/delta-neutral strategy_4_0_0_tau27_byMgroup_untilTTM/S050601_ATM_result/"
new_dir = "S050502_ATM_result/"
dir.create(paste0(new_dir), showWarnings = FALSE)

summaries_simple_longStraddle_overall_EW = read.csv(paste0(simple_straddle_dir,"longstraddle_overall_EW_0d2.csv"))
summaries_simple_longStraddle_cluster0_EW = read.csv(paste0(simple_straddle_dir,"longstraddle_cluster0_EW_0d2.csv"))
summaries_simple_longStraddle_cluster1_EW = read.csv(paste0(simple_straddle_dir,"longstraddle_cluster1_EW_0d2.csv"))

summaries_simple_longStraddle_overall_VW = read.csv(paste0(simple_straddle_dir,"longstraddle_overall_VW_0d2.csv"))
summaries_simple_longStraddle_cluster0_VW = read.csv(paste0(simple_straddle_dir,"longstraddle_cluster0_VW_0d2.csv"))
summaries_simple_longStraddle_cluster1_VW = read.csv(paste0(simple_straddle_dir,"longstraddle_cluster1_VW_0d2.csv"))

summaries_DH_longStraddle_overall_EW = read.csv(paste0(DH_straddle_dir,"longstraddle_overall_EW_0d2.csv"))
summaries_DH_longStraddle_cluster0_EW = read.csv(paste0(DH_straddle_dir,"longstraddle_cluster0_EW_0d2.csv"))
summaries_DH_longStraddle_cluster1_EW = read.csv(paste0(DH_straddle_dir,"longstraddle_cluster1_EW_0d2.csv"))

summaries_DH_longStraddle_overall_VW = read.csv(paste0(DH_straddle_dir,"longstraddle_overall_VW_0d2.csv"))
summaries_DH_longStraddle_cluster0_VW = read.csv(paste0(DH_straddle_dir,"longstraddle_cluster0_VW_0d2.csv"))
summaries_DH_longStraddle_cluster1_VW = read.csv(paste0(DH_straddle_dir,"longstraddle_cluster1_VW_0d2.csv"))

library(knitr)

# Convert summaries to LaTeX and print
print_latex_table <- function(summary_table, title) {
  cat(sprintf("\\toprule \\multicolumn{3}{l}{ %s}  \n",  title))
  print(kable(summary_table, format = "latex", booktabs = TRUE))
}

prepare_summary_EW <- function(summary_table) {
  selected_columns <- summary_table[, c("Median_Return_EW")]
  return(as.data.frame(t(selected_columns),row.names = c("Median")))
}
prepare_summary_VW <- function(summary_table) {
  selected_columns <- summary_table[, c("Median_Return_VW", "Num_obs")]
  return(as.data.frame(t(selected_columns),row.names = c("Median", "Num_obs")))
}
prepare_summary <- function(summary_table) {
  selected_columns <- summary_table[, c("Median_Return")]
  return(as.data.frame(t(selected_columns),row.names = c("Median")))
}

prepared_simple_longStraddle_EW_overall <- prepare_summary(summaries_simple_longStraddle_overall_EW)
prepared_simple_longStraddle_VW_overall <- prepare_summary(summaries_simple_longStraddle_overall_VW)
prepared_simple_longStraddle_overall <- rbind(prepared_simple_longStraddle_EW_overall, prepared_simple_longStraddle_VW_overall)
prepared_DH_longStraddle_EW_overall <- prepare_summary(summaries_DH_longStraddle_overall_EW)
prepared_DH_longStraddle_VW_overall <- prepare_summary(summaries_DH_longStraddle_overall_VW)
prepared_DH_longStraddle_overall <- rbind(prepared_DH_longStraddle_EW_overall, prepared_DH_longStraddle_VW_overall)
combined_table <- cbind(prepared_simple_longStraddle_overall, prepared_DH_longStraddle_overall)
colnames(combined_table) <- c("DITM_call", "ITM_call", "ATM_call", "OTM_call", "DOTM_call", "DITM_put", "ITM_put", "ATM_put", "OTM_put", "DOTM_put")
print_latex_table(combined_table, "Overall")

prepared_simple_longStraddle_EW_cluster0 <- prepare_summary(summaries_simple_longStraddle_cluster0_EW)
prepared_simple_longStraddle_VW_cluster0 <- prepare_summary(summaries_simple_longStraddle_cluster0_VW)
prepared_simple_longStraddle_cluster0 <- rbind(prepared_simple_longStraddle_EW_cluster0, prepared_simple_longStraddle_VW_cluster0)
prepared_DH_longStraddle_EW_cluster0 <- prepare_summary(summaries_DH_longStraddle_cluster0_EW)
prepared_DH_longStraddle_VW_cluster0 <- prepare_summary(summaries_DH_longStraddle_cluster0_VW)
prepared_DH_longStraddle_cluster0 <- rbind(prepared_DH_longStraddle_EW_cluster0, prepared_DH_longStraddle_VW_cluster0)
combined_table <- cbind(prepared_simple_longStraddle_cluster0, prepared_DH_longStraddle_cluster0)
colnames(combined_table) <- c("DITM_call", "ITM_call", "ATM_call", "OTM_call", "DOTM_call", "DITM_put", "ITM_put", "ATM_put", "OTM_put", "DOTM_put")
print_latex_table(combined_table, "Cluster0")

prepared_simple_longStraddle_EW_cluster1 <- prepare_summary(summaries_simple_longStraddle_cluster1_EW)
prepared_simple_longStraddle_VW_cluster1 <- prepare_summary(summaries_simple_longStraddle_cluster1_VW)
prepared_simple_longStraddle_cluster1 <- rbind(prepared_simple_longStraddle_EW_cluster1, prepared_simple_longStraddle_VW_cluster1)
prepared_DH_longStraddle_EW_cluster1 <- prepare_summary(summaries_DH_longStraddle_cluster1_EW)
prepared_DH_longStraddle_VW_cluster1 <- prepare_summary(summaries_DH_longStraddle_cluster1_VW)
prepared_DH_longStraddle_cluster1 <- rbind(prepared_DH_longStraddle_EW_cluster1, prepared_DH_longStraddle_VW_cluster1)
combined_table <- cbind(prepared_simple_longStraddle_cluster1, prepared_DH_longStraddle_cluster1)
colnames(combined_table) <- c("DITM_call", "ITM_call", "ATM_call", "OTM_call", "DOTM_call", "DITM_put", "ITM_put", "ATM_put", "OTM_put", "DOTM_put")
print_latex_table(combined_table, "Cluster1")
