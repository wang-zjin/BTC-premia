######### simple option with long calls #########
"
function to compute mean retunrs, mean number of traded options, and annualized sharpe ratio
for long option simple
"
long_simple = function(data, steps_ahead) 
{
  data1 = data %>%
    # for each model, compute net gain G_t and cost V_t on each day 
    # on day t, receive $$: we buy option at price BuyPremium_t
    # on day t+h, pay $$: we sell option at price SellPremium_th
    group_by(test_date) %>% 
    summarise(num_options = n(),
              
              G_t = sum(SellPremium_th- BuyPremium_t),
              V_t = sum(BuyPremium_t),
              std_Rt = sqrt(var((SellPremium_th - BuyPremium_t)/(BuyPremium_t))),
              
              # risk-free return, note that on day t, for each value of steps_ahead, RF_rate_for_s_days for each option is exactly the same
              # hence when I group by test_date and model, we have mean(RF_rate_for_s_days) == RF_rate_for_s_days
              RF_t = exp(steps_ahead*mean(IR_t)/365)-1) %>% 
    ungroup() %>% 
    
    # for each model, compute simple return R_t = G_t/V_t for each day
    mutate(R_t = G_t/V_t) %>% 
    mutate(ER_t = R_t - RF_t)  # excess return 
  
  return(list(day_by_day_res = data1 %>% mutate(steps_ahead = steps_ahead))) 
}

"
function to compute mean retunrs, mean number of traded options, and annualized sharpe ratio
for long option simple, by M_group
"
long_simple_Mgroup = function(data, steps_ahead) 
{
  data1 = data %>%
    # for each model, compute net gain G_t and cost V_t on each day 
    # on day t, receive $$: we buy option at price BuyPremium_t
    # on day t+h, pay $$: we sell option at price SellPremium_th
    group_by(test_date) %>% 
    summarise(num_options = n(),
              
              G_t = sum(SellPremium_th - BuyPremium_t),
              V_t = sum(BuyPremium_t),
              std_Rt = sqrt(var((SellPremium_th - BuyPremium_t)/(BuyPremium_t))),
              
              Cluster = Cluster,
              
              # risk-free return, note that on day t, for each value of steps_ahead, RF_rate_for_s_days for each option is exactly the same
              # hence when I group by test_date and model, we have mean(RF_rate_for_s_days) == RF_rate_for_s_days
              RF_t = exp(steps_ahead*mean(IR_t)/365)-1) %>%  
    
    ungroup() %>% 
    
    # for each model, compute simple return R_t = G_t/V_t for each day
    mutate(R_t = G_t/V_t) %>% 
    mutate(ER_t = R_t - RF_t)  # excess return 
  
  return(list(day_by_day_res = data1 %>% mutate(steps_ahead = steps_ahead))) 
}

