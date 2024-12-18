







clc,clear

ttm = 27;
[~,~,~]=mkdir("RiskPremia/moneyness/Bitcoin_Premium"); % Create directory for output, if it doesn't exist

%% Full-sample returns
% daily_price = readtable("data/BTC_USD_Quandl_2015_2022.csv");

opts = detectImportOptions("Data/BTC_USD_Quandl_2011_2023.csv", "Delimiter",",");
opts = setvartype(opts,1,"char");
daily_price = readtable("Data/BTC_USD_Quandl_2011_2023.csv",opts);
daily_price.Date = datetime(daily_price.Date,"Format","uuuu-MM-dd HH:mm:ss","InputFormat","uuuu/MM/dd");
daily_price = sortrows(daily_price,"Date");
% daily_price = daily_price(daily_price.Date <= datetime("2022-12-31"),:);
daily_price = daily_price(daily_price.Date >= datetime("2014-01-01"),:);

daily_price = sortrows(daily_price,"Date");
daily_price.Date = datetime(daily_price.Date,"Format","uuuu-MM-dd");

% 27-day realized returns
S_t_plus_ttm = daily_price.Adj_Close((1+ttm):end);
S_t = daily_price.Adj_Close(1:end-ttm);
% daily_price.return_t_minus_27 = [nan(27,1);log(S_t_plus_ttm./S_t)];
daily_price.return_t_minus_27 = [nan(27,1);(S_t_plus_ttm-S_t)./S_t];

% 27-day future returns
% daily_price.return_t_plus_27 = [log(S_t_plus_ttm./S_t);nan(27,1)];
daily_price.return_t_plus_27 = [(S_t_plus_ttm-S_t)./S_t;nan(27,1)];

% 1-day realized returns
S_t_plus_1 = daily_price.Adj_Close((1+1):end);
S_t = daily_price.Adj_Close(1:end-1);
% daily_price.return_t_minus_1 = [nan(1,1);log(S_t_plus_1./S_t)];
daily_price.return_t_minus_1 = [nan(1,1);(S_t_plus_1-S_t)./S_t];

% 1-day future returns
% daily_price.return_t_plus_1 = [log(S_t_plus_1./S_t);nan(27,1)];
daily_price.return_t_plus_1 = [(S_t_plus_1-S_t)./S_t;nan(1,1)];

% Get rid of NaN
daily_price = rmmissing(daily_price);
%% Cluster dates
% Merge with cluster dates
common_dates = readtable('Clustering/common_dates_cluster.csv');

dates_Q{1,1} = string(common_dates.Date(common_dates.Cluster==0));
dates_Q{1,2} = string(common_dates.Date(common_dates.Cluster==1));

%% Realized variance
realized_vola = nan(height(daily_price),2);
dates = daily_price.Date;
for i = (1+27):length(dates)-27

    sp1=sortrows(daily_price,"Date");
    St_minus_tau = sp1.Adj_Close(datenum(sp1.Date)>=datenum(dates(i))-ttm & datenum(sp1.Date)<=datenum(dates(i)));
    St_plus_tau = sp1.Adj_Close(datenum(sp1.Date)>=datenum(dates(i)) & datenum(sp1.Date)<=datenum(dates(i))+ttm);
    simpleret_before = St_minus_tau(2:end)./St_minus_tau(1:end-1)-1;
    simpleret_after = St_plus_tau(2:end)./St_plus_tau(1:end-1)-1;
    realized_vola(i,1)=sqrt(sum(simpleret_before.^2));
    realized_vola(i,2)=sqrt(sum(simpleret_after.^2));
end

daily_price.simpleRV=realized_vola(:,1);
daily_price.simpleFV=realized_vola(:,2);

% Get index
dates = datetime(dates_Q{1,1},"Format","uuuu-MM-dd","InputFormat","uuuuMMdd");
[~, idx_HV] = ismember(dates,daily_price.Date);

dates = datetime(dates_Q{1,2},"Format","uuuu-MM-dd","InputFormat","uuuuMMdd");
[~, idx_LV] = ismember(dates,daily_price.Date);

RR_OA = daily_price([idx_HV;idx_LV],:);
RR_HV = daily_price(idx_HV,:);
RR_LV = daily_price(idx_LV,:);

RR_OA=sortrows(RR_OA,"Date");
RR_HV=sortrows(RR_HV,"Date");
RR_LV=sortrows(RR_LV,"Date");


writetable(RR_OA,"RiskPremia/moneyness/Bitcoin_Premium/477_sample_return_OA.xlsx");
writetable(RR_HV,"RiskPremia/moneyness/Bitcoin_Premium/477_sample_return_HV.xlsx");
writetable(RR_LV,"RiskPremia/moneyness/Bitcoin_Premium/477_sample_return_LV.xlsx");