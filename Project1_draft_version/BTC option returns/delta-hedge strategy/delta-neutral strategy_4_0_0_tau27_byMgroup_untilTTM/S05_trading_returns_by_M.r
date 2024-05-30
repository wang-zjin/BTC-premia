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

ttm = 27
all_steps_ahead = ttm

###### ######

setwd("~/同步空间/Pricing_Kernel/EPK/delta-neutral strategy/delta-neutral strategy_2_3_1_tau27_byMgroup_untilTTM/")
dir.create(paste0("S05_trading_result_by_m/"), showWarnings = FALSE)

# trading_type = "Long" # Short or Long

###### Trading strategies by m ###### 
# f=1

files = tibble(weight = c("EW","QW","VW"))
trading_type_set = tibble(type = c("Long","Short"))

for (f in 1:nrow(files)){
  
  
    ####### Long strategies #######
    t=1
    trading_type = trading_type_set$type[t]
    
    longCall_by_m = read_csv(paste0("S03_trading_returns/",trading_type,"CallDH_by_M_",
                                     files$weight[f],".csv"))
    copy <- longCall_by_m %>%
      mutate(Cluster = 3)
    longCall_by_m <- rbind(longCall_by_m, copy) %>%
      mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                              ifelse(Cluster==1,"Cluster1","Overall")))
    longCall_by_m = longCall_by_m %>% 
      group_by(steps_ahead,Cluster,M_group) %>% 
      summarise(num_traded = n(),
                mean_return = mean(R_t)*100,
                sharpe_ratio = mean(ER_t)/sqrt(var(ER_t))) %>% 
      ungroup() %>% 
      mutate(sharpe_ratio = sharpe_ratio*sqrt(365/steps_ahead), # annualized Sharpe ratio
             strategy = paste0(trading_type," Call DH")) 
    
    longPut_by_m = read_csv(paste0("S03_trading_returns/",trading_type,"PutDH_by_M_",
                                    files$weight[f],".csv"))
    copy <- longPut_by_m %>%
      mutate(Cluster = 3)
    longPut_by_m <- rbind(longPut_by_m, copy) %>%
      mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                              ifelse(Cluster==1,"Cluster1","Overall")))
    longPut_by_m = longPut_by_m %>% 
      group_by(steps_ahead,Cluster,M_group) %>% 
      summarise(num_traded = n(),
                mean_return = mean(R_t)*100,
                sharpe_ratio = mean(ER_t)/sqrt(var(ER_t))) %>% 
      ungroup() %>% 
      mutate(sharpe_ratio = sharpe_ratio*sqrt(365/steps_ahead), # annualized Sharpe ratio
             strategy = paste0(trading_type," Put DH")) 
    
    longStraddle_by_m = read_csv(paste0("S03_trading_returns/DH_",trading_type,"Straddle_by_M_",
                                         files$weight[f],".csv"))
    copy <- longStraddle_by_m %>%
      mutate(Cluster = 3)
    longStraddle_by_m <- rbind(longStraddle_by_m, copy) %>%
      mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                              ifelse(Cluster==1,"Cluster1","Overall")))
    longStraddle_by_m = longStraddle_by_m %>% 
      group_by(steps_ahead,Cluster,M_group) %>% 
      summarise(num_traded = n(),
                mean_return = mean(R_t)*100,
                sharpe_ratio = mean(ER_t)/sqrt(var(ER_t))) %>% 
      ungroup() %>% 
      mutate(sharpe_ratio = sharpe_ratio*sqrt(365/steps_ahead), # annualized Sharpe ratio
             strategy = paste0(trading_type," straddle")) 
    
    
    ## combine all strategies for plotting
    dat_by_m = bind_rows(longCall_by_m,longPut_by_m) %>% 
      bind_rows(longStraddle_by_m) %>% 
      mutate(M_group1 = gsub(pattern = "\\[|\\]|\\(|\\)",replacement = "",x = M_group)) 
    dat_by_m$M = unlist(lapply(X = dat_by_m$M_group1,FUN = function(x) {
      tmp = unlist(strsplit(x = x,split = ","))
      return((as.numeric(tmp[1]) + as.numeric(tmp[2]))/2)
    }))
    
    dat_by_m = dat_by_m %>% 
      rename(
        `Mean return (%)` = "mean_return",
        `Sharpe ratio` = "sharpe_ratio",
        `Sum traded volume` = "num_traded"
      ) %>% 
      pivot_longer(cols = c("Sum traded volume","Mean return (%)","Sharpe ratio"), 
                   names_to = "Type",values_to = "Value") %>% 
      mutate(Type = factor(x = Type,levels = c("Sum traded volume","Mean return (%)","Sharpe ratio")), 
             model = factor(x = Cluster,levels = c("Cluster0","Cluster1","Overall")),
             strategy = factor(x = strategy,levels = c(paste0(trading_type," Call DH"),
                                                       paste0(trading_type," Put DH"),
                                                       paste0(trading_type," straddle")))) %>% 
      filter(steps_ahead == all_steps_ahead)
    
    
    (by_m_plt_long = dat_by_m  %>%
        ggplot(aes(x = M, y = Value)) +
        geom_point(aes(color = Cluster),size=2) +
        geom_line(aes(color = Cluster)) +
        # geom_smooth(se = FALSE, span = 0.5, color = "red") +
        scale_size_manual(values = c("kernel" = 0.5,"other" = 0.5,"All" = 0.5,"benchmark" = 0.8)) +
        scale_color_manual(values = c("Cluster0" = "#4361ee","Cluster1" = "#d90429","Overall" = "#adb5bd")) + 
        xlab("moneyness") +  ylab("") +
        ggh4x::facet_grid2(Type~strategy,scales = "free_y") + 
        scale_x_continuous(breaks = c(-0.15,-0.05,0.05,0.15),
                           labels = c("[-2,-0.10]","(-0.10,0]","(0,0.1]","(0.10,2]")) +
        theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)))
    by_m_plt_long = annotate_figure(by_m_plt_long,
                                     top = text_grob(paste0("DH option returns, tau = ",ttm),
                                                     size = 30, face = "bold"))
    
    ggsave(filename = paste0("S05_trading_result_by_m/",trading_type,"DH_by_m_",files$weight[f],".png"), plot = by_m_plt_long, bg = "transparent", width = 10, height = 10, dpi = 300)
    
  
}





