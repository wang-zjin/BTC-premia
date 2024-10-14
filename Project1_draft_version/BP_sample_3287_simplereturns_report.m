clc,clear

ttm = 27;
[~,~,~]=mkdir("Bitcoin_Premium/2_1_X_13"); % Create directory for output, if it doesn't exist

%% Full-sample returns
% daily_price = readtable("data/BTC_USD_Quandl_2015_2022.csv");

opts = detectImportOptions("data/BTC_USD_Quandl_2011_2023.csv", "Delimiter",",");
opts = setvartype(opts,1,"char");
daily_price = readtable("data/BTC_USD_Quandl_2011_2023.csv",opts);
daily_price.Date = datetime(daily_price.Date,"Format","uuuu-MM-dd HH:mm:ss","InputFormat","uuuu/MM/dd");
daily_price = sortrows(daily_price,"Date");
% daily_price = daily_price(daily_price.Date <= datetime("2022-12-31"),:);

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

% Select date
daily_price = daily_price(daily_price.Date >= datetime("2014-01-01"),:);
daily_price = daily_price(daily_price.Date <= datetime("2022-12-31"),:);

%% Save data
disp(mean(daily_price.return_t_minus_27)*365/ttm)
disp(mean(daily_price.return_t_plus_27)*365/ttm)

writetable(daily_price,"Bitcoin_Premium/2_1_X_13/3287_sample_return_OA.xlsx");