


%% Below is to use simple returns to calculate Sharpe Ratio all over again
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
%% Simple Returns
Russel2000 = sortrows(Russel2000,"Date");
Russel2000.Russel2000 = [nan;price2ret(Russel2000.AdjClose,1:height(Russel2000),'periodic')];

SP500 = sortrows(SP500,"Date");
SP500.SP500 = [nan;price2ret(SP500.AdjClose,1:height(SP500),'periodic')];

US_treasury_bond_index = sortrows(US_treasury_bond_index, "EffectiveDate");
US_treasury_bond_index = renamevars(US_treasury_bond_index,"EffectiveDate","Date");
US_treasury_bond_index.US_treasury_bond_index = [nan;price2ret(US_treasury_bond_index.S_PU_S_TreasuryBondIndex,1:height(US_treasury_bond_index),'periodic')];

GSCI = sortrows(GSCI, "EffectiveDate");
GSCI = renamevars(GSCI, "EffectiveDate", "Date");
GSCI.GSCI = [nan;price2ret(GSCI.S_PGSCI,1:height(GSCI),'periodic')];

BTC.Date = datetime(BTC.Date,"Format","uuuu-MM-dd");
BTC.BTC = [nan;price2ret(BTC.Adj_Close,1:height(BTC),'periodic')];

%% Date filter from 2014-06-01 to 2023-12-31
start_date = datetime("2014-06-01","InputFormat","uuuu-MM-dd");
end_date = datetime("2023-12-31","InputFormat","uuuu-MM-dd");

BTC = BTC(BTC.Date>=start_date & BTC.Date<=end_date, :);
SP500 = SP500(SP500.Date>=start_date & SP500.Date<=end_date, :);
Russel2000 = Russel2000(Russel2000.Date>=start_date & Russel2000.Date<=end_date, :);
US_treasury_bond_index = US_treasury_bond_index(US_treasury_bond_index.Date>=start_date & US_treasury_bond_index.Date<=end_date, :);
GSCI = GSCI(GSCI.Date>=start_date & GSCI.Date<=end_date, :);
%% Sharpe Ratio

Returns_daily = [mean(BTC.BTC(2:end)),mean(SP500.SP500(2:end)),mean(Russel2000.Russel2000(2:end)),mean(US_treasury_bond_index.US_treasury_bond_index(2:end)),mean(GSCI.GSCI(2:end))];
STD_daily = [std(BTC.BTC(2:end)),std(SP500.SP500(2:end)),std(Russel2000.Russel2000(2:end)),std(US_treasury_bond_index.US_treasury_bond_index(2:end)),std(GSCI.GSCI(2:end))];
SR_daily = Returns_daily./STD_daily;
Returns_ann = Returns_daily.*[365, 252, 252, 252, 252];
STD_ann = STD_daily.*sqrt([365, 252, 252, 252, 252]);
SR_ann = SR_daily.*sqrt([365, 252, 252, 252, 252]);
OBS = [height(BTC), height(SP500), height(Russel2000), height(US_treasury_bond_index), height(GSCI)];

SP_table = [Returns_daily*100;STD_daily*100;SR_daily;Returns_ann*100;STD_ann*100;SR_ann;OBS]';
info.rnames = strvcat('.','BTC','SPX','Russel_2000','US_Bond_Index','US_Commodity_Index');
info.cnames = strvcat('mu (%)','sigma (%)','SR_daily','mu (%)','sigma (%)','SR_ann','Obs');
info.fmt    = '%1.2f';
disp('Sharpe Rratio')
mprint(SP_table,info)

%% Log return Sharpe Ratio, from 2014-06-01 to 2023-12-31
clc,clear
simple_sharpe_ratio("2014-01-01","2022-12-31")
%% Simple return Sharpe Ratio, from 2014-06-01 to 2023-12-31
clc,clear
log_sharpe_ratio("2014-01-01","2022-12-31")
%% Monthly log return
clc,clear
log_sharpe_ratio_monthly("2014-01-01","2022-12-31")
%% Monthly simple return
clc,clear
simple_sharpe_ratio_monthly("2014-01-01","2022-12-31")
%% Functions
function simple_sharpe_ratio(startdate, enddate)
% Load data

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

% Simple Returns
Russel2000 = sortrows(Russel2000,"Date");
Russel2000.Russel2000 = [nan;price2ret(Russel2000.AdjClose,1:height(Russel2000),'periodic')];

SP500 = sortrows(SP500,"Date");
SP500.SP500 = [nan;price2ret(SP500.AdjClose,1:height(SP500),'periodic')];

US_treasury_bond_index = sortrows(US_treasury_bond_index, "EffectiveDate");
US_treasury_bond_index = renamevars(US_treasury_bond_index,"EffectiveDate","Date");
US_treasury_bond_index.US_treasury_bond_index = [nan;price2ret(US_treasury_bond_index.S_PU_S_TreasuryBondIndex,1:height(US_treasury_bond_index),'periodic')];

GSCI = sortrows(GSCI, "EffectiveDate");
GSCI = renamevars(GSCI, "EffectiveDate", "Date");
GSCI.GSCI = [nan;price2ret(GSCI.S_PGSCI,1:height(GSCI),'periodic')];

BTC.Date = datetime(BTC.Date,"Format","uuuu-MM-dd");
BTC.BTC = [nan;price2ret(BTC.Adj_Close,1:height(BTC),'periodic')];

% Date filter
start_date = datetime(startdate,"InputFormat","uuuu-MM-dd");
end_date = datetime(enddate,"InputFormat","uuuu-MM-dd");

BTC = BTC(BTC.Date>=start_date & BTC.Date<=end_date, :);
SP500 = SP500(SP500.Date>=start_date & SP500.Date<=end_date, :);
Russel2000 = Russel2000(Russel2000.Date>=start_date & Russel2000.Date<=end_date, :);
US_treasury_bond_index = US_treasury_bond_index(US_treasury_bond_index.Date>=start_date & US_treasury_bond_index.Date<=end_date, :);
GSCI = GSCI(GSCI.Date>=start_date & GSCI.Date<=end_date, :);
% Sharpe Ratio

Returns_daily = [mean(BTC.BTC(2:end)),mean(SP500.SP500(2:end)),mean(Russel2000.Russel2000(2:end)),mean(US_treasury_bond_index.US_treasury_bond_index(2:end)),mean(GSCI.GSCI(2:end))];
STD_daily = [std(BTC.BTC(2:end)),std(SP500.SP500(2:end)),std(Russel2000.Russel2000(2:end)),std(US_treasury_bond_index.US_treasury_bond_index(2:end)),std(GSCI.GSCI(2:end))];
SR_daily = Returns_daily./STD_daily;
Returns_ann = Returns_daily.*[365, 252, 252, 252, 252];
STD_ann = STD_daily.*sqrt([365, 252, 252, 252, 252]);
SR_ann = SR_daily.*sqrt([365, 252, 252, 252, 252]);
OBS = [height(BTC), height(SP500), height(Russel2000), height(US_treasury_bond_index), height(GSCI)];

SP_table = [Returns_daily*100;STD_daily*100;SR_daily;Returns_ann*100;STD_ann*100;SR_ann;OBS]';
info.rnames = strvcat('.','BTC','SPX','Russel_2000','US_Bond_Index','US_Commodity_Index');
info.cnames = strvcat('mu (%)','sigma (%)','SR_daily','mu (%)','sigma (%)','SR_ann','Obs');
info.fmt    = '%1.2f';
disp('Sharpe Rratio')
mprint(SP_table,info)
end

function log_sharpe_ratio(startdate,enddate)
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
% Returns
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

% Date filter
start_date = datetime(startdate,"InputFormat","uuuu-MM-dd");
end_date = datetime(enddate,"InputFormat","uuuu-MM-dd");

BTC = BTC(BTC.Date>=start_date & BTC.Date<=end_date, :);
SP500 = SP500(SP500.Date>=start_date & SP500.Date<=end_date, :);
Russel2000 = Russel2000(Russel2000.Date>=start_date & Russel2000.Date<=end_date, :);
US_treasury_bond_index = US_treasury_bond_index(US_treasury_bond_index.Date>=start_date & US_treasury_bond_index.Date<=end_date, :);
GSCI = GSCI(GSCI.Date>=start_date & GSCI.Date<=end_date, :);
% Sharpe Ratio

Returns_daily = [mean(BTC.BTC(2:end)),mean(SP500.SP500(2:end)),mean(Russel2000.Russel2000(2:end)),mean(US_treasury_bond_index.US_treasury_bond_index(2:end)),mean(GSCI.GSCI(2:end))];
STD_daily = [std(BTC.BTC(2:end)),std(SP500.SP500(2:end)),std(Russel2000.Russel2000(2:end)),std(US_treasury_bond_index.US_treasury_bond_index(2:end)),std(GSCI.GSCI(2:end))];
SR_daily = Returns_daily./STD_daily;
Returns_ann = Returns_daily.*[365, 252, 252, 252, 252];
STD_ann = STD_daily.*sqrt([365, 252, 252, 252, 252]);
SR_ann = SR_daily.*sqrt([365, 252, 252, 252, 252]);
OBS = [height(BTC), height(SP500), height(Russel2000), height(US_treasury_bond_index), height(GSCI)];

SP_table = [Returns_daily*100;STD_daily*100;SR_daily;Returns_ann*100;STD_ann*100;SR_ann;OBS]';
info.rnames = strvcat('.','BTC','SPX','Russel_2000','US_Bond_Index','US_Commodity_Index');
info.cnames = strvcat('mu (%)','sigma (%)','SR_daily','mu (%)','sigma (%)','SR_ann','Obs');
info.fmt    = '%1.2f';
disp('Sharpe Rratio')
mprint(SP_table,info)
end

function simple_sharpe_ratio_monthly(startdate, enddate)
% Load data

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

% Date filter
start_date = datetime(startdate,"InputFormat","uuuu-MM-dd");
end_date = datetime(enddate,"InputFormat","uuuu-MM-dd");


% Date column
Russel2000 = sortrows(Russel2000,"Date");

SP500 = sortrows(SP500,"Date");

US_treasury_bond_index = sortrows(US_treasury_bond_index, "EffectiveDate");
US_treasury_bond_index = renamevars(US_treasury_bond_index,"EffectiveDate","Date");

GSCI = sortrows(GSCI, "EffectiveDate");
GSCI = renamevars(GSCI, "EffectiveDate", "Date");

BTC.Date = datetime(BTC.Date,"Format","uuuu-MM-dd");
BTC = sortrows(BTC,"Date");


% Filter date
BTC = BTC(BTC.Date>=start_date & BTC.Date<=end_date, :);
SP500 = SP500(SP500.Date>=start_date & SP500.Date<=end_date, :);
Russel2000 = Russel2000(Russel2000.Date>=start_date & Russel2000.Date<=end_date, :);
US_treasury_bond_index = US_treasury_bond_index(US_treasury_bond_index.Date>=start_date & US_treasury_bond_index.Date<=end_date, :);
GSCI = GSCI(GSCI.Date>=start_date & GSCI.Date<=end_date, :);

% Simple Returns

Russel2000_monthly = monthly_simple_return(Russel2000, "Open", "AdjClose", "Russel2000");

SP500_monthly = monthly_simple_return(SP500, "Open", "AdjClose", "SP500");

US_treasury_bond_index_monthly = monthly_simple_return(US_treasury_bond_index, "S_PU_S_TreasuryBondIndex", "S_PU_S_TreasuryBondIndex", "US_treasury_bond_index");

GSCI_monthly = monthly_simple_return(GSCI, "S_PGSCI", "S_PGSCI", "GSCI");

BTC_monthly = monthly_simple_return(BTC, "Adj_Close", "Adj_Close", "BTC");


% Sharpe Ratio

Returns_monthly = [mean(BTC_monthly.BTC),mean(SP500_monthly.SP500),mean(Russel2000_monthly.Russel2000),mean(US_treasury_bond_index_monthly.US_treasury_bond_index),mean(GSCI_monthly.GSCI)];
STD_monthly = [std(BTC_monthly.BTC),std(SP500_monthly.SP500),std(Russel2000_monthly.Russel2000),std(US_treasury_bond_index_monthly.US_treasury_bond_index),std(GSCI_monthly.GSCI)];
SR_monthly = Returns_monthly./STD_monthly;
Returns_ann = Returns_monthly*12;
STD_ann = STD_monthly*sqrt(12);
SR_ann = SR_monthly*sqrt(12);
OBS = [height(BTC_monthly), height(SP500_monthly), height(Russel2000_monthly), height(US_treasury_bond_index_monthly), height(GSCI_monthly)];

SP_table = [Returns_monthly*100;STD_monthly*100;SR_monthly;Returns_ann*100;STD_ann*100;SR_ann;OBS]';
info.rnames = strvcat('.','BTC','SPX','Russel_2000','US_Bond_Index','US_Commodity_Index');
info.cnames = strvcat('mu (%)','sigma (%)','SR_daily','mu (%)','sigma (%)','SR_ann','Obs');
info.fmt    = '%1.2f';
disp('Sharpe Rratio')
mprint(SP_table,info)

    function monthly_table = monthly_simple_return(datatable, openprice, closeprice, indexname)
        % datatable = Russel2000;

        datatable.YearMonth = dateshift(datatable.Date, 'start', 'month');
        unique_months = unique(datatable.YearMonth);
        monthly_price = nan(length(unique_months)+1, 1);
        monthly_price(1)=datatable.(openprice)(1);

        error_month = [];
        % Calculate monthly returns
        for j = 1:length(unique_months)
            month_data = datatable(datatable.YearMonth == unique_months(j), :);

            % Ensure there are data points for the month
            if height(month_data) > 15
                monthly_price(j+1) = month_data.(closeprice)(end);
            else
                error_month=[error_month,j+1];
            end
        end
        monthly_price(error_month,:)=[];

        monthly_ret = price2ret(monthly_price, 1:length(monthly_price), 'periodic');

        monthly_date = datetime(unique(dateshift(datatable.Date, 'start', 'month')), "Format","yyyy-MM");
        monthly_date(error_month,:)=[];

        monthly_table = [table(monthly_date,'VariableNames',"Month"), table(monthly_ret,'VariableNames',indexname)];

    end

end




function log_sharpe_ratio_monthly(startdate, enddate)
% Load data

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

% Date filter
start_date = datetime(startdate,"InputFormat","uuuu-MM-dd");
end_date = datetime(enddate,"InputFormat","uuuu-MM-dd");


% Date column
Russel2000 = sortrows(Russel2000,"Date");

SP500 = sortrows(SP500,"Date");

US_treasury_bond_index = sortrows(US_treasury_bond_index, "EffectiveDate");
US_treasury_bond_index = renamevars(US_treasury_bond_index,"EffectiveDate","Date");

GSCI = sortrows(GSCI, "EffectiveDate");
GSCI = renamevars(GSCI, "EffectiveDate", "Date");

BTC.Date = datetime(BTC.Date,"Format","uuuu-MM-dd");
BTC = sortrows(BTC,"Date");


% Filter date
BTC = BTC(BTC.Date>=start_date & BTC.Date<=end_date, :);
SP500 = SP500(SP500.Date>=start_date & SP500.Date<=end_date, :);
Russel2000 = Russel2000(Russel2000.Date>=start_date & Russel2000.Date<=end_date, :);
US_treasury_bond_index = US_treasury_bond_index(US_treasury_bond_index.Date>=start_date & US_treasury_bond_index.Date<=end_date, :);
GSCI = GSCI(GSCI.Date>=start_date & GSCI.Date<=end_date, :);

% Simple Returns

Russel2000_monthly = monthly_log_return(Russel2000, "Open", "AdjClose", "Russel2000");

SP500_monthly = monthly_log_return(SP500, "Open", "AdjClose", "SP500");

US_treasury_bond_index_monthly = monthly_log_return(US_treasury_bond_index, "S_PU_S_TreasuryBondIndex", "S_PU_S_TreasuryBondIndex", "US_treasury_bond_index");

GSCI_monthly = monthly_log_return(GSCI, "S_PGSCI", "S_PGSCI", "GSCI");

BTC_monthly = monthly_log_return(BTC, "Adj_Close", "Adj_Close", "BTC");


% Sharpe Ratio

Returns_monthly = [mean(BTC_monthly.BTC),mean(SP500_monthly.SP500),mean(Russel2000_monthly.Russel2000),mean(US_treasury_bond_index_monthly.US_treasury_bond_index),mean(GSCI_monthly.GSCI)];
STD_monthly = [std(BTC_monthly.BTC),std(SP500_monthly.SP500),std(Russel2000_monthly.Russel2000),std(US_treasury_bond_index_monthly.US_treasury_bond_index),std(GSCI_monthly.GSCI)];
SR_monthly = Returns_monthly./STD_monthly;
Returns_ann = Returns_monthly*12;
STD_ann = STD_monthly*sqrt(12);
SR_ann = SR_monthly*sqrt(12);
OBS = [height(BTC_monthly), height(SP500_monthly), height(Russel2000_monthly), height(US_treasury_bond_index_monthly), height(GSCI_monthly)];

SP_table = [Returns_monthly*100;STD_monthly*100;SR_monthly;Returns_ann*100;STD_ann*100;SR_ann;OBS]';
info.rnames = strvcat('.','BTC','SPX','Russel_2000','US_Bond_Index','US_Commodity_Index');
info.cnames = strvcat('mu (%)','sigma (%)','SR_daily','mu (%)','sigma (%)','SR_ann','Obs');
info.fmt    = '%1.2f';
disp('Sharpe Rratio')
mprint(SP_table,info)


    function monthly_table = monthly_log_return(datatable, openprice, closeprice, indexname)
        % datatable = Russel2000;

        datatable.YearMonth = dateshift(datatable.Date, 'start', 'month');
        unique_months = unique(datatable.YearMonth);
        monthly_price = nan(length(unique_months)+1, 1);
        monthly_price(1)=datatable.(openprice)(1);

        error_month = [];
        % Calculate monthly returns
        for j = 1:length(unique_months)
            month_data = datatable(datatable.YearMonth == unique_months(j), :);

            % Ensure there are data points for the month
            if height(month_data) > 15
                monthly_price(j+1) = month_data.(closeprice)(end);
            else
                error_month=[error_month,j+1];
            end
        end
        monthly_price(error_month,:)=[];

        monthly_ret = price2ret(monthly_price);

        monthly_date = datetime(unique(dateshift(datatable.Date, 'start', 'month')), "Format","yyyy-MM");
        monthly_date(error_month,:)=[];

        monthly_table = [table(monthly_date,'VariableNames',"Month"), table(monthly_ret,'VariableNames',indexname)];

    end


end
