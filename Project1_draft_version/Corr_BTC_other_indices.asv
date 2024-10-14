clc,clear
export_folder = "Index_Correlation/";
[~,~,~] = mkdir(export_folder);

Russel2000 = readtable("data/Index/RUT.csv");
SP500 = readtable("data/Index/SPX.csv");
US_treasury_bond_index = readtable("data/Index/SP_US_Treasury_Bond_Index.xlsx");
GSCI = readtable("data/Index/SP_GSCI.xlsx");

opts = detectImportOptions("data/BTC_USD_Quandl_2011_2023.csv", "Delimiter",",");
opts = setvartype(opts,1,"char");
BTC= readtable("data/BTC_USD_Quandl_2011_2023.csv",opts);
BTC.Date = datetime(BTC.Date,"Format","uuuu-MM-dd HH:mm:ss","InputFormat","uuuu/MM/dd");
BTC = sortrows(BTC,"Date");
%% Returns
Russel2000 = sortrows(Russel2000,"Date");
Russel2000.Russel2000 = [nan;price2ret(Russel2000.AdjClose)];

SP500 = sortrows(SP500,"Date");
SP500.SP500 = [nan;price2ret(SP500.AdjClose)];

US_treasury_bond_index = sortrows(US_treasury_bond_index, "EffectiveDate");
US_treasury_bond_index = renamevars(US_treasury_bond_index,"EffectiveDate","Date");
US_treasury_bond_index.US_treasury_bond_index = [nan;price2ret(US_treasury_bond_index.S_PU_S_TreasuryBondIndex)];

GSCI = sortrows(GSCI, "EffectiveDate");
GSCI = renamevars(GSCI, "EffectiveDate", "Date");
GSCI.GSCI = [nan;price2ret(GSCI.S_PGSCI)];

BTC.Date = datetime(BTC.Date,"Format","uuuu-MM-dd");
BTC.BTC = [nan;price2ret(BTC.Adj_Close)];

%% Merge
Indices = innerjoin(BTC(:,["Date","BTC"]),SP500(:,["Date","SP500"]),"Keys","Date");
Indices = innerjoin(Indices,Russel2000(:,["Date","Russel2000"]),"Keys","Date");
Indices = innerjoin(Indices,US_treasury_bond_index(:,["Date","US_treasury_bond_index"]),"Keys","Date");
Indices = innerjoin(Indices,GSCI(:,["Date","GSCI"]),"Keys","Date");
Indices = renamevars(Indices, ["BTC","SP500","Russel2000","US_treasury_bond_index","GSCI"], ...
    ["BTC","S&P 500","Russel 2000", "US Bond", "Global Commodity"]);
Indices.Date = datetime(Indices.Date, "Format","uuuu-MM-dd");

Indices = rmmissing(Indices);

Price_daily = innerjoin(BTC(:,["Date","Adj_Close"]),SP500(:,["Date","AdjClose"]),"Keys","Date");
Price_daily = innerjoin(Price_daily,Russel2000(:,["Date","AdjClose"]),"Keys","Date");
Price_daily = innerjoin(Price_daily,US_treasury_bond_index(:,["Date","S_PU_S_TreasuryBondIndex"]),"Keys","Date");
Price_daily = innerjoin(Price_daily,GSCI(:,["Date","S_PGSCI"]),"Keys","Date");
Price_daily = renamevars(Price_daily, ["Adj_Close","AdjClose_Price_daily","AdjClose_right","S_PU_S_TreasuryBondIndex","S_PGSCI"], ...
    ["BTC","S&P 500","Russel 2000", "US Bond", "Global Commodity"]);
Price_daily.Date = datetime(Price_daily.Date, "Format","uuuu-MM-dd");

Price_daily = rmmissing(Price_daily);
%% Time series: Price
figure;
yyaxis left
plot(Price_daily.Date,table2array(Price_daily(:,"BTC")),"LineWidth",2);
ylabel("BTC price")
yyaxis right
plot(Price_daily.Date,table2array(Price_daily(:,["S&P 500","Russel 2000"])),"LineWidth",2);hold on
plot(Price_daily.Date,table2array(Price_daily(:,["US Bond","Global Commodity"])),"LineWidth",2);
ylabel("Index Price")
legend(["BTC","S&P 500","Russel 2000","US Bond","Global Commodity"],"Location","northwest")
set(gcf,'Position',[0,0,1500,600])
set(gca,'FontSize',20)
saveas(gcf,strcat(export_folder,"Price_time_series.png"))
%% Time series: Return
figure;
plot(Indices.Date,table2array(Indices(:,["BTC","S&P 500","Russel 2000","US Bond","Global Commodity"])),"LineWidth",2);
legend(["BTC","S&P 500","Russel 2000","US Bond","Global Commodity"],"Location","northwest")
ylim([-0.5,0.5])
set(gcf,'Position',[0,0,1500,600])
set(gca,'FontSize',20)
saveas(gcf,strcat(export_folder,"Return_time_series.png"))
%% Correlation
Cor = corr(table2array(Indices(:,2:end)));
Cor(tril(true(size(Cor)),0)) = NaN;
disp(Cor)

Cor_triu = triu(Cor,1);
t_stat = Cor_triu * sqrt(height(Indices)-2) ./ sqrt(1-Cor_triu.^2);
df = height(Indices) - 2;

p_value = 2 * (1 - tcdf(abs(t_stat), df));
p_value(tril(true(size(p_value)),0)) = NaN;
disp(p_value)

info.rnames = strvcat('.','BTC','SPX','Russel_2000','US_Bond_Index','US_Commodity_Index');
info.cnames = strvcat('BTC','SPX','Russel_2000','US_Bond_Index','US_Commodity_Index');
info.fmt    = '%1.3f';
disp('Correlation Matrix')
mprint(Cor,info)
mprint(p_value,info)