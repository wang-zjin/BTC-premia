library(tidyverse)

setwd("~/同步空间/Pricing_Kernel/EPK/delta-neutral strategy/delta-neutral strategy_4_0_0_tau27_byMgroup_untilTTM/")

compute_breakdown = TRUE # whether to breakdown returns and sharpe ratio by (tau,M) values
ttm = 27
all_steps_ahead = ttm

##### #####

# files = tibble(weight = c("EW","QW","VW"))

# for (f in 1:nrow(files)){
  
  if (compute_breakdown) {
    long_straddle_by_M = list(); 
  }
  
# for (s in 1:length(all_steps_ahead)) {
# s = 4
# steps_ahead = all_steps_ahead[s]

long_calls = read_csv(paste0("S02_trading_prepare/BTC_ttm27",
                             "_",as.character(ttm),"ahead_calls.csv")) %>% 
  filter(value_t != 0, Tau_t == ttm) 
# since for long straddles, we buy on day t and sell on day t+h
# we compute the buy price (BuyPrice_t) on day t and sell price (SellPrice_th) on day t+h
# according to the effective spread measure accordingly
long_calls = long_calls %>% 
  mutate(Value_th = ifelse(Spot_th>Strike,Spot_th-Strike-Premium_t,-Premium_t))

long_puts = read_csv(paste0("S02_trading_prepare/BTC_ttm27",
                            "_",as.character(ttm),"ahead_puts.csv")) %>% 
  filter(value_t != 0, Tau_t == ttm) 

# since for long straddles, we buy on day t and sell on day t+h
# we compute the buy price (BuyPrice_t) on day t and sell price (SellPrice_th) on day t+h
# according to the effective spread measure accordingly
long_puts = long_puts %>% 
  mutate(Value_th = ifelse(Spot_th>Strike,-Premium_t,Strike-Spot_th-Premium_t))

####### Overall returns ####### 
long_straddle_dat = bind_rows(long_calls %>% mutate(Option_type = "Call"),
                              long_puts %>% mutate(Option_type = "Put")) %>% 
  # get the actual value of delta of put options (which are < 0) - since in the previous code,
  # I keep the absolute values of deltas of puts
  mutate(Delta_t = ifelse(Option_type == "Put", - Delta_t, Delta_t)) %>%
  # filter and keep options with both call and put
  group_by(test_date,Strike,Tau_t) %>%
  mutate(num_distinct_options = n_distinct(Option_type)) %>%
  ungroup() %>%
  arrange(test_date, Strike, Tau_t, Option_type, Cluster) %>%
  filter(num_distinct_options == 2) 


# Now I want to calculate straddle returns, with different moneyness range.
# A straddle is constructed using a pair of call and put with the same strike at the same date.
# Notice we have many transaction records for the same strike at the same date, so we calculate the average
# to ease construction.
# The weight for call and put is chosen so such weight_call * Delta_call + weight_put * Delta_put = 0
# and weight_call + weight_put = 1
# For every pair, we calculate straddle returns "R_t", such that R_t = weight_call * option_return_call + weight_put * option_return_put.
# In "long_straddle_dat_by_moneyness", I have already calculated option_return of both call and put.
# Now let's calculate "R_t".

EW_straddle_returns <- long_straddle_dat %>%
  group_by(test_date, Strike, Cluster) %>%
  summarise(Moneyness = mean(Moneyness_t),
            Delta_call = mean(Delta_t[Option_type == "Call"]),
            Delta_put = mean(Delta_t[Option_type == "Put"]),
            option_return_call = mean(option_return[Option_type == "Call"]),
            option_return_put = mean(option_return[Option_type == "Put"]),
            value_t = sum(value_t)
  ) %>%
  mutate(weight_call = -Delta_put/(Delta_call-Delta_put),
         weight_put = 1-weight_call,
         R_t = weight_call*option_return_call + weight_put*option_return_put)

VW_straddle_returns <- long_straddle_dat %>%
  group_by(test_date, Strike, Cluster) %>%
  summarise(Moneyness = sum(value_t*Moneyness_t)/sum(value_t),
            Delta_call = sum(value_t[Option_type == "Call"]*Delta_t[Option_type == "Call"])/sum(value_t[Option_type == "Call"]),
            Delta_put = sum(value_t[Option_type == "Put"]*Delta_t[Option_type == "Put"])/sum(value_t[Option_type == "Put"]),
            option_return_call = sum(value_t[Option_type == "Call"]*option_return[Option_type == "Call"])/sum(value_t[Option_type == "Call"]),
            option_return_put = sum(value_t[Option_type == "Put"]*option_return[Option_type == "Put"])/sum(value_t[Option_type == "Put"]),
            value_t = sum(value_t)
  ) %>%
  mutate(weight_call = -Delta_put/(Delta_call-Delta_put),
         weight_put = 1-weight_call,
         R_t = weight_call*option_return_call + weight_put*option_return_put)


write_csv(EW_straddle_returns,paste0("S03_trading_returns/DH_LongStraddle_by_M_EW_ttm",as.character(ttm),".csv"))

write_csv(VW_straddle_returns,paste0("S03_trading_returns/DH_LongStraddle_by_M_VW_ttm",as.character(ttm),".csv"))
