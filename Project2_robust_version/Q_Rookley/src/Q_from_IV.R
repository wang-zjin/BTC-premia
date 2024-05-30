# we use modify the formula of Q
# setwd(wd)

# output Q-density of log return, P-density of log return, EPK of log return

source("Q_Rookley/src/EPK_library.R")

estimate_Q_from_IV = function(logret, sigmas_r, dsigmadr, d2sigmadr2, rf, tau, out_dir){
  
  # sigma = sigma(r)
  # sigma1 = dsigma/dr
  # sigma2 = d^2sigma/dr^2
  # r = log(m), r:logret, m:moneyness
  # sigma(r) = signa(log(m)) = sigma*(m)
  # dsigma*/dm = dsigma/dr * 1/m
  # d^2sigma*/dm^2 = 1/m^2 * [d^2sigma/dr^2 - (dsigma/dr)]
  
  
  # Create directory for output if it doesnt exist
  # print(out_dir)
  dir.create(out_dir, showWarnings = TRUE)
  
  ## logreturn and moneyness 
  mon.grid.scaled =  exp(logret)
  sigmas = sigmas_r
  sigmas1 = dsigmadr / mon.grid.scaled
  sigmas2 = 1/mon.grid.scaled^2 * (d2sigmadr2 - dsigmadr)
  
  
  
  #### applying rookley
  
  fder = rookley(mon.grid.scaled, sigmas, sigmas1, sigmas2, rf, tau);
  
  #### final computations
  
  d2fdX2 = fder[,3];
  
  #### SPD and CDF
  SPD = new.env();
  SPD$SPD_Moneyness = exp(rf*tau) * d2fdX2  ;
  SPD$SPD_return = exp(rf*tau) * d2fdX2 * mon.grid.scaled;
  SPD=as.list(SPD);
  
  CDF = new.env()
  CDF$CDF_Moneyness = exp(rf*tau) * fder[,2]+1
  CDF$CDF_return = CDF$CDF_Moneyness
  
  
  #### Output
  out = list(mon.grid.scaled,
             SPD$SPD_Moneyness,
             log(mon.grid.scaled),
             SPD$SPD_return,
             sigmas,
             CDF$CDF_Moneyness,
             CDF$CDF_return,
             sigmas1,
             sigmas2)
  # out=p.BS
  return(out)
  
}
