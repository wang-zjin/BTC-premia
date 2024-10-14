


% Bitcoin Premium (BP) 
% This script calculates the Bitcoin Premium using Kernel Density Estimation (ePDF) with different bandwidths.
% It processes data for various Time to Maturity (TTM) values.
%% load data
clear,clc
addpath("m_Files_Color")                  % Add directory to MATLAB's search path for custom color files
addpath("m_Files_Color/colormap")         % Add subdirectory for colormap files
[~,~,~]=mkdir("Bitcoin_Premium/2_1_X_13");  % Create directory for output, if it doesn't exist
% daily_price = readtable("data/BTC_USD_Quandl_2015_2022.csv"); % Reading daily price data

opts = detectImportOptions("data/BTC_USD_Quandl_2011_2023.csv", "Delimiter",",");
opts = setvartype(opts,1,"char");
daily_price = readtable("data/BTC_USD_Quandl_2011_2023.csv",opts);
daily_price.Date = datetime(daily_price.Date,"Format","uuuu-MM-dd HH:mm:ss","InputFormat","uuuu/MM/dd");
daily_price = sortrows(daily_price,"Date");
daily_price = daily_price(daily_price.Date <= datetime("2022-12-31"),:);
daily_price = daily_price(daily_price.Date >= datetime("2014-01-01"),:);

Summary_return_fullsample = zeros(1,7);
%% Load cluster
ttm = 27;

% Reading and processing common dates data
fid = fopen('Clustering/Clustering_0_3_0_multiQ_QfromIV_R99/common dates.txt', 'r');
file_content = fscanf(fid, '%c');
fclose(fid);
% String manipulations to format the dates correctly
Common_dates = split(strrep(strrep(strrep(strrep(file_content, '[', ''), ']', ''), ' ', ''), '''', ''), ',');
Common_dates = string(Common_dates);

% Reading implied volatility (IV) matrix and filtering dates
IV_matrx = readtable(strcat("data/IV/interpolated IVs R2 0.99/merged/interpolated_IVmatrix_ttm",num2str(ttm),"_R99_merged.csv"),"VariableNamingRule","preserve","ReadVariableNames",true);
Dates_ttm = string(IV_matrx.Properties.VariableNames(2:end)');
ind = ismember(Dates_ttm,Common_dates);
dates_list = datetime(string(IV_matrx.Properties.VariableNames(2:end)'), "InputFormat","yyyyMMdd","Format","yyyy-MM-dd");
dates_list = dates_list(ind);
dates = string(dates_list);

% Define clusters based on selected dates
dates_cluster = dates;
dates_Q =cell(1,2);
dates_Q{1,1} = dates_cluster([0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1,...
    0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
    0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0,...
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0,...
    0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1,...
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,...
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
    0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0,...
    0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1]==1);
dates_Q{1,2} = dates_cluster([0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1,...
    0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
    0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0,...
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0,...
    0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1,...
    1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0,...
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
    0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0,...
    0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
    1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1]==0);

%% TTM 27
ttm = 27;

ret = (-1:0.01:1)';
% Calculation of Q-density and returns (forward and backward)
% Q-density of simple return
Q_average_simple = Q_density_average_ttm27([dates_Q{1,1};dates_Q{1,2}],ret);
% forward returns
return_overall_forward = Return_overall_forward(daily_price,dates_Q,ttm);
% backward return
return_overall_backward = Return_overall_backward(daily_price,dates_Q,ttm);
% forward and backward return
return_overall = Simple_return_fullsample_overlapping(daily_price,ttm);
return_overall = rescale_shift_return_exp(return_overall,0,0,2.560,2.560,ttm);
% This sqrt(0.57)=0.7550 comes from the sample mean of realized variance of
% dates overall

Summary_return_fullsample(1,:) = [mean(return_overall),std(return_overall),min(return_overall),max(return_overall),prctile(return_overall,25),prctile(return_overall,75),numel(return_overall)];

% ePDF and Bitcoin Premium calculation for different bandwidths
% Loop through various bandwidths to calculate and store BP
BP_average_simple_different_NB = [];
VRP_average_simple_different_NB = [];
P_simple_different_NB = [];
for n_bin = 6:15
    f =P_epdf_overall_ttm27(return_overall,ret,n_bin);
    % Bitcoin Premium

%     f_simple=interp1(exp(ret)-1,f./exp(ret),ret,'linear','extrap');
    f_simple=f;
    f_simple(f_simple<0)=0;
    BP_DCA_simple = BP_DCA_OA(ret,f_simple,Q_average_simple);
    VRP_average_simple = VRP_overall(ret,f_simple,Q_average_simple,0.582/365*27,0.011/365*27);

%     trapz(ret,f_simple)

    BP_average_simple_different_NB = [BP_average_simple_different_NB,BP_DCA_simple];
    VRP_average_simple_different_NB = [VRP_average_simple_different_NB,VRP_average_simple];
    P_simple_different_NB = [P_simple_different_NB,f_simple];
end

% Write results to a table
outtable = array2table([ret, BP_average_simple_different_NB], ...
    'VariableNames',["Returns","BP_NB6","BP_NB7","BP_NB8","BP_NB9","BP_NB10","BP_NB11","BP_NB12","BP_NB13","BP_NB14","BP_NB15"]);
writetable(outtable, "Bitcoin_Premium/2_1_X_13/BP_DCA_ePDF_3287_forward_onlyVR_OA_differentNB_ttm27.xlsx")
outtable = array2table([ret, VRP_average_simple_different_NB], ...
    'VariableNames',["Returns","VRP_NB6","VRP_NB7","VRP_NB8","VRP_NB9","VRP_NB10","VRP_NB11","VRP_NB12","VRP_NB13","VRP_NB14","VRP_NB15"]);
writetable(outtable, "Bitcoin_Premium/2_1_X_13/VRP_ePDF_3287_forward_onlyVR_OA_differentNB_ttm27.xlsx")
outtable = array2table([ret, Q_average_simple, P_simple_different_NB], ...
    'VariableNames',["Returns","Q_overall","P_NB6","P_NB7","P_NB8","P_NB9","P_NB10","P_NB11","P_NB12","P_NB13","P_NB14","P_NB15"]);
writetable(outtable, "Bitcoin_Premium/2_1_X_13/Q_P_ePDF_3287_forward_onlyVR_OA_differentNB_ttm27.xlsx")
%% print summary statistics of return full sample
clear info;
info.rnames = strvcat('.','TTM 27');
info.cnames = strvcat('Mean','Std.','Min','Max','25% percentile','75% percentile','Obs.');
info.fmt    = '%10.4f';
mprint(Summary_return_fullsample,info)
%% functions
% Below are the custom functions used for various calculations like scaling PDF, calculating BP, and calculating forward/backward returns.
function f = scale_PDF(ret,f)
f=f./trapz(ret,f);
end


function BP_average_simple = BP_overall(ret,f_simple,Q_average_simple)
BP_average_simple=zeros(size(Q_average_simple));
for i=2:length(ret)
    BP_average_simple(i)          = trapz(ret(1:i),(f_simple(1:i) -Q_average_simple(1:i)).*ret(1:i));
end
% disp(BP_average_simple_ttm27(end))
BP_average_simple          = BP_average_simple/BP_average_simple(end);
end


function return_overall_forward = Return_overall_forward(daily_price,dates_Q,ttm)
return_cluster0_forward = zeros(size(dates_Q{1,1}));
return_cluster1_forward = zeros(size(dates_Q{1,2}));
for i=1:numel(return_cluster0_forward)
    sp1=daily_price;
    sp1(datenum(sp1.Date)<datenum(dates_Q{1,1}(i),"yyyy-mm-dd") | datenum(sp1.Date)>datenum(dates_Q{1,1}(i),"yyyy-mm-dd")+ttm,:)=[];
    return_cluster0_forward(i)=log(sp1.Adj_Close(1)/sp1.Adj_Close(end));
end
for i=1:numel(return_cluster1_forward)
    sp1=daily_price;
    sp1(datenum(sp1.Date)<datenum(dates_Q{1,2}(i),"yyyy-mm-dd") | datenum(sp1.Date)>datenum(dates_Q{1,2}(i),"yyyy-mm-dd")+ttm,:)=[];
    return_cluster1_forward(i)=log(sp1.Adj_Close(1)/sp1.Adj_Close(end));
end
return_overall_forward = [return_cluster0_forward;return_cluster1_forward];
end


function return_overall_backward = Return_overall_backward(daily_price,dates_Q,ttm)
return_cluster0_backward = zeros(size(dates_Q{1,1}));
return_cluster1_backward = zeros(size(dates_Q{1,2}));
for i=1:numel(return_cluster0_backward)
    sp1=daily_price;
    sp1(datenum(sp1.Date)<datenum(dates_Q{1,1}(i),"yyyy-mm-dd")-ttm | datenum(sp1.Date)>datenum(dates_Q{1,1}(i),"yyyy-mm-dd"),:)=[];
    return_cluster0_backward(i)=log(sp1.Adj_Close(1)/sp1.Adj_Close(end));
end
for i=1:numel(return_cluster1_backward)
    sp1=daily_price;
    sp1(datenum(sp1.Date)<datenum(dates_Q{1,2}(i),"yyyy-mm-dd")-ttm | datenum(sp1.Date)>datenum(dates_Q{1,2}(i),"yyyy-mm-dd"),:)=[];
    return_cluster1_backward(i)=log(sp1.Adj_Close(1)/sp1.Adj_Close(end));
end
return_overall_backward = [return_cluster0_backward;return_cluster1_backward];
end


function Q_average_simple = Q_density_average_ttm27(dates_Q,ret)
% Q-density of simple return
Q_simple = zeros(numel(-1:0.01:1),numel(dates_Q));
for i=1:numel(dates_Q)
    a = strcat("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Output/Q_density_logreturn_",dates_Q(i),".csv");
    data_q = readtable(a);
    Q_simple(:,i)=interp1(exp(data_q.Return)-1,data_q.Q_density./exp(data_q.Return),-1:0.01:1,'linear','extrap');
end
Q_simple(Q_simple<0)=0;
Q_average_simple = mean(Q_simple,2);
Q_average_simple= scale_PDF(ret,Q_average_simple);
end

function Q_average_simple = Q_density_average_ttm14(dates_Q,ret)
% Q-density of simple return
Q_simple = zeros(numel(-1:0.01:1),numel(dates_Q));
for i=1:numel(dates_Q)
    a = strcat("Q_Tail_Fit/All_Tail_2_9_2_1_Q_from_IV/Output/Q_density_logreturn_",dates_Q(i),".csv");
    data_q = readtable(a);
    Q_simple(:,i)=interp1(exp(data_q.Return)-1,data_q.Q_density./exp(data_q.Return),-1:0.01:1,'linear','extrap');
end
Q_simple(Q_simple<0)=0;
Q_average_simple = mean(Q_simple,2);
Q_average_simple= scale_PDF(ret,Q_average_simple);
end

function Q_average_simple = Q_density_average_ttm9(dates_Q,ret)

% Q-density of simple return
Q_simple = zeros(numel(-1:0.01:1),numel(dates_Q));
for i=1:numel(dates_Q)
    a = strcat("Q_Tail_Fit/All_Tail_2_9_1_1_Q_from_IV/Output/Q_density_logreturn_",dates_Q(i),".csv");
    data_q = readtable(a);
    Q_simple(:,i)=interp1(exp(data_q.Return)-1,data_q.Q_density./exp(data_q.Return),-1:0.01:1,'linear','extrap');
end
Q_simple(Q_simple<0)=0;
Q_average_simple = mean(Q_simple,2);
Q_average_simple= scale_PDF(ret,Q_average_simple);
end

function Q_average_simple = Q_density_average_ttm5(dates_Q,ret)

% Q-density of simple return
Q_simple = zeros(numel(-1:0.01:1),numel(dates_Q));
for i=1:numel(dates_Q)
    a = strcat("Q_Tail_Fit/All_Tail_2_9_0_1_Q_from_IV/Output/Q_density_logreturn_",dates_Q(i),".csv");
    data_q = readtable(a);
    Q_simple(:,i)=interp1(exp(data_q.Return)-1,data_q.Q_density./exp(data_q.Return),-1:0.01:1,'linear','extrap');
end
Q_simple(Q_simple<0)=0;
Q_average_simple = mean(Q_simple,2);
Q_average_simple= scale_PDF(ret,Q_average_simple);
end


function return_overall = Return_fullsample_overlapping(daily_price,ttm)

return_overall = log(daily_price.Adj_Close(1:end-ttm)./daily_price.Adj_Close((1+ttm):end));
end


function return_overall = Return_fullsample_nonoverlapping(daily_price,ttm)

% Flip the table to make the earliest date come first
daily_price = flipud(daily_price);
% Initialize an array to store the returns
return_overall = [];
% Calculate non-overlapping 5-day returns
for i = 1:ttm:(height(daily_price) - ttm)
    initialPrice = daily_price.Adj_Close(i);
    finalPrice = daily_price.Adj_Close(i + ttm);
    returns = log(finalPrice / initialPrice);
    return_overall = [returns; return_overall];
end
end



function [f,xi]=P_epdf_overall_ttm5(return_overall,ret,n_bin)
if nargin < 2
    ret = -1:0.01:1;
end
[f,xi] = computePDFusingECDF_10th_poly(return_overall,n_bin);
% figure;
% plot(xi,f,'LineWidth',1);
% figure;
% plot(xi(F>=0.1 & F<=0.9,:),f(F>=0.1 & F<=0.9,:),'LineWidth',1);hold on
% plot(xi(F>=0.1 & F<=0.9,:),F(F>=0.1 & F<=0.9,:),'LineWidth',1);hold off
f_cut=f;
X_cut=xi;
% disp(trapz(X_cut,f_cut))
% figure;
% plot(X_cut,f_cut,'LineWidth',1);hold on
% plot(X_cut,F_cut,'LineWidth',1);hold off
[Q_rt, rt, details] = GEV_tail(f_cut,X_cut, ...
    'Initial_paras_left',[-0.18,0.1, 0.02], ...
    'Initial_paras_right', [-0.18,0.1, -0.1],...
    'Upper_bound_paras_left', [0.4, 0.11,  0.5], ...
    'Upper_bound_paras_right', [0.4, 0.11, 0.5], ...
    'Lower_bound_paras_left', [-0.5, 0.05, -0.5], ...
    'Lower_bound_paras_right', [-0.5, 0.05, -0.5]);
% % figure;
% % plot(rt,Q_rt)
% probability_matrix = zeros(3,1);
% probability_matrix(1,1)=trapz(details.return_range(details.return_range<details.raw_rt(1)),details.q_l(details.return_range<details.raw_rt(1)));
% probability_matrix(2,1)=trapz(details.raw_rt,details.raw_Qrt);
% probability_matrix(3,1)=trapz(details.return_range(details.return_range>details.raw_rt(end)),details.q_r(details.return_range>details.raw_rt(end)));
% % 
% disp((probability_matrix(:,1)))
% disp(sum(probability_matrix(:,1)))
% % 
% disp([details.solution_l, details.solution_r])
% % disp([details.target_l(:,1); details.target_r(:,1)])
% figure;
% plot(details.raw_rt, details.raw_Qrt)
% xlim([min(rt), max(rt)])
% hold on
% plot([details.target_l(:,1); details.target_r(:,1)], [details.target_l(:,2); details.target_r(:,2)], 'xr')
% plot(details.return_range,details.q_l,'-.','Color',[0.2235, 0.0588, 0.4314])
% plot(details.return_range,details.q_r,'--','Color',[0.9922, 0.6314, 0.4314])
% hold off
% legend({'Q Rookley','target points','left tail','right tail'})
% ylim([0, 9])
% xticks(min(rt):0.2:max(rt))
xi = ret;
f = interp1(rt,Q_rt,ret);
f=f./trapz(xi,f);
end


function [f,xi]=P_epdf_overall_ttm9(return_overall,ret,n_bin)
if nargin < 2
    ret = -1:0.01:1;
end
[f,xi] = computePDFusingECDF_10th_poly(return_overall,n_bin);
% figure;
% plot(xi,f,'LineWidth',1);
% % figure;
% plot(xi(F>=0.1 & F<=0.9,:),f(F>=0.1 & F<=0.9,:),'LineWidth',1);hold on
% plot(xi(F>=0.1 & F<=0.9,:),F(F>=0.1 & F<=0.9,:),'LineWidth',1);hold off
f_cut=f;
X_cut=xi;
% disp(trapz(X_cut,f_cut))
% figure;
% plot(X_cut,f_cut,'LineWidth',1);hold on
% plot(X_cut,F_cut,'LineWidth',1);hold off
[Q_rt, rt, details] = GEV_tail(f_cut,X_cut, ...
    'Initial_paras_left',[-0.18,0.1, 0.02], ...
    'Initial_paras_right', [-0.18,0.1, -0.1],...
    'Upper_bound_paras_left', [0.4, 0.11,  0.5], ...
    'Upper_bound_paras_right', [0.4, 0.11, 0.5], ...
    'Lower_bound_paras_left', [-0.5, 0.05, -0.5], ...
    'Lower_bound_paras_right', [-0.5, 0.05, -0.5]);
% % figure;
% % plot(rt,Q_rt)
% probability_matrix = zeros(3,1);
% probability_matrix(1,1)=trapz(details.return_range(details.return_range<details.raw_rt(1)),details.q_l(details.return_range<details.raw_rt(1)));
% probability_matrix(2,1)=trapz(details.raw_rt,details.raw_Qrt);
% probability_matrix(3,1)=trapz(details.return_range(details.return_range>details.raw_rt(end)),details.q_r(details.return_range>details.raw_rt(end)));
% 
% disp((probability_matrix(:,1)))
% disp(sum(probability_matrix(:,1)))
% % 
% disp([details.solution_l, details.solution_r])
% % disp([details.target_l(:,1); details.target_r(:,1)])
% figure;
% plot(details.raw_rt, details.raw_Qrt)
% xlim([min(rt), max(rt)])
% hold on
% plot([details.target_l(:,1); details.target_r(:,1)], [details.target_l(:,2); details.target_r(:,2)], 'xr')
% plot(details.return_range,details.q_l,'-.','Color',[0.2235, 0.0588, 0.4314])
% plot(details.return_range,details.q_r,'--','Color',[0.9922, 0.6314, 0.4314])
% hold off
% legend({'Q Rookley','target points','left tail','right tail'})
% ylim([0, 9])
% xticks(min(rt):0.2:max(rt))
xi = ret;
f = interp1(rt,Q_rt,ret);
f=f./trapz(xi,f);
end


function [f,xi]=P_epdf_overall_ttm14(return_overall,ret,n_bin)
if nargin < 2
    ret = -1:0.01:1;
end
[f,xi] = computePDFusingECDF_10th_poly(return_overall,n_bin);
% figure;
% plot(xi,f,'LineWidth',1);
% figure;
% plot(xi(F>=0.1 & F<=0.9,:),f(F>=0.1 & F<=0.9,:),'LineWidth',1);hold on
% plot(xi(F>=0.1 & F<=0.9,:),F(F>=0.1 & F<=0.9,:),'LineWidth',1);hold off
f_cut=f;
X_cut=xi;
% disp(trapz(X_cut,f_cut))
% figure;
% plot(X_cut,f_cut,'LineWidth',1);hold on
% plot(X_cut,F_cut,'LineWidth',1);hold off
[Q_rt, rt, details] = GEV_tail(f_cut,X_cut, ...
    'Initial_paras_left',[-0.18,0.1, 0.02], ...
    'Initial_paras_right', [-0.18,0.1, -0.1],...
    'Upper_bound_paras_left', [0.4, 0.11,  0.5], ...
    'Upper_bound_paras_right', [0.4, 0.11, 0.5], ...
    'Lower_bound_paras_left', [-0.5, 0.05, -0.5], ...
    'Lower_bound_paras_right', [-0.5, 0.05, -0.5]);
% % figure;
% % plot(rt,Q_rt)
% probability_matrix = zeros(3,1);
% probability_matrix(1,1)=trapz(details.return_range(details.return_range<details.raw_rt(1)),details.q_l(details.return_range<details.raw_rt(1)));
% probability_matrix(2,1)=trapz(details.raw_rt,details.raw_Qrt);
% probability_matrix(3,1)=trapz(details.return_range(details.return_range>details.raw_rt(end)),details.q_r(details.return_range>details.raw_rt(end)));
% disp((probability_matrix(:,1)))
% disp(sum(probability_matrix(:,1)))
% disp([details.solution_l, details.solution_r])
% % disp([details.target_l(:,1); details.target_r(:,1)])
% figure;
% plot(details.raw_rt, details.raw_Qrt)
% xlim([min(rt), max(rt)])
% hold on
% plot([details.target_l(:,1); details.target_r(:,1)], [details.target_l(:,2); details.target_r(:,2)], 'xr')
% plot(details.return_range,details.q_l,'-.','Color',[0.2235, 0.0588, 0.4314])
% plot(details.return_range,details.q_r,'--','Color',[0.9922, 0.6314, 0.4314])
% hold off
% legend({'Q Rookley','target points','left tail','right tail'})
% ylim([0, 9])
% xticks(min(rt):0.2:max(rt))
xi = ret;
f = interp1(rt,Q_rt,ret);
f=f./trapz(xi,f);
end


function [f,xi]=P_epdf_overall_ttm27(return_overall,ret,n_bin)
if nargin < 2
    ret = -1:0.01:1;
end
[f,xi] = computePDFusingECDF_10th_poly(return_overall,n_bin);
% figure;
% plot(xi,f,'LineWidth',1);
% figure;
% plot(xi(F>=0.1 & F<=0.9,:),f(F>=0.1 & F<=0.9,:),'LineWidth',1);hold on
% plot(xi(F>=0.1 & F<=0.9,:),F(F>=0.1 & F<=0.9,:),'LineWidth',1);hold off
f_cut=f;
X_cut=xi;
% disp(trapz(X_cut,f_cut))
% figure;
% plot(X_cut,f_cut,'LineWidth',1);hold on
% plot(X_cut,F_cut,'LineWidth',1);hold off
[Q_rt, rt, details] = GEV_tail(f_cut,X_cut, ...
    'Initial_paras_left',[-0.18,0.1, 0.02], ...
    'Initial_paras_right', [-0.18,0.1, -0.1],...
    'Upper_bound_paras_left', [0.4, 0.11,  0.5], ...
    'Upper_bound_paras_right', [0.4, 0.11, 0.5], ...
    'Lower_bound_paras_left', [-0.5, 0.05, -0.5], ...
    'Lower_bound_paras_right', [-0.5, 0.05, -0.5]);
% % figure;
% % plot(rt,Q_rt)
% probability_matrix = zeros(3,1);
% probability_matrix(1,1)=trapz(details.return_range(details.return_range<details.raw_rt(1)),details.q_l(details.return_range<details.raw_rt(1)));
% probability_matrix(2,1)=trapz(details.raw_rt,details.raw_Qrt);
% probability_matrix(3,1)=trapz(details.return_range(details.return_range>details.raw_rt(end)),details.q_r(details.return_range>details.raw_rt(end)));
% 
% disp((probability_matrix(:,1)))
% disp(sum(probability_matrix(:,1)))
% % 
% disp([details.solution_l, details.solution_r])
% % disp([details.target_l(:,1); details.target_r(:,1)])
% figure;
% plot(details.raw_rt, details.raw_Qrt)
% xlim([min(rt), max(rt)])
% hold on
% plot([details.target_l(:,1); details.target_r(:,1)], [details.target_l(:,2); details.target_r(:,2)], 'xr')
% plot(details.return_range,details.q_l,'-.','Color',[0.2235, 0.0588, 0.4314])
% plot(details.return_range,details.q_r,'--','Color',[0.9922, 0.6314, 0.4314])
% hold off
% legend({'Q Rookley','target points','left tail','right tail'})
% ylim([0, 9])
% xticks(min(rt):0.2:max(rt))
xi = ret;
f = interp1(rt,Q_rt,ret);
f=f./trapz(xi,f);
end

function [y_fit, x_fit] = computePDFusingECDF_10th_poly(data,n_bin)
if nargin<2
    n_bin = 10;
end
% Determine the 10th and 90th percentiles
p10 = prctile(data, 10);
p90 = prctile(data, 90);
edges = linspace(min(data), max(data), n_bin); % Adjust the number of bins
[n, x] = hist(data, edges);                    % Get histogram counts (n) and bin centers (x)
n = n / trapz(x, n);                           % Normalize to make it a PDF
X_cut = [p10,x(x>p10 & x<p90),p90];
f_cut = interp1(x,n,X_cut);
% Fit a tenth-order polynomial
p = polyfit(X_cut, f_cut, 10);
% Generate a smooth curve for the fitted polynomial
x_fit = linspace(p10, p90, 1000);
y_fit = polyval(p, x_fit);
y_fit = polyval(p, x_fit)/trapz(x_fit,y_fit)*0.8;
% disp(trapz(x_fit,y_fit))
end


function [Q_rt, rt, details] = GEV_tail(q_rt, r_t, varargin)
parseObj = inputParser;
functionName='Q_tail_est_para_Figlewski';
addParameter(parseObj,'Initial_paras_left', [0.2,0.13,0.03],@(x)validateattributes(x,{'numeric'},{'size',[1,3]},functionName));
addParameter(parseObj,'Initial_paras_right',[0.2,0.13,0.03],@(x)validateattributes(x,{'numeric'},{'size',[1,3]},functionName));
addParameter(parseObj,'Upper_bound_paras_left', [0.5, 0.20,  0.5],@(x)validateattributes(x,{'numeric'},{'size',[1,3]},functionName));
addParameter(parseObj,'Lower_bound_paras_left',[-0.05, 0.01, -0.5],@(x)validateattributes(x,{'numeric'},{'size',[1,3]},functionName));
addParameter(parseObj,'Upper_bound_paras_right', [0.5, 0.25, 0.5],@(x)validateattributes(x,{'numeric'},{'size',[1,3]},functionName));
addParameter(parseObj,'Lower_bound_paras_right',[-0.05, 0.01, -0.5],@(x)validateattributes(x,{'numeric'},{'size',[1,3]},functionName));
addParameter(parseObj,'IR',0,@(x)validateattributes(x,{'numeric'},{'size',[1,1]},functionName));
parse(parseObj,varargin{:});
Initial_paras_left = parseObj.Results.Initial_paras_left;
Initial_paras_right= parseObj.Results.Initial_paras_right;
ub_right = parseObj.Results.Upper_bound_paras_right;
lb_right = parseObj.Results.Lower_bound_paras_right;
ub_left = parseObj.Results.Upper_bound_paras_left;
lb_left = parseObj.Results.Lower_bound_paras_left;
rng("default")
paras = zeros(2,3);
%%%%%% right tail & left tail %%%%%
if max(r_t)<1
    alpha1 = max(r_t);
    target_r=[alpha1-0.01,alpha1];
else
    error('Maximal return excess 1.')
end
rnd_r = spline(r_t, q_rt, target_r);
cdf_r = 0.9;
if min(r_t)>-1
    alpha1 = min(r_t);
    target_l=[alpha1,alpha1+0.01];
else
    error('Manimal return excess -1.')
end
rnd_l = spline(r_t, q_rt, target_l);
cdf_l = 0.1;
% return
ret1 = -1:0.001:round(target_l(1),3);
ret2 = round(target_l(1),3)+0.001:round(target_r(2),3)-0.001;
ret3 = round(target_r(2),3):0.001:1;
ret = [ret1, ret2, ret3];
% optimization
A = []; b = [];
Aeq = []; beq = [];
lb = [lb_left,lb_right];
ub = [ub_left,ub_right];
x0=[Initial_paras_left,Initial_paras_right];
FitnessFunction = @(x) sum([(gevpdf(-target_l(1),x(1),x(2),x(3)) - rnd_l(1))^2, ...
    (gevpdf(-target_l(2),x(1),x(2),x(3)) - rnd_l(2))^2/10,...
    (1-gevcdf(-target_l(1),x(1),x(2),x(3)) - cdf_l)^2,... 
    (gevpdf(target_r(1),x(4),x(5),x(6)) - rnd_r(1))^2/10, ...
    (gevpdf(target_r(2),x(4),x(5),x(6)) - rnd_r(2))^2, ...
    (gevcdf(target_r(2),x(4),x(5),x(6)) - cdf_r)^2]);
options = optimoptions("fmincon",...
    "Algorithm","interior-point",...
    "EnableFeasibilityMode",true,...
    "SubproblemAlgorithm","cg");
[x,fval] = fmincon(FitnessFunction,x0,A,b,Aeq,beq,lb,ub,@tail_constraint,options);
fval_max=max(fval,[],2);
solution=x(find(fval_max==min(fval_max),1),:);
value=fval(find(fval_max==min(fval_max),1),:);
%%%%%% output %%%%%
errors=value;
disp(['Error is',num2str(errors)])

paras(1,:)=solution(1:3);
paras(2,:)=solution(4:6);

solution_l = paras(1,:);
solution_r= paras(2,:);

return_range = -1:0.001:1;
q_r = gevpdf((round(target_r(2),3)+0.001):0.001:max(return_range), solution_r(1,1),solution_r(1,2),solution_r(1,3));
q_l = gevpdf(-min(return_range):-0.001:(-round(target_l(1),3)+0.001), solution_l(1,1),solution_l(1,2),solution_l(1,3));

rt=[min(return_range):0.001:(round(target_l(1),3)-0.001), ...
    round(target_l(1),3):0.001:round(target_r(2),3), ...
    (round(target_r(2),3)+0.001):0.001:max(return_range)];
Q_rt=[q_l,spline(r_t,q_rt,round(target_l(1),3):0.001:round(target_r(2),3)),q_r];

details.return_range = return_range;

details.raw_rt = round(target_l(1),3):0.001:round(target_r(2),3);
details.raw_Qrt = spline(r_t,q_rt,round(target_l(1),3):0.001:round(target_r(2),3));

details.q_r = gevpdf(return_range,solution_r(1,1),solution_r(1,2),solution_r(1,3));
details.q_l = gevpdf(-return_range,solution_l(1,1),solution_l(1,2),solution_l(1,3));

details.target_r = [target_r', rnd_r'];
details.target_l = [target_l', rnd_l'];

details.solution_l = paras(1,:);
details.solution_r= paras(2,:);

    function [c,ceq] = tail_constraint(x)
        Q1 = gevpdf(-ret1,x(1),x(2),x(3));
        Q2 = interp1(r_t,q_rt,ret2);
        Q3 = gevpdf(ret3,x(4),x(5),x(6));
        Q = [Q1, Q2, Q3];
        c(1) = 1 - gevcdf(-target_l(1),x(1),x(2),x(3)) - cdf_l - 0.01;
        c(2) = -0.01 - (1 - gevcdf(-target_l(1),x(1),x(2),x(3)) - cdf_l);
        c(3) = gevcdf(target_r(2),x(4),x(5),x(6)) - cdf_r - 0.01;
        c(4) = -0.01 - (gevcdf(target_r(2),x(4),x(5),x(6)) - cdf_r);
        ceq(1) = gevpdf(-target_l(1),x(1),x(2),x(3))-rnd_l(1);   % Compute nonlinear equalities at x.
        ceq(2) = gevpdf(target_r(2),x(4),x(5),x(6))-rnd_r(2);   % Compute nonlinear equalities at x.
    end
end


function returns = rescale_shift_return_exp(returns,return_overall,return_cluster,variance_overall,variance_cluster,ttm)

return_overall = return_overall*ttm/365;
return_cluster = return_cluster*ttm/365;
returns = returns - return_overall;
returns = returns*( sqrt(variance_cluster) / sqrt(variance_overall) );
returns = returns + return_cluster;
end

function return_overall = Simple_return_fullsample_overlapping(daily_price,ttm)

daily_price = sortrows(daily_price,"Date");
return_overall = (daily_price.Adj_Close((1+ttm):end)-daily_price.Adj_Close(1:end-ttm))./daily_price.Adj_Close(1:end-ttm);
end

function VRP_average_simple = VRP_overall(ret,f_simple,Q_average_simple,E_P,E_Q)
VRP_average_simple=zeros(size(Q_average_simple));
for i=2:length(ret)
    VRP_average_simple(i)          = trapz(ret(1:i),Q_average_simple(1:i).*( ret(1:i) - E_Q).^2 - f_simple(1:i).*(ret(1:i) - E_P).^2);
end
% disp(BP_average_simple_ttm27(end))
% VRP_average_simple          = VRP_average_simple/VRP_average_simple(end);
end

function BP_OA = BP_DCA_OA(ret,p_OA,q_OA)
BP_OA=zeros(size(q_OA));
for i=2:length(ret)
    BP_OA(i)          = trapz(ret(1:i),(p_OA(1:i) -q_OA(1:i)).*ret(1:i));
end
% disp(BP_average_simple_ttm27(end))
BP_OA          = BP_OA/BP_OA(end);
end

function BP_cluster = BP_cluster(ret,p_OA,q_OA,p_cluster,q_cluster,N_OA,N_cluster)
BP_OA=zeros(size(q_OA));
BP_cluster=zeros(size(q_cluster));
for i=2:length(ret)
    BP_OA(i)          = trapz(ret(1:i),(p_OA(1:i) -q_OA(1:i)).*ret(1:i));
    BP_cluster(i)     = trapz(ret(1:i),(p_cluster(1:i) -q_cluster(1:i)).*ret(1:i));
end
% disp(BP_average_simple_ttm27(end))
w = N_cluster/N_OA;
BP_cluster          = w*BP_cluster/BP_OA(end);
end