
######### simple with short options  #########
"
function to compute mean retunrs, mean number of traded options, and annualized sharpe ratio
for short option simple
"
short_simple = function(data, steps_ahead) 
{
  data1 = data %>%
    # for each model, compute net gain G_t and cost V_t on each day 
    # on day t, need to pay money: we sell option at price SellPremium_t 
    # on day t+h, receive money: we buy option at price BuyPremium_th 
    group_by(M_floor) %>% 
    summarise(num_options = n(),
              
              G_t = sum(SellPremium_t- BuyPremium_th),
              V_t = sum(SellPremium_t),
              std_Rt = sqrt(var((SellPremium_t- BuyPremium_th)/(SellPremium_t))),
              
              # risk-free return, note that on day t, for each value of steps_ahead, RF_rate_for_s_days for each option is exactly the same
              # hence when I group by test_date and model, we have mean(RF_rate_for_s_days) == RF_rate_for_s_days
              RF_t = exp(steps_ahead*mean(IR_t)/365)-1) %>% 
    ungroup() %>% 
    
    # for each model, compute simple return R_t = G_t/V_t for each day
    mutate(R_t = G_t/V_t) %>% 
    mutate(ER_t = R_t - RF_t) # excess return 
  
  return(list(day_by_day_res = data1 %>% mutate(steps_ahead = steps_ahead))) 
}

"
function to compute mean retunrs, mean number of traded options, and annualized sharpe ratio
for short option simple, by M_group
"
short_simple_Mgroup = function(data, steps_ahead) 
{
  data1 = data %>%
    # for each model, compute net gain G_t and cost V_t on each day 
    # on day t, need to pay money: we sell option at price SellPremium_t
    # on day t+h, receive money: we buy option at price BuyPremium_th
    group_by(test_date) %>% 
    summarise(num_options = n(),
              
              G_t = sum(SellPremium_t - BuyPremium_th),
              V_t = sum(SellPremium_t),
              std_Rt = sqrt(var((SellPremium_t - BuyPremium_th)/(SellPremium_t))),
              
              Cluster = Cluster,
              
              # risk-free return, note that on day t, for each value of steps_ahead, RF_rate_for_s_days for each option is exactly the same
              # hence when I group by test_date and model, we have mean(RF_rate_for_s_days) == RF_rate_for_s_days
              RF_t = exp(steps_ahead*mean(IR_t)/365)-1) %>%  
    
    ungroup() %>% 
    
    # for each model, compute simple return R_t = G_t/V_t for each day
    mutate(R_t = G_t/V_t) %>% 
    mutate(ER_t = R_t - RF_t) # excess return 
  
  return(list(day_by_day_res = data1 %>% mutate(steps_ahead = steps_ahead))) 
}


