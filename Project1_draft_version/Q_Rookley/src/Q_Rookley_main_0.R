# we use modify the formula of Q
# setwd(wd)

# output Q-density of log return, P-density of log return, EPK of log return

source("EPK_library.r")

# Mapping Table for Input

# Column ... X
# 1 - date
# 2 - IV
# 3 - 1 for Call, 0 for Put
# 4 - Tau 
# 5 - Strike
# 6 - assigned meanwhile as put2call[,6]+ put2call[,7] -  put2call[,5]*exp(- mean(put2call[,8])* tau);
# 7 - Spot
# 8 - Probably Interest Rate
# 9 - assigned meanwhile Moneyness: Spot/Strike

bootstrap_epk = function(f, ts, currdate, out_dir, bandwidth, mon_low, mon_up){
  
  # f = "tmp/confidence_band_input_17.csv"
  # ts = 'data/BTC_USD_Quandl.csv'
  #currdate = as.Date("2021-04-06")
  #out_dir = 'out/'
  
  # Create directory for output if it doesnt exist
  dir.create(out_dir, showWarnings = FALSE)
  
  ngrid = 200;
  #bandwidth = 0.08;
  
  print(paste0('bandwidth: ', bandwidth))
  
  XX = read.csv(f)
  XX[,1] = as.Date(XX[,1])
  
  if(nrow(XX) < 100){
    stop('Too few data points!')
  }
  
  #currdate = as.Date(unique(XX[,1]))
  #if(length(currdate) > 1) stop('too many dates')
  
  #for(currdate in unique_dates){
  
  iday = which(XX[,1] == currdate)
  
  day1 = XX[XX[,1] == currdate,] #XX[XX[,1]==XX[iday,1],]; 
  day1 = day1[day1[,2]>0,];
  tau = day1[1,4];
  
  day1.mat = day1[day1[,4]== tau,];
  day1.call = day1.mat[day1.mat[,3]==1,];
  day1.put = day1.mat[day1.mat[,3]==0,];
  
  # compute the moneyness
  day1.call[,9]=day1.call[,5]/day1.call[,7];
  day1.put[,9]=day1.put[,5]/day1.put[,7];
  
  # Filter
  # only out and at the money options
  #day1.call = day1.call[day1.call[,9]>=1,];
  #day1.put = day1.put[day1.put[,9]<=1,];
  
  # put to calls
  put2call = day1.put;
  put2call[,6] = put2call[,6]+ put2call[,7] -  put2call[,5]*exp(- mean(put2call[,8])* tau);
  
  put2call = put2call[order(put2call[,5]),];
  day1.call = day1.call[order(day1.call[,5]),];
  data = rbind(put2call,day1.call);
  
  # Subset:  IV between 0.05 and 2, Tau > 0
  data = data[(data[,2]>0.05) & (data[,2] < 2) & (data[,4] > 0),];
  
  # no - arbitrage condition
  print('test no arbitrage condition')
  #write.table(data, file=paste(name,"_cleaned.txt", sep=""), row.names=F, col.names=F, quote=F)
  
  n = dim(data)[1];
  
  price.median = median(data[,7]);
  print(price.median)
  
  if (exists("util.param")==0) {util.param = c(exp(util.coef[1]), -util.coef[2], cor(log(SPD$SPD), log(mon.grid.scaled))^2);
  } else {util.coef = cbind(util.coef,c(exp(util.coef[1]), -util.coef[2], cor(log(SPD$SPD), log(mon.grid.scaled))^2));}
  
  out = list(price.median)
  # out=p.BS
  return(out)
  
}
