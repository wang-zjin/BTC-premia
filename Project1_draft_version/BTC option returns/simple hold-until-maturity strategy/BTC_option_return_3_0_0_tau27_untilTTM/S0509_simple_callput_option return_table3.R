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

setwd("~/同步空间/Pricing_Kernel/EPK/BTC option return/BTC_option_return_3_0_0_tau27_untilTTM/")
callput_dir = "S050502_ATM_result/"
straddle_dir = "S050701_ATM_result/"
new_dir = "S050502_ATM_result/"
dir.create(paste0(new_dir), showWarnings = FALSE)

summaries_longcall_overall = read.csv(paste0(callput_dir,"longcall_overall_0d2.csv"))
summaries_longcall_cluster0 = read.csv(paste0(callput_dir,"longcall_cluster0_0d2.csv"))
summaries_longcall_cluster1 = read.csv(paste0(callput_dir,"longcall_cluster1_0d2.csv"))

summaries_longput_overall = read.csv(paste0(callput_dir,"longput_overall_0d2.csv"))
summaries_longput_cluster0 = read.csv(paste0(callput_dir,"longput_cluster0_0d2.csv"))
summaries_longput_cluster1 = read.csv(paste0(callput_dir,"longput_cluster1_0d2.csv"))

library(knitr)

# Convert summaries to LaTeX and print
print_latex_table <- function(summary_table, title) {
  cat(sprintf("\\toprule \\multicolumn{3}{l}{ %s}  \n",  title))
  # cat("\\bottomrule & \\multicolumn{5}{c}{Long call} & \\multicolumn{5}{c}{Long put} \n")
  # cat("\\caption{\\footnotesize Simple option return [\\%], the same segmentation for all clusters}")
  # cat("\\cmidrule(r){2-6}\\cmidrule(r){7-11} & DITM & ITM & ATM & OTM & DOTM & DOTM & OTM & ATM & ITM & DITM \n")
  print(kable(summary_table, format = "latex", booktabs = TRUE))
  # cat("\\end{table}\n")
}

prepare_summary <- function(summary_table) {
  selected_columns <- summary_table[, c("Equally_Average", "Weighted_Average", "Num_obs")]
  df = as.data.frame(t(selected_columns))
  rownames(df) = c("EW","VW","Num_obs")
  return(df)
}

prepared_longcall_overall <- prepare_summary(summaries_longcall_overall)
prepared_longput_overall <- prepare_summary(summaries_longput_overall)
combined_table <- cbind(prepared_longcall_overall, prepared_longput_overall)
colnames(combined_table) <- c("DITM_call", "ITM_call", "ATM_call", "OTM_call", "DOTM_call", "DITM_put", "ITM_put", "ATM_put", "OTM_put", "DOTM_put")
print_latex_table(combined_table, "Overall")

prepared_longcall_cluster0 <- prepare_summary(summaries_longcall_cluster0)
prepared_longput_cluster0 <- prepare_summary(summaries_longput_cluster0)
combined_table <- cbind(prepared_longcall_cluster0, prepared_longput_cluster0)
colnames(combined_table) <- c("DITM_call", "ITM_call", "ATM_call", "OTM_call", "DOTM_call", "DITM_put", "ITM_put", "ATM_put", "OTM_put", "DOTM_put")
print_latex_table(combined_table, "Cluster0")

prepared_longcall_cluster1 <- prepare_summary(summaries_longcall_cluster1)
prepared_longput_cluster1 <- prepare_summary(summaries_longput_cluster1)
combined_table <- cbind(prepared_longcall_cluster1, prepared_longput_cluster1)
colnames(combined_table) <- c("DITM_call", "ITM_call", "ATM_call", "OTM_call", "DOTM_call", "DITM_put", "ITM_put", "ATM_put", "OTM_put", "DOTM_put")
print_latex_table(combined_table, "Cluster1")
