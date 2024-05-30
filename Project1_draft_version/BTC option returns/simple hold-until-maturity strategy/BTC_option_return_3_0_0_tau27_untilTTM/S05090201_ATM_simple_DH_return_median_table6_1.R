rm(list = ls())
library(tidyverse)
library(ggplot2)
library(ggpubr)
library(dplyr)
library(tidyr)
library(tibble)
library(knitr)



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
simple_callput_dir = "BTC option return/BTC_option_return_4_0_0_tau27_untilTTM/S050502_ATM_result/"
simple_straddle_dir = "BTC option return/BTC_option_return_4_0_0_tau27_untilTTM/S050701_ATM_result/"
DH_callput_dir = "delta-neutral strategy/delta-neutral strategy_5_0_0_tau27_byMgroup_untilTTM/S050501_ATM_result/"
DH_straddle_dir = "delta-neutral strategy/delta-neutral strategy_5_0_0_tau27_byMgroup_untilTTM/S050601_ATM_result/"
new_dir = "BTC option return/BTC_option_return_4_0_0_tau27_untilTTM/S050502_ATM_result/"
dir.create(paste0(new_dir), showWarnings = FALSE)

# Convert summaries to LaTeX and print
print_latex_table <- function(summary_table, title) {
  cat(sprintf("\\toprule \\multicolumn{3}{l}{ %s}  \n",  title))
  print(kable(summary_table, format = "latex", booktabs = TRUE))
}

prepare_summary <- function(summary_table) {
  df = as.data.frame(summary_table)
  rownames(df) = c("Overall","HV","LV")
  colnames(df) = c("Call_simple","Put_simple","Straddle_simple","Call_DH","Put_DH","Straddle_DH")
  return(df)
}

prepare_table6 = function(ATM_def){
  summaries_simple_longcall_overall = read.csv(paste0(simple_callput_dir,"longcall_overall_",ATM_def,".csv"))
  summaries_simple_longcall_cluster0 = read.csv(paste0(simple_callput_dir,"longcall_cluster0_",ATM_def,".csv"))
  summaries_simple_longcall_cluster1 = read.csv(paste0(simple_callput_dir,"longcall_cluster1_",ATM_def,".csv"))
  
  summaries_simple_longput_overall = read.csv(paste0(simple_callput_dir,"longput_overall_",ATM_def,".csv"))
  summaries_simple_longput_cluster0 = read.csv(paste0(simple_callput_dir,"longput_cluster0_",ATM_def,".csv"))
  summaries_simple_longput_cluster1 = read.csv(paste0(simple_callput_dir,"longput_cluster1_",ATM_def,".csv"))
  
  summaries_simple_longStraddle_overall = read.csv(paste0(simple_straddle_dir,"longstraddle_overall_EW_",ATM_def,".csv"))
  summaries_simple_longStraddle_cluster0 = read.csv(paste0(simple_straddle_dir,"longstraddle_cluster0_EW_",ATM_def,".csv"))
  summaries_simple_longStraddle_cluster1 = read.csv(paste0(simple_straddle_dir,"longstraddle_cluster1_EW_",ATM_def,".csv"))
  print(1)
  summaries_DH_longcall_overall = read.csv(paste0(DH_callput_dir,"longcall_overall_",ATM_def,".csv"))
  summaries_DH_longcall_cluster0 = read.csv(paste0(DH_callput_dir,"longcall_cluster0_",ATM_def,".csv"))
  summaries_DH_longcall_cluster1 = read.csv(paste0(DH_callput_dir,"longcall_cluster1_",ATM_def,".csv"))
  
  summaries_DH_longput_overall = read.csv(paste0(DH_callput_dir,"longput_overall_",ATM_def,".csv"))
  summaries_DH_longput_cluster0 = read.csv(paste0(DH_callput_dir,"longput_cluster0_",ATM_def,".csv"))
  summaries_DH_longput_cluster1 = read.csv(paste0(DH_callput_dir,"longput_cluster1_",ATM_def,".csv"))
  
  summaries_DH_longStraddle_overall = read.csv(paste0(DH_straddle_dir,"longstraddle_overall_EW_",ATM_def,".csv"))
  summaries_DH_longStraddle_cluster0 = read.csv(paste0(DH_straddle_dir,"longstraddle_cluster0_EW_",ATM_def,".csv"))
  summaries_DH_longStraddle_cluster1 = read.csv(paste0(DH_straddle_dir,"longstraddle_cluster1_EW_",ATM_def,".csv"))
  
  tb_overall <- c(summaries_simple_longcall_overall$Median_Return[3],summaries_simple_longput_overall$Median_Return[3],summaries_simple_longStraddle_overall$Median_Return[3])
  tb_cluster0 <- c(summaries_simple_longcall_cluster0$Median_Return[3],summaries_simple_longput_cluster0$Median_Return[3],summaries_simple_longStraddle_cluster0$Median_Return[3])
  tb_cluster1 <- c(summaries_simple_longcall_cluster1$Median_Return[3],summaries_simple_longput_cluster1$Median_Return[3],summaries_simple_longStraddle_cluster1$Median_Return[3])
  tb_simple <- rbind(tb_overall,tb_cluster0,tb_cluster1)
  
  tb_overall <- c(summaries_DH_longcall_overall$Median_Return[3],summaries_DH_longput_overall$Median_Return[3],summaries_DH_longStraddle_overall$Median_Return[3])
  tb_cluster0 <- c(summaries_DH_longcall_cluster0$Median_Return[3],summaries_DH_longput_cluster0$Median_Return[3],summaries_DH_longStraddle_cluster0$Median_Return[3])
  tb_cluster1 <- c(summaries_DH_longcall_cluster1$Median_Return[3],summaries_DH_longput_cluster1$Median_Return[3],summaries_DH_longStraddle_cluster1$Median_Return[3])
  tb_DH <- rbind(tb_overall,tb_cluster0,tb_cluster1)
  
  prepared_summary_table <- prepare_summary(cbind(tb_simple,tb_DH))
  
  return(prepared_summary_table)
}

ATM_def = c("0d2","0d1","0d05")

table6 = prepare_table6(ATM_def[1])
print_latex_table(table6, "[-0.2, 0.2]")

table6 = prepare_table6(ATM_def[2])
print_latex_table(table6, "[-0.1, 0.1]")

table6 = prepare_table6(ATM_def[3])
print_latex_table(table6, "[-0.05, 0.05]")

