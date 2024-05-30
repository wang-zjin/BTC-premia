library(tidyverse)
library(ggplot2)

setwd("~/同步空间/Pricing_Kernel/EPK/delta-neutral strategy/delta-neutral strategy_0_0_2_tau5/")

dir.create(paste0("S04_summary/"), showWarnings = FALSE)

##### original option data #####

files = tibble(weight = c("EW","QW","VW"))

for (f in 1:nrow(files)){
  
  # Use this to get total available number of option pairs
  options = read_csv(paste0("data/BTC_",files$weight[f],".csv"))
  options = options %>%
    filter(abs(moneyness) <= 2) %>% 
    filter(volume > 0)
  
  options1 = options %>%
    # filter and keep options with both call and put
    group_by(Date,Strike,tau) %>%
    mutate(num_ops = n()) %>%
    ungroup() %>%
    filter(num_ops == 2)  
  options1 = options1 %>% 
    arrange(Date,tau,Strike,PC_type)
  
  
  ###### Overall summary ######
  # count number of options with maturity of at least steps_ahead (only those options will be available for trading
  # in steps_ahead forecasting)
  overall_num_avai_ops = list()
  # for (s in c(1,5,10,15,20)) {
  for (s in c(5)) {  
    overall_num_avai_ops[[paste0("total_num_ops_for",as.character(s),"steps_ahead")]] = options1 %>% 
      filter(tau >= s) %>% 
      group_by(Date) %>% 
      summarise(total_num_ops = n()) %>% # number of puts and calls (that come in pairs) available for stradlles
      ungroup() %>% 
      mutate(Date = as.Date(as.character(Date),format = "%Y-%m-%d"),
             steps_ahead = s) %>%
      rename(test_date = Date)
  }
  overall_num_avai_ops = Reduce(x = overall_num_avai_ops,f = bind_rows)
  
  
  
  ######### Long Straddle #########
  long_straddle = read_csv(paste0("S03_trading_returns/DN_LongStraddle_overall_",
                                  files$weight[f],".csv"))
  long_straddle = long_straddle %>% 
    inner_join(overall_num_avai_ops) %>% 
    mutate(perc_traded_ops = num_options/total_num_ops*100)
  
  long_straddle_overall = long_straddle %>% 
    # mean of simple return (R_t) and Sharpe ratio SR_t
    group_by(steps_ahead) %>% 
    summarise(mean_perc_traded_ops = mean(perc_traded_ops),
              mean_return = mean(R_t)*100,
              std_return = sqrt(var(ER_t)),
              sharpe_ratio = mean(ER_t)/sqrt(var(ER_t)),
              mean_net_gain = mean(G_t)) %>% 
    ungroup() %>% 
    mutate(sharpe_ratio = sharpe_ratio*sqrt(365/steps_ahead)) %>%  # annualized Sharpe ratio
    gather(key = "Type",value = "Value",-steps_ahead) %>% 
    mutate(steps_ahead = paste0("$h = ",as.character(steps_ahead),"$"),
           Type = factor(Type,levels = c("mean_perc_traded_ops","mean_net_gain","mean_return","std_return","sharpe_ratio"))) %>% 
    spread(key = "steps_ahead",value = "Value") %>% 
    arrange(Type) %>% 
    select(Type,`$h = 5$`) %>% 
    mutate(across(where(is.numeric), round, 2))
  
  
  ######### Short #########
  short_straddle = read_csv(paste0("S03_trading_returns/DN_ShortStraddle_overall_",
                                   files$weight[f],".csv"))
  short_straddle = short_straddle %>% 
    inner_join(overall_num_avai_ops) %>% 
    mutate(perc_traded_ops = num_options/total_num_ops*100)
  
  short_straddle_overall = short_straddle %>% 
    # mean of simple return (R_t) and Sharpe ratio SR_t
    group_by(steps_ahead) %>% 
    summarise(mean_perc_traded_ops = mean(perc_traded_ops),
              mean_return = mean(R_t)*100,
              std_return = sqrt(var(ER_t)),
              sharpe_ratio = mean(ER_t)/sqrt(var(ER_t)),
              mean_net_gain = mean(G_t)) %>% 
    ungroup() %>% 
    mutate(sharpe_ratio = sharpe_ratio*sqrt(365/steps_ahead)) %>%  # annualized Sharpe ratio
    gather(key = "Type",value = "Value",-steps_ahead) %>% 
    mutate(steps_ahead = paste0("$h = ",as.character(steps_ahead),"$"),
           Type = factor(Type,levels = c("mean_perc_traded_ops","mean_net_gain","mean_return","std_return","sharpe_ratio"))) %>% 
    spread(key = "steps_ahead",value = "Value") %>% 
    arrange(Type) %>% 
    select(Type,`$h = 5$`) %>% 
    mutate(across(where(is.numeric), round, 2)) 
  
    write.table(long_straddle_overall, file = paste0("S04_summary/LongStraddle_overall_",files$weight[f],".txt"), sep = ",", row.names = FALSE, col.names = TRUE)
    write.table(short_straddle_overall, file = paste0("S04_summary/ShortStraddle_overall_",files$weight[f],".txt"), sep = ",", row.names = FALSE, col.names = TRUE)
  
}

