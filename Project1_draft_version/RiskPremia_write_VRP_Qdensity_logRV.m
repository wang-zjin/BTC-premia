%% Volatility risk prermium
% 1. Q estimated from interpolated IV
% 2. P estimated by kernel density
% 3. P realised volatility
% 4. P forward-looking volatility
%% load data
clear,clc
[~,~,~]=mkdir("RiskPremia/1_12_3_1_2/");
addpath("m_Files_Color/colormap/")
daily_price = readtable("data/BTC_USD_Quandl_2015_2022.csv");

ttm = 27;

fid = fopen('Clustering/Clustering_0_3_0_multiQ_QfromIV_R99/common dates.txt', 'r');
file_content = fscanf(fid, '%c');
fclose(fid);
file_content = strrep(file_content, '[', '');
file_content = strrep(file_content, ']', '');
file_content = strrep(file_content, ' ', '');
file_content = strrep(file_content, '''', '');
Common_dates = split(file_content, ',');
Common_dates = string(Common_dates);

IV_matrx = readtable(strcat("data/IV/interpolated IVs R2 0.99/merged/interpolated_IVmatrix_ttm",num2str(ttm),"_R99_merged.csv"),"VariableNamingRule","preserve","ReadVariableNames",true);
Dates_ttm = string(IV_matrx.Properties.VariableNames(2:end)');
ind = ismember(Dates_ttm,Common_dates);
dates_list = datetime(string(IV_matrx.Properties.VariableNames(2:end)'), "InputFormat","yyyyMMdd","Format","yyyy-MM-dd");
dates_list = dates_list(ind);
dates = string(dates_list);

 
% dates_cluster = dates(end:-1:1);
dates_cluster = dates;
dates_Q =cell(1,2);
index0 = ([0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
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
index1 = ([0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
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
dates_Q{1,1} = dates_cluster(index0);
dates_Q{1,2} = dates_cluster(index1);
tb_date_cluster0 = table(dates_list(index0),'VariableNames',"Date");
tb_date_cluster1 = table(dates_list(index1),'VariableNames',"Date");
tb_date_overall = table(dates_list,'VariableNames',"Date");

%% Realized volatility
realized_vola = zeros(numel(dates),2);
for i = 1:length(dates)

    sp1=sortrows(daily_price,"Date");
    logret_before = price2ret(sp1.Adj_Close(datenum(sp1.Date)>=datenum(dates(i),"yyyy-mm-dd")-ttm-1 & datenum(sp1.Date)<=datenum(dates(i),"yyyy-mm-dd")-1));
    logret_after = price2ret(sp1.Adj_Close(datenum(sp1.Date)>=datenum(dates(i),"yyyy-mm-dd")+1 & datenum(sp1.Date)<=datenum(dates(i),"yyyy-mm-dd")+ttm));
    realized_vola(i,1)=sqrt(sum(logret_before.^2)*365/ttm);
    realized_vola(i,2)=sqrt(sum(logret_after.^2)*365/ttm);
end

tb_RV_cluster0 = [tb_date_cluster0, table(realized_vola(index0,1).^2,'VariableNames',"RV"),table(zeros(size(tb_date_cluster0)),'VariableNames',"Cluster")];
tb_RV_cluster1 = [tb_date_cluster1, table(realized_vola(index1,1).^2,'VariableNames',"RV"),table(ones(size(tb_date_cluster1)),'VariableNames',"Cluster")];
tb_RV_overall = [tb_date_overall, table(realized_vola(:,1).^2,'VariableNames',"RV"),table(index1','VariableNames',"Cluster")];

%% Generate time varying Q moments table
ret = (-1:0.01:1)';
% Q-density
Q_cluster0 = zeros(numel(-1:0.01:1),numel(dates_Q{1,1}));
Q_cluster1 = zeros(numel(-1:0.01:1),numel(dates_Q{1,2}));
for i=1:numel(dates_Q{1,1})
    a = strcat("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Output/Q_density_logreturn_",dates_Q{1,1}(i),".csv");
    data_q = readtable(a);
    Q_cluster0(:,i)=interp1(exp(data_q.Return)-1,data_q.Q_density./exp(data_q.Return),ret,'linear','extrap');
end
Q_cluster0(Q_cluster0<0)=0;
Q_cluster0_average=mean(Q_cluster0,2);
for i=1:numel(dates_Q{1,2})
    a = strcat("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Output/Q_density_logreturn_",dates_Q{1,2}(i),".csv");
    data_q = readtable(a);
    Q_cluster1(:,i)=interp1(exp(data_q.Return)-1,data_q.Q_density./exp(data_q.Return),ret,'linear','extrap');
end
Q_cluster1(Q_cluster1<0)=0;
Q_cluster1_average=mean(Q_cluster1,2);
Q_overall = [Q_cluster0 Q_cluster1];
Q_average = mean(Q_overall,2);

Moments_Q_t = zeros(size(Q_overall,2),7);
Moments_Q_t(:,1) = trapz(ret,Q_overall);
Moments_Q_t(:,2) = trapz(ret,Q_overall.*repmat(ret,1,size(Q_overall,2)));% 1th moment
Moments_Q_t(:,3) = trapz(ret,Q_overall.*(repmat(ret,1,size(Q_overall,2))-repmat(Moments_Q_t(:,2)',size(Q_overall,1),1)).^2);% 2th central moment
Moments_Q_t(:,4) = trapz(ret,Q_overall.*(repmat(ret,1,size(Q_overall,2))-repmat(Moments_Q_t(:,2)',size(Q_overall,1),1)).^3);% 3th central moment
Moments_Q_t(:,5) = trapz(ret,Q_overall.*(repmat(ret,1,size(Q_overall,2))-repmat(Moments_Q_t(:,2)',size(Q_overall,1),1)).^4);% 4th central moment
Moments_Q_t(:,6) = Moments_Q_t(:,4)./(Moments_Q_t(:,3).^1.5);  % Skewness
Moments_Q_t(:,7) = Moments_Q_t(:,5)./(Moments_Q_t(:,3).^2)-3;  % Kurtosis

Moments_Q_c1_t = zeros(size(Q_cluster1,2),7);
Moments_Q_c1_t(:,1) = trapz(ret,Q_cluster1);
Moments_Q_c1_t(:,2) = trapz(ret,Q_cluster1.*repmat(ret,1,size(Q_cluster1,2)));% 1th moment
Moments_Q_c1_t(:,3) = trapz(ret,Q_cluster1.*(repmat(ret,1,size(Q_cluster1,2))-repmat(Moments_Q_c1_t(:,2)',size(Q_cluster1,1),1)).^2);% 2th central moment
Moments_Q_c1_t(:,4) = trapz(ret,Q_cluster1.*(repmat(ret,1,size(Q_cluster1,2))-repmat(Moments_Q_c1_t(:,2)',size(Q_cluster1,1),1)).^3);% 3th central moment
Moments_Q_c1_t(:,5) = trapz(ret,Q_cluster1.*(repmat(ret,1,size(Q_cluster1,2))-repmat(Moments_Q_c1_t(:,2)',size(Q_cluster1,1),1)).^4);% 4th central moment
Moments_Q_c1_t(:,6) = Moments_Q_c1_t(:,4)./(Moments_Q_c1_t(:,3).^1.5);  % Skewness
Moments_Q_c1_t(:,7) = Moments_Q_c1_t(:,5)./(Moments_Q_c1_t(:,3).^2)-3;  % Kurtosis

Moments_Q_c0_t = zeros(size(Q_cluster0,2),7);
Moments_Q_c0_t(:,1) = trapz(ret,Q_cluster0);
Moments_Q_c0_t(:,2) = trapz(ret,Q_cluster0.*repmat(ret,1,size(Q_cluster0,2)));% 1th moment
Moments_Q_c0_t(:,3) = trapz(ret,Q_cluster0.*(repmat(ret,1,size(Q_cluster0,2))-repmat(Moments_Q_c0_t(:,2)',size(Q_cluster0,1),1)).^2);% 2th central moment
Moments_Q_c0_t(:,4) = trapz(ret,Q_cluster0.*(repmat(ret,1,size(Q_cluster0,2))-repmat(Moments_Q_c0_t(:,2)',size(Q_cluster0,1),1)).^3);% 3th central moment
Moments_Q_c0_t(:,5) = trapz(ret,Q_cluster0.*(repmat(ret,1,size(Q_cluster0,2))-repmat(Moments_Q_c0_t(:,2)',size(Q_cluster0,1),1)).^4);% 4th central moment
Moments_Q_c0_t(:,6) = Moments_Q_c0_t(:,4)./(Moments_Q_c0_t(:,3).^1.5);  % Skewness
Moments_Q_c0_t(:,7) = Moments_Q_c0_t(:,5)./(Moments_Q_c0_t(:,3).^2)-3;  % Kurtosis

tb_Moments_Q_t = [[tb_date_cluster0;tb_date_cluster1], array2table(Moments_Q_t(:,[2,3,6,7]),'VariableNames',["Mean","Variance","Skewness","Kurtosis"])];
tb_Moments_Q_c0_t = [tb_date_cluster0, array2table(Moments_Q_c0_t(:,[2,3,6,7]),'VariableNames',["Mean","Variance","Skewness","Kurtosis"])];
tb_Moments_Q_c1_t = [tb_date_cluster1, array2table(Moments_Q_c1_t(:,[2,3,6,7]),'VariableNames',["Mean","Variance","Skewness","Kurtosis"])];

%% Generate table "tb_Qdensity_RV_VRP"
tb_Q_variance_Qdensity_overall = tb_Moments_Q_t(:,["Date","Variance"]);
tb_Q_variance_Qdensity_cluster0 = tb_Moments_Q_c0_t(:,["Date","Variance"]);
tb_Q_variance_Qdensity_cluster1 = tb_Moments_Q_c1_t(:,["Date","Variance"]);

tb_Q_variance_Qdensity_overall.Variance = tb_Q_variance_Qdensity_overall.Variance*365/ttm;
tb_Q_variance_Qdensity_cluster0.Variance = tb_Q_variance_Qdensity_cluster0.Variance*365/ttm;
tb_Q_variance_Qdensity_cluster1.Variance = tb_Q_variance_Qdensity_cluster1.Variance*365/ttm;

tb_Q_variance_Qdensity_overall.Properties.VariableNames("Variance") = "Q_variance_Qdensity";
tb_Q_variance_Qdensity_cluster0.Properties.VariableNames("Variance") = "Q_variance_Qdensity";
tb_Q_variance_Qdensity_cluster1.Properties.VariableNames("Variance") = "Q_variance_Qdensity";

tb_Qdensity_RV_VRP_overall = innerjoin(tb_Q_variance_Qdensity_overall, tb_RV_overall,"Key","Date");
tb_Qdensity_RV_VRP_cluster0 = innerjoin(tb_Q_variance_Qdensity_cluster0, tb_RV_cluster0,"Key","Date");
tb_Qdensity_RV_VRP_cluster1 = innerjoin(tb_Q_variance_Qdensity_cluster1, tb_RV_cluster1,"Key","Date");
tb_Qdensity_RV_VRP_overall = addvars(tb_Qdensity_RV_VRP_overall, tb_Qdensity_RV_VRP_overall.Q_variance_Qdensity-tb_Qdensity_RV_VRP_overall.RV, 'NewVariableNames',"VRP");
tb_Qdensity_RV_VRP_cluster0 = addvars(tb_Qdensity_RV_VRP_cluster0, tb_Qdensity_RV_VRP_cluster0.Q_variance_Qdensity-tb_Qdensity_RV_VRP_cluster0.RV, 'NewVariableNames',"VRP");
tb_Qdensity_RV_VRP_cluster1 = addvars(tb_Qdensity_RV_VRP_cluster1, tb_Qdensity_RV_VRP_cluster1.Q_variance_Qdensity-tb_Qdensity_RV_VRP_cluster1.RV, 'NewVariableNames',"VRP");

%% Save tb_Qdensity_RV_VRP_cluster0, tb_Qdensity_RV_VRP_cluster1
writetable(tb_Qdensity_RV_VRP_cluster0,"RiskPremia/1_12_3_1_2/VRP_Qdensity_logRV_cluster0.csv");
writetable(tb_Qdensity_RV_VRP_cluster1,"RiskPremia/1_12_3_1_2/VRP_Qdensity_logRV_cluster1.csv");