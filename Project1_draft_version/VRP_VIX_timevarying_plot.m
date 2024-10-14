%% Volatility risk prermium
% 1. Q estimated from interpolated IV
% 2. P estimated by kernel density
% 3. P realised volatility
% 4. P forward-looking volatility

% Difference between "BTC_1_12_3_3_ttm27_QfromIV_multiQ_VRP_VIX_2cluster.m" with
% "BTC_1_12_3_1_2_ttm27_QfromIV_multiQ_VRP_VIX_2cluster.m" ?
%
% - "BTC_1_12_3_3_ttm27_QfromIV_multiQ_VRP_VIX_2cluster.m" does not
% calculate "tb_VIX_RV_VRP" table
%
% - "BTC_1_12_3_1_2_ttm27_QfromIV_multiQ_VRP_VIX_2cluster.m" does calculate
% "tb_VIX_RV_VRP" table
%% load data
clear,clc
[~,~,~]=mkdir("VRP/1_12_3_1_2/");
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

    sp1=daily_price(end:-1:1,:);
    logret_before = price2ret(sp1.Adj_Close(datenum(sp1.Date)>=datenum(dates(i),"yyyy-mm-dd")-ttm-1 & datenum(sp1.Date)<=datenum(dates(i),"yyyy-mm-dd")-1));
    logret_after = price2ret(sp1.Adj_Close(datenum(sp1.Date)>=datenum(dates(i),"yyyy-mm-dd") & datenum(sp1.Date)<=datenum(dates(i),"yyyy-mm-dd")+ttm));
    realized_vola(i,1)=sqrt(sum(logret_before.^2)*365/ttm);
    realized_vola(i,2)=sqrt(sum(logret_after.^2)*365/ttm);
end

RV=nan(4,3);
RV(1,:)=[mean(realized_vola(index0,1)),mean(realized_vola(index1,1)),mean(realized_vola(:,1))];
RV(2,:)=[std(realized_vola(index0,1)), std(realized_vola(index1,1)), std(realized_vola(:,1))];
RV(3,:)=[mean(realized_vola(index0,2)),mean(realized_vola(index1,2)),mean(realized_vola(:,2))];
RV(4,:)=[std(realized_vola(index0,2)), std(realized_vola(index1,2)), std(realized_vola(:,2))];
clear info;
info.rnames = strvcat('.',['Realized volatility ttm = ',num2str(ttm)],'std',['Forward-looking volatility ttm = ',num2str(ttm)],'std');
info.cnames = strvcat('Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
mprint(RV,info)

tb_RV_cluster0 = [tb_date_cluster0, table(realized_vola(index0,1).^2,'VariableNames',"RV")];
tb_RV_cluster1 = [tb_date_cluster1, table(realized_vola(index1,1).^2,'VariableNames',"RV")];
tb_RV_overall = [tb_date_overall, table(realized_vola(:,1).^2,'VariableNames',"RV")];

%% Plot BTC daily price
daily_price_sub = daily_price(daily_price.Date>datetime("2017-07-01"),:);
figure;
plot(daily_price_sub.Date,daily_price_sub.Adj_Close,'LineWidth',2);hold on
x_shaded = [datetime("2020-02-15"), datetime("2020-05-08"), datetime("2020-05-08"), datetime("2020-02-15")];% x-coordinates of the shaded area
y_shaded = [-0.5, -0.5, max(daily_price_sub.Adj_Close)*2, max(daily_price_sub.Adj_Close)*2];% y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
xlim([min(daily_price_sub.Date)-20,max(daily_price_sub.Date)])
ylim([0,max(daily_price_sub.Adj_Close)*1.1])
set(gcf,'Position',[0,0,450,300])
% Turn off the box surrounding the plot
% Hide the top (north) and right (east) lines of the frame
box on
ax = gca;
ax.YAxisLocation = 'left';
ax.XAxisLocation = 'bottom';
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
saveas(gcf,"VRP/1_12_3_1_2/BTC_daily_RV_outliers.png")
%% Rolling window return
roll_ret = zeros(numel(dates),2);
for i = 1:length(dates)

        sp1=daily_price(end:-1:1,:);
        logret_before=price2ret(sp1.Adj_Close(datenum(sp1.Date)>=datenum(dates(i),"yyyy-mm-dd")-ttm & datenum(sp1.Date)<=datenum(dates(i),"yyyy-mm-dd")));
        logret_after=price2ret(sp1.Adj_Close(datenum(sp1.Date)>=datenum(dates(i),"yyyy-mm-dd") & datenum(sp1.Date)<=datenum(dates(i),"yyyy-mm-dd")+ttm));
        roll_ret(i,1)=sum(logret_before)*365/ttm;
        roll_ret(i,2)=sum(logret_after)*365/ttm;
%         roll_ret(i,1)=prod(logret_before+1)^(365/ttm);
%         roll_ret(i,2)=prod(logret_after+1)^(365/ttm);
end

RR=nan(4,3);
RR(1,:)=[mean(roll_ret(index0,1)),mean(roll_ret(index1,1)),mean(roll_ret(:,1))];
RR(2,:)=[std(roll_ret(index0,1)), std(roll_ret(index1,1)), std(roll_ret(:,1))];
RR(3,:)=[mean(roll_ret(index0,2)),mean(roll_ret(index1,2)),mean(roll_ret(:,2))];
RR(4,:)=[std(roll_ret(index0,2)), std(roll_ret(index1,2)), std(roll_ret(:,2))];
clear info;
info.rnames = strvcat('.','S_{t-1}/S_{t-ttm}-1','std','S_{t+ttm}/S_{t+1}','std');
info.cnames = strvcat('Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
mprint(RR,info)

% Output past return, future return
tb_PR_FR = [tb_date_overall,...
    array2table(roll_ret,'VariableNames',["PR","FR"]),...
    table(index1','VariableNames',"Cluster")];
writetable(tb_PR_FR,"VRP/1_12_3_1_2/Cluster_PR_FR.csv");
%% Regression

lm=fitlm([roll_ret(index0,1),realized_vola(index0,1)],realized_vola(index0,2))
lm=fitlm([roll_ret(index1,1),realized_vola(index1,1)],realized_vola(index1,2))

lm=fitlm([roll_ret(index0,1),realized_vola(index0,1)],roll_ret(index0,2))
lm=fitlm([roll_ret(index1,1),realized_vola(index1,1)],roll_ret(index1,2))

lm=fitlm([realized_vola(index0,1)],realized_vola(index0,2))
lm=fitlm([roll_ret(index0,1)],roll_ret(index0,2))

lm=fitlm([realized_vola(index1,1)],realized_vola(index1,2))
lm=fitlm([roll_ret(index1,1)],roll_ret(index1,2))

%% Q-density
ret = (-1:0.01:1)';
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
%% forward-looking returns
return_cluster0 = zeros(size(dates_Q{1,1}));
return_cluster1 = zeros(size(dates_Q{1,2}));
for i=1:numel(return_cluster0)
    sp1=daily_price;
    sp1(datenum(sp1.Date)<datenum(dates_Q{1,1}(i),"yyyy-mm-dd") | datenum(sp1.Date)>datenum(dates_Q{1,1}(i),"yyyy-mm-dd")+ttm,:)=[];
    return_cluster0(i)=sp1.Adj_Close(end)/sp1.Adj_Close(1)-1;
end
for i=1:numel(return_cluster1)
    sp1=daily_price;
    sp1(datenum(sp1.Date)<datenum(dates_Q{1,2}(i),"yyyy-mm-dd") | datenum(sp1.Date)>datenum(dates_Q{1,2}(i),"yyyy-mm-dd")+ttm,:)=[];
    return_cluster1(i)=sp1.Adj_Close(end)/sp1.Adj_Close(1)-1;
end
return_overall = [return_cluster0;return_cluster1];
%% VRP: Q density - forward P
ret = (-1:0.01:1)';
Moments_Q = zeros(1,7);
Moments_Q(1,1) = trapz(ret,Q_average);
Moments_Q(1,2) = trapz(ret,Q_average.*ret);% 1th moment
Moments_Q(1,3) = trapz(ret,Q_average.*(ret-Moments_Q(1,2)).^2);% 2th central moment
Moments_Q(1,4) = trapz(ret,Q_average.*(ret-Moments_Q(1,2)).^3);% 3th central moment
Moments_Q(1,5) = trapz(ret,Q_average.*(ret-Moments_Q(1,2)).^4);% 4th central moment
Moments_Q(1,6) = Moments_Q(1,4)/(Moments_Q(1,3)^1.5);  % Skewness
Moments_Q(1,7) = Moments_Q(1,5)/(Moments_Q(1,3)^2)-3;  % Kurtosis

Moments_Q_c1 = zeros(1,7);
Moments_Q_c1(1,1) = trapz(ret,Q_cluster1_average);
Moments_Q_c1(1,2) = trapz(ret,Q_cluster1_average.*ret);% 1th moment
Moments_Q_c1(1,3) = trapz(ret,Q_cluster1_average.*(ret-Moments_Q_c1(1,2)).^2);% 2th central moment
Moments_Q_c1(1,4) = trapz(ret,Q_cluster1_average.*(ret-Moments_Q_c1(1,2)).^3);% 3th central moment
Moments_Q_c1(1,5) = trapz(ret,Q_cluster1_average.*(ret-Moments_Q_c1(1,2)).^4);% 4th central moment
Moments_Q_c1(1,6) = Moments_Q_c1(1,4)/(Moments_Q_c1(1,3)^1.5);  % Skewness
Moments_Q_c1(1,7) = Moments_Q_c1(1,5)/(Moments_Q_c1(1,3)^2)-3;  % Kurtosis

Moments_Q_c0 = zeros(1,7);
Moments_Q_c0(1,1) = trapz(ret,Q_cluster0_average);
Moments_Q_c0(1,2) = trapz(ret,Q_cluster0_average.*ret);% 1th moment
Moments_Q_c0(1,3) = trapz(ret,Q_cluster0_average.*(ret-Moments_Q_c0(1,2)).^2);% 2th central moment
Moments_Q_c0(1,4) = trapz(ret,Q_cluster0_average.*(ret-Moments_Q_c0(1,2)).^3);% 3th central moment
Moments_Q_c0(1,5) = trapz(ret,Q_cluster0_average.*(ret-Moments_Q_c0(1,2)).^4);% 4th central moment
Moments_Q_c0(1,6) = Moments_Q_c0(1,4)/(Moments_Q_c0(1,3)^1.5);  % Skewness
Moments_Q_c0(1,7) = Moments_Q_c0(1,5)/(Moments_Q_c0(1,3)^2)-3;  % Kurtosis

f_forward = ksdensity(return_overall,ret); 
Moments_P_forward = zeros(1,7);
Moments_P_forward(1,1) = trapz(ret,f_forward);
Moments_P_forward(1,2) = trapz(ret,f_forward.*ret);% 1th moment
Moments_P_forward(1,3) = trapz(ret,f_forward.*(ret-Moments_P_forward(1,2)).^2);% 2th central moment
Moments_P_forward(1,4) = trapz(ret,f_forward.*(ret-Moments_P_forward(1,2)).^3);% 3th central moment
Moments_P_forward(1,5) = trapz(ret,f_forward.*(ret-Moments_P_forward(1,2)).^4);% 4th central moment
Moments_P_forward(1,6) = Moments_P_forward(1,4)/(Moments_P_forward(1,3)^1.5);  % Skewness
Moments_P_forward(1,7) = Moments_P_forward(1,5)/(Moments_P_forward(1,3)^2)-3;  % Kurtosis

f0_forward = ksdensity(return_cluster0,ret); 
Moments_P_c0_forward = zeros(1,7);
Moments_P_c0_forward(1,1) = trapz(ret,f0_forward);
Moments_P_c0_forward(1,2) = trapz(ret,f0_forward.*ret);% 1th moment
Moments_P_c0_forward(1,3) = trapz(ret,f0_forward.*(ret-Moments_P_c0_forward(1,2)).^2);% 2th central moment
Moments_P_c0_forward(1,4) = trapz(ret,f0_forward.*(ret-Moments_P_c0_forward(1,2)).^3);% 3th central moment
Moments_P_c0_forward(1,5) = trapz(ret,f0_forward.*(ret-Moments_P_c0_forward(1,2)).^4);% 4th central moment
Moments_P_c0_forward(1,6) = Moments_P_c0_forward(1,4)/(Moments_P_c0_forward(1,3)^1.5);  % Skewness
Moments_P_c0_forward(1,7) = Moments_P_c0_forward(1,5)/(Moments_P_c0_forward(1,3)^2)-3;  % Kurtosis

f1_forward = ksdensity(return_cluster1,ret); 
Moments_P_c1_forward = zeros(1,7);
Moments_P_c1_forward(1,1) = trapz(ret,f1_forward);
Moments_P_c1_forward(1,2) = trapz(ret,f1_forward.*ret);% 1th moment
Moments_P_c1_forward(1,3) = trapz(ret,f1_forward.*(ret-Moments_P_c1_forward(1,2)).^2);% 2th central moment
Moments_P_c1_forward(1,4) = trapz(ret,f1_forward.*(ret-Moments_P_c1_forward(1,2)).^3);% 3th central moment
Moments_P_c1_forward(1,5) = trapz(ret,f1_forward.*(ret-Moments_P_c1_forward(1,2)).^4);% 4th central moment
Moments_P_c1_forward(1,6) = Moments_P_c1_forward(1,4)/(Moments_P_c1_forward(1,3)^1.5);  % Skewness
Moments_P_c1_forward(1,7) = Moments_P_c1_forward(1,5)/(Moments_P_c1_forward(1,3)^2)-3;  % Kurtosis

VRP_forward=nan(3,3);
VRP_forward(1,1:3)=[Moments_Q_c0(1,3),Moments_Q_c1(1,3),Moments_Q(1,3)]*365/ttm;
VRP_forward(2,1:3)=[Moments_P_c0_forward(1,3),Moments_P_c1_forward(1,3),Moments_P_forward(1,3)]*365/ttm;
VRP_forward(3,1:3)=VRP_forward(1,:)-VRP_forward(2,:);
clear info;
info.rnames = strvcat('.','Q annualized variance','P annualized variance','Variance risk premium');
info.cnames = strvcat('Cluster 0','Cluster 1','Overall');
info.fmt    = '%10.2f';
mprint(VRP_forward,info)
% Save VRP data
outputtable = array2table(VRP_forward','VariableNames',["Q","P","VRP"]);
writetable(outputtable, "VRP/1_12_3_1_2/Qdensity_ForwardDensity.csv")


%% backward-looking returns
return_cluster0 = zeros(size(dates_Q{1,1}));
return_cluster1 = zeros(size(dates_Q{1,2}));
return_cluster0_1lag = zeros(size(dates_Q{1,1}));
return_cluster1_1lag = zeros(size(dates_Q{1,2}));
for i=1:numel(return_cluster0)
    sp1=daily_price;
    sp1(datenum(sp1.Date)<datenum(dates_Q{1,1}(i),"yyyy-mm-dd")-ttm | datenum(sp1.Date)>datenum(dates_Q{1,1}(i),"yyyy-mm-dd"),:)=[];
    return_cluster0(i)=sp1.Adj_Close(end)/sp1.Adj_Close(1)-1;
    sp2=daily_price;
    sp2(datenum(sp2.Date)<datenum(dates_Q{1,1}(i),"yyyy-mm-dd")-ttm | datenum(sp2.Date)>=datenum(dates_Q{1,1}(i),"yyyy-mm-dd"),:)=[];
    return_cluster0_1lag(i)=sp2.Adj_Close(end)/sp2.Adj_Close(1)-1;
end
for i=1:numel(return_cluster1)
    sp1=daily_price;
    sp1(datenum(sp1.Date)<datenum(dates_Q{1,2}(i),"yyyy-mm-dd")-ttm | datenum(sp1.Date)>datenum(dates_Q{1,2}(i),"yyyy-mm-dd"),:)=[];
    return_cluster1(i)=sp1.Adj_Close(end)/sp1.Adj_Close(1)-1;
    sp2=daily_price;
    sp2(datenum(sp2.Date)<datenum(dates_Q{1,2}(i),"yyyy-mm-dd")-ttm | datenum(sp2.Date)>=datenum(dates_Q{1,2}(i),"yyyy-mm-dd"),:)=[];
    return_cluster1_1lag(i)=sp2.Adj_Close(end)/sp2.Adj_Close(1)-1;
end
return_overall = [return_cluster0;return_cluster1];
return_overall_1lag = [return_cluster0_1lag;return_cluster1_1lag];
%% VRP: Q density - backward P

f_backward = ksdensity(return_overall,ret); 
Moments_P_backward = zeros(1,7);
Moments_P_backward(1,1) = trapz(ret,f_backward);
Moments_P_backward(1,2) = trapz(ret,f_backward.*ret);% 1th moment
Moments_P_backward(1,3) = trapz(ret,f_backward.*(ret-Moments_P_backward(1,2)).^2);% 2th central moment
Moments_P_backward(1,4) = trapz(ret,f_backward.*(ret-Moments_P_backward(1,2)).^3);% 3th central moment
Moments_P_backward(1,5) = trapz(ret,f_backward.*(ret-Moments_P_backward(1,2)).^4);% 4th central moment
Moments_P_backward(1,6) = Moments_P_backward(1,4)/(Moments_P_backward(1,3)^1.5);  % Skewness
Moments_P_backward(1,7) = Moments_P_backward(1,5)/(Moments_P_backward(1,3)^2)-3;  % Kurtosis

f0_backward = ksdensity(return_cluster0,ret); 
Moments_P_c0_backward = zeros(1,7);
Moments_P_c0_backward(1,1) = trapz(ret,f0_backward);
Moments_P_c0_backward(1,2) = trapz(ret,f0_backward.*ret);% 1th moment
Moments_P_c0_backward(1,3) = trapz(ret,f0_backward.*(ret-Moments_P_c0_backward(1,2)).^2);% 2th central moment
Moments_P_c0_backward(1,4) = trapz(ret,f0_backward.*(ret-Moments_P_c0_backward(1,2)).^3);% 3th central moment
Moments_P_c0_backward(1,5) = trapz(ret,f0_backward.*(ret-Moments_P_c0_backward(1,2)).^4);% 4th central moment
Moments_P_c0_backward(1,6) = Moments_P_c0_backward(1,4)/(Moments_P_c0_backward(1,3)^1.5);  % Skewness
Moments_P_c0_backward(1,7) = Moments_P_c0_backward(1,5)/(Moments_P_c0_backward(1,3)^2)-3;  % Kurtosis

f1_backward = ksdensity(return_cluster1,ret); 
Moments_P_c1_backward = zeros(1,7);
Moments_P_c1_backward(1,1) = trapz(ret,f1_backward);
Moments_P_c1_backward(1,2) = trapz(ret,f1_backward.*ret);% 1th moment
Moments_P_c1_backward(1,3) = trapz(ret,f1_backward.*(ret-Moments_P_c1_backward(1,2)).^2);% 2th central moment
Moments_P_c1_backward(1,4) = trapz(ret,f1_backward.*(ret-Moments_P_c1_backward(1,2)).^3);% 3th central moment
Moments_P_c1_backward(1,5) = trapz(ret,f1_backward.*(ret-Moments_P_c1_backward(1,2)).^4);% 4th central moment
Moments_P_c1_backward(1,6) = Moments_P_c1_backward(1,4)/(Moments_P_c1_backward(1,3)^1.5);  % Skewness
Moments_P_c1_backward(1,7) = Moments_P_c1_backward(1,5)/(Moments_P_c1_backward(1,3)^2)-3;  % Kurtosis

VRP_backward=nan(3,3);
VRP_backward(1,1:3)=[Moments_Q_c0(1,3),Moments_Q_c1(1,3),Moments_Q(1,3)]*365/ttm;
VRP_backward(2,1:3)=[Moments_P_c0_backward(1,3),Moments_P_c1_backward(1,3),Moments_P_backward(1,3)]*365/ttm;
VRP_backward(3,1:3)=VRP_backward(1,:)-VRP_backward(2,:);
clear info;
info.rnames = strvcat('.','Q annualized variance','P annualized variance','Variance risk premium');
info.cnames = strvcat('Cluster 0','Cluster 1','Overall');
info.fmt    = '%10.2f';
mprint(VRP_backward,info)
% Save VRP data
outputtable = array2table(VRP_backward','VariableNames',["Q","P","VRP"]);
writetable(outputtable, "VRP/1_12_3_1_2/Qdensity_BackwardDensity.csv")
%% VRP: Q density variance - realized variance
VRP_RV=nan(4,3);
VRP_RV(1,:)=[Moments_Q_c0(1,3),Moments_Q_c1(1,3),Moments_Q(1,3)]*365/ttm;
VRP_RV(2,:)=[mean(realized_vola(index0,1).^2),mean(realized_vola(index1,1).^2),mean(realized_vola(:,1).^2)];
VRP_RV(3,:)=VRP_RV(1,:)-VRP_RV(2,:);
VRP_RV(4,:)=[numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_list)];
clear info;
info.rnames = strvcat('.','Q annualized variance','P annualized backward-looking variance','Variance risk premium','Num. of observation');
info.cnames = strvcat('Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
mprint(VRP_RV,info)
outputtable = array2table(VRP_RV','VariableNames',["Q","P","VRP","Num"]);
writetable(outputtable, "VRP/1_12_3_1_2/Qdensity_RV.csv")
%% VRP: Q density - forward-looking volatility
VRP_FV=nan(4,3);
VRP_FV(1,:)=[Moments_Q_c0(1,3),Moments_Q_c1(1,3),Moments_Q(1,3)]*365/ttm;
VRP_FV(2,:)=[mean(realized_vola(index0,2).^2),mean(realized_vola(index1,2).^2),mean(realized_vola(:,2).^2)];
VRP_FV(3,:)=VRP_FV(1,:)-VRP_FV(2,:);
VRP_FV(4,:)=[numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_list)];
clear info;
info.rnames = strvcat('.','Q annualized volatility','P annualized forward-looking volatility','Volatility risk premium','Num. of observation');
info.cnames = strvcat('Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
mprint(VRP_FV,info)
% Save VRP data
outputtable = array2table(VRP_RV','VariableNames',["Q","P","VRP","Num"]);
writetable(outputtable, "VRP/1_12_3_1_2/Qdensity_FV.csv")
%% Moments for each time t
ret = (-1:0.01:1)';
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
%% Moments ANOVA of cluster 1 and 0 (annualized)
% Q is Q density
cluster_label = [repmat("cluster_0",numel(dates_Q{1,1}),1);repmat("cluster_1",numel(dates_Q{1,2}),1)];
cluster_label_0 = [repmat("cluster_0",numel(dates_Q{1,1}),1);repmat("overall",numel(dates_Q{1,1})+numel(dates_Q{1,2}),1)];
cluster_label_1 = [repmat("cluster_1",numel(dates_Q{1,2}),1);repmat("overall",numel(dates_Q{1,1})+numel(dates_Q{1,2}),1)];
% P: Forward density vs backward density
[~,tbl11,stats11] = anova1([Moments_Q_c0_t(:,3);Moments_Q_t(:,3)]*365/ttm,cluster_label_0);
[~,tbl12,stats12] = anova1([Moments_Q_c1_t(:,3);Moments_Q_t(:,3)]*365/ttm,cluster_label_1);
[~,tbl31] = anova1(([sqrt(Moments_Q_c0_t(:,3))-sqrt(Moments_P_c0_forward(1,3));sqrt(Moments_Q_t(:,3))-sqrt(Moments_P_forward(1,3))])*sqrt(365/ttm),cluster_label_0);
[~,tbl32] = anova1(([sqrt(Moments_Q_c1_t(:,3))-sqrt(Moments_P_c1_forward(1,3));sqrt(Moments_Q_t(:,3))-sqrt(Moments_P_forward(1,3))])*sqrt(365/ttm),cluster_label_1);
[~,tbl33] = anova1(([sqrt(Moments_Q_c0_t(:,3))-sqrt(Moments_P_c0_backward(1,3));sqrt(Moments_Q_t(:,3))-sqrt(Moments_P_backward(1,3))])*sqrt(365/ttm),cluster_label_0);
[~,tbl34] = anova1(([sqrt(Moments_Q_c1_t(:,3))-sqrt(Moments_P_c1_backward(1,3));sqrt(Moments_Q_t(:,3))-sqrt(Moments_P_backward(1,3))])*sqrt(365/ttm),cluster_label_1);

VRP_difference_for_bac=nan(6,6);
VRP_difference_for_bac(1,:)=[sqrt(stats11.means(1)),sqrt(stats12.means(1)),sqrt(stats11.means(2)),sqrt(stats11.means(1)),sqrt(stats12.means(1)),sqrt(stats11.means(2))];
VRP_difference_for_bac(2,[1,2,4,5])=[tbl11{2,6},tbl12{2,6},tbl11{2,6},tbl12{2,6}];
VRP_difference_for_bac(3,:)=sqrt([Moments_P_c0_forward(1,3),Moments_P_c1_forward(1,3),Moments_P_forward(1,3),Moments_P_c0_backward(1,3),Moments_P_c1_backward(1,3),Moments_P_backward(1,3)]*365/ttm);
VRP_difference_for_bac(4,:)=[VRP_forward(1,:)-VRP_forward(2,:),VRP_backward(1,:)-VRP_backward(2,:)];
VRP_difference_for_bac(5,[1,2,4,5])=[tbl31{2,6},tbl32{2,6},tbl33{2,6},tbl34{2,6}];
VRP_difference_for_bac(6,:)=[numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_Q{1,1})+numel(dates_Q{1,2}),numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_Q{1,1})+numel(dates_Q{1,2})];
clear info;
info.rnames = strvcat('.','Q ann vola','p-value','P ann vola','VRP','p-value','Num of obser');
info.cnames = strvcat('Cluster 0','Cluster 1','Overall','Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
mprint(VRP_difference_for_bac,info)

% P: RV vs FV
[~,tbl11,stats11] = anova1([Moments_Q_c0_t(:,3);Moments_Q_t(:,3)]*365/ttm,cluster_label_0);
[~,tbl12,stats12] = anova1([Moments_Q_c1_t(:,3);Moments_Q_t(:,3)]*365/ttm,cluster_label_1);
[~,tbl31] = anova1(([sqrt(Moments_Q_c0_t(:,3)*365/ttm)-mean(realized_vola(index0,1));sqrt(Moments_Q_t(:,3)*365/ttm)-mean(realized_vola(:,1))]),cluster_label_0);
[~,tbl32] = anova1(([sqrt(Moments_Q_c1_t(:,3)*365/ttm)-mean(realized_vola(index1,1));sqrt(Moments_Q_t(:,3)*365/ttm)-mean(realized_vola(:,1))]),cluster_label_1);
[~,tbl33] = anova1(([sqrt(Moments_Q_c0_t(:,3)*365/ttm)-mean(realized_vola(index0,2));sqrt(Moments_Q_t(:,3)*365/ttm)-mean(realized_vola(:,1))]),cluster_label_0);
[~,tbl34] = anova1(([sqrt(Moments_Q_c1_t(:,3)*365/ttm)-mean(realized_vola(index1,2));sqrt(Moments_Q_t(:,3)*365/ttm)-mean(realized_vola(:,1))]),cluster_label_1);

VRP_difference_RV_FV=nan(6,6);
VRP_difference_RV_FV(1,:)=[sqrt(stats11.means(1)),sqrt(stats12.means(1)),sqrt(stats11.means(2)),sqrt(stats11.means(1)),sqrt(stats12.means(1)),sqrt(stats11.means(2))];
VRP_difference_RV_FV(2,[1,2,4,5])=[tbl11{2,6},tbl12{2,6},tbl11{2,6},tbl12{2,6}];
VRP_difference_RV_FV(3,:)=[mean(realized_vola(index0,1)),mean(realized_vola(index1,1)),mean(realized_vola(:,1)),...
    mean(realized_vola(index0,2)),mean(realized_vola(index1,2)),mean(realized_vola(:,2))];
VRP_difference_RV_FV(4,:)=[VRP_RV(1,:)-VRP_RV(2,:),VRP_FV(1,:)-VRP_FV(2,:)];
VRP_difference_RV_FV(5,[1,2,4,5])=[tbl31{2,6},tbl32{2,6},tbl33{2,6},tbl34{2,6}];
VRP_difference_RV_FV(6,:)=[numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_Q{1,1})+numel(dates_Q{1,2}),numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_Q{1,1})+numel(dates_Q{1,2})];
clear info;
info.rnames = strvcat('.','Q ann vola','p-value','P ann vola','VRP','p-value','Num of obser');
info.cnames = strvcat('Cluster 0','Cluster 1','Overall','Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
mprint(VRP_difference_RV_FV,info)

close all

%% Compare forward and backward P density
P_moments_forward_vs_backward = nan(4,6);
P_moments_forward_vs_backward(1,:) = [Moments_P_c0_forward(1,2),Moments_P_c1_forward(1,2),Moments_P_forward(1,2),Moments_P_c0_backward(1,2),Moments_P_c1_backward(1,2),Moments_P_backward(1,2)]*365/ttm;
P_moments_forward_vs_backward(2,:) = [Moments_P_c0_forward(1,3),Moments_P_c1_forward(1,3),Moments_P_forward(1,3),Moments_P_c0_backward(1,3),Moments_P_c1_backward(1,3),Moments_P_backward(1,3)]*365/ttm;
P_moments_forward_vs_backward(3,:) = [Moments_P_c0_forward(1,6),Moments_P_c1_forward(1,6),Moments_P_forward(1,6),Moments_P_c0_backward(1,6),Moments_P_c1_backward(1,6),Moments_P_backward(1,6)];
P_moments_forward_vs_backward(4,:) = [Moments_P_c0_forward(1,7),Moments_P_c1_forward(1,7),Moments_P_forward(1,7),Moments_P_c0_backward(1,7),Moments_P_c1_backward(1,7),Moments_P_backward(1,7)];
clear info;
info.rnames = strvcat('.','Annual mean','Annual variance','Skewness','Excess kurtosis');
info.cnames = strvcat('Cluster 0','Cluster 1','Overall','Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
mprint(P_moments_forward_vs_backward,info)

%% Introduce VIX
VIX = readtable(['data/VIX/update_20231211/btc_vix_EWA_',num2str(ttm),'.csv']);
Q_vola_VIX_cluster0=VIX.EMA((ismember(VIX.Date,dates_list(index0))))/100;
Q_vola_VIX_cluster1=VIX.EMA((ismember(VIX.Date,dates_list(index1))))/100;
Q_vola_VIX_overall=VIX.EMA((ismember(VIX.Date,dates_list)))/100;
tb_Q_variance_VIX_cluster0 = array2table(Q_vola_VIX_cluster0.^2,'VariableNames',"Q_variance_VIX");
tb_Q_variance_VIX_cluster1 = array2table(Q_vola_VIX_cluster1.^2,'VariableNames',"Q_variance_VIX");
tb_Q_variance_VIX_overall = array2table(Q_vola_VIX_overall.^2,'VariableNames',"Q_variance_VIX");
tb_Q_date_VIX_cluster0 = table(VIX.Date((ismember(VIX.Date,dates_list(index0)))),'VariableNames',"Date");
tb_Q_date_VIX_cluster1 = table(VIX.Date((ismember(VIX.Date,dates_list(index1)))),'VariableNames',"Date");
tb_Q_date_VIX_overall = table(VIX.Date((ismember(VIX.Date,dates_list))),'VariableNames',"Date");
tb_Q_variance_VIX_cluster0 = [tb_Q_date_VIX_cluster0, tb_Q_variance_VIX_cluster0];
tb_Q_variance_VIX_cluster1 = [tb_Q_date_VIX_cluster1, tb_Q_variance_VIX_cluster1];
tb_Q_variance_VIX_overall = [tb_Q_date_VIX_overall, tb_Q_variance_VIX_overall];
%% VRP: VIX - Forward density volatility
VRP_VIX=nan(4,3);
VRP_VIX(1,:)=[mean(Q_vola_VIX_cluster0),mean(Q_vola_VIX_cluster1),mean(Q_vola_VIX_overall)];
VRP_VIX(2,:)=sqrt([Moments_P_c0_forward(1,3),Moments_P_c1_forward(1,3),Moments_P_forward(1,3)]*365/ttm);
VRP_VIX(3,:)=VRP_VIX(1,:)-VRP_VIX(2,:);
VRP_VIX(4,:)=[numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_list)];
clear info;
info.rnames = strvcat('.','Q annualized volatility','P annualized forward-looking volatility','Volatility risk premium','Num. of observation');
info.cnames = strvcat('Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
mprint(VRP_VIX,info)
% Save VRP data
outputtable = array2table(VRP_VIX','VariableNames',["Q","P","VRP","Num"]);
writetable(outputtable, "VRP/1_12_3_1_2/VIX_ForwardDensity.csv")
%% Moments ANOVA of cluster 0 and 1 (annualized)
% P: forward density
cluster_label_0 = [repmat("cluster_0",numel(dates_Q{1,1}),1);repmat("overall",numel(dates_Q{1,1})+numel(dates_Q{1,2}),1)];
cluster_label_1 = [repmat("cluster_1",numel(dates_Q{1,2}),1);repmat("overall",numel(dates_Q{1,1})+numel(dates_Q{1,2}),1)];
cluster_label_0_VIX = [repmat("cluster_0",numel(Q_vola_VIX_cluster0),1);repmat("overall",numel(Q_vola_VIX_cluster0)+numel(Q_vola_VIX_cluster1),1)];
cluster_label_1_VIX = [repmat("cluster_1",numel(Q_vola_VIX_cluster1),1);repmat("overall",numel(Q_vola_VIX_cluster0)+numel(Q_vola_VIX_cluster1),1)];
% Q: Q density vs VIX
[~,tbl11,stats11] = anova1([Moments_Q_c0_t(:,3);Moments_Q_t(:,3)]*365/ttm,cluster_label_0);
[~,tbl12,stats12] = anova1([Moments_Q_c1_t(:,3);Moments_Q_t(:,3)]*365/ttm,cluster_label_1);
[~,tbl13,stats13] = anova1([Q_vola_VIX_cluster0;Q_vola_VIX_overall],cluster_label_0_VIX);
[~,tbl14,stats14] = anova1([Q_vola_VIX_cluster1;Q_vola_VIX_overall],cluster_label_1_VIX);
[~,tbl31] = anova1(([sqrt(Moments_Q_c0_t(:,3))-sqrt(Moments_P_c0_forward(1,3));sqrt(Moments_Q_t(:,3))-sqrt(Moments_P_forward(1,3))])*sqrt(365/ttm),cluster_label_0);
[~,tbl32] = anova1(([sqrt(Moments_Q_c1_t(:,3))-sqrt(Moments_P_c1_forward(1,3));sqrt(Moments_Q_t(:,3))-sqrt(Moments_P_forward(1,3))])*sqrt(365/ttm),cluster_label_1);
[~,tbl33] = anova1(([Q_vola_VIX_cluster0-sqrt(Moments_P_c0_forward(1,3)*365/ttm);Q_vola_VIX_overall-sqrt(Moments_P_forward(1,3)*365/ttm)]),cluster_label_0_VIX);
[~,tbl34] = anova1(([Q_vola_VIX_cluster1-sqrt(Moments_P_c1_forward(1,3)*365/ttm);Q_vola_VIX_overall-sqrt(Moments_P_forward(1,3)*365/ttm)]),cluster_label_1_VIX);

VRP_difference_for_VIX=nan(6,6);
VRP_difference_for_VIX(1,:)=[sqrt(stats11.means(1)),sqrt(stats12.means(1)),sqrt(stats11.means(2)),stats13.means(1),stats14.means(1),stats13.means(2)];
VRP_difference_for_VIX(2,[1,2,4,5])=[tbl11{2,6},tbl12{2,6},tbl13{2,6},tbl14{2,6}];
VRP_difference_for_VIX(3,:)=sqrt([Moments_P_c0_forward(1,3),Moments_P_c1_forward(1,3),Moments_P_forward(1,3),Moments_P_c0_forward(1,3),Moments_P_c1_forward(1,3),Moments_P_forward(1,3)]*365/ttm);
VRP_difference_for_VIX(4,:)=[VRP_forward(3,:),VRP_VIX(3,:)];
VRP_difference_for_VIX(5,[1,2,4,5])=[tbl31{2,6},tbl32{2,6},tbl33{2,6},tbl34{2,6}];
VRP_difference_for_VIX(6,:)=[numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_Q{1,1})+numel(dates_Q{1,2}),numel(Q_vola_VIX_cluster0),numel(Q_vola_VIX_cluster1),numel(Q_vola_VIX_overall)];
clear info;
info.rnames = strvcat('.','Q ann vola','p-value','P ann vola','VRP','p-value','Num of obser');
info.cnames = strvcat('Cluster 0','Cluster 1','Overall','Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
disp('Q average vs. VIX average')
mprint(VRP_difference_for_VIX,info)

close all
%% VRP: VIX - Backward density
VRP_VIX=nan(4,3);
VRP_VIX(1,:)=[mean(Q_vola_VIX_cluster0),mean(Q_vola_VIX_cluster1),mean(Q_vola_VIX_overall)];
VRP_VIX(2,:)=sqrt([Moments_P_c0_backward(1,3),Moments_P_c1_backward(1,3),Moments_P_backward(1,3)]*365/ttm);
VRP_VIX(3,:)=VRP_VIX(1,:)-VRP_VIX(2,:);
VRP_VIX(4,:)=[numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_list)];
clear info;
info.rnames = strvcat('.','Q annualized volatility','P annualized forward-looking volatility','Volatility risk premium','Num. of observation');
info.cnames = strvcat('Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
mprint(VRP_VIX,info)
% Save VRP data
outputtable = array2table(VRP_VIX','VariableNames',["Q","P","VRP","Num"]);
writetable(outputtable, "VRP/1_12_3_1_2/VIX_BackwardDensity.csv")
%% Moments ANOVA of cluster 0 and 1 (annualized)
% P: backward density
cluster_label_0 = [repmat("cluster_0",numel(dates_Q{1,1}),1);repmat("overall",numel(dates_Q{1,1})+numel(dates_Q{1,2}),1)];
cluster_label_1 = [repmat("cluster_1",numel(dates_Q{1,2}),1);repmat("overall",numel(dates_Q{1,1})+numel(dates_Q{1,2}),1)];
cluster_label_0_VIX = [repmat("cluster_0",numel(Q_vola_VIX_cluster0),1);repmat("overall",numel(Q_vola_VIX_cluster0)+numel(Q_vola_VIX_cluster1),1)];
cluster_label_1_VIX = [repmat("cluster_1",numel(Q_vola_VIX_cluster1),1);repmat("overall",numel(Q_vola_VIX_cluster0)+numel(Q_vola_VIX_cluster1),1)];
% Q: Q density vs VIX
[~,tbl11,stats11] = anova1([Moments_Q_c0_t(:,3);Moments_Q_t(:,3)]*365/ttm,cluster_label_0);
[~,tbl12,stats12] = anova1([Moments_Q_c1_t(:,3);Moments_Q_t(:,3)]*365/ttm,cluster_label_1);
[~,tbl13,stats13] = anova1([Q_vola_VIX_cluster0;Q_vola_VIX_overall],cluster_label_0_VIX);
[~,tbl14,stats14] = anova1([Q_vola_VIX_cluster1;Q_vola_VIX_overall],cluster_label_1_VIX);
[~,tbl31] = anova1(([sqrt(Moments_Q_c0_t(:,3))-sqrt(Moments_P_c0_backward(1,3));sqrt(Moments_Q_t(:,3))-sqrt(Moments_P_backward(1,3))])*sqrt(365/ttm),cluster_label_0);
[~,tbl32] = anova1(([sqrt(Moments_Q_c1_t(:,3))-sqrt(Moments_P_c1_backward(1,3));sqrt(Moments_Q_t(:,3))-sqrt(Moments_P_backward(1,3))])*sqrt(365/ttm),cluster_label_1);
[~,tbl33] = anova1(([Q_vola_VIX_cluster0-sqrt(Moments_P_c0_backward(1,3)*365/ttm);Q_vola_VIX_overall-sqrt(Moments_P_backward(1,3)*365/ttm)]),cluster_label_0_VIX);
[~,tbl34] = anova1(([Q_vola_VIX_cluster1-sqrt(Moments_P_c1_backward(1,3)*365/ttm);Q_vola_VIX_overall-sqrt(Moments_P_backward(1,3)*365/ttm)]),cluster_label_1_VIX);

VRP_difference_for_VIX=nan(6,6);
VRP_difference_for_VIX(1,:)=[sqrt(stats11.means(1)),sqrt(stats12.means(1)),sqrt(stats11.means(2)),stats13.means(1),stats14.means(1),stats13.means(2)];
VRP_difference_for_VIX(2,[1,2,4,5])=[tbl11{2,6},tbl12{2,6},tbl13{2,6},tbl14{2,6}];
VRP_difference_for_VIX(3,:)=sqrt([Moments_P_c0_backward(1,3),Moments_P_c1_backward(1,3),Moments_P_backward(1,3),Moments_P_c0_backward(1,3),Moments_P_c1_backward(1,3),Moments_P_backward(1,3)]*365/ttm);
VRP_difference_for_VIX(4,:)=[VRP_backward(3,:),VRP_VIX(3,:)];
VRP_difference_for_VIX(5,[1,2,4,5])=[tbl31{2,6},tbl32{2,6},tbl33{2,6},tbl34{2,6}];
VRP_difference_for_VIX(6,:)=[numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_Q{1,1})+numel(dates_Q{1,2}),numel(Q_vola_VIX_cluster0),numel(Q_vola_VIX_cluster1),numel(Q_vola_VIX_overall)];
clear info;
info.rnames = strvcat('.','Q ann vola','p-value','P ann vola','VRP','p-value','Num of obser');
info.cnames = strvcat('Cluster 0','Cluster 1','Overall','Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
disp('Q average vs. VIX average')
mprint(VRP_difference_for_VIX,info)

close all
%% volatility risk premium: using VIX and backward realized variance

tb_VIX_RV_VRP_cluster0 = innerjoin(tb_Q_variance_VIX_cluster0, tb_RV_cluster0,"Key","Date");
tb_VIX_RV_VRP_cluster1 = innerjoin(tb_Q_variance_VIX_cluster1, tb_RV_cluster1,"Key","Date");
tb_VIX_RV_VRP_overall = innerjoin(tb_Q_variance_VIX_overall, tb_RV_overall,"Key","Date");
tb_VIX_RV_VRP_cluster0 = addvars(tb_VIX_RV_VRP_cluster0, tb_VIX_RV_VRP_cluster0.Q_variance_VIX-tb_VIX_RV_VRP_cluster0.RV, 'NewVariableNames',"VRP");
tb_VIX_RV_VRP_cluster1 = addvars(tb_VIX_RV_VRP_cluster1, tb_VIX_RV_VRP_cluster1.Q_variance_VIX-tb_VIX_RV_VRP_cluster1.RV, 'NewVariableNames',"VRP");
tb_VIX_RV_VRP_overall = addvars(tb_VIX_RV_VRP_overall, tb_VIX_RV_VRP_overall.Q_variance_VIX-tb_VIX_RV_VRP_overall.RV, 'NewVariableNames',"VRP");
VRP_VIX_RV=nan(4,3);
VRP_VIX_RV(1,:)=[mean(tb_VIX_RV_VRP_cluster0.Q_variance_VIX),mean(tb_VIX_RV_VRP_cluster1.Q_variance_VIX),mean(tb_VIX_RV_VRP_overall.Q_variance_VIX)];
VRP_VIX_RV(2,:)=[mean(tb_VIX_RV_VRP_cluster0.RV),            mean(tb_VIX_RV_VRP_cluster1.RV),            mean(tb_VIX_RV_VRP_overall.RV)];
VRP_VIX_RV(3,:)=[mean(tb_VIX_RV_VRP_cluster0.VRP),           mean(tb_VIX_RV_VRP_cluster1.VRP),           mean(tb_VIX_RV_VRP_overall.VRP)];
VRP_VIX_RV(4,:)=[height(tb_VIX_RV_VRP_cluster0),height(tb_VIX_RV_VRP_cluster1),height(tb_VIX_RV_VRP_overall)];
clear info;
info.rnames = strvcat('.','Q annualized variance','P annualized realized variance','Variance risk premium','Num. of observation');
info.cnames = strvcat('Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
mprint(VRP_VIX_RV,info)
% Save VRP data
outputtable = array2table(VRP_VIX_RV','VariableNames',["Q","P","VRP","Num"]);
writetable(outputtable, "VRP/1_12_3_1_2/VIX_RV.csv")
%% Moments ANOVA of cluster 0 and 1 (annualized)
cluster_label_0 = [repmat("cluster_0",numel(dates_Q{1,1}),1);repmat("overall",numel(dates_Q{1,1})+numel(dates_Q{1,2}),1)];
cluster_label_1 = [repmat("cluster_1",numel(dates_Q{1,2}),1);repmat("overall",numel(dates_Q{1,1})+numel(dates_Q{1,2}),1)];
cluster_label_0_VIX = [repmat("cluster_0",height(tb_VIX_RV_VRP_cluster0),1);repmat("overall",height(tb_VIX_RV_VRP_overall),1)];
cluster_label_1_VIX = [repmat("cluster_1",height(tb_VIX_RV_VRP_cluster1),1);repmat("overall",height(tb_VIX_RV_VRP_overall),1)];
% Q average vs VIX average
[~,tbl11,stats11] = anova1([Moments_Q_c0_t(:,3);Moments_Q_t(:,3)]*365/ttm,cluster_label_0);
[~,tbl12,stats12] = anova1([Moments_Q_c1_t(:,3);Moments_Q_t(:,3)]*365/ttm,cluster_label_1);
[~,tbl13,stats13] = anova1([tb_VIX_RV_VRP_cluster0.Q_variance_VIX;tb_VIX_RV_VRP_overall.Q_variance_VIX],cluster_label_0_VIX);
[~,tbl14,stats14] = anova1([tb_VIX_RV_VRP_cluster1.Q_variance_VIX;tb_VIX_RV_VRP_overall.Q_variance_VIX],cluster_label_1_VIX);
[~,tbl31] = anova1(([Moments_Q_c0_t(:,3)*365/ttm-mean(realized_vola(index0,1).^2);Moments_Q_t(:,3)*365/ttm-mean(realized_vola(:,1).^2)]),cluster_label_0);
[~,tbl32] = anova1(([Moments_Q_c1_t(:,3)*365/ttm-mean(realized_vola(index1,1).^2);Moments_Q_t(:,3)*365/ttm-mean(realized_vola(:,1).^2)]),cluster_label_1);
[~,tbl33] = anova1(([tb_VIX_RV_VRP_cluster0.VRP;tb_VIX_RV_VRP_overall.VRP]),cluster_label_0_VIX);
[~,tbl34] = anova1(([tb_VIX_RV_VRP_cluster1.VRP;tb_VIX_RV_VRP_overall.VRP]),cluster_label_1_VIX);

VRP_difference_for_VIX=nan(6,6);
VRP_difference_for_VIX(1,:)=[stats11.means(1),stats12.means(1),stats11.means(2),stats13.means(1),stats14.means(1),stats13.means(2)];
VRP_difference_for_VIX(2,[1,2,4,5])=[tbl11{2,6},tbl12{2,6},tbl13{2,6},tbl14{2,6}];
VRP_difference_for_VIX(3,:)=[mean(realized_vola(index0,1).^2),mean(realized_vola(index1,1).^2),mean(realized_vola(:,1).^2),mean(tb_VIX_RV_VRP_cluster0.RV),mean(tb_VIX_RV_VRP_cluster1.RV),mean(tb_VIX_RV_VRP_overall.RV)];
VRP_difference_for_VIX(4,:)=[VRP_RV(3,:),VRP_VIX_RV(3,:)];
VRP_difference_for_VIX(5,[1,2,4,5])=[tbl31{2,6},tbl32{2,6},tbl33{2,6},tbl34{2,6}];
VRP_difference_for_VIX(6,:)=[numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_Q{1,1})+numel(dates_Q{1,2}),height(tb_VIX_RV_VRP_cluster0),height(tb_VIX_RV_VRP_cluster1),height(tb_VIX_RV_VRP_overall)];
clear info;
info.rnames = strvcat('.','Q ann variance','p-value','P ann variance','VRP','p-value','Num of obser');
info.cnames = strvcat('Cluster 0','Cluster 1','Overall','Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
disp('Q average vs. VIX average')
mprint(VRP_difference_for_VIX,info)

close all
%% volatility risk premium: using VIX and forward future volatility
VRP_VIX=nan(4,3);
VRP_VIX(1,:)=[mean(Q_vola_VIX_cluster0),mean(Q_vola_VIX_cluster1),mean(Q_vola_VIX_overall)];
VRP_VIX(2,:)=[mean(realized_vola(index0,2)),mean(realized_vola(index1,2)),mean(realized_vola(:,2))];
VRP_VIX(3,:)=VRP_VIX(1,:)-VRP_VIX(2,:);
VRP_VIX(4,:)=[numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_list)];
clear info;
info.rnames = strvcat('.','Q annualized volatility','P annualized realized volatility','Volatility risk premium','Num. of observation');
info.cnames = strvcat('Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
mprint(VRP_VIX,info)
% Save VRP data
outputtable = array2table(VRP_VIX','VariableNames',["Q","P","VRP","Num"]);
writetable(outputtable, "VRP/1_12_3_1_2/VIX_FV.csv")
%% Moments ANOVA of cluster 0 and 1 (annualized)
cluster_label_0 = [repmat("cluster_0",numel(dates_Q{1,1}),1);repmat("overall",numel(dates_Q{1,1})+numel(dates_Q{1,2}),1)];
cluster_label_1 = [repmat("cluster_1",numel(dates_Q{1,2}),1);repmat("overall",numel(dates_Q{1,1})+numel(dates_Q{1,2}),1)];
cluster_label_0_VIX = [repmat("cluster_0",numel(Q_vola_VIX_cluster0),1);repmat("overall",numel(Q_vola_VIX_cluster0)+numel(Q_vola_VIX_cluster1),1)];
cluster_label_1_VIX = [repmat("cluster_1",numel(Q_vola_VIX_cluster1),1);repmat("overall",numel(Q_vola_VIX_cluster0)+numel(Q_vola_VIX_cluster1),1)];
% Q average vs VIX average
[~,tbl11,stats11] = anova1([Moments_Q_c0_t(:,3);   Moments_Q_t(:,3)]*365/ttm,cluster_label_0);
[~,tbl12,stats12] = anova1([Moments_Q_c1_t(:,3);   Moments_Q_t(:,3)]*365/ttm,cluster_label_1);
[~,tbl13,stats13] = anova1([Q_vola_VIX_cluster0.^2;Q_vola_VIX_overall.^2],   cluster_label_0_VIX);
[~,tbl14,stats14] = anova1([Q_vola_VIX_cluster1.^2;Q_vola_VIX_overall.^2],   cluster_label_1_VIX);
[~,tbl31] = anova1(([Moments_Q_c0_t(:,3)*365/ttm-mean(realized_vola(index0,2).^2);Moments_Q_t(:,3)*365/ttm-mean(realized_vola(:,2).^2)]),cluster_label_0);
[~,tbl32] = anova1(([Moments_Q_c1_t(:,3)*365/ttm-mean(realized_vola(index1,2).^2);Moments_Q_t(:,3)*365/ttm-mean(realized_vola(:,2).^2)]),cluster_label_1);
[~,tbl33] = anova1(([Q_vola_VIX_cluster0.^2-mean(realized_vola(index0,2).^2);Q_vola_VIX_overall.^2-mean(realized_vola(:,2).^2)]),cluster_label_0_VIX);
[~,tbl34] = anova1(([Q_vola_VIX_cluster1.^2-mean(realized_vola(index1,2).^2);Q_vola_VIX_overall.^2-mean(realized_vola(:,2).^2)]),cluster_label_1_VIX);

VRP_difference_for_VIX=nan(6,6);
VRP_difference_for_VIX(1,:)=[stats11.means(1),stats12.means(1),stats11.means(2),stats13.means(1),stats14.means(1),stats13.means(2)];
VRP_difference_for_VIX(2,[1,2,4,5])=[tbl11{2,6},tbl12{2,6},tbl13{2,6},tbl14{2,6}];
VRP_difference_for_VIX(3,:)=[mean(realized_vola(index0,2)),mean(realized_vola(index1,2)),mean(realized_vola(:,2)),mean(realized_vola(index0,2)),mean(realized_vola(index1,2)),mean(realized_vola(:,2))];
VRP_difference_for_VIX(4,:)=[VRP_FV(3,:),VRP_VIX(3,:)];
VRP_difference_for_VIX(5,[1,2,4,5])=[tbl31{2,6},tbl32{2,6},tbl33{2,6},tbl34{2,6}];
VRP_difference_for_VIX(6,:)=[numel(dates_Q{1,1}),numel(dates_Q{1,2}),numel(dates_Q{1,1})+numel(dates_Q{1,2}),numel(Q_vola_VIX_cluster0),numel(Q_vola_VIX_cluster1),numel(Q_vola_VIX_overall)];
clear info;
info.rnames = strvcat('.','Q ann vola','p-value','P ann vola','VRP','p-value','Num of obser');
info.cnames = strvcat('Cluster 0','Cluster 1','Overall','Cluster 0','Cluster 1', 'Overall');
info.fmt    = '%10.2f';
disp('Q average vs. VIX average')
mprint(VRP_difference_for_VIX,info)

close all
%% VRP across time

figure;
scatter(tb_VIX_RV_VRP_cluster0.Date,tb_VIX_RV_VRP_cluster0.VRP,15,'b','filled');hold on
scatter(tb_VIX_RV_VRP_cluster1.Date,tb_VIX_RV_VRP_cluster1.VRP,15,'r','filled');hold off
legend('HV','LV')
xlim([datetime("2017-07-01"),datetime("2022-12-17")])
set(gcf,'Position',[0,0,450,300])
box on
ax = gca;
ax.YAxisLocation = 'left';
ax.XAxisLocation = 'bottom';
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
saveas(gcf,"VRP/1_12_3_1_2/VRP_VIX_RV_scatter.png")

figure;
scatter(tb_VIX_RV_VRP_cluster0.Date,tb_VIX_RV_VRP_cluster0.VRP,15,'b','filled');hold on
scatter(tb_VIX_RV_VRP_cluster1.Date,tb_VIX_RV_VRP_cluster1.VRP,15,'r','filled');
x_shaded = [datetime("2020-03-15"), datetime("2020-04-08"), datetime("2020-04-08"), datetime("2020-03-15")];% x-coordinates of the shaded area
y_shaded = [-2, -2, 2, 2];                % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.05, 'EdgeColor','none');                                       % 'k' for black color, 10% transparent
hold off
legend('HV','LV')
xlim([datetime("2017-07-01"),datetime("2022-12-17")])
ylim([-1.5,1.5])
set(gcf,'Position',[0,0,450,300])
box on
ax = gca;
ax.YAxisLocation = 'left';
ax.XAxisLocation = 'bottom';
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
saveas(gcf,"VRP/1_12_3_1_2/VRP_VIX_RV_scatter_1.png")

figure;
plot(tb_VIX_RV_VRP_cluster0.Date,smooth(datenum(tb_VIX_RV_VRP_cluster0.Date),tb_VIX_RV_VRP_cluster0.VRP,15),'b',"LineWidth",2);hold on
plot(tb_VIX_RV_VRP_cluster1.Date,smooth(datenum(tb_VIX_RV_VRP_cluster1.Date),tb_VIX_RV_VRP_cluster1.VRP,15),'r',"LineWidth",2);
plot(tb_VIX_RV_VRP_overall.Date,smooth(datenum(tb_VIX_RV_VRP_overall.Date),tb_VIX_RV_VRP_overall.VRP,15),'k',"LineWidth",2);hold off
legend('HV','LV', 'Overall')
xlim([datetime("2017-07-01"),datetime("2022-12-17")])
set(gca,'FontSize',15)
set(gcf,'Position',[0,0,450,300])
saveas(gcf,"VRP/1_12_3_1_2/VRP_VIX_RV_smooth.png")


figure;
scatter(tb_VIX_RV_VRP_overall.Date,tb_VIX_RV_VRP_overall.VRP,15,'k',"filled");
xlim([datetime("2017-07-01"),datetime("2022-12-17")])
set(gca,'FontSize',15)
set(gcf,'Position',[0,0,450,300])
saveas(gcf,"VRP/1_12_3_1_2/VRP_VXBTC_RV_scatter_overall.png")

figure;
% scatter(tb_VIX_RV_VRP_overall.Date,tb_VIX_RV_VRP_overall.Q_variance_VIX,20,[1,0.6471,0],          "filled");hold on
% scatter(tb_VIX_RV_VRP_overall.Date,tb_VIX_RV_VRP_overall.RV,            20,[0.1961,0.8039,0.1961],"filled");hold off
scatter(tb_VIX_RV_VRP_overall.Date,tb_VIX_RV_VRP_overall.Q_variance_VIX,30,[0.9059,0.1608,0.5412],"s",      "filled");hold on
scatter(tb_VIX_RV_VRP_overall.Date,tb_VIX_RV_VRP_overall.RV,            30,[0,     0.5451,0.5451],"d","filled");
x_shaded = [datetime("2020-03-15"), datetime("2020-04-08"), datetime("2020-05-08"), datetime("2020-02-15")];% x-coordinates of the shaded area
y_shaded = [-0.5, -0.5, max(daily_price_sub.Adj_Close)*2, max(daily_price_sub.Adj_Close)*2];% y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
hold off
xlim([datetime("2017-07-01"),datetime("2022-12-17")])
ylim([0,5])
legend({'VXBTC^2','RV'})
set(gcf,'Position',[0,0,450,300])
box on
ax = gca;
ax.YAxisLocation = 'left';
ax.XAxisLocation = 'bottom';
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
saveas(gcf,"VRP/1_12_3_1_2/VRP_VXBTC_RV_withPQ_scatter_overall.png")

%% EP plot
tb_realized_EP_c0 = innerjoin(tb_PR_FR,tb_Moments_Q_c0_t,"Key","Date");
tb_realized_EP_c1 = innerjoin(tb_PR_FR,tb_Moments_Q_c1_t,"Key","Date");
tb_realized_EP_OA = innerjoin(tb_PR_FR,tb_Moments_Q_t,"Key","Date");
tb_realized_EP_c0 = addvars(tb_realized_EP_c0,tb_realized_EP_c0.PR-tb_realized_EP_c0.Mean*365/ttm,'NewVariableNames',"EP");
tb_realized_EP_c1 = addvars(tb_realized_EP_c1,tb_realized_EP_c1.PR-tb_realized_EP_c1.Mean*365/ttm,'NewVariableNames',"EP");
tb_realized_EP_OA = addvars(tb_realized_EP_OA,tb_realized_EP_OA.PR-tb_realized_EP_OA.Mean*365/ttm,'NewVariableNames',"EP");

figure;
scatter(tb_realized_EP_OA.Date,tb_realized_EP_OA.EP,15,'k','filled')
set(gcf,'Position',[0,0,450,300])
box on
ax = gca;
ax.YAxisLocation = 'left';
ax.XAxisLocation = 'bottom';
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
title('Realized Risk premium = Realized returns - 1st moment of Q','FontSize',12)
saveas(gcf,"VRP/1_12_3_1_2/EP_RR_density_scatter_overall.png")

figure;
scatter(tb_realized_EP_OA.Date,tb_realized_EP_OA.PR,15,'k','filled')
set(gca,'FontSize',15)
set(gcf,'Position',[0,0,450,300])
title('Realized Risk premium = Realized returns - RF0')
saveas(gcf,"VRP/1_12_3_1_2/EP_RR_IR0_scatter_overall.png")
%% Exclude outliers
outlier_index = find(abs(tb_realized_EP_OA.EP)>=5);
tb_realized_EP_OA_subset = tb_realized_EP_OA(abs(tb_realized_EP_OA.EP)<5,:);
figure;
scatter(tb_realized_EP_OA_subset.Date,tb_realized_EP_OA_subset.EP,15,'k','filled');hold on
for i=1:length(outlier_index)
    x_shaded = [tb_realized_EP_OA.Date(outlier_index(i))-0.5, tb_realized_EP_OA.Date(outlier_index(i))+0.5, tb_realized_EP_OA.Date(outlier_index(i))+0.5, tb_realized_EP_OA.Date(outlier_index(i))-0.5];% x-coordinates of the shaded area
    y_shaded = [min(tb_realized_EP_OA_subset.EP)*2,           min(tb_realized_EP_OA_subset.EP)*2,           max(tb_realized_EP_OA_subset.EP)*2,           max(tb_realized_EP_OA_subset.EP)*2];% y-coordinates of the shaded area
    fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.5, 'EdgeColor','none'); % 'k' for black color, 10% transparent
end
hold off    
xlim([datetime("2017-07-01"),datetime("2022-12-17")])
set(gca,'FontSize',15)
set(gcf,'Position',[0,0,450,300])
title('Realized Equity premium = Realized returns - 1st moment of Q','FontSize',12)
saveas(gcf,"VRP/1_12_3_1_2/EP_RR_density_scatter_1_overall.png")

figure;
scatter(tb_realized_EP_OA_subset.Date,tb_realized_EP_OA_subset.PR,15,'k','filled');hold on
for i=1:length(outlier_index)
    x_shaded = [tb_realized_EP_OA.Date(outlier_index(i))-0.5, tb_realized_EP_OA.Date(outlier_index(i))+0.5, tb_realized_EP_OA.Date(outlier_index(i))+0.5, tb_realized_EP_OA.Date(outlier_index(i))-0.5];% x-coordinates of the shaded area
    y_shaded = [min(tb_realized_EP_OA_subset.EP)*2,           min(tb_realized_EP_OA_subset.EP)*2,           max(tb_realized_EP_OA_subset.EP)*2,           max(tb_realized_EP_OA_subset.EP)*2];% y-coordinates of the shaded area
    fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.5, 'EdgeColor','none'); % 'k' for black color, 10% transparent
end
hold off    
xlim([datetime("2017-07-01"),datetime("2022-12-17")])
set(gca,'FontSize',15)
set(gcf,'Position',[0,0,450,300])
title('Realized Equity premium = Realized returns - RF0')
saveas(gcf,"VRP/1_12_3_1_2/EP_RR_IR0_scatter_1_overall.png")


tb_realized_EP_c0_subset = tb_realized_EP_c0(abs(tb_realized_EP_c0.EP)<5,:);
tb_realized_EP_c1_subset = tb_realized_EP_c1(abs(tb_realized_EP_c1.EP)<5,:);
figure;
scatter(tb_realized_EP_c0_subset.Date,tb_realized_EP_c0_subset.EP,15,'b','filled');hold on
scatter(tb_realized_EP_c1_subset.Date,tb_realized_EP_c1_subset.EP,15,'r','filled');
for i=1:length(outlier_index)
    x_shaded = [tb_realized_EP_OA.Date(outlier_index(i))-0.5, tb_realized_EP_OA.Date(outlier_index(i))+0.5, tb_realized_EP_OA.Date(outlier_index(i))+0.5, tb_realized_EP_OA.Date(outlier_index(i))-0.5];% x-coordinates of the shaded area
    y_shaded = [min(tb_realized_EP_OA_subset.EP)*2,           min(tb_realized_EP_OA_subset.EP)*2,           max(tb_realized_EP_OA_subset.EP)*2,           max(tb_realized_EP_OA_subset.EP)*2];% y-coordinates of the shaded area
    fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.5, 'EdgeColor','none'); % 'k' for black color, 10% transparent
end
hold off    
xlim([datetime("2017-07-01"),datetime("2022-12-17")])
legend('HV','LV')
set(gcf,'Position',[0,0,450,300])
box on
ax = gca;
ax.YAxisLocation = 'left';
ax.XAxisLocation = 'bottom';
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
% title('Realized Equity premium = Realized returns - 1st moment of Q','FontSize',12)
saveas(gcf,"VRP/1_12_3_1_2/EP_RR_density_scatter_2cluster.png")

figure;
scatter(tb_realized_EP_c0_subset.Date,tb_realized_EP_c0_subset.PR,15,'b','filled');hold on
scatter(tb_realized_EP_c1_subset.Date,tb_realized_EP_c1_subset.PR,15,'r','filled');
for i=1:length(outlier_index)
    x_shaded = [tb_realized_EP_OA.Date(outlier_index(i))-0.5, tb_realized_EP_OA.Date(outlier_index(i))+0.5, tb_realized_EP_OA.Date(outlier_index(i))+0.5, tb_realized_EP_OA.Date(outlier_index(i))-0.5];% x-coordinates of the shaded area
    y_shaded = [min(tb_realized_EP_OA_subset.EP)*2,           min(tb_realized_EP_OA_subset.EP)*2,           max(tb_realized_EP_OA_subset.EP)*2,           max(tb_realized_EP_OA_subset.EP)*2];% y-coordinates of the shaded area
    fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.5, 'EdgeColor','none'); % 'k' for black color, 10% transparent
end
hold off    
xlim([datetime("2017-07-01"),datetime("2022-12-17")])
legend('HV','LV')
set(gca,'FontSize',15)
set(gcf,'Position',[0,0,450,300])
title('Realized Equity premium = Realized returns - RF0')
saveas(gcf,"VRP/1_12_3_1_2/EP_RR_IR0_scatter_2cluster.png")

%% Save tb_realized_EP_OA, tb_realized_EP_c0, tb_realized_EP_c1
writetable(tb_realized_EP_OA,"VRP/1_12_3_1_2/EP_RR_density_overall.csv");
writetable(tb_realized_EP_c0,"VRP/1_12_3_1_2/EP_RR_density_cluster0.csv");
writetable(tb_realized_EP_c1,"VRP/1_12_3_1_2/EP_RR_density_cluster1.csv");

%% Annualized first moment of RND
figure;
scatter(tb_realized_EP_OA.Date,tb_realized_EP_OA.Mean,15,'k','filled');
title('First moment of estimated RND with GEV tails')
saveas(gcf,"VRP/1_12_3_1_2/First_moment_RND.png")
figure;
boxplot(tb_realized_EP_OA.Mean)
title('First moment of estimated RND with GEV tails')
saveas(gcf,"VRP/1_12_3_1_2/First_moment_RND_boxplot.png")

%% EP with fit and CI
tb_realized_EP_OA = readtable("VRP/1_12_3_1_2/EP_RR_density_overall.csv");
tb_realized_EP_c0 = readtable("VRP/1_12_3_1_2/EP_RR_density_cluster0.csv");
tb_realized_EP_c1 = readtable("VRP/1_12_3_1_2/EP_RR_density_cluster1.csv");

outlier_index = find(abs(tb_realized_EP_OA.EP)>=5);
tb_realized_EP_OA_subset = tb_realized_EP_OA(abs(tb_realized_EP_OA.EP)<5,:);
tb_realized_EP_c0_subset = tb_realized_EP_c0(abs(tb_realized_EP_c0.EP)<5,:);
tb_realized_EP_c1_subset = tb_realized_EP_c1(abs(tb_realized_EP_c1.EP)<5,:);
% Example data
x = [tb_realized_EP_c0_subset.Date;tb_realized_EP_c1_subset.Date];
y = [tb_realized_EP_c0_subset.EP;  tb_realized_EP_c1_subset.EP];
[x_sorted, idx] = sort(x);
y_sorted = y(idx);

% Scatter plot
figure;
scatter(x_sorted, y_sorted,15,'k', 'filled');

hold on;

% Linear regression and plot
x_datenum = datenum(x_sorted);
lm = fitlm(x_datenum,y_sorted);
x_pred = x_datenum; 
[y_pred, ci] = predict(lm, x_pred);
plot(datetime(x_pred,'ConvertFrom','datenum'), y_pred, 'r-', 'LineWidth', 2); % Linear fit line
plot(nan, nan, 'r--'); % Confidence interval for linear fit

% LOESS smoothing
span = 0.3; % Span for LOESS smoothing
y_loess = smoothdata(y_pred, 'loess', span*length(y_pred));
plot(datetime(x_pred,'ConvertFrom','datenum'), y_loess, 'g-', 'LineWidth', 2); % LOESS line

plot(datetime(x_pred,'ConvertFrom','datenum'), ci, 'r--'); % Confidence interval for linear fit

for i=1:length(outlier_index)
    x_shaded = [tb_realized_EP_OA.Date(outlier_index(i))-0.5, tb_realized_EP_OA.Date(outlier_index(i))+0.5, tb_realized_EP_OA.Date(outlier_index(i))+0.5, tb_realized_EP_OA.Date(outlier_index(i))-0.5];% x-coordinates of the shaded area
    y_shaded = [min(tb_realized_EP_OA_subset.EP)*2,           min(tb_realized_EP_OA_subset.EP)*2,           max(tb_realized_EP_OA_subset.EP)*2,           max(tb_realized_EP_OA_subset.EP)*2];% y-coordinates of the shaded area
    fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.5, 'EdgeColor','none'); % 'k' for black color, 10% transparent
end

hold off;

xlim([datetime("2017-07-01"),datetime("2022-12-17")])
ylim([-10,10])
legend('EP', 'Linear Fit', 'Confidence Interval', 'LOESS Smoothing', 'Location', 'best');
set(gcf,'Position',[0,0,450,300]);  
box on
ax = gca;
ax.YAxisLocation = 'left';
ax.XAxisLocation = 'bottom';
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
% title('Scatter Plot with Linear and LOESS Smoothing');
saveas(gcf,"VRP/1_12_3_1_2/EP_RR_density_scatter_fit_CI.png")
%% Save tb_VIX_RV_VRP_cluster0, tb_VIX_RV_VRP_cluster1
writetable(tb_VIX_RV_VRP_cluster0,"VRP/1_12_3_1_2/VRP_VIX_RV_cluster0.csv");
writetable(tb_VIX_RV_VRP_cluster1,"VRP/1_12_3_1_2/VRP_VIX_RV_cluster1.csv");
%% VRP with fit and CI

tb_VIX_RV_VRP_cluster0 = readtable("VRP/1_12_3_1_2/VRP_VIX_RV_cluster0.csv");
tb_VIX_RV_VRP_cluster1 = readtable("VRP/1_12_3_1_2/VRP_VIX_RV_cluster1.csv");

tb_VIX_RV_VRP_cluster0_subset = tb_VIX_RV_VRP_cluster0(abs(tb_VIX_RV_VRP_cluster0.VRP)<=2,:);
tb_VIX_RV_VRP_cluster1_subset = tb_VIX_RV_VRP_cluster1(abs(tb_VIX_RV_VRP_cluster1.VRP)<=2,:);

% Example data
x = [tb_VIX_RV_VRP_cluster0_subset.Date;tb_VIX_RV_VRP_cluster1_subset.Date];
y = [tb_VIX_RV_VRP_cluster0_subset.VRP; tb_VIX_RV_VRP_cluster1_subset.VRP];
[x_sorted, idx] = sort(x);
y_sorted = y(idx);

% Scatter plot
figure;
scatter(x_sorted, y_sorted,15,'k', 'filled');

hold on;

% Linear regression and plot
x_datenum = datenum(x_sorted);
lm = fitlm(x_datenum,y_sorted);
x_pred = x_datenum; 
[y_pred, ci] = predict(lm, x_pred);
plot(datetime(x_pred,'ConvertFrom','datenum'), y_pred, 'r-', 'LineWidth', 2); % Linear fit line
plot(nan, nan, 'r--'); % Confidence interval for linear fit

% LOESS smoothing
span = 0.3; % Span for LOESS smoothing
y_loess = smoothdata(y_pred, 'loess', span*length(y_pred));
plot(datetime(x_pred,'ConvertFrom','datenum'), y_loess, 'g-', 'LineWidth', 2); % LOESS line

plot(datetime(x_pred,'ConvertFrom','datenum'), ci, 'r--'); % Confidence interval for linear fit

x_shaded = [datetime("2020-03-15"), datetime("2020-04-08"), datetime("2020-04-08"), datetime("2020-03-15")];% x-coordinates of the shaded area
y_shaded = [-2, -2, 2, 2];                % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.05, 'EdgeColor','none');                                       % 'k' for black color, 10% transparent

hold off;
    
xlim([datetime("2017-07-01"),datetime("2022-12-17")])
ylim([-1.5,1.5])
legend('VRP', 'Linear Fit', 'Confidence Interval', 'LOESS Smoothing', 'Location', 'best');
set(gcf,'Position',[0,0,450,300]);  
box on
ax = gca;
ax.YAxisLocation = 'left';
ax.XAxisLocation = 'bottom';
ax.FontSize = 15;
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
saveas(gcf,"VRP/1_12_3_1_2/VRP_VIX_RV_scatter_fit_CI.png")

%% Close all
close all
%% Calculate moments of cluster 0
Moments_0 = zeros(numel(dates_Q{1,1}),7);
for i = 1:length(dates_Q{1,1})

        a = strcat("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Output/Q_density_logreturn_",dates_Q{1,1}(i),".csv");
        data_q = readtable(a);
        Moments_0(i,1) = trapz(data_q.Return,data_q.Q_density);
        Moments_0(i,2) = trapz(data_q.Return,data_q.Q_density.*data_q.Return);% 1th moment
        Moments_0(i,3) = trapz(data_q.Return,data_q.Q_density.*(data_q.Return-Moments_0(i,2)).^2);% 2th central moment
        Moments_0(i,4) = trapz(data_q.Return,data_q.Q_density.*(data_q.Return-Moments_0(i,2)).^3);% 3th central moment
        Moments_0(i,5) = trapz(data_q.Return,data_q.Q_density.*(data_q.Return-Moments_0(i,2)).^4);% 4th central moment
        Moments_0(i,6) = Moments_0(i,4)/(Moments_0(i,3)^1.5);  % Skewness
        Moments_0(i,7) = Moments_0(i,5)/(Moments_0(i,3)^2)-3;  % Kurtosis
end
%% Calculate moments of cluster 1
Moments_1 = zeros(numel(dates_Q{1,2}),7);
for i = 1:length(dates_Q{1,2})

        a = strcat("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Output/Q_density_logreturn_",dates_Q{1,2}(i),".csv");
        data_q = readtable(a);
        Moments_1(i,1) = trapz(data_q.Return,data_q.Q_density);
        Moments_1(i,2) = trapz(data_q.Return,data_q.Q_density.*data_q.Return);% 1th moment
        Moments_1(i,3) = trapz(data_q.Return,data_q.Q_density.*(data_q.Return-Moments_1(i,2)).^2);% 2th central moment
        Moments_1(i,4) = trapz(data_q.Return,data_q.Q_density.*(data_q.Return-Moments_1(i,2)).^3);% 3th central moment
        Moments_1(i,5) = trapz(data_q.Return,data_q.Q_density.*(data_q.Return-Moments_1(i,2)).^4);% 4th central moment
        Moments_1(i,6) = Moments_1(i,4)/(Moments_1(i,3)^1.5);  % Skewness
        Moments_1(i,7) = Moments_1(i,5)/(Moments_1(i,3)^2)-3;  % Kurtosis
end
%% Output Qdensity-RV-VRP and Qdensity-FV-VRP
table_c0 = [table(dates_Q{1,1},'VariableNames',"Date"),...
    table(sqrt(Moments_0(:,3)*365/ttm),'VariableNames',"Q"),...
    table(realized_vola(index0,1),'VariableNames',"RV"),...
    table(sqrt(Moments_0(:,3)*365/ttm)-realized_vola(index0,1),'VariableNames',"VRP_RV"),...
    table(realized_vola(index0,2),'VariableNames',"FV"),...
    table(sqrt(Moments_0(:,3)*365/ttm)-realized_vola(index0,2),'VariableNames',"VRP_FV"),...
    table(zeros(size(dates_Q{1,1})),'VariableNames',"Cluster")];
table_c1 = [table(dates_Q{1,2},'VariableNames',"Date"),...
    table(sqrt(Moments_1(:,3)*365/ttm),'VariableNames',"Q"),...
    table(realized_vola(index1,1),'VariableNames',"RV"),...
    table(sqrt(Moments_1(:,3)*365/ttm)-realized_vola(index1,1),'VariableNames',"VRP_RV"),...
    table(realized_vola(index1,2),'VariableNames',"FV"),...
    table(sqrt(Moments_1(:,3)*365/ttm)-realized_vola(index1,2),'VariableNames',"VRP_FV"),...
    table(ones(size(dates_Q{1,2})),'VariableNames',"Cluster")];
outputtable = [table_c0;table_c1];
writetable(outputtable,"VRP/1_12_3_1_2/Cluster_Qdensity_FV_RV.csv");
%% Output VIX-RV-VRP and VIX-FV-VRP
Q_vola_VIX_cluster0=VIX.EMA((ismember(VIX.Date,dates_list(index0))))/100;
Q_vola_VIX_cluster1=VIX.EMA((ismember(VIX.Date,dates_list(index1))))/100;
Q_vola_VIX_overall=VIX.EMA((ismember(VIX.Date,dates_list)))/100;
table_c0 = [table(VIX.Date(ismember(VIX.Date,dates_list(index0))),'VariableNames',"Date"),...
    table(Q_vola_VIX_cluster0,'VariableNames',"VIX"),...
    table(realized_vola(and(index0,ismember(dates_list,VIX.Date)'),1),'VariableNames',"RV"),...
    table(Q_vola_VIX_cluster0-realized_vola(and(index0,ismember(dates_list,VIX.Date)'),1),'VariableNames',"VRP_RV"),...
    table(realized_vola(and(index0,ismember(dates_list,VIX.Date)'),2),'VariableNames',"FV"),...
    table(Q_vola_VIX_cluster0-realized_vola(and(index0,ismember(dates_list,VIX.Date)'),2),'VariableNames',"VRP_FV"),...
    table(zeros(size(Q_vola_VIX_cluster0)),'VariableNames',"Cluster")];
table_c1 = [table(VIX.Date(ismember(VIX.Date,dates_list(index1))),'VariableNames',"Date"),...
    table(Q_vola_VIX_cluster1,'VariableNames',"VIX"),...
    table(realized_vola(and(index1,ismember(dates_list,VIX.Date)'),1),'VariableNames',"RV"),...
    table(Q_vola_VIX_cluster1-realized_vola(and(index1,ismember(dates_list,VIX.Date)'),1),'VariableNames',"VRP_RV"),...
    table(realized_vola(and(index1,ismember(dates_list,VIX.Date)'),2),'VariableNames',"FV"),...
    table(Q_vola_VIX_cluster1-realized_vola(and(index1,ismember(dates_list,VIX.Date)'),2),'VariableNames',"VRP_FV"),...
    table(ones(size(Q_vola_VIX_cluster1)),'VariableNames',"Cluster")];
outputtable = [table_c0;table_c1];
writetable(outputtable,"VRP/1_12_3_1_2/Cluster_VIX_FV_RV.csv");