%% Tail fit by GEV distribution 2.6.2.1.2
% we use "Q_tail_est_para_Figlewski_NI_6_1stMoment.m" instead of "Q_tail_est_para_Figlewski_NI.m" 

clear,clc
addpath('m_Files_Color/')
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Moneyness");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Return");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Output");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Return/Raw_density");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Return/Fit_process");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Return/Full_tail");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Return/Full_tail_with_color");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Moneyness/Raw_density");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Moneyness/Fit_process");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Moneyness/Full_tail");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Moneyness/Full_tail_with_color");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/GIF");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Q_matrix");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/paras");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/probability_matrix");
[~,~,~]=mkdir("Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/cutoff");

% option = readtable("data/processed/20172022_processed_1_3_4.csv");

IR = readtable("data/interest_rate/IR_daily.csv");
IR.index=datetime(IR.index);
IR.DTB3=IR.DTB3/100;

ttm=27;
% series = "0_1_3";

% IV_matrx = readtable(strcat("Q_from_IV/IV_matrix/interpolated IVs R2 0.99/interpolated_IV",num2str(ttm),"_99.csv"));
% dates_list = sort(IV_matrx.Var1(2:end));

option = readtable("data/processed/20172022_processed_1_3_4.csv");
dates_list = datetime(datestr(unique(option.date((option.tau>=ttm) & (option.tau<=ttm) & (option.date>=datetime("2017-07-01")) & (option.date<=datetime("2022-12-31")))),'YYYY-mm-DD'),"Format","yyyy-MM-dd");
dates_list([0,1, 3, 4, 7, 9, 10, 12, 13, 16, 53]+1)=[];

rng("default")
error_case=zeros(size(dates_list));
paras_l = zeros(numel(dates_list), 3);
paras_r = zeros(numel(dates_list), 3);
Q_matrix=zeros(numel(-1:0.001:1),numel(dates_list));
probability_matrix=zeros(3,numel(dates_list));
cutoffs = zeros(numel(dates_list), 2);
%% Fit tail
for i = 1:numel(dates_list)
    date = datestr(dates_list(i),'yyyy-mm-dd');
    a = strcat("Compare_Q_Rookley/RND/Rookley_Q_CB_1722_1_2_5_ttm",num2str(ttm),"/btc_pk_", date, "_bw_0.3.csv");
    data_q = readtable(a);
%     data_q([1,end],:) = [];

    interest_rate = IR.DTB3(IR.index==datetime(dates_list(i)));

    ii=find(data_q.spdy==max(data_q.spdy));
    spdy1=data_q.spdy(1:ii);
    spdy2=data_q.spdy(ii:end);
    d1=diff(data_q.spdy(1:ii));
    d2=diff(data_q.spdy(ii:end));
    ret_ub = 1;
    ret_lb = -1;
    if any(d2>=0)
        ret_ub = min(ret_ub,round(data_q.ret(find(d2>=0,1)+ii-3),2)-0.01);
    end
    if any(spdy2<0)
        ret_ub = min(ret_ub, round(data_q.ret(find(spdy2<0.1,1)+ii-3),2)-0.01);
    end
    data_q(data_q.ret>ret_ub,:)=[];
    if any(d1<=0)
        ret_lb = max(ret_lb,round(data_q.ret(find(d1<=0,1,"last")+2),2)+0.01);
    end
    if any(spdy1<0)
        ret_lb = max(ret_lb, round(data_q.ret(find(spdy1<0.1,1,"last")+2),2)+0.01);
    end
    data_q(data_q.ret<ret_lb,:)=[];

    %%%%%%%%%%  log return  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     [Q_rt, rt, paras] = Q_tail_logret(data_q.spdy, data_q.m);
%     [paras,errors]= Q_tail_est_para_Figlewski_NI_6_1stMoment(data_q.spdy, data_q.m, ...
%         data_q.cdf_m,'Initial_paras_left',[0.3128,0.0456, 0.0296],'IR',interest_rate);
    [paras,errors]= Q_tail_est_para_Figlewski_NI_6_1stMoment(data_q.spdy, data_q.m, ...
        data_q.cdf_m,'IR',interest_rate);

    disp(errors)

    paras_l(i,:) = paras(1,:);
    paras_r(i,:) = paras(2,:);

    

    [Q_rt, rt, details] = Q_tail_use_para_Figlewski(data_q.spdy, data_q.m, data_q.cdf_m, 'paras_Left', paras_l(i,:),'paras_Right', paras_r(i,:));

    Q_matrix(:,i)=Q_rt';

    probability_matrix(1,i)=trapz(details.return_range(details.return_range<details.raw_rt(1)),details.q_l(details.return_range<details.raw_rt(1)));
    probability_matrix(2,i)=trapz(details.raw_rt,details.raw_Qrt);
    probability_matrix(3,i)=trapz(details.return_range(details.return_range>details.raw_rt(end)),details.q_r(details.return_range>details.raw_rt(end)));

    disp(sum(probability_matrix(:,i)))

    cutoffs(i,1)=details.target_l(1,1);
    cutoffs(i,2)=details.target_r(end,1);

    %%% input Q-density
    close all
    figure;
    plot(details.raw_rt, details.raw_Qrt)
    ylim([0, 9])
    xlim([min(rt), max(rt)])
    xticks(min(rt):0.2:max(rt))
    saveas(gcf,strcat('Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Return/Raw_density/Raw_density_',date,'.png'))


    %     solution_r = paras(2,:);
    %     solution_r(1,1) = solution_r(1,1)-0.38;
    %     solution_r(1,2) = solution_r(1,2);
    %     solution_r(1,3) = solution_r(1,3)+0.09;
    % %     solution_r(1,3) = [-0.1478    0.0613   -0.0107];
    %     details.q_r = gevpdf(return_range,solution_r(1,1),solution_r(1,2),solution_r(1,3));

    %%% procedure of tail fit
    close all
    figure;
    plot(details.raw_rt, details.raw_Qrt)
    xlim([min(rt), max(rt)])
    hold on
    plot([details.target_l(:,1); details.target_r(:,1)], [details.target_l(:,2); details.target_r(:,2)], 'xr')
    plot(details.return_range,details.q_l,'-.','Color',[0.2235, 0.0588, 0.4314])
    plot(details.return_range,details.q_r,'--','Color',[0.9922, 0.6314, 0.4314])
    hold off
    legend({'Q Rookley','target points','left tail','right tail'})
    ylim([0, 9])
    xticks(min(rt):0.2:max(rt))
    saveas(gcf,strcat('Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Return/Fit_process/Fit_process_',date,'.png'))

    %%% full tail
    close all
    figure;
    plot(rt, Q_rt)
    ylim([0, 9])
    xlim([min(rt), max(rt)])
    xticks(min(rt):0.2:max(rt))
    saveas(gcf,strcat('Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Return/Full_tail/Full_tail_',date,'.png'))

    %%% tail with different colors
    %     figure;
    plot(details.raw_rt, details.raw_Qrt)
    hold on
    plot(details.return_range(details.return_range<details.raw_rt(1)), details.q_l(details.return_range<details.raw_rt(1)), '--','Color',[0.2235, 0.0588, 0.4314])
    plot(details.return_range(details.return_range>details.raw_rt(end)), details.q_r(details.return_range>details.raw_rt(end)), '--','Color',[0.9922, 0.6314, 0.4314])
    hold off
    ylim([0, 9])
    xlim([min(rt), max(rt)])
    xticks(min(rt):0.2:max(rt))
    saveas(gcf,strcat('Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Return/Full_tail_with_color/Show_tail_',date,'.png'))

    % write Q density
    output = table(rt', Q_rt','VariableNames',{'Return', 'Q_density'});
    writetable(output,strcat('Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Output/Q_density_logreturn_',date,'.csv'))

end

outputtable = array2table(cutoffs,"VariableNames",{'left','right'});
writetable(outputtable,'Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/cutoff/cutoff.csv')
outputtable = array2table(Q_matrix,"VariableNames",string(dates_list));
writetable(outputtable,'Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Q_matrix/Q_matrix.csv')
outputtable = array2table(paras_r,"VariableNames",{'xi','b','a'});
writetable(outputtable,'Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/paras/paras_right.csv')
outputtable = array2table(paras_l,"VariableNames",{'xi','b','a'});
writetable(outputtable,'Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/paras/paras_left.csv')
outputtable = array2table(probability_matrix,"VariableNames",string(dates_list));
writetable(outputtable,'Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/probability_matrix/probability_matrix.csv')

for i = 1:numel(dates_list)
    if any(Q_matrix(:,i)<0)
        i
        % 54 59 71
    end
end
%% probability matrix
probability_matrix=table2array(readtable('Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/probability_matrix/probability_matrix.csv','ReadVariableNames',true));
probability_matrix(4,:)=sum(probability_matrix);
find(probability_matrix(4,:)==max(probability_matrix(4,:)))
possib_report=nan(4,4);
possib_report(1,1:4)=[mean(probability_matrix(1,:)),mean(probability_matrix(2,:)),mean(probability_matrix(3,:)),mean(probability_matrix(4,:))];
possib_report(2,1:4)=[std(probability_matrix(1,:)), std(probability_matrix(2,:)), std(probability_matrix(3,:)), std(probability_matrix(4,:))];
possib_report(3,1:4)=[max(probability_matrix(1,:)), max(probability_matrix(2,:)), max(probability_matrix(3,:)), max(probability_matrix(4,:))];
possib_report(4,1:4)=[min(probability_matrix(1,:)), min(probability_matrix(2,:)), min(probability_matrix(3,:)), min(probability_matrix(4,:))];
possib_report(5,1:4)=[numel(dates_list),            numel(dates_list),            numel(dates_list),            numel(dates_list)];
clear info;
info.rnames = strvcat('.','Mean','Std','Max','Min','Num.');
info.cnames = strvcat('Left tail','Raw density (middle part)','Right tail','Total');
info.fmt    = '%10.2f';
mprint(possib_report,info)
% figure;
% plot(datetime(dates_list,"Format","MMMyyyy"),probability_matrix(1,:));hold on
% plot(datetime(dates_list,"Format","MMMyyyy"),probability_matrix(2,:));
% plot(datetime(dates_list,"Format","MMMyyyy"),probability_matrix(3,:));hold off
% addpath('m_Files_Color/hatchfill2_r8/')
x=datetime(dates_list,"Format","MMMyyyy");
y=probability_matrix(1:3,:)';
figure;
Go=bar(x,y,'stacked');
xticks(datetime(floor(linspace(min(datenum(x)),max(datenum(x)),12)),'ConvertFrom','datenum'));
xticklabels(datestr(datetime(floor(linspace(min(datenum(x)),max(datenum(x)),12)),'ConvertFrom','datenum'),'mmmyyyy'))
ylim([0,1.3])
legend({'Left tail','Raw density (middle part)','Right tail'},'FontSize',12)
ylabel('probability','FontSize',15)
title(strcat('probability of tails fit, tau=',num2str(ttm)),'FontSize',15)
saveas(gcf,'Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/probability_matrix/3parts.png')
%% probability with cutoff
cutoffs=table2array(readtable('Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/cutoff/cutoff.csv','ReadVariableNames',true));
x=datetime(dates_list,"Format","MMMyyyy");
y=probability_matrix(1:3,:)';

figure;
yyaxis left
Go=bar(x,y,'stacked');
default_colors = get(groot, 'defaultAxesColorOrder');
set(gca, 'ColorOrder', default_colors)
for i=1:length(Go)
    Go(i).FaceColor = 'flat';
    Go(i).CData = default_colors(i, :);
end
ylabel('Probability', 'Color', [0 0 0],'FontSize',15)
set(gca, 'ycolor', [0 0 0]);
ylim([0,1.3])
yyaxis right
plot(x,cutoffs,'-', 'Color',[0.1725    0.6275    0.1725],'LineWidth',2);hold on
plot(x,max(cutoffs(:,1))*ones(size(x)),'r--', 'LineWidth',1);
plot(x,min(cutoffs(:,2))*ones(size(x)),'r--', 'LineWidth',1);hold off
text(max(x)+10,max(cutoffs(:,1)),num2str(round(max(cutoffs(:,1)),2)),"Color",'red');
text(max(x)+10,min(cutoffs(:,2)),num2str(round(min(cutoffs(:,2)),2)),"Color",'red');
ylabel('Cutoffs', 'Color', [0.1725    0.6275    0.1725],'FontSize',15)
set(gca, 'ycolor', [0.1725    0.6275    0.1725]);
ylim([-1,1])
xticks(datetime(floor(linspace(min(datenum(x)),max(datenum(x)),12)),'ConvertFrom','datenum'));
xticklabels(datestr(datetime(floor(linspace(min(datenum(x)),max(datenum(x)),12)),'ConvertFrom','datenum'),'mmmyyyy'))
title(strcat('probability with tails and cutoffs, tau=',num2str(ttm)),'FontSize',15)
saveas(gcf,'Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/probability_matrix/3parts_with_cutoff.png')
%% Parameters matrix
paras_l=table2array(readtable('Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/paras/paras_left.csv','ReadVariableNames',true));
paras_report=nan(5,3);
paras_report(1,1:3)=[mean(paras_l(:,1)),mean(paras_l(:,2)),mean(paras_l(:,3))];
paras_report(2,1:3)=[std(paras_l(:,1)), std(paras_l(:,2)), std(paras_l(:,3))];
paras_report(3,1:3)=[max(paras_l(:,1)), max(paras_l(:,2)), max(paras_l(:,3))];
paras_report(4,1:3)=[min(paras_l(:,1)), min(paras_l(:,2)), min(paras_l(:,3))];
paras_report(5,1:3)=[numel(dates_list), numel(dates_list), numel(dates_list)];
clear info;
info.rnames = strvcat('.','Mean','Std','Max','Min','Num.');
info.cnames = strvcat('xi','b','a');
info.fmt    = '%10.2f';
mprint(paras_report,info)
paras_r=table2array(readtable('Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/paras/paras_right.csv','ReadVariableNames',true));
paras_report=nan(5,3);
paras_report(1,1:3)=[mean(paras_r(:,1)),mean(paras_r(:,2)),mean(paras_r(:,3))];
paras_report(2,1:3)=[std(paras_r(:,1)), std(paras_r(:,2)), std(paras_r(:,3))];
paras_report(3,1:3)=[max(paras_r(:,1)), max(paras_r(:,2)), max(paras_r(:,3))];
paras_report(4,1:3)=[min(paras_r(:,1)), min(paras_r(:,2)), min(paras_r(:,3))];
paras_report(5,1:3)=[numel(dates_list), numel(dates_list), numel(dates_list)];
clear info;
info.rnames = strvcat('.','Mean','Std','Max','Min','Num.');
info.cnames = strvcat('xi','b','a');
info.fmt    = '%10.2f';
mprint(paras_report,info)

figure;
subplot(1,2,1)
plot(x,paras_l);
ylim([-0.5,0.5])
xticks(datetime(floor(linspace(min(datenum(x)),max(datenum(x)),8)),'ConvertFrom','datenum'));
xticklabels(datestr(datetime(floor(linspace(min(datenum(x)),max(datenum(x)),8)),'ConvertFrom','datenum'),'mmmyyyy'))
legend({'xi','b','a'})
title('left tails')
subplot(1,2,2)
plot(x,paras_r);
xticks(datetime(floor(linspace(min(datenum(x)),max(datenum(x)),8)),'ConvertFrom','datenum'));
xticklabels(datestr(datetime(floor(linspace(min(datenum(x)),max(datenum(x)),8)),'ConvertFrom','datenum'),'mmmyyyy'))
ylim([-0.5,0.5])
title('right tails')
sgtitle(strcat('Coefficients of GEV tails, tau=',num2str(ttm)))
saveas(gcf,'Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/paras/coefficients.png')
%% point out problematic dates
figure;
subplot(1,2,1)
plot(x,paras_l);hold on
ylim([-0.5,0.5])
xticks(datetime(floor(linspace(min(datenum(x)),max(datenum(x)),8)),'ConvertFrom','datenum'));
xticklabels(datestr(datetime(floor(linspace(min(datenum(x)),max(datenum(x)),8)),'ConvertFrom','datenum'),'mmmyyyy'))
for i = 1:numel(dates_list)
    if probability_matrix(4,i)>1.05
        scatter(x(i),paras_l(i,1),60,[0 0.4470 0.7410])
        scatter(x(i),paras_l(i,2),60,[0.8500 0.3250 0.0980])
        scatter(x(i),paras_l(i,3),60,[0.9290 0.6940 0.1250])
    end
end
hold off
legend({'xi','b','a','problematic'})
title('left tails')
subplot(1,2,2)
plot(x,paras_r);
xticks(datetime(floor(linspace(min(datenum(x)),max(datenum(x)),8)),'ConvertFrom','datenum'));
xticklabels(datestr(datetime(floor(linspace(min(datenum(x)),max(datenum(x)),8)),'ConvertFrom','datenum'),'mmmyyyy'))
ylim([-0.5,0.5])
title('right tails')
sgtitle(strcat('Coefficients of GEV tails, tau',num2str(ttm)))
set(gcf,'position',[0,0,1500,800])
saveas(gcf,'Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/paras/coefficients_with_problematic.png')

%% Copy Qs estimated from interpolated IV
ttm=27;
IV_matrx = readtable(strcat("Q_from_IV/IV_matrix/interpolated IVs R2 0.99/interpolated_IV",num2str(ttm),"_99.csv"));
dates_list = sort(IV_matrx.Var1(2:end));

for i = 1:numel(dates_list)
    date = datestr(dates_list(i),'yyyy-mm-dd');
    a = strcat('Q_Tail_Fit/All_Tail_2_8_3_3_Q_from_IV/Output/Q_density_logreturn_',date,'.csv');
    Q_table = readtable(a);
    writetable(Q_table,strcat('Q_Tail_Fit/All_Tail_2_9_3_1_Q_from_IV/Output/Q_density_logreturn_',date,'.csv'))
end