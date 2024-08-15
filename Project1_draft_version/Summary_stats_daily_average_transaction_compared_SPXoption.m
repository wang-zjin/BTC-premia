%% Summary Statistics for BTC Options
clear, clc

% Load the processed options data, daily BTC prices and DVOL
option = readtable("data/processed/20172022_processed_1_3_4.csv");
daily_price = readtable("data/BTC_USD_Quandl_2011_2023.csv");
% BTC_Dvol = readtable("data/DVOL.csv");

% Ensure the Summary_stats directory exists for output
[~,~,~] = mkdir("Summary_stats/1_3_5/daily_observations/");

%% delete option if IV==0
option(option.IV<=0,:)=[];
option(option.tau<=0,:)=[];
%% delete options with price < 10
sum(option.option_price<=10)
option = option(option.option_price>10,:);
%% delete observations with extremely low BTC price (less than $2000)
sum(option.BTC_price<1500)
unique(option.date(option.BTC_price<1500))
option(option.BTC_price<1500,:)=[];
%% Exclude 2022-12
option(option.date>=datetime("20221201","Inputform","uuuuMMdd"),:) = [];
%% number of transaction, quantity and volume overtime
[unique_date, ~, idx_date] = unique(string(option.date));
volume_daily = accumarray(idx_date, option.option_price.*option.quantity, [], @sum);
quantity_daily = accumarray(idx_date, option.quantity, [], @sum);
transaction_daily = accumarray(idx_date, ones(size(option.option_price)), [], @sum);

% unique month & days in each month
[unique_month_BTC, ~, idx_month] = unique(string(datestr(option.date,'yyyymm')));
daysInMonth = eomday(year(datetime(strcat(unique_month_BTC,'01'),'InputFormat','uuuuMMdd')), month(datetime(strcat(unique_month_BTC,'01'),'InputFormat','uuuuMMdd')));

% daily average transaction
transaction_average_daily_BTC = accumarray(idx_month, ones(size(option.option_price)), [], @sum);
transaction_average_daily_BTC = transaction_average_daily_BTC ./ daysInMonth;

figure;
bar(datetime(strcat(unique_month_BTC,'01'),'InputFormat','uuuuMMdd'), transaction_average_daily_BTC)
ylabel('Transaction')
% title('Average daily BTC option transactions per month')
xlim([datetime("2017-07-01"),datetime("2022-12-01")])
xticks([datetime("2017-07-01"),datetime("2018-08-01"),datetime("2019-09-01"),datetime("2020-10-01"), ...
    datetime("2021-11-01"),datetime("2022-12-01")]);
dateaxis('x',12)
set(gcf,'Position',[0,0,1500,600])
set(gca,'FontSize',20)
% saveas(gcf,"Summary_stats/1_3_5/daily_observations/Daily_average_transaction.png")


fprintf('%10.0f\n', mean(transaction_average_daily_BTC));
fprintf('%10.0f\n', mean(transaction_average_daily_BTC(1:30)));
fprintf('%10.0f\n', mean(transaction_average_daily_BTC(31:end)));

%% SPX options daily average transaction
SPX_option_volume = readtable("data/SPX_option/daily_volume_SPX_2017-07-01_2022-12-31.csv");
SPX_option_volume.Date = datetime(SPX_option_volume.TradeDate,"Format","uuuu-MM-dd","InputFormat","uuuu/MM/dd");

[unique_month_SPX, ~, idx_month] = unique(string(datestr(SPX_option_volume.Date,'yyyymm')));
daysInMonth = eomday(year(datetime(strcat(unique_month_SPX,'01'),'InputFormat','uuuuMMdd')), month(datetime(strcat(unique_month_SPX,'01'),'InputFormat','uuuuMMdd')));
transaction_average_daily_SPX = accumarray(idx_month, SPX_option_volume.Volume, [], @sum);
transaction_average_daily_SPX = transaction_average_daily_SPX ./ daysInMonth;


fprintf('%10.0f\n', mean(transaction_average_daily_SPX));
fprintf('%10.0f\n', mean(transaction_average_daily_SPX(1:30)));
fprintf('%10.0f\n', mean(transaction_average_daily_SPX(31:end)));

%% Figure: BTC vs SPX option daily average transactions
figure;
yyaxis left
bar(datetime(strcat(unique_month_BTC,'01'),'InputFormat','uuuuMMdd'), transaction_average_daily_BTC/1000);hold on
ylabel('BTC option transaction')
yyaxis right
plot(datetime(strcat(unique_month_SPX,'01'),'InputFormat','uuuuMMdd'), transaction_average_daily_SPX/1000,'-','LineWidth',3,'Color','r');
ylabel('SPX option transaction')
set(gca, 'ycolor', [1,0,0]);
% title('Average daily BTC option transactions per month')
xlim([datetime("2017-07-01"),datetime("2022-12-01")])
xticks([datetime("2017-07-01"),datetime("2018-08-01"),datetime("2019-09-01"),datetime("2020-10-01"), ...
    datetime("2021-11-01"),datetime("2022-12-01")]);
dateaxis('x',12)
set(gcf,'Position',[0,0,1500,600])
set(gca,'FontSize',20)

saveas(gcf,"Summary_stats/1_3_5/daily_observations/Daily_average_transaction_BTC_SPX.png")
