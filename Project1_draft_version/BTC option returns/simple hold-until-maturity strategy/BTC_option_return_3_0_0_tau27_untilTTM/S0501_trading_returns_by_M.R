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

setwd("~/同步空间/Pricing_Kernel/EPK/BTC option return/BTC_option_return_3_0_0_tau27_untilTTM/")
new_dir = "S0501_trading_result_by_m/"
dir.create(paste0(new_dir), showWarnings = FALSE)

# trading_type = "Long" # Short or Long

###### Trading strategies by m ###### 
# f=1

# files = tibble(weight = c("EW","QW","VW"))
trading_type_set = tibble(type = c("Long","Short"))

# for (f in 1:nrow(files)){
  
  
  ####### Long strategies #######
  t=1
  trading_type = trading_type_set$type[t]
  
  longCall_by_m = read_csv(paste0("S03_trading_returns/",trading_type,"Callsimple_by_M_ttm",
                                  as.character(ttm),".csv"))
  copy <- longCall_by_m %>%
    mutate(Cluster = 3)
  longCall_by_m <- rbind(longCall_by_m, copy) %>%
    mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                            ifelse(Cluster==1,"Cluster1","Overall")))
  longCall_by_m = longCall_by_m %>% 
    mutate(mean_return = R_t*100,
           strategy = paste0(trading_type," Call simple")) 
  
  longPut_by_m = read_csv(paste0("S03_trading_returns/",trading_type,"Putsimple_by_M_ttm",
                                 as.character(ttm),".csv"))
  copy <- longPut_by_m %>%
    mutate(Cluster = 3)
  longPut_by_m <- rbind(longPut_by_m, copy) %>%
    mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                            ifelse(Cluster==1,"Cluster1","Overall")))
  longPut_by_m = longPut_by_m %>% 
    mutate(mean_return = R_t*100,
           strategy = paste0(trading_type," Put simple")) 
  
  longStraddle_by_m = read_csv(paste0("S03_trading_returns/simple_",trading_type,"Straddle_by_M_ttm",
                                      as.character(ttm),".csv"))
  copy <- longStraddle_by_m %>%
    mutate(Cluster = 3)
  longStraddle_by_m <- rbind(longStraddle_by_m, copy) %>%
    mutate(Cluster = ifelse(Cluster==0,"Cluster0",
                            ifelse(Cluster==1,"Cluster1","Overall")))
  longStraddle_by_m = longStraddle_by_m %>% 
    mutate(mean_return = R_t*100,
           strategy = paste0(trading_type," straddle")) 
  
  
  ## combine all strategies for plotting
  dat_by_m = bind_rows(longCall_by_m,longPut_by_m) %>% 
    bind_rows(longStraddle_by_m) %>% 
    mutate(M_group1 = gsub(pattern = "\\[|\\]|\\(|\\)",replacement = "",x = M_group)) 
  dat_by_m$M = unlist(lapply(X = dat_by_m$M_group1,FUN = function(x) {
    tmp = unlist(strsplit(x = x,split = ","))
    return((as.numeric(tmp[1]) + as.numeric(tmp[2]))/2)
  }))
  
  # Ensure 'M' is a factor in the correct order
  dat_by_m$M <- factor(dat_by_m$M, levels = sort(unique(dat_by_m$M)))
  
  # Create a complete grid of combinations
  complete_grid <- expand.grid(M = levels(dat_by_m$M), 
                               Cluster = c("Cluster0", "Cluster1", "Overall"),
                               strategy = unique(dat_by_m$strategy), 
                               stringsAsFactors = TRUE)
  # Left join with original data
  full_dat_by_m <- left_join(complete_grid, dat_by_m, by = c("M", "Cluster","strategy"))
  
  # Create a data frame for labels
  label_data <- dat_by_m %>%
    distinct(M, M_group) %>%
    arrange(M)
  
  x_labels <- paste(rep(c("Cluster0", "Cluster1", "Overall"), length(label_data$M_group)), rep(label_data$M_group, each=3), sep=" - ")
  
  by_m_plt_long = ggplot(full_dat_by_m,
                         aes(x = interaction(M, Cluster, lex.order = TRUE), y = mean_return, fill = Cluster, color = Cluster)) +
    facet_wrap(~ strategy, nrow = 1,scales = "free_y") +
    geom_rect(aes(xmin = 3.5, xmax = 6.5, ymin = -Inf, ymax = Inf, fill = "grey"), alpha = 0.1, color = NA, inherit.aes = FALSE) +  # Shaded background
    geom_rect(aes(xmin = 9.5, xmax = 12.5, ymin = -Inf, ymax = Inf, fill = "grey"), alpha = 0.1, color = NA, inherit.aes = FALSE) +  # Shaded background
    geom_boxplot(position = position_dodge(width = 0.8), width = 0.5, alpha = 0.5) +
    scale_x_discrete(labels = x_labels) +
    scale_color_manual(values = c("Cluster0" = "blue", "Cluster1" = "red", "Overall" = "black")) +
    scale_fill_manual(values = c("Cluster0" = "blue", "Cluster1" = "red", "Overall" = "black")) +
    ylim(-100, 200) +  # Fixed y-axis range
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1),
          axis.title.y = element_text(face = "bold",size = 20), # Bold and larger y-axis labels
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank()) +
    labs(title = "", x = "Return", y = "Mean Return (%)")
  
  by_m_plt_long = annotate_figure(by_m_plt_long,
                                  top = text_grob(paste0("simple option returns, tau = ",ttm),
                                                  size = 30, face = "bold"))
  
  ggsave(filename = paste0(new_dir,trading_type,"simple_by_m_ttm",as.character(ttm),".png"), plot = by_m_plt_long, bg = "transparent", width = 22, height = 10, dpi = 300)
  
  
# }





