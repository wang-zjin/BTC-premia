                    

clc,clear
option = readtable("data/processed/20172022_processed_1_3_4.csv");

[~,~,~]=mkdir("Summary_stats/1_3_6_multiQ_clustering");

ttm = 5;

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
clustering_labels = [0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
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
        1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1];
index0 = (clustering_labels==1);
index1 = (clustering_labels==0);
dates_Q{1,1} = dates_cluster(index0);
dates_Q{1,2} = dates_cluster(index1);

%% Histogram of transaction
Colors = [0,0,1;1,0,0;0,0,0]; 
volume_cluster=nan(3,3);

figure;
i=1;
    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")) & string(option.putcall)=="C",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    title(['HV']);
    ylabel("Call")
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(1,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")) & string(option.putcall)=="P",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i+3);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylabel("Put")
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(2,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")),:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i+6);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylabel("Call + Put")
    ylim([0,2.5e7])
    xlim([0,2])
    xlabel("Moneyness K/S")
    set(gca,'FontSize',15)
    volume_cluster(3,i)=sum(volume_moneyness);
i=2;
    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")) & string(option.putcall)=="C",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    title(['LV']);
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(1,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")) & string(option.putcall)=="P",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i+3);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(2,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")),:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i+6);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylim([0,2.5e7])
    xlim([0,2])
    xlabel("Moneyness K/S")
    set(gca,'FontSize',15)
    volume_cluster(3,i)=sum(volume_moneyness);

i=3;
    option1 = option(ismember(option.date,datetime([dates_Q{1};dates_Q{2}],"Format","yyyy-MM-dd")) & string(option.putcall)=="C",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel([dates_Q{1};dates_Q{2}]);
    subplot(3,3,i);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    title(['Overall']);
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(1,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime([dates_Q{1};dates_Q{2}],"Format","yyyy-MM-dd")) & string(option.putcall)=="P",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel([dates_Q{1};dates_Q{2}]);
    subplot(3,3,i+3);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(2,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime([dates_Q{1};dates_Q{2}],"Format","yyyy-MM-dd")),:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel([dates_Q{1};dates_Q{2}]);
    subplot(3,3,i+6);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylim([0,2.5e7])
    xlim([0,2])
    xlabel("Moneyness K/S")
    set(gca,'FontSize',15)
    volume_cluster(3,i)=sum(volume_moneyness);

%     sgtitle('Histogram of daily average transaction volume, multivariate Q clustering')
set(gcf,'Position',[0,0,800,480])
saveas(gcf, "Summary_stats/1_3_6_multiQ_clustering/Hist_transaction_2cluster_3by3.png")

clear info;
info.rnames = strvcat('.','Call','Put','Call + Put');
info.cnames = strvcat('Cluster 0','Cluster 1','Overall');
info.fmt    = '%10.2f';
disp('Transaction of clusters')
mprint(volume_cluster,info)
%% Histogram of quantity
Colors = [0,0,1;1,0,0;0,0,0]; 
volume_cluster=nan(3,3);

figure;
i=1;
    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")) & string(option.putcall)=="C",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    title(['Cluster ',num2str(i-1)]);
    ylabel("Call")
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(1,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")) & string(option.putcall)=="P",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i+3);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylabel("Put")
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(2,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")),:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i+6);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylabel("Call + Put")
    ylim([0,2.5e7])
    xlim([0,2])
    xlabel("Moneyness K/S")
    set(gca,'FontSize',15)
    volume_cluster(3,i)=sum(volume_moneyness);
i=2;
    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")) & string(option.putcall)=="C",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    title(['Cluster ',num2str(i-1)]);
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(1,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")) & string(option.putcall)=="P",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i+3);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(2,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")),:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i+6);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylim([0,2.5e7])
    xlim([0,2])
    xlabel("Moneyness K/S")
    set(gca,'FontSize',15)
    volume_cluster(3,i)=sum(volume_moneyness);

i=3;
    option1 = option(ismember(option.date,datetime([dates_Q{1};dates_Q{2}],"Format","yyyy-MM-dd")) & string(option.putcall)=="C",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel([dates_Q{1};dates_Q{2}]);
    subplot(3,3,i);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    title(['Overall']);
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(1,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime([dates_Q{1};dates_Q{2}],"Format","yyyy-MM-dd")) & string(option.putcall)=="P",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel([dates_Q{1};dates_Q{2}]);
    subplot(3,3,i+3);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(2,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime([dates_Q{1};dates_Q{2}],"Format","yyyy-MM-dd")),:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel([dates_Q{1};dates_Q{2}]);
    subplot(3,3,i+6);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylim([0,2.5e7])
    xlim([0,2])
    xlabel("Moneyness K/S")
    set(gca,'FontSize',15)
    volume_cluster(3,i)=sum(volume_moneyness);

%     sgtitle('Histogram of daily average transaction volume, multivariate Q clustering')
set(gcf,'Position',[0,0,800,480])
saveas(gcf, "Summary_stats/1_3_6_multiQ_clustering/Hist_quantity_2cluster_3by3.png")

clear info;
info.rnames = strvcat('.','Call','Put','Call + Put');
info.cnames = strvcat('Cluster 0','Cluster 1','Overall');
info.fmt    = '%10.2f';
disp('Transaction volume of clusters')
mprint(volume_cluster,info)
%% Histogram of volume
Colors = [0,0,1;1,0,0;0,0,0]; 
volume_cluster=nan(3,3);

figure;
i=1;
    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")) & string(option.putcall)=="C",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    title(['Cluster ',num2str(i-1)]);
    ylabel("Call")
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(1,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")) & string(option.putcall)=="P",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i+3);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylabel("Put")
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(2,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")),:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i+6);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylabel("Call + Put")
    ylim([0,2.5e7])
    xlim([0,2])
    xlabel("Moneyness K/S")
    set(gca,'FontSize',15)
    volume_cluster(3,i)=sum(volume_moneyness);
i=2;
    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")) & string(option.putcall)=="C",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    title(['Cluster ',num2str(i-1)]);
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(1,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")) & string(option.putcall)=="P",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i+3);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(2,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime(dates_Q{1,i},"Format","yyyy-MM-dd")),:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel(dates_Q{1,i});
    subplot(3,3,i+6);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylim([0,2.5e7])
    xlim([0,2])
    xlabel("Moneyness K/S")
    set(gca,'FontSize',15)
    volume_cluster(3,i)=sum(volume_moneyness);

i=3;
    option1 = option(ismember(option.date,datetime([dates_Q{1};dates_Q{2}],"Format","yyyy-MM-dd")) & string(option.putcall)=="C",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel([dates_Q{1};dates_Q{2}]);
    subplot(3,3,i);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    title(['Overall']);
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(1,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime([dates_Q{1};dates_Q{2}],"Format","yyyy-MM-dd")) & string(option.putcall)=="P",:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel([dates_Q{1};dates_Q{2}]);
    subplot(3,3,i+3);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylim([0,2.5e7])
    xlim([0,2])
    set(gca,'FontSize',15)
    volume_cluster(2,i)=sum(volume_moneyness);

    option1 = option(ismember(option.date,datetime([dates_Q{1};dates_Q{2}],"Format","yyyy-MM-dd")),:);
    [unique_moneyness, ~, idx_moneyness] = unique(round(option1.moneyness,2));
    volume_moneyness = accumarray(idx_moneyness, option1.volume, [], @sum)/numel([dates_Q{1};dates_Q{2}]);
    subplot(3,3,i+6);
    bar(unique_moneyness,volume_moneyness,"FaceColor",Colors(i,:),"EdgeColor","none");
    ylim([0,2.5e7])
    xlim([0,2])
    xlabel("Moneyness K/S")
    set(gca,'FontSize',15)
    volume_cluster(3,i)=sum(volume_moneyness);

%     sgtitle('Histogram of daily average transaction volume, multivariate Q clustering')
set(gcf,'Position',[0,0,800,480])
saveas(gcf, "Summary_stats/1_3_6_multiQ_clustering/Hist_volume_2cluster_3by3.png")

clear info;
info.rnames = strvcat('.','Call','Put','Call + Put');
info.cnames = strvcat('Cluster 0','Cluster 1','Overall');
info.fmt    = '%10.2f';
disp('Transaction value of clusters')
mprint(volume_cluster,info)