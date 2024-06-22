# We use the same segmentation for OA, HV, LV to asign DITM, ITM, ATM, OTM, DOTM
# Instead of return, we use delta to asign these groups

# In this file, we report simple strategy and DH strategy at the same table to generate 3 ATM tables

# In each table, we report 6 coloum: simple call, simple put, simple straddlee, DH call, DH put, DH straddle
# and 6 rows: overall returns, overall obs., HV returns, HV obs., LV returns, LV obs.

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

setwd("~/Documents/GitHub/BTC-premia/Project1_draft_version/BTC option returns/")
simple_callput_dir = "simple hold-until-maturity strategy/BTC_option_return_3_0_1_tau27_untilTTM/S0701_ATM_result/"
simple_straddle_dir = "simple hold-until-maturity strategy/BTC_option_return_3_0_1_tau27_untilTTM/S0701_ATM_result/"
DH_callput_dir = "delta-hedge strategy/delta-neutral strategy_4_0_1_tau27/S0701_ATM_result/"
DH_straddle_dir = "delta-hedge strategy/delta-neutral strategy_4_0_1_tau27/S0701_ATM_result/"
new_dir = "simple hold-until-maturity strategy/BTC_option_return_3_0_1_tau27_untilTTM/S0702_ATM_simple_DH_result/"
dir.create(paste0(new_dir), showWarnings = FALSE)

# Convert summaries to LaTeX and print
print_latex_table <- function(summary_table, title) {
  cat(sprintf("\\toprule \\multicolumn{3}{l}{ %s}  \n",  title))
  print(kable(summary_table, format = "latex", booktabs = TRUE))
}

prepare_summary <- function(summary_table) {
  df = as.data.frame(summary_table)
  rownames(df) = c("Overall","Overall Obs.","HV","HV Obs.","LV","LV Obs.")
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
  
  summaries_DH_longcall_overall = read.csv(paste0(DH_callput_dir,"longcall_overall_",ATM_def,".csv"))
  summaries_DH_longcall_cluster0 = read.csv(paste0(DH_callput_dir,"longcall_cluster0_",ATM_def,".csv"))
  summaries_DH_longcall_cluster1 = read.csv(paste0(DH_callput_dir,"longcall_cluster1_",ATM_def,".csv"))
  
  summaries_DH_longput_overall = read.csv(paste0(DH_callput_dir,"longput_overall_",ATM_def,".csv"))
  summaries_DH_longput_cluster0 = read.csv(paste0(DH_callput_dir,"longput_cluster0_",ATM_def,".csv"))
  summaries_DH_longput_cluster1 = read.csv(paste0(DH_callput_dir,"longput_cluster1_",ATM_def,".csv"))
  
  summaries_DH_longStraddle_overall = read.csv(paste0(DH_straddle_dir,"longstraddle_overall_EW_",ATM_def,".csv"))
  summaries_DH_longStraddle_cluster0 = read.csv(paste0(DH_straddle_dir,"longstraddle_cluster0_EW_",ATM_def,".csv"))
  summaries_DH_longStraddle_cluster1 = read.csv(paste0(DH_straddle_dir,"longstraddle_cluster1_EW_",ATM_def,".csv"))
  
  tb_overall <- cbind(rbind(summaries_simple_longcall_overall$Equally_Average[3],summaries_simple_longcall_overall$Num_obs[3]),
                      rbind(summaries_simple_longput_overall$Equally_Average[3],summaries_simple_longput_overall$Num_obs[3]),
                      rbind(summaries_simple_longStraddle_overall$Equally_Average[3],summaries_simple_longStraddle_overall$Num_obs[3]))
  tb_cluster0 <- cbind(rbind(summaries_simple_longcall_cluster0$Equally_Average[3],summaries_simple_longcall_cluster0$Num_obs[3]),
                       rbind(summaries_simple_longput_cluster0$Equally_Average[3],summaries_simple_longput_cluster0$Num_obs[3]),
                       rbind(summaries_simple_longStraddle_cluster0$Equally_Average[3],summaries_simple_longStraddle_cluster0$Num_obs[3]))
  tb_cluster1 <- cbind(rbind(summaries_simple_longcall_cluster1$Equally_Average[3],summaries_simple_longcall_cluster1$Num_obs[3]),
                       rbind(summaries_simple_longput_cluster1$Equally_Average[3],summaries_simple_longput_cluster1$Num_obs[3]),
                       rbind(summaries_simple_longStraddle_cluster1$Equally_Average[3],summaries_simple_longStraddle_cluster1$Num_obs[3]))
  tb_simple <- rbind(tb_overall,tb_cluster0,tb_cluster1)
  
  tb_overall <- cbind(rbind(summaries_DH_longcall_overall$Equally_Average[3],summaries_DH_longcall_overall$Num_obs[3]),
                      rbind(summaries_DH_longput_overall$Equally_Average[3],summaries_DH_longput_overall$Num_obs[3]),
                      rbind(summaries_DH_longStraddle_overall$Equally_Average[3],summaries_DH_longStraddle_overall$Num_obs[3]))
  tb_cluster0 <- cbind(rbind(summaries_DH_longcall_cluster0$Equally_Average[3],summaries_DH_longcall_cluster0$Num_obs[3]),
                       rbind(summaries_DH_longput_cluster0$Equally_Average[3],summaries_DH_longput_cluster0$Num_obs[3]),
                       rbind(summaries_DH_longStraddle_cluster0$Equally_Average[3],summaries_DH_longStraddle_cluster0$Num_obs[3]))
  tb_cluster1 <- cbind(rbind(summaries_DH_longcall_cluster1$Equally_Average[3],summaries_DH_longcall_cluster1$Num_obs[3]),
                       rbind(summaries_DH_longput_cluster1$Equally_Average[3],summaries_DH_longput_cluster1$Num_obs[3]),
                       rbind(summaries_DH_longStraddle_cluster1$Equally_Average[3],summaries_DH_longStraddle_cluster1$Num_obs[3]))
  tb_DH <- rbind(tb_overall,tb_cluster0,tb_cluster1)
  
  prepared_summary_table <- prepare_summary(cbind(tb_simple,tb_DH))
  
  return(prepared_summary_table)
}

ATM_def = c("0d35_0d65","0d4_0d6","0d45_0d55")

table6 = prepare_table6(ATM_def[1])
print_latex_table(table6, "[0.35, 0.65]")

table6 = prepare_table6(ATM_def[2])
print_latex_table(table6, "[0.4, 0.6]")

table6 = prepare_table6(ATM_def[3])
print_latex_table(table6, "[0.45, 0.55]")

