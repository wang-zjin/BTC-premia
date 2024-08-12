%% summary statistics 1.3.5
% 1.option data "20172022_processed_1_3_4.csv"
% 2.Time span from 20170701 to 20221217
% 3.delete option with tau less than 1
% 4.delete option with prices less than $10
% 5.delete option with IV less or equal to 0
% 8.delete observations with extremely low BTC price (less than $2000)
%% load data
clear,clc
option1 = readtable("data/17Jul_18Dec/sampleall.csv");
option2 = readtable("data/deribit20192020/option1920clean.csv");
option3 = readtable("data/all_btc33.csv");
option = [option1;option2;option3];
clear option1 option2 option3
[~,~,~]=mkdir("Summary_stats/1_3_5");

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
%% volume
volume = option.BTC_price .* option.quantity;
moneyness = option.K ./ option.BTC_price;
option = addvars(option, volume, moneyness, 'NewVariableNames',{'volume', 'moneyness'});
volume = option.option_price .* option.quantity;
option = addvars(option, volume, 'NewVariableNames',{'volume_optionprice'});
tau_type = string(option.K);
% for i=1:numel(tau_type)
%     if option.tau(i)<=9
%         tau_type(i)='<=9';
%     elseif option.tau(i)<27
%         tau_type(i)='10_26';
%     elseif option.tau(i)<=33
%         tau_type(i)='27_33';
%     else
%         tau_type(i)='>33';
%     end
% end
tau_type(option.tau<=9)='<=9';
tau_type(option.tau>9 & option.tau<27)='10_26';
tau_type(option.tau>=27 & option.tau<=33)='27_33';
tau_type(option.tau>33)='>33';
option = addvars(option, tau_type, 'NewVariableNames',{'tau_range'});

moneyness_type = tau_type;
% for i=1:numel(moneyness_type)
%     if option.moneyness(i) < 0.9
%         moneyness_type(i)='<0d9';
%     elseif option.moneyness(i) <= 0.97
%         moneyness_type(i)='0d9_0d97';
%     elseif option.moneyness(i) < 1.03
%         moneyness_type(i)='0d97_1d03';
%     elseif option.moneyness(i) < 1.1
%         moneyness_type(i)='1d03_1d1';
%     else
%         moneyness_type(i)='g>1d1';
%     end
% end
moneyness_type(option.moneyness < 0.9)='<0d9';
moneyness_type(option.moneyness >= 0.9 & option.moneyness <= 0.97)='0d9_0d97';
moneyness_type(option.moneyness > 0.97 & option.moneyness < 1.03)='0d97_1d03';
moneyness_type(option.moneyness >= 1.03 & option.moneyness <= 1.1)='1d03_1d1';
moneyness_type(option.moneyness > 1.1)='g>1d1';
option = addvars(option, moneyness_type, 'NewVariableNames',{'moneyness_range'});
clear tau_type moneyness_type
%% Average IV of BTC call options
IV_table = nan(6,5);
IV_table(1,:) = [mean(option.IV(option.moneyness<0.9 & option.tau<=9 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness<0.9 & option.tau>9 & option.tau<=26 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness<0.9 & option.tau>=27 & option.tau<=33 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness<0.9 & option.tau>33 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness<0.9 & strcmp(option.putcall,'C'),:))];
IV_table(2,:) = [mean(option.IV(option.moneyness>=0.9 & option.moneyness<0.97 & option.tau<=9 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=0.9 & option.moneyness<0.97 & option.tau>9 & option.tau<=26 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=0.9 & option.moneyness<0.97 & option.tau>=27 & option.tau<=33 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=0.9 & option.moneyness<0.97 & option.tau>33 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=0.9 & strcmp(option.putcall,'C'),:))];
IV_table(3,:) = [mean(option.IV(option.moneyness>=0.97 & option.moneyness<1.03 & option.tau<=9 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=0.97 & option.moneyness<1.03 & option.tau>9 & option.tau<=26 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=0.97 & option.moneyness<1.03 & option.tau>=27 & option.tau<=33 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=0.97 & option.moneyness<1.03 & option.tau>33 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=0.97 & strcmp(option.putcall,'C'),:))];
IV_table(4,:) = [mean(option.IV(option.moneyness>=1.03 & option.moneyness<1.10 & option.tau<=9 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=1.03 & option.moneyness<1.10 & option.tau>9 & option.tau<=26 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=1.03 & option.moneyness<1.10 & option.tau>=27 & option.tau<=33 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=1.03 & option.moneyness<1.10 & option.tau>33 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=1.03 & strcmp(option.putcall,'C'),:))];
IV_table(5,:) = [mean(option.IV(option.moneyness>=1.10 & option.tau<=9 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=1.10 & option.tau>9 & option.tau<=26 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=1.10 & option.tau>=27 & option.tau<=33 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=1.10 & option.tau>33 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.moneyness>=1.10 & strcmp(option.putcall,'C'),:))];
IV_table(6,:) = [mean(option.IV(option.tau<=9 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.tau>9 & option.tau<=26 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.tau>=27 & option.tau<=33 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(option.tau>33 & strcmp(option.putcall,'C'),:)),...
    mean(option.IV(strcmp(option.putcall,'C'),:))];
IV_table = IV_table/100;
clear info;
info.rnames = strvcat('.','(0,0.9)','[0.9,0.97)','[0.97,1.03)','[1.03,1.10)','>1.10','Average');
info.cnames = strvcat('(0,9]','(9,26]','[27,33]','>33','Average');
info.fmt    = '%10.2f';
mprint(IV_table,info)
writetable(table(IV_table),"Summary_stats/1_3_5/Average_IV_call.csv")
%% Average IV of BTC put options
IV_table = nan(6,5);
IV_table(1,:) = [mean(option.IV(option.moneyness<0.9 & option.tau<=9 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness<0.9 & option.tau>9 & option.tau<=26 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness<0.9 & option.tau>=27 & option.tau<=33 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness<0.9 & option.tau>33 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness<0.9 & strcmp(option.putcall,'P'),:))];
IV_table(2,:) = [mean(option.IV(option.moneyness>=0.9 & option.moneyness<0.97 & option.tau<=9 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=0.9 & option.moneyness<0.97 & option.tau>9 & option.tau<=26 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=0.9 & option.moneyness<0.97 & option.tau>=27 & option.tau<=33 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=0.9 & option.moneyness<0.97 & option.tau>33 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=0.9 & strcmp(option.putcall,'P'),:))];
IV_table(3,:) = [mean(option.IV(option.moneyness>=0.97 & option.moneyness<1.03 & option.tau<=9 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=0.97 & option.moneyness<1.03 & option.tau>9 & option.tau<=26 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=0.97 & option.moneyness<1.03 & option.tau>=27 & option.tau<=33 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=0.97 & option.moneyness<1.03 & option.tau>33 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=0.97 & strcmp(option.putcall,'P'),:))];
IV_table(4,:) = [mean(option.IV(option.moneyness>=1.03 & option.moneyness<1.10 & option.tau<=9 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=1.03 & option.moneyness<1.10 & option.tau>9 & option.tau<=26 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=1.03 & option.moneyness<1.10 & option.tau>=27 & option.tau<=33 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=1.03 & option.moneyness<1.10 & option.tau>33 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=1.03 & strcmp(option.putcall,'P'),:))];
IV_table(5,:) = [mean(option.IV(option.moneyness>=1.10 & option.tau<=9 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=1.10 & option.tau>9 & option.tau<=26 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=1.10 & option.tau>=27 & option.tau<=33 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=1.10 & option.tau>33 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.moneyness>=1.10 & strcmp(option.putcall,'P'),:))];
IV_table(6,:) = [mean(option.IV(option.tau<=9 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.tau>9 & option.tau<=26 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.tau>=27 & option.tau<=33 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(option.tau>33 & strcmp(option.putcall,'P'),:)),...
    mean(option.IV(strcmp(option.putcall,'P'),:))];
IV_table = IV_table/100;
clear info;
info.rnames = strvcat('.','(0,0.9)','[0.9,0.97)','[0.97,1.03)','[1.03,1.10)','>1.10','Average');
info.cnames = strvcat('(0,9]','(9,26]','[27,33]','>33','Average');
info.fmt    = '%10.2f';
mprint(IV_table,info)
writetable(table(IV_table),"Summary_stats/1_3_5/Average_IV_put.csv")
%% summary statistics: number of transactions
[tbl,~,~,labels] = crosstab(option.moneyness_range,  option.tau_range);
tbl = tbl / sum(sum(tbl));
X_labels = labels(1:4,2)';
for i = 1:numel(X_labels)
    X_labels{i}=strcat('tau_',X_labels{i});
end
X_labels = X_labels(:,[4,3,1,2]);
tbl = tbl(:,[4,3,1,2]);

Y_labels = labels(:,1)';
for i = 1:numel(Y_labels)
    Y_labels{i}=strcat('m_',Y_labels{i});
end
Y_labels = Y_labels(:,[1,5,3,2,4]);
tbl = tbl([1,5,3,2,4],:);

tbl = [tbl;sum(tbl)];
Y_labels = [Y_labels,{'Total'}];
tbl = [tbl,sum(tbl,2)];
X_labels = [X_labels,{'Total'}];

Tbl = array2table(tbl,'VariableNames',X_labels,'RowNames',Y_labels);
writetable(Tbl,"Summary_stats/1_3_5/option_characteristics_transaction_overall.csv")

% call option
[tbl_call,~,~,labels_call] = crosstab(option.moneyness_range(strcmp(option.putcall,'C')),  option.tau_range(strcmp(option.putcall,'C')));
tbl_call = tbl_call / sum(sum(tbl_call));
tbl_call = tbl_call(:,[4,3,1,2]);
tbl_call = tbl_call([5,3,2,1,4],:);
tbl_call = [tbl_call;sum(tbl_call)];
tbl_call = [tbl_call,sum(tbl_call,2)];

Tbl_call = array2table(tbl_call,'VariableNames',X_labels,'RowNames',Y_labels);
writetable(Tbl_call,"Summary_stats/1_3_5/option_characteristics_transaction_call.csv")

% put option
[tbl_put,~,~,labels_put] = crosstab(option.moneyness_range(strcmp(option.putcall,'P')),  option.tau_range(strcmp(option.putcall,'P')));
tbl_put = tbl_put / sum(sum(tbl_put));
tbl_put = tbl_put(:,[4,3,1,2]);
tbl_put = tbl_put([1,4,3,5,2],:);
tbl_put = [tbl_put;sum(tbl_put)];
tbl_put = [tbl_put,sum(tbl_put,2)];

Tbl_put = array2table(tbl_put,'VariableNames',X_labels,'RowNames',Y_labels);
writetable(Tbl_put,"Summary_stats/1_3_5/option_characteristics_transaction_put.csv")

%% summary statistics: quantity

[unique_tau_range, ~, idx_tau_range] = unique(string(option.tau_range));
% volume_tau_range = accumarray(idx_tau_range, option.quantity, [], @sum);

[unique_m_range_1, ~, idx_m_range_1] = unique(string(option.moneyness_range(idx_tau_range==1)));
unique_m_range_1
quantity_m_range_1 = accumarray(idx_m_range_1, option.quantity(idx_tau_range==1), [], @sum);
[unique_m_range_2, ~, idx_m_range_2] = unique(string(option.moneyness_range(idx_tau_range==2)));
quantity_m_range_2 = accumarray(idx_m_range_2, option.quantity(idx_tau_range==2), [], @sum);
[unique_m_range_3, ~, idx_m_range_3] = unique(string(option.moneyness_range(idx_tau_range==3)));
quantity_m_range_3 = accumarray(idx_m_range_3, option.quantity(idx_tau_range==3), [], @sum);
[unique_m_range_4, ~, idx_m_range_4] = unique(string(option.moneyness_range(idx_tau_range==4)));
quantity_m_range_4 = accumarray(idx_m_range_4, option.quantity(idx_tau_range==4), [], @sum);

tbl = [quantity_m_range_1, quantity_m_range_2, quantity_m_range_3, quantity_m_range_4];
tbl = tbl/sum(sum(tbl));
tbl = tbl(:,[3,1,2,4]);
tbl = tbl([4,2,1,3,5],:);
tbl = [tbl;sum(tbl)];
tbl = [tbl,sum(tbl,2)];
Tbl = array2table(tbl,'VariableNames',X_labels,'RowNames',Y_labels);
writetable(Tbl,"Summary_stats/1_3_5/option_characteristics_quantity_overall.csv")

% call
option_call = option(strcmp(option.putcall,'C'),:);
[unique_tau_range_call, ~, idx_tau_range_call] = unique(string(option_call.tau_range));
unique_tau_range_call

[unique_m_range_call_1, ~, idx_m_range_call_1] = unique(string(option_call.moneyness_range(idx_tau_range_call==1)));
unique_m_range_call_1
quantity_m_range_call_1 = accumarray(idx_m_range_call_1, option_call.quantity(idx_tau_range_call==1), [], @sum);
[unique_m_range_call_2, ~, idx_m_range_call_2] = unique(string(option_call.moneyness_range(idx_tau_range_call==2)));
quantity_m_range_call_2 = accumarray(idx_m_range_call_2, option_call.quantity(idx_tau_range_call==2), [], @sum);
[unique_m_range_call_3, ~, idx_m_range_call_3] = unique(string(option_call.moneyness_range(idx_tau_range_call==3)));
quantity_m_range_call_3 = accumarray(idx_m_range_call_3, option_call.quantity(idx_tau_range_call==3), [], @sum);
[unique_m_range_call_4, ~, idx_m_range_call_4] = unique(string(option_call.moneyness_range(idx_tau_range_call==4)));
quantity_m_range_call_4 = accumarray(idx_m_range_call_4, option_call.quantity(idx_tau_range_call==4), [], @sum);

tbl_call = [quantity_m_range_call_1, quantity_m_range_call_2, quantity_m_range_call_3, quantity_m_range_call_4];
tbl_call = tbl_call/sum(sum(tbl_call));
tbl_call = tbl_call(:,[3,1,2,4]);
tbl_call = tbl_call([4,2,1,3,5],:);
tbl_call = [tbl_call;sum(tbl_call)];
tbl_call = [tbl_call,sum(tbl_call,2)];
Tbl_call = array2table(tbl_call,'VariableNames',X_labels,'RowNames',Y_labels);
writetable(Tbl_call,"Summary_stats/1_3_5/option_characteristics_quantity_call.csv")


% put
option_put = option(strcmp(option.putcall,'P'),:);
[unique_tau_range_put, ~, idx_tau_range_put] = unique(string(option_put.tau_range));
unique_tau_range_put
[unique_m_range_put_1, ~, idx_m_range_put_1] = unique(string(option_put.moneyness_range(idx_tau_range_put==1)));
quantity_m_range_put_1 = accumarray(idx_m_range_put_1, option_put.quantity(idx_tau_range_put==1), [], @sum);
[unique_m_range_put_2, ~, idx_m_range_put_2] = unique(string(option_put.moneyness_range(idx_tau_range_put==2)));
quantity_m_range_put_2 = accumarray(idx_m_range_put_2, option_put.quantity(idx_tau_range_put==2), [], @sum);
[unique_m_range_put_3, ~, idx_m_range_put_3] = unique(string(option_put.moneyness_range(idx_tau_range_put==3)));
quantity_m_range_put_3 = accumarray(idx_m_range_put_3, option_put.quantity(idx_tau_range_put==3), [], @sum);
[unique_m_range_put_4, ~, idx_m_range_put_4] = unique(string(option_put.moneyness_range(idx_tau_range_put==4)));
quantity_m_range_put_4 = accumarray(idx_m_range_put_4, option_put.quantity(idx_tau_range_put==4), [], @sum);

tbl_put = [quantity_m_range_put_1, quantity_m_range_put_2, quantity_m_range_put_3, quantity_m_range_put_4];
tbl_put = tbl_put/sum(sum(tbl_put));
tbl_put = tbl_put(:,[3,1,2,4]);
tbl_put = tbl_put([4,2,1,3,5],:);
tbl_put = [tbl_put;sum(tbl_put)];
tbl_put = [tbl_put,sum(tbl_put,2)];
Tbl_put = array2table(tbl_put,'VariableNames',X_labels,'RowNames',Y_labels);
writetable(Tbl_put,"Summary_stats/1_3_5/option_characteristics_quantity_put.csv")

%% summary statistics: volume
[unique_tau_range, ~, idx_tau_range] = unique(string(option.tau_range));
unique_tau_range

[unique_m_range_1, ~, idx_m_range_1] = unique(string(option.moneyness_range(idx_tau_range==1)));
unique_m_range_1
volume_m_range_1 = accumarray(idx_m_range_1, option.quantity(idx_tau_range==1).*option.option_price(idx_tau_range==1), [], @sum);
[unique_m_range_2, ~, idx_m_range_2] = unique(string(option.moneyness_range(idx_tau_range==2)));
volume_m_range_2 = accumarray(idx_m_range_2, option.quantity(idx_tau_range==2).*option.option_price(idx_tau_range==2), [], @sum);
[unique_m_range_3, ~, idx_m_range_3] = unique(string(option.moneyness_range(idx_tau_range==3)));
volume_m_range_3 = accumarray(idx_m_range_3, option.quantity(idx_tau_range==3).*option.option_price(idx_tau_range==3), [], @sum);
[unique_m_range_4, ~, idx_m_range_4] = unique(string(option.moneyness_range(idx_tau_range==4)));
volume_m_range_4 = accumarray(idx_m_range_4, option.quantity(idx_tau_range==4).*option.option_price(idx_tau_range==4), [], @sum);

tbl = [volume_m_range_1, volume_m_range_2, volume_m_range_3, volume_m_range_4];
tbl = tbl/sum(sum(tbl));
tbl = tbl(:,[3,1,2,4]);
tbl = tbl([4,2,1,3,5],:);
tbl = [tbl;sum(tbl)];
tbl = [tbl,sum(tbl,2)];
Tbl = array2table(tbl,'VariableNames',X_labels,'RowNames',Y_labels);
writetable(Tbl,"Summary_stats/1_3_5/option_characteristics_volume_overall.csv")

% call
option_call = option(strcmp(option.putcall,'C'),:);
[unique_tau_range_call, ~, idx_tau_range_call] = unique(string(option_call.tau_range));
unique_tau_range_call

[unique_m_range_call_1, ~, idx_m_range_call_1] = unique(string(option_call.moneyness_range(idx_tau_range_call==1)));
unique_m_range_call_1
volume_m_range_call_1 = accumarray(idx_m_range_call_1, option_call.quantity(idx_tau_range_call==1).*option_call.option_price(idx_tau_range_call==1), [], @sum);
[unique_m_range_call_2, ~, idx_m_range_call_2] = unique(string(option_call.moneyness_range(idx_tau_range_call==2)));
volume_m_range_call_2 = accumarray(idx_m_range_call_2, option_call.quantity(idx_tau_range_call==2).*option_call.option_price(idx_tau_range_call==2), [], @sum);
[unique_m_range_call_3, ~, idx_m_range_call_3] = unique(string(option_call.moneyness_range(idx_tau_range_call==3)));
volume_m_range_call_3 = accumarray(idx_m_range_call_3, option_call.quantity(idx_tau_range_call==3).*option_call.option_price(idx_tau_range_call==3), [], @sum);
[unique_m_range_call_4, ~, idx_m_range_call_4] = unique(string(option_call.moneyness_range(idx_tau_range_call==4)));
volume_m_range_call_4 = accumarray(idx_m_range_call_4, option_call.quantity(idx_tau_range_call==4).*option_call.option_price(idx_tau_range_call==4), [], @sum);

tbl_call = [volume_m_range_call_1, volume_m_range_call_2, volume_m_range_call_3, volume_m_range_call_4];
tbl_call = tbl_call/sum(sum(tbl_call));
tbl_call = tbl_call(:,[3,1,2,4]);
tbl_call = tbl_call([4,2,1,3,5],:);
tbl_call = [tbl_call;sum(tbl_call)];
tbl_call = [tbl_call,sum(tbl_call,2)];
Tbl_call = array2table(tbl_call,'VariableNames',X_labels,'RowNames',Y_labels);
writetable(Tbl_call,"Summary_stats/1_3_5/option_characteristics_volume_call.csv")

% put
option_put = option(strcmp(option.putcall,'P'),:);
[unique_tau_range_put, ~, idx_tau_range_put] = unique(string(option_put.tau_range));
unique_tau_range_put

[unique_m_range_put_1, ~, idx_m_range_put_1] = unique(string(option_put.moneyness_range(idx_tau_range_put==1)));
unique_m_range_put_1
volume_m_range_put_1 = accumarray(idx_m_range_put_1, option_put.quantity(idx_tau_range_put==1).*option_put.option_price(idx_tau_range_put==1), [], @sum);
[unique_m_range_put_2, ~, idx_m_range_put_2] = unique(string(option_put.moneyness_range(idx_tau_range_put==2)));
volume_m_range_put_2 = accumarray(idx_m_range_put_2, option_put.quantity(idx_tau_range_put==2).*option_put.option_price(idx_tau_range_put==2), [], @sum);
[unique_m_range_put_3, ~, idx_m_range_put_3] = unique(string(option_put.moneyness_range(idx_tau_range_put==3)));
volume_m_range_put_3 = accumarray(idx_m_range_put_3, option_put.quantity(idx_tau_range_put==3).*option_put.option_price(idx_tau_range_put==3), [], @sum);
[unique_m_range_put_4, ~, idx_m_range_put_4] = unique(string(option_put.moneyness_range(idx_tau_range_put==4)));
volume_m_range_put_4 = accumarray(idx_m_range_put_4, option_put.quantity(idx_tau_range_put==4).*option_put.option_price(idx_tau_range_put==4), [], @sum);

tbl_put = [volume_m_range_put_1, volume_m_range_put_2, volume_m_range_put_3, volume_m_range_put_4];
tbl_put = tbl_put/sum(sum(tbl_put));
tbl_put = tbl_put(:,[3,1,2,4]);
tbl_put = tbl_put([4,2,1,3,5],:);
tbl_put = [tbl_put;sum(tbl_put)];
tbl_put = [tbl_put,sum(tbl_put,2)];
Tbl_put = array2table(tbl_put,'VariableNames',X_labels,'RowNames',Y_labels);
writetable(Tbl_put,"Summary_stats/1_3_5/option_characteristics_volume_put.csv")


%% sort by date, putcall, K
[~,I]=sortrows(option,["date","putcall","K"]);
option1 = option(I,:);

%% Summary statistics of option variables for call and puts separately
option_call = option(strcmp(option.putcall,'C'),:);
tau=round([mean(option_call.tau);median(option_call.tau);std(option_call.tau);min(option_call.tau);max(option_call.tau);size(option_call,1)],2);
moneyness=round([mean(option_call.moneyness);median(option_call.moneyness);std(option_call.moneyness);min(option_call.moneyness);max(option_call.moneyness);size(option_call,1)],2);
IV=round([mean(option_call.IV);median(option_call.IV);std(option_call.IV);min(option_call.IV);max(option_call.IV);size(option_call,1)*100]/100,2);
tb = table(tau,moneyness, IV);
tb.Properties.RowNames = {'Mean', 'Median', 'Std. Dev.', 'Min', 'Max','Total'};
writetable(tb,"Summary_stats/1_3_5/sum_stats_variables_call.csv")

option_put = option(strcmp(option.putcall,'P'),:);
tau=round([mean(option_put.tau);median(option_put.tau);std(option_put.tau);min(option_put.tau);max(option_put.tau);size(option_call,1)],2);
moneyness=round([mean(option_put.moneyness);median(option_put.moneyness);std(option_put.moneyness);min(option_put.moneyness);max(option_put.moneyness);size(option_call,1)],2);
IV=round([mean(option_put.IV);median(option_put.IV);std(option_put.IV);min(option_put.IV);max(option_put.IV);size(option_call,1)*100]/100,2);
tb = table(tau,moneyness, IV);
tb.Properties.RowNames = {'Mean', 'Median', 'Std. Dev.', 'Min', 'Man','Total'};
writetable(tb,"Summary_stats/1_3_5/sum_stats_variables_put.csv")
