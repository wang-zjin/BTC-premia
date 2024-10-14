



% Bitcoin Premium (BP) Analysis
% The script plots ePDF (Kernel Density Estimation) with different bandwidths (BW) for Bitcoin Premium 
% It creates a 4x3 subplot for different Time to Maturity (TTM) values, each with multiple ePDF plots using different bandwidths.
%% load data
clear,clc
addpath("m_Files_Color")                 % Add directory to MATLAB's search path for custom color files
addpath("m_Files_Color/colormap")        % Add subdirectory for colormap files
[~,~,~]=mkdir("Bitcoin_Premium/2_1_X_13"); % Create directory for output, if it doesn't exist

% Read Bitcoin Premium data from Excel files for different TTM (Time to Maturity) values
BP_overall_ttm27=readtable("Bitcoin_Premium/2_1_X_13/BP_SCA_ePDF_3287_forward_onlyVR_OA_differentNB_ttm27.xlsx");
BP_c0_ttm27=readtable("Bitcoin_Premium/2_1_X_13/BP_SCA_ePDF_3287_forward_onlyVR_c0_differentNB_ttm27.xlsx");
BP_c1_ttm27=readtable("Bitcoin_Premium/2_1_X_13/BP_SCA_ePDF_3287_forward_onlyVR_c1_differentNB_ttm27.xlsx");

ret_simple=BP_c0_ttm27.Returns; % Extract simple returns for plotting

%% Plot BP overall
shadow_x_negative = [-0.6, -0.2];
shadow_x_positive = [0.2, 0.6];
figure;
plot(ret_simple,BP_overall_ttm27.BP_NB11,'Color','k','LineWidth',2);hold on
% plot(ret_simple,BP_overall_ttm27.BP_NB11,'Color','k','LineWidth',2);

x_shaded = [shadow_x_negative(1), shadow_x_negative(2), shadow_x_negative(2), shadow_x_negative(1)];% x-coordinates of the shaded area
y_shaded = [-1.5, -1.5, 8, 8];                                       % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
x_shaded = [ shadow_x_positive(1), shadow_x_positive(2), shadow_x_positive(2), shadow_x_positive(1)]; % x-coordinates of the shaded area
y_shaded = [-1.5, -1.5, 8, 8];                                       % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
hold off
% grid on
xlim([-1,1]),ylim([0,1.5])
xticks([-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1])
% ylabel('$\hat{BP}$','FontSize',20,'Interpreter','tex')
xlabel('Return','FontSize',15)
% title("Overall",'FontSize',20)
legend('$\widehat{BP}_{HV}$','FontSize',15,'Interpreter','latex','Location','Northwest','box','off')

set(gcf,'Position',[0,0,450,300])
ax = gca;
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
% sgtitle(strcat('BP, full sample overlapping empirical PDF by rescaled returns'),'FontSize',30)
saveas(gcf,"Bitcoin_Premium/2_1_X_13/BP_SCA_ePDF_3287_forward_onlyVR_OA_NB11_1by1_plot.png")

BP_sub1 = BP_overall_ttm27.BP_NB11(ret_simple>=shadow_x_negative(1) & ret_simple<=shadow_x_negative(2));
BP_sub2 = BP_overall_ttm27.BP_NB11(ret_simple>=shadow_x_positive(1) & ret_simple<=shadow_x_positive(2));
disp([BP_sub1(end)-BP_sub1(1),BP_sub2(end)-BP_sub2(1)])

%% Plot BP for 2 HV cluster 
shadow_x_negative = [-0.6, -0.2];
shadow_x_positive = [0.2, 0.6];
figure;
plot(ret_simple,BP_c0_ttm27.BP_NB11,'Color','b','LineWidth',2);hold on
% plot(ret_simple,BP_overall_ttm27.BP_NB11,'Color','k','LineWidth',2);

x_shaded = [shadow_x_negative(1), shadow_x_negative(2), shadow_x_negative(2), shadow_x_negative(1)];                                 % x-coordinates of the shaded area
y_shaded = [-1.5, -1.5, 8, 8];                                       % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'b', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
x_shaded = [ shadow_x_positive(1), shadow_x_positive(2), shadow_x_positive(2), shadow_x_positive(1)];                                 % x-coordinates of the shaded area
y_shaded = [-1.5, -1.5, 8, 8];                                       % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'b', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
hold off
% grid on
xlim([-1,1]),ylim([0,1.5])
xticks([-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1])
% ylabel('$\hat{BP}$','FontSize',20,'Interpreter','tex')
xlabel('Return','FontSize',15)
% title("Overall",'FontSize',20)
legend('$\widehat{BP}_{HV}$','FontSize',15,'Interpreter','latex','Location','Northwest','box','off')

set(gcf,'Position',[0,0,450,300])
ax = gca;
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
% sgtitle(strcat('BP, full sample overlapping empirical PDF by rescaled returns'),'FontSize',30)
saveas(gcf,"Bitcoin_Premium/2_1_X_13/BP_SCA_ePDF_3287_forward_onlyVR_c0_NB11_1by1_plot.png")


BP_sub1 = BP_c0_ttm27.BP_NB11(ret_simple>=shadow_x_negative(1) & ret_simple<=shadow_x_negative(2));
BP_sub2 = BP_c0_ttm27.BP_NB11(ret_simple>=shadow_x_positive(1) & ret_simple<=shadow_x_positive(2));
disp([BP_sub1(end)-BP_sub1(1),BP_sub2(end)-BP_sub2(1)])

%% Plot BP for 2 LV cluster
shadow_x_negative = [-0.4, -0.2];
shadow_x_positive = [0.2, 0.6];
figure;
plot(ret_simple,BP_c1_ttm27.BP_NB11,'Color','r','LineWidth',2);hold on
% plot(ret_simple,BP_overall_ttm27.BP_NB11,'Color','k','LineWidth',2);

x_shaded = [shadow_x_negative(1), shadow_x_negative(2), shadow_x_negative(2), shadow_x_negative(1)];                                 % x-coordinates of the shaded area
y_shaded = [-1.5, -1.5, 8, 8];                                       % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'r', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
x_shaded = [ shadow_x_positive(1), shadow_x_positive(2), shadow_x_positive(2), shadow_x_positive(1)];                                 % x-coordinates of the shaded area
y_shaded = [-1.5, -1.5, 8, 8];                                       % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'r', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
hold off
% grid on
xlim([-1,1]),ylim([0,1.5])
xticks([-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1])
% ylabel('$\hat{BP}$','FontSize',20,'Interpreter','tex')
xlabel('Return','FontSize',15)
% title("Overall",'FontSize',20)
legend('$\widehat{BP}_{LV}$','FontSize',15,'Interpreter','latex','Location','Northwest','box','off')

set(gcf,'Position',[0,0,450,300])
ax = gca;
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
% sgtitle(strcat('BP, full sample overlapping empirical PDF by rescaled returns'),'FontSize',30)
saveas(gcf,"Bitcoin_Premium/2_1_X_13/BP_SCA_ePDF_3287_forward_onlyVR_c1_NB11_1by1_plot.png")


BP_sub1 = BP_c1_ttm27.BP_NB11(ret_simple>=shadow_x_negative(1) & ret_simple<=shadow_x_negative(2));
BP_sub2 = BP_c1_ttm27.BP_NB11(ret_simple>=shadow_x_positive(1) & ret_simple<=shadow_x_positive(2));
disp([BP_sub1(end)-BP_sub1(1),BP_sub2(end)-BP_sub2(1)])

%% Plot BP for OA, HV, LV

figure;
plot(ret_simple,BP_overall_ttm27.BP_NB11,'Color','k','LineWidth',2);hold on
plot(ret_simple,BP_c0_ttm27.BP_NB11,'Color','b','LineWidth',2);
plot(ret_simple,BP_c1_ttm27.BP_NB11,'Color','r','LineWidth',2);
% plot(ret_simple,BP_overall_ttm27.BP_NB11,'Color','k','LineWidth',2);

hold off
% grid on
xlim([-1,1]),ylim([0,1.5])
xticks([-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1])
% ylabel('$\hat{BP}$','FontSize',20,'Interpreter','tex')
xlabel('Return','FontSize',15)
% title("Overall",'FontSize',20)
legend(["$\widehat{BP}_{OA}$","$\widehat{BP}_{HV}$","$\widehat{BP}_{LV}$"],'FontSize',15,'Interpreter','latex','Location','Northwest','box','off')

set(gcf,'Position',[0,0,450,300])
ax = gca;
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
% sgtitle(strcat('BP, full sample overlapping empirical PDF by rescaled returns'),'FontSize',30)
saveas(gcf,"Bitcoin_Premium/2_1_X_13/BP_SCA_ePDF_3287_forward_onlyVR_OAc0c1_NB11_1by1_plot.png")


