library(tidyverse)
library(ggplot2)
library(gridExtra)
theme_set(theme_bw())

setwd("~/同步空间/Pricing_Kernel/EPK/delta-neutral strategy/delta-neutral strategy_4_0_0_tau27_byMgroup_untilTTM/")

compute_breakdown = TRUE # whether to breakdown returns and sharpe ratio by (tau,M) values
ttm = 27
all_steps_ahead = ttm

##### #####

# files = tibble(weight = c("EW","QW","VW"))

# for (f in 1:nrow(files)) {
  
  if (compute_breakdown) {
    long_put_DH_by_M = list(); 
  }
  
  for (i in 1:length(all_steps_ahead)) {
    # i = 1
    steps_ahead = all_steps_ahead[i]
    
    dat = read_csv(paste0("S02_trading_prepare/BTC_ttm27","_",as.character(ttm),"ahead_puts.csv")) 
    
    dat = dat %>% 
      filter(value_t != 0, Tau_t == ttm) 
    # since for long put DH, we buy options on day t and sell options on day t+h
    # we compute the buy price (BuyPremium_t) on day t and sell price (SellPremium_th) on day t+h
    # according to the effective spread measure accordingly
    dat = dat %>% 
      mutate(BuyPremium_t = Premium_t,
             SellPremium_th = option_value,
             BuySpot_t = Spot_t,
             SellSpot_th = Spot_th 
      )
    
    ########## DH returns overall ########## 
    # out = long_DH(data = dat, 
    #                   steps_ahead = steps_ahead)
    # 
    # overall_day_by_day_res = list();
    # overall_day_by_day_res[[paste0("h = ",steps_ahead)]] = out$day_by_day_res
    
    
    ########## DH returns by (tau,M) categories ########## 
    if (compute_breakdown) {
      dat = dat %>% 
        mutate(M_group = ifelse(Return_t <= -0.5, "(-1,-0.5]",
                                ifelse(Return_t <= -0.1, "(-0.5,-0.1]",
                                       ifelse(Return_t<=0.15,"(-0.1,0.15]",
                                              ifelse(Return_t<=0.6,"(0.15,0.6]","(0.6,1]")))))
      
      M_groups = unique(dat$M_group)
      
      
      for (i in 1:length(M_groups)) {
        # i = 1
        
        long_put_DH_out = list(day_by_day_res = dat %>%
                                 mutate(steps_ahead = steps_ahead) %>%
                                 filter(M_group == M_groups[i]) %>%
                                 mutate(R_t = (SellSpot_th*Delta_t + SellPremium_th - BuyPremium_t - BuySpot_t*Delta_t)/(BuySpot_t*Delta_t+BuyPremium_t),
                                        RF_t = exp(steps_ahead*mean(IR_t)/365)-1,
                                        ER_t = R_t - RF_t) 
        )
        long_put_DH_by_M[[paste0(M_groups[i],"_steps",steps_ahead,"ahead")]] = long_put_DH_out$day_by_day_res %>% 
          mutate(M_group = M_groups[i])
      }
      
      
    }
    
    
  }
  
  # overall_day_by_day_res = Reduce(x = overall_day_by_day_res,f = bind_rows)
  # write_csv(overall_day_by_day_res,paste0("S03_trading_returns/LongPutDH_overall_",
  #                                         files$weight[f],".csv"))
  
  
  
  if (compute_breakdown) {
    long_put_DH_by_M = Reduce(x = long_put_DH_by_M,f = bind_rows)
    write_csv(long_put_DH_by_M,paste0("S03_trading_returns/LongPutDH_by_M_ttm",as.character(ttm),".csv"))
    
  }
  
# }

