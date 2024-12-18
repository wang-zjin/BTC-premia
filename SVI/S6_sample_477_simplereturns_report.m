





clc,clear

ttm = 27;
[~,~,~]=mkdir("RiskPremia/moneyness/Bitcoin_Premium/"); % Create directory for output, if it doesn't exist

%% P backward returns sample moments 
% Load sample returns
RR_OA = readtable("RiskPremia/moneyness/Bitcoin_Premium/477_sample_return_OA.xlsx");
RR_c0 = readtable("RiskPremia/moneyness/Bitcoin_Premium/477_sample_return_HV.xlsx");
RR_c1 = readtable("RiskPremia/moneyness/Bitcoin_Premium/477_sample_return_LV.xlsx");

% Overall
P_mu_OA_back = mean(RR_OA.return_t_minus_27)*365/ttm;
P_sigma_OA_back = mean(RR_OA.simpleRV)*365/ttm;
% HV
P_mu_c0_back = mean(RR_c0.return_t_minus_27)*365/ttm;
P_sigma_c0_back = mean(RR_c0.simpleRV)*365/ttm;
% LV
P_mu_c1_back = mean(RR_c1.return_t_minus_27)*365/ttm;
P_sigma_c1_back = mean(RR_c1.simpleRV)*365/ttm;
%% Other P density moments
% Overall
P_mu_OA_for = mean(RR_OA.return_t_plus_27)*365/ttm;
P_sigma_OA_for = mean(RR_OA.simpleFV)*365/ttm;
% HV
P_mu_c0_for = mean(RR_c0.return_t_plus_27)*365/ttm;
P_sigma_c0_for = mean(RR_c0.simpleFV)*365/ttm;
% LV
P_mu_c1_for = mean(RR_c1.return_t_plus_27)*365/ttm;
P_sigma_c1_for = mean(RR_c1.simpleFV)*365/ttm;
%% Report
Moments_summary = [P_mu_OA_back, P_mu_c0_back, P_mu_c1_back, P_mu_OA_for, P_mu_c0_for, P_mu_c1_for;
    P_sigma_OA_back, P_sigma_c0_back, P_sigma_c1_back, P_sigma_OA_for, P_sigma_c0_for, P_sigma_c1_for];
info.rnames = strvcat('.','Ann mean','Ann variance');
info.cnames = strvcat('Overall','Cluster 0','Cluster 1','Overall','Cluster 0','Cluster 1');
info.fmt    = '%10.3f';
disp('P moments backward, P moments forward')
mprint(Moments_summary,info)


%% Function
function Moments_summary = density_moments(ret, density, ttm)
Moments = zeros(4,1);
Moments(1,1) = trapz(ret, density.*ret);% 1th moment
Moments(2,1) = trapz(ret, density.*(ret-Moments(1,1)).^2);% 2th central moment
Moments(3,1) = trapz(ret, density.*(ret-Moments(1,1)).^3);% 3th central moment
Moments(4,1) = trapz(ret, density.*(ret-Moments(1,1)).^4);% 4th central moment

Mean = Moments(1,1)*365/ttm;
Variance = Moments(2,1)*365/ttm;
Skewness = Moments(3,1)/Moments(2,1)^1.5;
Kurtosis = Moments(4,1)/Moments(2,1)^2;

Moments_summary = [Mean;Variance;Skewness;Kurtosis];
end

function Moments_summary = sample_moments(returns, ttm)
Moments = zeros(4,1);
Moments(1,1) = mean(returns);% 1th moment
Moments(2,1) = var(returns);% 2th central moment
Moments(3,1) = skewness(returns);% 3th central moment
Moments(4,1) = kurtosis(returns);% 4th central moment

Mean = Moments(1,1)*365/ttm;
Variance = Moments(2,1)*365/ttm;
Skewness = Moments(3,1);
Kurtosis = Moments(4,1);

Moments_summary = [Mean;Variance;Skewness;Kurtosis];
end

function Moments_summary = sample_moments_iqr(returns, ttm)
Moments = zeros(4,1);
Moments(1,1) = mean(returns);% 1th moment
Moments(2,1) = iqr(returns)^2;% 2th central moment
Moments(3,1) = mean((returns-Moments(1,1)).^3);% 3th central moment
Moments(4,1) = mean((returns-Moments(1,1)).^4);% 4th central moment

Mean = Moments(1,1)*365/ttm;
Variance = Moments(2,1)*365/ttm;
Skewness = Moments(3,1)/Moments(2,1)^1.5;
Kurtosis = Moments(4,1)/Moments(2,1)^2;

Moments_summary = [Mean;Variance;Skewness;Kurtosis];
end
















