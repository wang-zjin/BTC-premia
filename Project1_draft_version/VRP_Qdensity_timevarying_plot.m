%% This file plots VRP over time

% Original file in "matlab_code_for_BTC" is
% "BTC_1_12_3_1_2_plot_VRP_Qdensity.m"

clc,clear
tb_Qdensity_RV_VRP_cluster0 = readtable("VRP/1_12_3_1_2/VRP_Qdensity_RV_cluster0.csv");
tb_Qdensity_RV_VRP_cluster1 = readtable("VRP/1_12_3_1_2/VRP_Qdensity_RV_cluster1.csv");
tb_Qdensity_RV_VRP_overall = [tb_Qdensity_RV_VRP_cluster0;tb_Qdensity_RV_VRP_cluster1];

%% VRP across time

figure;
scatter(tb_Qdensity_RV_VRP_cluster0.Date,tb_Qdensity_RV_VRP_cluster0.VRP,15,'b','filled');hold on
scatter(tb_Qdensity_RV_VRP_cluster1.Date,tb_Qdensity_RV_VRP_cluster1.VRP,15,'r','filled');hold off
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
saveas(gcf,"VRP/1_12_3_1_2/VRP_Qdensity_RV_scatter.png")

figure;
scatter(tb_Qdensity_RV_VRP_cluster0.Date,tb_Qdensity_RV_VRP_cluster0.VRP,15,'b','filled');hold on
scatter(tb_Qdensity_RV_VRP_cluster1.Date,tb_Qdensity_RV_VRP_cluster1.VRP,15,'r','filled');
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
saveas(gcf,"VRP/1_12_3_1_2/VRP_Qdensity_RV_scatter_1.png")

