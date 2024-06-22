clc,clear
option = readtable("data/processed/20172022_processed_1_3_4.csv");

IR = readtable("data/interest_rate/IR_daily.csv");
IR.index=datetime(IR.index);
IR.DTB3=IR.DTB3/100;



%% test if dates are continuous
% uniq_date = unique(option.date);
% (uniq_date(end)-uniq_date(1))/24
% %% transform transaction data into order book data
% % sort by: dates, tau, K, PC_type
% % 3 outputs: equally weighted, quantity-weighted, value-weighted
% option1 = option;
% option1.delta = zeros(size(option1,1),1);
% option1.Dividend_yield = zeros(size(option1,1),1);
% option1.PC_type = zeros(size(option1,1),1);
% option1.interest_rate = zeros(size(option1,1),1);
% for i1=1:size(option1,1)
% 
%     interest_rate = IR.DTB3(IR.index==option.date(i1));
%     option1.interest_rate(i1) = interest_rate;
% 
% end
% call_index = (string(option1.putcall)=="C");
% option1.PC_type(call_index) = 1;
% option1.delta(call_index) = normcdf((log(option1.BTC_price(call_index)./option1.K(call_index)) + ...
%     (option1.BTC_price.interest_rate(call_index)+0.5*(option1.IV(call_index)/100).^2).*option1.tau(call_index)) ./ sqrt((option1.IV(call_index)/100).^2.*option1.tau(call_index)));
% put_index = (string(option1.putcall)=="P");   
% option1.delta(put_index) = normcdf((log(option1.BTC_price(put_index)./option1.K(put_index)) + ...
%     (option1.BTC_price.interest_rate(put_index)+0.5*(option1.IV(put_index)/100).^2).*option1.tau(put_index)) ./ sqrt((option1.IV(put_index)/100).^2.*option1.tau(put_index)));
% option2 = table(option1.date,option1.K,option1.option_price,option1.IV/100,option1.BTC_price, ...
%     option1.tau,option1.quantity,option1.value,option1.PC_type,option1.Dividend_yield,option1.moneyness,option1.interest_rate, option1.delta,...
%     'VariableNames',["Date","Strike","Premium","IV","Spot","tau","quantity","value","PC_type","DividendYield","moneyness","IR","delta"]);
% 
% option2.Properties.VariableNames=["Date","Strike","Premium","IV","Spot","tau","quantity","value","PC_type","DividendYield","moneyness","IR","delta"];
%% calculate ttm27 option
option1 = option(option.tau==27,:);

% Assuming your table is named option1
summary(option1)

% Data cleaning again
option1(option1.IV==0, :) = [];

option1.delta = zeros(size(option1,1),1);
option1.Dividend_yield = zeros(size(option1,1),1);
option1.PC_type = zeros(size(option1,1),1);
option1.interest_rate = zeros(size(option1,1),1);
for i1=1:size(option1,1)
    interest_rate = IR.DTB3(IR.index==option1.date(i1));
    option1.interest_rate(i1) = interest_rate;

end
% For call options, delta = N(d1)
% For put options, delta = N(d1) - 1
% d1 = (log(S/K)+(r+0.5*sigma^2)*tau)/(sigma*sqrt(tau))
call_index = (string(option1.putcall)=="C");
option1.PC_type(call_index) = 1;
option1.delta(call_index) = normcdf((log(option1.BTC_price(call_index)./option1.K(call_index)) + ...
    (option1.interest_rate(call_index)+0.5*(option1.IV(call_index)/100).^2).*option1.tau(call_index)/365) ./ sqrt((option1.IV(call_index)/100).^2.*option1.tau(call_index)/365));
put_index = (string(option1.putcall)=="P");
option1.PC_type(put_index) = -1;
option1.delta(put_index) = normcdf((log(option1.BTC_price(put_index)./option1.K(put_index)) + ...
    (option1.interest_rate(put_index)+0.5*(option1.IV(put_index)/100).^2).*option1.tau(put_index)/365) ./ sqrt((option1.IV(put_index)/100).^2.*option1.tau(put_index)/365))-1;
option2 = table(option1.date,option1.K,option1.option_price,option1.IV/100,option1.BTC_price, ...
    option1.tau,option1.quantity,option1.volume,option1.PC_type,option1.Dividend_yield,option1.moneyness,option1.interest_rate, option1.delta,...
    'VariableNames',["Date","Strike","Premium","IV","Spot","tau","quantity","value","PC_type","DividendYield","moneyness","IR","delta"]);

option2.Properties.VariableNames=["Date","Strike","Premium","IV","Spot","tau","quantity","value","PC_type","DividendYield","moneyness","IR","delta"];

%% Save data
version = '0_0_1';
[~,~,~]=mkdir(['data/processed/for_option_return/BTC_option_',version]);
writetable(option2,['data/processed/for_option_return/BTC_option_ttm27_',version,'.csv'])

