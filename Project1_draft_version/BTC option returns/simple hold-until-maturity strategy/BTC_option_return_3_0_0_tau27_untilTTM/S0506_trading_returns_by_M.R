# Clear Workspace
rm(list = ls())

# Load Libraries
library(tidyverse)
library(ggplot2)
library(ggpubr)

# Theme Setup
theme_set(theme_bw() + theme(
  text = element_text(size = 15),
  axis.line = element_line(colour = "black"),
  aspect.ratio = 1,
  legend.title = element_blank()
))

# Basic Setup
ttm = 27
setwd("~/同步空间/Pricing_Kernel/EPK/BTC option return/BTC_option_return_3_0_0_tau27_untilTTM/")
new_dir = "S0506_trading_result_by_m/"
dir.create(new_dir, showWarnings = FALSE)
trading_type_set = tibble(type = c("Long", "Short"))

# Read and Process Data
process_data <- function(trading_type, ttm, strategy_type) {
  file_path <- paste0("S03_trading_returns/", trading_type, strategy_type, "simple_by_M_ttm", as.character(ttm), ".csv")
  data <- read_csv(file_path) %>%
    rbind(., mutate(., Cluster = 3)) %>%
    mutate(Cluster = ifelse(Cluster == 0, "Cluster0", ifelse(Cluster == 1, "Cluster1", "Overall")),
           mean_return = R_t * 100,
           strategy = paste0(trading_type, " ", strategy_type, " simple"))
  return(data)
}

longCall_by_m <- process_data(trading_type_set$type[1], ttm, "Call")
longPut_by_m <- process_data(trading_type_set$type[1], ttm, "Put")

M_bound = c(-0.2, 0.2)
increment = 0.05

# Combine and Preprocess
dat_by_m <- bind_rows(longCall_by_m, longPut_by_m) %>%
  filter(Return_t >= M_bound[1] & Return_t <= M_bound[2]) %>%
  mutate(M_fine = cut(Return_t, breaks = seq(M_bound[1], M_bound[2], by = increment), include.lowest = TRUE),
         M_fine_group = as.character(M_fine),
         M_fine_group1 = gsub(pattern = "\\[|\\]|\\(|\\)", replacement = "", x = M_fine_group),
         M = unlist(lapply(X = M_fine_group1, FUN = function(x) {
           tmp = unlist(strsplit(x = x,split = ","))
           return((as.numeric(tmp[1]) + as.numeric(tmp[2]))/2)
         }))
         ) %>%
  mutate(M=round(M,3))

dat_by_m <- arrange(dat_by_m, M, test_date)

# Quantile Calculation Function
calculate_quantiles <- function(df, M_sequence, cluster, strategy) {
  results_df <- tibble(
    M_sequence = M_sequence,
    quantile_25th = NA_real_,
    median = NA_real_,
    quantile_75th = NA_real_
  )
  for (i in seq_along(M_sequence)) {
    filtered_rows <- filter(df, M == M_sequence[i], Cluster == cluster, strategy == strategy)
    if (nrow(filtered_rows) > 0) {
      results_df$quantile_25th[i] <- quantile(filtered_rows$mean_return, probs = 0.25, na.rm = TRUE)
      results_df$median[i] <- median(filtered_rows$mean_return, na.rm = TRUE)
      results_df$quantile_75th[i] <- quantile(filtered_rows$mean_return, probs = 0.75, na.rm = TRUE)
    }
  }
  return(results_df)
}

# Define M_sequence and Calculate Quantiles for Each Cluster
M_sequence <- round(seq(M_bound[1] + increment/2, M_bound[2] - increment/2, by = increment), 3)

results_df_OA_call <- calculate_quantiles(dat_by_m, M_sequence, "Overall","Long Call simple")
results_df_OA_put <- calculate_quantiles(dat_by_m, M_sequence, "Overall","Long Put simple")
results_df_HV_call <- calculate_quantiles(dat_by_m, M_sequence, "Cluster0","Long Call simple")
results_df_HV_put <- calculate_quantiles(dat_by_m, M_sequence, "Cluster0","Long Put simple")
results_df_LV_call <- calculate_quantiles(dat_by_m, M_sequence, "Cluster1","Long Call simple")
results_df_LV_put <- calculate_quantiles(dat_by_m, M_sequence, "Cluster1","Long Put simple")

# Combine quantiles into a long format for easier plotting with ggplot2
long_df_OA_call <- results_df_OA_call %>%
  pivot_longer(cols = c("quantile_25th", "median", "quantile_75th"), 
               names_to = "Quantile", 
               values_to = "Value")
# Plot
plt_OA <- ggplot(long_df_OA_call, aes(x = M_sequence, y = Value)) +
  geom_line(aes(color = Quantile)) +
  geom_point(aes(shape = Quantile, color = Quantile)) +
  scale_color_manual(values = c("quantile_25th" = "blue", "median" = "red", "quantile_75th" = "blue")) +
  scale_shape_manual(values = c("quantile_25th" = 17, "median" = 16, "quantile_75th" = 17)) +
  labs(title = "Quantiles of Return_t by M_sequence",
       x = "M Sequence",
       y = "Value") +
  theme(legend.title = element_blank()) # Optional: remove legend title

# Save the plot
ggsave(filename = paste0(new_dir,trading_type_set$type[1],"_Call_","simple_by_m_ttm",as.character(ttm),"_",as.character("OA"),".png"), plot = plt_OA, bg = "transparent", width = 14, height = 7, dpi = 300)

# install.packages("Hmisc")
library(Hmisc)

# Modified Quantile Calculation Function to Include Weights
calculate_quantiles <- function(df, M_sequence, cluster, strategy, weights_col) {
  results_df <- tibble(
    M_sequence = M_sequence,
    quantile_25th = NA_real_,
    median = NA_real_,
    quantile_75th = NA_real_
  )
  
  for (i in seq_along(M_sequence)) {
    filtered_rows <- filter(df, M == M_sequence[i], Cluster == cluster, strategy == strategy)
    
    if (nrow(filtered_rows) > 0) {
      weights <- filtered_rows$Volume_t  # Extract the weights
      
      # Calculate weighted quantiles
      results_df$quantile_25th[i] <- wtd.quantile(filtered_rows$mean_return, weights, probs = 0.25, na.rm = TRUE)
      results_df$median[i] <- wtd.quantile(filtered_rows$mean_return, weights, probs = 0.5, na.rm = TRUE)
      results_df$quantile_75th[i] <- wtd.quantile(filtered_rows$mean_return, weights, probs = 0.75, na.rm = TRUE)
    }
  }
  
  return(results_df)
}

# Example usage, assuming 'Volume_t' is the column you wish to use as weights
results_df_OA_call <- calculate_quantiles(dat_by_m, M_sequence, "Overall", "Long Call simple", "Volume_t")




