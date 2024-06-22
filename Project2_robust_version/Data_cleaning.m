%% Data cleaning
%% load data from different resources
clear,clc
option1 = readtable("data/17Jul_18Dec/sampleall.csv");           % Scrabed by Raul 
option2 = readtable("data/deribit20192020/option1920clean.csv"); % Scrabed by Raul 
option3 = readtable("data/all_btc33.csv");                       % Scrabed by Julian

% Notice there is an overlapping period between Raul and Julian data
% Remove Julia data before 2021 from the third dataset to avoid overlap
option3(option3.date < datetime("2021-01-01"), :) = [];

option = [option1;option2;option3];
clear option1 option2 option3
[~,~,~]=mkdir("Summary_stats/1_3_4");

%% delete option if IV<=0
option(option.IV<=0,:)=[];
option(option.tau<=0,:)=[];
%% delete options with price < 10
% Identify and delete options with price less than or equal to 10
% calculate and display the number of such options for review
disp(['Options with price <= 10: ', num2str(sum(option.option_price <= 10))]);
option = option(option.option_price>10,:);
%% delete observations with extremely low BTC price (less than $1500)
% Identify and delete observations where BTC price is extremely low (<$1500)
% These low prices are unusual as BTC prices in these periods have never
% showed such low, this phenomenon might be due to scrabing error or sudden
% crash of exchange. Since these observations are relatively small, we
% could just kill them.

% Display the count and unique dates of such observations before removal
disp(['Observations with BTC price < 1500: ', num2str(sum(option.BTC_price < 1500))]);
disp('Unique dates for low BTC price observations:');
disp(unique(option.date(option.BTC_price < 1500)));
option(option.BTC_price < 1500, :) = [];

%% Drop rows with NaA values
% Find rows with NaN values
rows_with_nan = any(isnan(option{:,2:7}), 2);
rows_with_nan = or(rows_with_nan,any(isnat(option.date), 2));
rows_with_nan = or(rows_with_nan, cellfun(@isempty, option.putcall));

% Display rows with NaN values
T_NaN = option(rows_with_nan, :);
disp(T_NaN);

option = rmmissing(option);

%% Generate volume, tau_range, moneyness_range
volume = option.BTC_price .* option.quantity;
moneyness = option.K ./ option.BTC_price;
option = addvars(option, volume, moneyness, 'NewVariableNames',{'volume', 'moneyness'});

volume_optionprice = option.option_price .* option.quantity;
option = addvars(option, volume_optionprice, 'NewVariableNames',{'volume_optionprice'});

tau_group = string(option.K);
tau_group(option.tau<=9)='<=9';
tau_group(option.tau>9 & option.tau<27)='10_26';
tau_group(option.tau>=27 & option.tau<=33)='27_33';
tau_group(option.tau>33)='>33';
option = addvars(option, tau_group, 'NewVariableNames',{'tau_range'});

moneyness_group = tau_group;
moneyness_group(option.moneyness < 0.9)='<0d9';
moneyness_group(option.moneyness >= 0.9 & option.moneyness <= 0.97)='0d9_0d97';
moneyness_group(option.moneyness > 0.97 & option.moneyness < 1.03)='0d97_1d03';
moneyness_group(option.moneyness >= 1.03 & option.moneyness <= 1.1)='1d03_1d1';
moneyness_group(option.moneyness > 1.1)='g>1d1';
option = addvars(option, moneyness_group, 'NewVariableNames',{'moneyness_range'});
clear tau_group moneyness_group

%% sort by date, putcall, K
[~,I]=sortrows(option,["date","putcall","K"]);
option_sorted = option(I,:);

%% Save data
[~,~,~]=mkdir("data/processed");
writetable(option_sorted,"data/processed/20172022_processed_1_3_4.csv");

readtable("data/processed/20172022_processed_1_3_4.csv");