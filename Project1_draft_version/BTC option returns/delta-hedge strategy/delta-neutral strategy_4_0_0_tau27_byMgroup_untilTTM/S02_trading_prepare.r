library(tidyverse)
library(ggplot2)
library(lubridate)
theme_set(theme_bw())

# args = commandArgs(trailingOnly = TRUE) 
# print(args)
# 
# steps_ahead = args[1]
steps_ahead = 1
ttm = 27

setwd("~/同步空间/Pricing_Kernel/EPK/delta-neutral strategy/delta-neutral strategy_4_0_0_tau27_byMgroup_untilTTM/")

##### BTC prices ##### 
spots = read_csv("data/BTC_USD_Quandl_2015_2022.csv")
spots = spots %>% 
  mutate(Date = as.Date(as.character(Date),format = "%Y-%m-%d")) %>% 
  rename(test_date = Date, BTC_price = Adj.Close)



##### interest rate data ##### 
IR = read_csv("data/IR_daily.csv")
IR = IR %>% 
  mutate(index = as.Date(as.character(index),format = "%Y-%m-%d"),
         DTB3 = DTB3/100) %>% 
  rename(test_date = index, IR = DTB3)

# interest rate for steps_ahead day maturity
IR_for_s_days = IR %>% 
  group_by(test_date)

##### option data #####
data_dir = "data/"
output_dir = "S02_trading_prepare/"
dir.create(output_dir, showWarnings = FALSE)

files = tibble(ttm = 27) %>%
mutate(in_dir = c(paste0(data_dir,"BTC_option_ttm27_0_0_0.csv")),
       out_dir = c(paste0(output_dir,"BTC_","ttm27")))

### Cluster dates
cluster0_dates = read_csv(paste0("data/dates_ttm5_cluster0.csv"))
cluster1_dates = read_csv(paste0("data/dates_ttm5_cluster1.csv"))
cluster0_dates$Date <- as.Date(cluster0_dates$Date, format="%Y-%m-%d")
cluster1_dates$Date <- as.Date(cluster1_dates$Date, format="%Y-%m-%d")


# for (f in 1:nrow(files)) {
  options = read_csv(files$in_dir)
  
  options1 = options %>% 
    filter(!is.na(delta))
  
  # all dates 
  options1 = options1 %>% 
    mutate(Date = as.Date(as.character(Date),format = "%Y-%m-%d"))
  
  ##### deltas and option ID ##### 
  
  options1 = options1 %>% 
    select(Date, PC_type, Strike, Spot, Premium, tau, moneyness, delta, IV, IR, DividendYield, value, quantity,delta) %>% 
    rename(delta_t = delta,
           IV_t = IV, 
           Spot_t = Spot,
           Premium_t = Premium,
           Moneyness_t = moneyness,
           Tau_t = tau,
           IR_t = IR,
           value_t = value,
           Quantity_t = quantity,
           DividendYield_t = DividendYield,
           Delta_t = delta)
  
  # take absolute values of delta
  options1 = options1 %>% 
    mutate(Delta_t = abs(Delta_t))
  
  # Create options2 and modify the Date column
  options2 <- options1 %>%
    mutate(Date = Date + days(ttm))
  
  # Perform a left join and create the 'spots_th' variable
  options2 <- options2 %>%
    left_join(spots, by = c("Date" = "test_date")) %>%
    mutate(Spot_th = BTC_price) %>%
    select(-BTC_price)  # Optional, to remove the 'BTC_price' column from 'options2'
  
  options2 = options2 %>%
    filter(Tau_t==ttm)
  
  options2 = options2 %>%
    mutate(option_value = ifelse(PC_type==1,ifelse(Spot_th>Strike,Spot_th-Strike,0),
                                 ifelse(Spot_th<Strike,Strike-Spot_th,0))) %>%
    mutate(option_return = (option_value/Premium_t)-1)
  
  options2 = options2 %>% 
    mutate(M_floor = floor(Moneyness_t*100)/100,
           Return_t = Moneyness_t-1)
  
  options2 = options2 %>%
    mutate(Date = Date - days(ttm))
  
  options2$Cluster <- NA
  options2$Cluster[options2$Date %in% cluster0_dates$Date] <- 0
  options2$Cluster[options2$Date %in% cluster1_dates$Date] <- 1
  options2 <- options2 %>%
    filter(!is.na(Cluster))
  
  calls = options2 %>% filter(PC_type > 0) %>% rename(test_date = Date)
  puts = options2 %>% filter(PC_type < 0)  %>% rename(test_date = Date)
  
  
  
  write_csv(calls,paste0(files$out_dir,"_",as.character(ttm),"ahead_calls.csv"))
  write_csv(puts,paste0(files$out_dir,"_",as.character(ttm),"ahead_puts.csv"))
  write_csv(options2,paste0(files$out_dir,".csv"))
# }

