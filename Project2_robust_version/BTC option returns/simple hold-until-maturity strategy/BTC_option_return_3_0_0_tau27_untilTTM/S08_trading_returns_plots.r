library(tidyverse)
library(ggplot2)
library(grid)
library(ggpubr)

theme_set(theme_bw() +
            theme(text = element_text(size=20),
                  axis.line = element_line(colour = "black"),
                  aspect.ratio = 1.7,
                  axis.text.x = element_text(angle=90, vjust=.5, hjust=1),
                  legend.title=element_blank()
            ))

idir = "~/Desktop/Hannah/work/SPX/Analysis/S04_FAR/PCA_2009_2021_evenly_spaced/trading_strategies/S03_trading_returns/"
trading_stradtegy = "DN_LongStraddle" # this must be consistent with how we name strategy in idir 

all_effective_spread_measures =  c(0,0.5,0.75,1) # trading cost
filtering_thrsh = 0.005 # threshold for filtering trading signals

level_dat = tibble()
for (e in all_effective_spread_measures) {
  long_straddle = read_csv(paste0(idir,trading_stradtegy,"_overall_thrs",
                                  as.character(filtering_thrsh),"_EffSpread",
                                  as.character(e),".csv"))
  long_straddle = long_straddle %>% 
    filter(! model %in% c("fNTK1","fNTK5")) %>% 
    mutate(model = case_when(model == "fNTK3" ~ "fNTK",
                             TRUE ~ model
    )) %>% 
    mutate(model = factor(x = model,
                          levels = c("CW","AHBS","fRW","fLinK","fGauK","fLapK","fNTK")),
           Year = format(test_date, format = "%Y"))
  
  
  dat_all_years = long_straddle %>% 
    group_by(steps_ahead,model) %>% 
    summarise(sharpe_ratio = mean(ER_t)/sqrt(var(ER_t)),
              mean_return = mean(R_t)*100) %>% 
    ungroup() %>% 
    mutate(sharpe_ratio = sharpe_ratio*sqrt(252/steps_ahead)) %>%  # annualized Sharpe ratio
    mutate(effective_measure = paste0("EM = ",as.character(e*100),"%"),
           type = "level",
           Year = "all_years")
  
  dat_by_years = long_straddle %>% 
    group_by(steps_ahead,model,Year) %>% 
    summarise(sharpe_ratio = mean(ER_t)/sqrt(var(ER_t)),
              mean_return = mean(R_t)*100) %>% 
    ungroup() %>% 
    mutate(sharpe_ratio = sharpe_ratio*sqrt(252/steps_ahead)) %>%  # annualized Sharpe ratio
    mutate(effective_measure = paste0("EM = ",as.character(e*100),"%"),
           type = "level")
  
  level_dat = bind_rows(level_dat,bind_rows(dat_all_years,dat_by_years))
}


all_effective_spread_measures = paste0("EM = ",as.character(all_effective_spread_measures*100),"%")
all_steps_ahead = unique(level_dat$steps_ahead)
benchmark_model = 'fNTK'
years = unique(level_dat$Year)


########## All years, no trading costs, filtering threshold of 0.005 ########## 
dat_all_years = level_dat %>% 
  filter(Year == "all_years") %>% 
  mutate(model_type = ifelse(model %in% c("fGauK","fLapK","fNTK","fLinK"),"kernel","other"),
         steps_ahead = paste0("h = ",steps_ahead)) %>%
  mutate(steps_ahead = factor(steps_ahead,
                              levels = c("h = 1","h = 5","h = 10","h = 15","h = 20"))) %>% 
  pivot_longer(cols = c("mean_return","sharpe_ratio"),
               values_to = "value",
               names_to = "measurement") %>% 
  mutate(type_measurement = paste0(measurement," ",type)) %>% 
  mutate(type_measurement = case_when(type_measurement == "mean_return level" ~ "Level MR (%)",
                                      type_measurement == "sharpe_ratio level" ~ "Level SR",
                                      TRUE ~ type_measurement)) %>% 
  mutate(type_measurement = factor(x = type_measurement, levels = c("Level MR (%)","Level SR")),
         effective_measure = factor(x = effective_measure,levels = c("EM = 0%","EM = 50%","EM = 75%","EM = 100%")))


MR_level = dat_all_years %>% 
  filter(type_measurement == "Level MR (%)",
         effective_measure == "EM = 0%")  %>% 
  ggplot(aes(x=model, y=value)) +
  geom_bar(aes(fill = model_type),stat="identity", 
           position=position_dodge()) +
  scale_fill_manual(values = c("kernel" = "#4361ee","other" = "#d90429")) +
  theme(legend.position = "none") +
  xlab("") + 
  ylab("Mean return (%)") + 
  facet_grid(cols = vars(steps_ahead)) 

SR_level = dat_all_years %>% 
  filter(type_measurement == "Level SR",
         effective_measure == "EM = 0%")  %>% 
  ggplot(aes(x=model, y=value)) +
  geom_bar(aes(fill = model_type),stat="identity", 
           position=position_dodge()) +
  scale_fill_manual(values = c("kernel" = "#4361ee","other" = "#d90429")) +
  theme(legend.position = "none") +
  xlab("") + 
  ylab("Sharpe ratio") + 
  facet_grid(cols = vars(steps_ahead))


pdf(paste0("S08_trading_result_plots/",trading_stradtegy,"_thrs",filtering_thrsh,"_EffSpr0.pdf"),
    width = 23,height = 5)
ggarrange(plotlist = list(MR_level,SR_level),
          ncol = 2,nrow = 1,labels = c("(a)","(b)"),
          font.label = list(face = "plain",size = 21))
dev.off()


######### All years, different trading costs ######### 
MR_level_with_cost = dat_all_years %>% 
  filter(type_measurement == "Level MR (%)",
         effective_measure != "EM = 0%")  %>% 
  ggplot(aes(x=model, y=value)) +
  geom_bar(aes(fill = model_type),stat="identity", 
           position=position_dodge()) +
  scale_fill_manual(values = c("kernel" = "#4361ee","other" = "#d90429")) +
  theme(legend.position = "none") +
  xlab("") + ylab("Mean return (%)") + 
  ggh4x::facet_grid2(effective_measure~steps_ahead) #,scales = "free_y"

SR_level_with_cost = dat_all_years %>% 
  filter(type_measurement == "Level SR",
         effective_measure != "EM = 0%")  %>% 
  ggplot(aes(x=model, y=value)) +
  geom_bar(aes(fill = model_type),stat="identity", 
           position=position_dodge()) +
  scale_fill_manual(values = c("kernel" = "#4361ee","other" = "#d90429")) +
  theme(legend.position = "none") +
  xlab("") + ylab("Sharpe ratio") + 
  ggh4x::facet_grid2(effective_measure~steps_ahead) #,scales = "free_y"


pdf(paste0("S08_trading_result_plots/",trading_stradtegy,"_thrs",filtering_thrsh,"_with_TransactionCosts.pdf"),
    width = 23,height = 11)
ggarrange(plotlist = list(MR_level_with_cost,SR_level_with_cost),
          ncol = 2,nrow = 1,labels = c("(a)","(b)"),
          font.label = list(face = "plain",size = 21))
dev.off()


######### Different years, no trading costs, filtering threshold of 0.005 ######### 
dat_by_years = level_dat %>% 
  filter(Year != "all_years") %>% 
  mutate(model_type = ifelse(model %in% c("fGauK","fLapK","fNTK","fLinK"),"kernel","other"),
         steps_ahead = paste0("h = ",steps_ahead)) %>%
  mutate(steps_ahead = factor(steps_ahead,
                              levels = c("h = 1","h = 5","h = 10","h = 15","h = 20"))) %>% 
  pivot_longer(cols = c("mean_return","sharpe_ratio"),
               values_to = "value",
               names_to = "measurement") %>% 
  mutate(type_measurement = paste0(measurement," ",type)) %>% 
  mutate(type_measurement = case_when(type_measurement == "mean_return level" ~ "Level MR (%)",
                                      type_measurement == "sharpe_ratio level" ~ "Level SR",
                                      TRUE ~ type_measurement)) %>% 
  mutate(type_measurement = factor(x = type_measurement, levels = c("Level MR (%)","Level SR")),
         effective_measure = factor(x = effective_measure,levels = c("EM = 0%","EM = 50%","EM = 75%","EM = 100%")),
         Year = factor(x = Year,levels = c("2019","2020","2021")))

MR_level_by_years = dat_by_years %>% 
  filter(type_measurement == "Level MR (%)",
         effective_measure == "EM = 0%")  %>% 
  ggplot(aes(x=model, y=value)) +
  geom_bar(aes(fill = model_type),stat="identity", 
           position=position_dodge()) +
  scale_fill_manual(values = c("kernel" = "#4361ee","other" = "#d90429")) +
  theme(legend.position = "none") +
  xlab("") + 
  ylab("Mean return (%)") + 
  ggh4x::facet_grid2(Year~steps_ahead) #,scales = "free_y"


SR_level_by_years = dat_by_years %>% 
  filter(type_measurement == "Level SR",
         effective_measure == "EM = 0%")  %>% 
  ggplot(aes(x=model, y=value)) +
  geom_bar(aes(fill = model_type),stat="identity", 
           position=position_dodge()) +
  scale_fill_manual(values = c("kernel" = "#4361ee","other" = "#d90429")) +
  theme(legend.position = "none") +
  xlab("") + 
  ylab("Sharpe ratio") + 
  ggh4x::facet_grid2(Year~steps_ahead) #,scales = "free_y"

pdf(paste0("S08_trading_result_plots/",trading_stradtegy,"_thrs",filtering_thrsh,"_EffSpr0_by_years.pdf"),
    width = 23,height = 11)
ggarrange(plotlist = list(MR_level_by_years,SR_level_by_years),
          ncol = 2,nrow = 1,labels = c("(a)","(b)"),
          font.label = list(face = "plain",size = 21))
dev.off()

########### Different filtering thresholds, no trading cost, across the whole test period ########### 
filtering_thrsh = c(0.005,0.05,0.1) # threshold for filtering trading signals

level_dat1 = tibble()
for (f in filtering_thrsh) {
  long_straddle = read_csv(paste0(idir,trading_stradtegy,"_overall_thrs",
                                  as.character(f),"_EffSpread0.csv"))
  long_straddle = long_straddle %>% 
    filter(! model %in% c("fNTK1","fNTK5","fPolK")) %>% 
    mutate(model = case_when(model == "fNTK3" ~ "fNTK",
                             TRUE ~ model
    )) %>% 
    mutate(model = factor(x = model,
                          levels = c("CW","AHBS","fRW","fLinK","fGauK","fLapK","fNTK")))
  
  dat = long_straddle %>% 
    group_by(steps_ahead,model) %>% 
    summarise(sharpe_ratio = mean(ER_t)/sqrt(var(ER_t)),
              mean_return = mean(R_t)*100) %>% 
    ungroup() %>% 
    mutate(sharpe_ratio = sharpe_ratio*sqrt(252/steps_ahead)) %>%  # annualized Sharpe ratio
    mutate(type = "level",
           filtering_thrsh = f)
  level_dat1 = bind_rows(level_dat1,dat) 
}

all_steps_ahead = unique(level_dat1$steps_ahead)
benchmark_model = 'fNTK'

dat_all_years1 = level_dat1 %>% 
  mutate(model_type = ifelse(model %in% c("fGauK","fLapK","fNTK","fLinK"),"kernel","other"),
         steps_ahead = paste0("h = ",steps_ahead)) %>%
  mutate(steps_ahead = factor(steps_ahead,
                              levels = c("h = 1","h = 5","h = 10","h = 15","h = 20"))) %>% 
  pivot_longer(cols = c("mean_return","sharpe_ratio"),
               values_to = "value",
               names_to = "measurement") %>% 
  mutate(type_measurement = paste0(measurement," ",type),
         filtering_thrsh = paste0("threshold = ",filtering_thrsh*100,"%")) %>% 
  mutate(type_measurement = case_when(type_measurement == "mean_return level" ~ "Level MR (%)",
                                      type_measurement == "sharpe_ratio level" ~ "Level SR",
                                      TRUE ~ type_measurement)) %>% 
  mutate(type_measurement = factor(x = type_measurement, levels = c("Level MR (%)","Level SR")),
         filtering_thrsh = factor(x = filtering_thrsh,levels = c("threshold = 0.5%","threshold = 5%","threshold = 10%")))


MR_level1 = dat_all_years1 %>% 
  filter(type_measurement == "Level MR (%)")  %>% 
  ggplot(aes(x=model, y=value)) +
  geom_bar(aes(fill = model_type),stat="identity", 
           position=position_dodge()) +
  scale_fill_manual(values = c("kernel" = "#4361ee","other" = "#d90429")) +
  theme(legend.position = "none") +
  xlab("") + 
  ylab("Mean return (%)") + 
  facet_grid(filtering_thrsh~steps_ahead) 

SR_level1 = dat_all_years1 %>% 
  filter(type_measurement == "Level SR")  %>% 
  ggplot(aes(x=model, y=value)) +
  geom_bar(aes(fill = model_type),stat="identity", 
           position=position_dodge()) +
  scale_fill_manual(values = c("kernel" = "#4361ee","other" = "#d90429")) +
  theme(legend.position = "none") +
  xlab("") + 
  ylab("Sharpe ratio") + 
  facet_grid(filtering_thrsh~steps_ahead)

pdf(paste0("S08_trading_result_plots/",trading_stradtegy,"_DifferentThrshs_EffSpr0.pdf"),
    width = 23,height = 11)
ggarrange(plotlist = list(MR_level1,SR_level1),
          ncol = 2,nrow = 1,labels = c("(a)","(b)"),
          font.label = list(face = "plain",size = 21))
dev.off()
