########################
"
function to compute mean retunrs, mean number of traded options, and annualized sharpe ratio
for either short calls, short puts or short straddles (short calls and short puts together)
"
short_returns = function(data,steps_ahead) {
  data1 =  data %>% 
    
    # for each model, compute net gain G_t and cost V_t on each day 
    group_by(M_floor) %>% 
    summarise(num_options = n(),
              
              G_t = sum(SellPrice_t - BuyPrice_th), # cash inflow of SellPrice_t on day t, then need to pay BuyPrice_th on day t+h
              V_t = sum(SellPrice_t), # standardize by how much we receive, V_t = sum(SellPrice_t) on day t
              std_Rt = sqrt(var((SellPrice_t - BuyPrice_th)/(SellPrice_t))),
              
              # risk-free return, note that on day t, for each value of steps_ahead, RF_rate_for_s_days for each option is exactly the same
              # hence when I group by test_date and model, we have mean(RF_rate_for_s_days) == RF_rate_for_s_days
              RF_t = exp(steps_ahead*mean(IR_t)/365)-1) %>% 
    ungroup() %>% 
    
    # for each model, compute simple return R_t = G_t/V_t for each day
    mutate(R_t = G_t/V_t) %>% 
    mutate(ER_t = R_t - RF_t)  # excess return 
  
  
  return(list(day_by_day_res = data1 %>% mutate(steps_ahead = steps_ahead))) 
  
}
########################
"
function to compute mean retunrs, mean number of traded options, and annualized sharpe ratio
for either short calls, short puts or short straddles (short calls and short puts together)
by M_group
"
short_returns_Mgroup = function(data,steps_ahead) {
  data1 =  data %>% 
    
    # for each model, compute net gain G_t and cost V_t on each day 
    group_by(test_date) %>% 
    summarise(num_options = n(),
              
              G_t = sum(SellPrice_t - BuyPrice_th), # cash inflow of SellPrice_t on day t, then need to pay BuyPrice_th on day t+h
              V_t = sum(SellPrice_t), # standardize by how much we receive, V_t = sum(SellPrice_t) on day t
              std_Rt = sqrt(var((SellPrice_t - BuyPrice_th)/(SellPrice_t))),
              
              
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

########################
"
function to compute mean retunrs, mean number of traded options, and annualized sharpe ratio
for either long calls, long puts or long straddles (long calls and long puts together)
"
long_returns = function(data,steps_ahead) {
  data1 =  data %>%
    
    # for each model, compute net gain G_t and cost V_t on each day
    group_by(M_floor) %>%
    summarise(num_options = n(),
              
              G_t = sum(-BuyPrice_t + SellPrice_th), # pay investment cost of BuyPrice_t on day t, then sell off the portfolio and receive SellPrice_th on day t+h
              V_t = sum(BuyPrice_t), # standardize by how much we pay, V_t = sum(BuyPrice_t) on day t
              std_Rt = sqrt(var((-BuyPrice_t + SellPrice_th)/(BuyPrice_t))),
              
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
for either long calls, long puts or long straddles (long calls and long puts together)
by M_group
"
long_returns_Mgroup = function(data,steps_ahead) {
  data1 =  data %>%
    
    # for each model, compute net gain G_t and cost V_t on each day
    group_by(test_date) %>%
    summarise(num_options = n(),
              
              G_t = sum(-BuyPrice_t + SellPrice_th), # pay investment cost of BuyPrice_t on day t, then sell off the portfolio and receive SellPrice_th on day t+h
              V_t = sum(BuyPrice_t), # standardize by how much we pay, V_t = sum(BuyPrice_t) on day t
              std_Rt = sqrt(var((-BuyPrice_t + SellPrice_th)/(BuyPrice_t))),
              
              
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



########################
"
function to compute mean retunrs, mean number of traded options, and annualized sharpe ratio
for short straddles (short calls and short puts together), delta-neutralized with stocks
"
short_withStock_returns = function(data,stock_data,steps_ahead) {
  # for a pair of put and call options, to short a delta-neutral straddle portfolio with stocks:
  # supposed the sum of deltas of put and call options is delta_sum
  # if delta_sum > 0 
  # --> on day t, need to offset by buying stocks while selling options (similar to short call delta-hedging)
  # on day t+h, sell the stocks while buying options
  ##
  # if delta_sum < 0 
  # --> on day t, need to offset by a selling stocks while selling options (similar to short put delta-hedging)
  # on day t+h, buy the stocks while buying options
  stock_data1 = stock_data %>% 
    mutate(stock_G_t = ifelse(delta_sum > 0, 
                              abs(delta_sum)*(Spot_close_th - Spot_close_t), # buy on day t and sell on day t+h
                              abs(delta_sum)*(- Spot_close_th + Spot_close_t)), # sell on day t and buy on day t+h
           
           # if delta_sum > 0, we buy stocks hence cost stock_V_t = delta_sum*Spot_close_t > 0,
           # if delta_sum < 0, we buy stocks hence cost stock_V_t = delta_sum*Spot_close_t < 0 (i.e. receive $$)
           stock_V_t = delta_sum*Spot_close_t) %>% 
    
    # for each model, compute net gain G_t and cost V_t from trading stocks on each day 
    group_by(M_floor) %>% 
    summarise(stock_G_t = sum(stock_G_t),
              
              # if stock_V_t < 0, $$ received is more than $$ paid on day t (hence negative cost)
              # if stock_V_t > 0, $$ received is less than $$ paid on day t (hence positive cost)
              stock_V_t = sum(stock_V_t))
  
  
  data1 =  data %>% 
    
    # for each model, compute net gain G_t and cost V_t on each day 
    group_by(M_floor) %>% 
    summarise(num_options = n(),
              
              # cash inflow of SellPrice_t on day t, then need to pay BuyPrice_th on day t+h
              G_t = sum(SellPrice_t - BuyPrice_th), 
              
              # how much we receive, V_t = - sum(SellPrice_t) < 0 is the (negative) cost on day t
              V_t = - sum(SellPrice_t), 
              std_Rt = sqrt(var((SellPrice_t - BuyPrice_th)/(SellPrice_t))),
              
              # risk-free return, note that on day t, for each value of steps_ahead, RF_rate_for_s_days for each option is exactly the same
              # hence when I group by test_date and model, we have mean(RF_rate_for_s_days) == RF_rate_for_s_days
              RF_t = exp(steps_ahead*mean(RF_rate_for_s_days)/365)-1) %>% 
    ungroup() %>% 
    
    # take into account net gain and cost from trading stocks 
    inner_join(stock_data1) %>% 
    mutate(G_t = G_t + stock_G_t,
           
           # V_t = absolute amount of $$ that we either receive (if V_t + stock_V_t < 0) or pay (if V_t + stock_V_t > 0) on day t
           V_t = abs(V_t + stock_V_t)) %>% 
    
    # for each model, compute simple return R_t = G_t/V_t for each day
    mutate(R_t = G_t/V_t) %>% 
    mutate(ER_t = R_t - RF_t)  # excess return 
  
  
  return(list(day_by_day_res = data1 %>% mutate(steps_ahead = steps_ahead))) 
  
}
