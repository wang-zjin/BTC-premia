library(tidyverse)
library(ggplot2)
library(ggpubr)

theme_set(theme_bw() +
            theme(text = element_text(size=15),
                  axis.line = element_line(colour = "black"),
                  # panel.border = element_blank(),
                  aspect.ratio = 1,
                  legend.title=element_blank()
            ))

###### ######
shapes = c("All" = 4,
           "CW" = 0,
           "AHBS" = 1,
           "fRW" = 2,
           "fGauK" = 15,
           "fLapK" = 16,
           "fLinK" = 17)

idir = "~/Desktop/Hannah/work/SPX/Analysis/S04_FAR/PCA_2009_2021_evenly_spaced/trading_strategies/S03_trading_returns/"
idir_allOptions = "~/Desktop/Hannah/work/SPX/Analysis/S04_FAR/PCA_2009_2021_evenly_spaced/trading_strategies/trading_with_AllOptions/S03_trading_returns/"
filtering_thrsh = 0.005 # threshold for filtering trading signals
effective_spread_measure =  0 # trading cost


###### Trading strategies by m ###### 
returns_by_m = function(data, data_with_allOptions,
                        selected_steps_ahead = 20, strategy_name = "") {
  data = bind_rows(data,data_with_allOptions) %>% 
    group_by(steps_ahead,model,M_group,Year) %>% 
    summarise(num_traded = mean(num_options),
              mean_return = mean(R_t)*100,
              sharpe_ratio = mean(ER_t)/sqrt(var(ER_t))) %>% 
    ungroup() %>% 
    mutate(sharpe_ratio = sharpe_ratio*sqrt(252/steps_ahead))
  
  data = data %>% 
    filter(! model %in% c("fNTK1","fNTK5")) %>% 
    mutate(M_group1 = gsub(pattern = "\\[|\\]|\\(|\\)",replacement = "",x = M_group),
           model = ifelse(model=="fNTK3","fNTK",model)) 
  data$M = unlist(lapply(X = data$M_group1,FUN = function(x) {
    tmp = unlist(strsplit(x = x,split = ","))
    return((as.numeric(tmp[1]) + as.numeric(tmp[2]))/2)
  }))
  
  data = data %>% 
    rename(
      `Mean return (%)` = "mean_return",
      `Sharpe ratio` = "sharpe_ratio",
      `Mean traded volume` = "num_traded"
    ) %>% 
    pivot_longer(cols = c("Mean traded volume","Mean return (%)","Sharpe ratio"), 
                 names_to = "Type",values_to = "Value") %>% 
    mutate(Type = factor(x = Type,levels = c("Mean traded volume","Mean return (%)","Sharpe ratio")), 
           model = factor(x = model,levels = c("All","CW","AHBS","fRW","fLinK","fGauK","fLapK","fNTK"))) %>% 
    filter(steps_ahead == selected_steps_ahead)
  
  plt = data %>%
    mutate(model_type = ifelse(model=="All","All",
                               ifelse(model %in% c("fGauK","fLapK","fLinK"),"kernel",
                                      ifelse(model == "fNTK",
                                             "benchmark","other")))) %>%
    ggplot(aes(x = M, y = Value, 
               group = model, size = model_type)) +
    geom_point(aes(shape = model,color = model_type),fill = "black",size=2) +
    geom_line(aes(color = model_type)) +
    scale_size_manual(values = c("kernel" = 0.5,"other" = 0.5,"All" = 0.5,"benchmark" = 0.8)) +
    scale_color_manual(values = c("kernel" = "#4361ee","other" = "#d90429","benchmark" = "black","All" = "#adb5bd")) + 
    scale_shape_manual(values = c(shapes,"fNTK" = 8)) +
    xlab("m group") +  ylab("") +
    ggh4x::facet_grid2(Type~Year,scales = "free_y") + 
    scale_x_continuous(breaks = c(-1.25,-0.25,0.25,1.25),
                       labels = c("[-2,-0.5]","(-0.5,0]","(0,0.5]","(0.5,2]")) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    ggtitle(strategy_name)
  
}

shortCall_by_m = returns_by_m(data = read_csv(paste0(idir,"ShortCallDH_by_M_thrs",
                                                     as.character(filtering_thrsh),"_EffSpread",
                                                     as.character(effective_spread_measure),".csv")) %>% 
                                mutate(Year = format(test_date, format = "%Y")),
                              data_with_allOptions = read_csv(paste0(idir_allOptions,
                                                                     "ShortCallDH_by_M_thrs0_EffSpread0.csv")) %>% 
                                mutate(Year = format(test_date, format = "%Y"),
                                       model = "All"),
                              selected_steps_ahead = 20,
                              strategy_name = "Short call delta-hedging")

shortPut_by_m = returns_by_m(data = read_csv(paste0(idir,"ShortPutDH_by_M_thrs",
                                                    as.character(filtering_thrsh),"_EffSpread",
                                                    as.character(effective_spread_measure),".csv")) %>% 
                               mutate(Year = format(test_date, format = "%Y")),
                             data_with_allOptions = read_csv(paste0(idir_allOptions,
                                                                    "ShortPutDH_by_M_thrs0_EffSpread0.csv")) %>% 
                               mutate(Year = format(test_date, format = "%Y"),
                                      model = "All"),
                             selected_steps_ahead = 20,
                             strategy_name = "Short put delta-hedging")

shortStraddle_by_m = returns_by_m(data = read_csv(paste0(idir,"DN_ShortStraddle_by_M_thrs",
                                                         as.character(filtering_thrsh),"_EffSpread",
                                                         as.character(effective_spread_measure),".csv")) %>% 
                                    mutate(Year = format(test_date, format = "%Y")),
                                  data_with_allOptions = read_csv(paste0(idir_allOptions,
                                                                         "DN_ShortStraddle_by_M_thrs0_EffSpread0.csv")) %>% 
                                    mutate(Year = format(test_date, format = "%Y"),
                                           model = "All"),
                                  selected_steps_ahead = 20,
                                  strategy_name = "Short straddle")

longCall_by_m = returns_by_m(data = read_csv(paste0(idir,"LongCallDH_by_M_thrs",
                                                    as.character(filtering_thrsh),"_EffSpread",
                                                    as.character(effective_spread_measure),".csv")) %>% 
                               mutate(Year = format(test_date, format = "%Y")),
                             data_with_allOptions = read_csv(paste0(idir_allOptions,
                                                                    "LongCallDH_by_M_thrs0_EffSpread0.csv")) %>% 
                               mutate(Year = format(test_date, format = "%Y"),
                                      model = "All"),
                             selected_steps_ahead = 20,
                             strategy_name = "Long call delta-hedging")

longPut_by_m = returns_by_m(data = read_csv(paste0(idir,"LongPutDH_by_M_thrs",
                                                   as.character(filtering_thrsh),"_EffSpread",
                                                   as.character(effective_spread_measure),".csv")) %>% 
                              mutate(Year = format(test_date, format = "%Y")),
                            data_with_allOptions = read_csv(paste0(idir_allOptions,
                                                                   "LongPutDH_by_M_thrs0_EffSpread0.csv")) %>% 
                              mutate(Year = format(test_date, format = "%Y"),
                                     model = "All"),
                            selected_steps_ahead = 20,
                            strategy_name = "Long put delta-hedging")

longStraddle_by_m = returns_by_m(data = read_csv(paste0(idir,"DN_LongStraddle_by_M_thrs",
                                                        as.character(filtering_thrsh),"_EffSpread",
                                                        as.character(effective_spread_measure),".csv")) %>% 
                                   mutate(Year = format(test_date, format = "%Y")),
                                 data_with_allOptions = read_csv(paste0(idir_allOptions,
                                                                        "DN_LongStraddle_by_M_thrs0_EffSpread0.csv")) %>% 
                                   mutate(Year = format(test_date, format = "%Y"),
                                          model = "All"),
                                 selected_steps_ahead = 20,
                                 strategy_name = "Long straddle")


###### Trading strategies by tau ###### 
returns_by_tau = function(data, data_with_allOptions,
                          selected_steps_ahead = 20, strategy_name = "") {
  data = bind_rows(data,data_with_allOptions) %>% 
    group_by(steps_ahead,model,tau_group,Year) %>% 
    summarise(num_traded = mean(num_options),
              mean_return = mean(R_t)*100,
              sharpe_ratio = mean(ER_t)/sqrt(var(ER_t))) %>% 
    ungroup() %>% 
    mutate(sharpe_ratio = sharpe_ratio*sqrt(252/steps_ahead))
  
  data = data %>% 
    filter(! model %in% c("fNTK1","fNTK5")) %>% 
    mutate(tau_group1 = gsub(pattern = "\\[|\\]|\\(|\\)",replacement = "",x = tau_group),
           model = ifelse(model=="fNTK3","fNTK",model)) 
  data$tau = unlist(lapply(X = data$tau_group1,FUN = function(x) {
    tmp = unlist(strsplit(x = x,split = ","))
    return((as.numeric(tmp[1]) + as.numeric(tmp[2]))/2)
  }))
  
  data = data %>% 
    rename(
      `Mean return (%)` = "mean_return",
      `Sharpe ratio` = "sharpe_ratio",
      `Mean traded volume` = "num_traded"
    ) %>% 
    pivot_longer(cols = c("Mean traded volume","Mean return (%)","Sharpe ratio"), 
                 names_to = "Type",values_to = "Value") %>% 
    mutate(Type = factor(x = Type,levels = c("Mean traded volume","Mean return (%)","Sharpe ratio")), 
           model = factor(x = model,levels = c("All","CW","AHBS","fRW","fLinK","fGauK","fLapK","fNTK"))) %>% 
    filter(steps_ahead == selected_steps_ahead)
  
  plt = data %>%
    mutate(model_type = ifelse(model=="All","All",
                               ifelse(model %in% c("fGauK","fLapK","fLinK"),"kernel",
                                      ifelse(model == "fNTK",
                                             "benchmark","other")))) %>%
    ggplot(aes(x = tau, y = Value, 
               group = model, size = model_type)) +
    geom_point(aes(shape = model,color = model_type),fill = "black",size=2) +
    geom_line(aes(color = model_type)) +
    scale_size_manual(values = c("kernel" = 0.5,"other" = 0.5,"All" = 0.5,"benchmark" = 0.8)) +
    scale_color_manual(values = c("kernel" = "#4361ee","other" = "#d90429","benchmark" = "black","All" = "#adb5bd")) + 
    scale_shape_manual(values = c(shapes,"fNTK" = 8)) +
    xlab(expression(paste(tau," group"))) + ylab("") +
    ggh4x::facet_grid2(Type~Year,scales = "free_y") + 
    scale_x_continuous(breaks = c(32.5,90,150,216),
                       labels = c("[5,60]","(60,120]","(120,180]","(180,252]")) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    ggtitle(strategy_name)
  
}


shortCall_by_tau = returns_by_tau(data = read_csv(paste0(idir,"ShortCallDH_by_tau_thrs",
                                                         as.character(filtering_thrsh),"_EffSpread",
                                                         as.character(effective_spread_measure),".csv")) %>% 
                                    mutate(Year = format(test_date, format = "%Y")),
                                  data_with_allOptions = read_csv(paste0(idir_allOptions,
                                                                         "ShortCallDH_by_tau_thrs0_EffSpread0.csv")) %>% 
                                    mutate(Year = format(test_date, format = "%Y"),
                                           model = "All"),
                                  selected_steps_ahead = 20,
                                  strategy_name = "Short call delta-hedging")

shortPut_by_tau = returns_by_tau(data = read_csv(paste0(idir,"ShortPutDH_by_tau_thrs",
                                                        as.character(filtering_thrsh),"_EffSpread",
                                                        as.character(effective_spread_measure),".csv")) %>% 
                                   mutate(Year = format(test_date, format = "%Y")),
                                 data_with_allOptions = read_csv(paste0(idir_allOptions,
                                                                        "ShortPutDH_by_tau_thrs0_EffSpread0.csv")) %>% 
                                   mutate(Year = format(test_date, format = "%Y"),
                                          model = "All"),
                                 selected_steps_ahead = 20,
                                 strategy_name = "Short put delta-hedging")

shortStraddle_by_tau = returns_by_tau(data = read_csv(paste0(idir,"DN_ShortStraddle_by_tau_thrs",
                                                             as.character(filtering_thrsh),"_EffSpread",
                                                             as.character(effective_spread_measure),".csv")) %>% 
                                        mutate(Year = format(test_date, format = "%Y")),
                                      data_with_allOptions = read_csv(paste0(idir_allOptions,
                                                                             "DN_ShortStraddle_by_tau_thrs0_EffSpread0.csv")) %>% 
                                        mutate(Year = format(test_date, format = "%Y"),
                                               model = "All"),
                                      selected_steps_ahead = 20,
                                      strategy_name = "Short straddle")

longCall_by_tau = returns_by_tau(data = read_csv(paste0(idir,"LongCallDH_by_tau_thrs",
                                                        as.character(filtering_thrsh),"_EffSpread",
                                                        as.character(effective_spread_measure),".csv")) %>% 
                                   mutate(Year = format(test_date, format = "%Y")),
                                 data_with_allOptions = read_csv(paste0(idir_allOptions,
                                                                        "LongCallDH_by_tau_thrs0_EffSpread0.csv")) %>% 
                                   mutate(Year = format(test_date, format = "%Y"),
                                          model = "All"),
                                 selected_steps_ahead = 20,
                                 strategy_name = "Long call delta-hedging")

longPut_by_tau = returns_by_tau(data = read_csv(paste0(idir,"LongPutDH_by_tau_thrs",
                                                       as.character(filtering_thrsh),"_EffSpread",
                                                       as.character(effective_spread_measure),".csv")) %>% 
                                  mutate(Year = format(test_date, format = "%Y")),
                                data_with_allOptions = read_csv(paste0(idir_allOptions,
                                                                       "LongPutDH_by_tau_thrs0_EffSpread0.csv")) %>% 
                                  mutate(Year = format(test_date, format = "%Y"),
                                         model = "All"),
                                selected_steps_ahead = 20,
                                strategy_name = "Long put delta-hedging")

longStraddle_by_tau = returns_by_tau(data = read_csv(paste0(idir,"DN_LongStraddle_by_tau_thrs",
                                                            as.character(filtering_thrsh),"_EffSpread",
                                                            as.character(effective_spread_measure),".csv")) %>% 
                                       mutate(Year = format(test_date, format = "%Y")),
                                     data_with_allOptions = read_csv(paste0(idir_allOptions,
                                                                            "DN_LongStraddle_by_tau_thrs0_EffSpread0.csv")) %>% 
                                       mutate(Year = format(test_date, format = "%Y"),
                                              model = "All"),
                                     selected_steps_ahead = 20,
                                     strategy_name = "Long straddle")

pdf(paste0("S08_trading_result_by_tau_M/ShortStrategies_returns_by_tau_m_by_years.pdf"),
    width = 18,height = 24)
ggarrange(plotlist = list(shortCall_by_m,shortCall_by_tau,
                          shortPut_by_m,shortPut_by_tau,
                          shortStraddle_by_m,shortStraddle_by_tau),
          ncol = 2,nrow = 3,labels = c("(a)","(b)","(c)","(d)","(e)","(f)"),
          font.label = list(size = 20,face = "plain"))
dev.off()


pdf(paste0("S08_trading_result_by_tau_M/LongStrategies_returns_by_tau_m_by_years.pdf"),
    width = 18,height = 24)
ggarrange(plotlist = list(longCall_by_m,longCall_by_tau,
                          longPut_by_m,longPut_by_tau,
                          longStraddle_by_m,longStraddle_by_tau),
          ncol = 2,nrow = 3,labels = c("(a)","(b)","(c)","(d)","(e)","(f)"),
          font.label = list(size = 20,face = "plain"))
dev.off()
