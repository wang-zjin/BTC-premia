% Density analysis
% The script plots Q and P density, P by ePDF (Kernel Density Estimation) with different bandwidths (NB) for Equity Premium 
% It creates a 2x2 subplot for different Time to Maturity (TTM) values, each with multiple ePDF plots using different bandwidths.
%% load data
clear,clc
addpath("m_Files_Color")                 % Add directory to MATLAB's search path for custom color files
addpath("m_Files_Color/colormap")        % Add subdirectory for colormap files
[~,~,~]=mkdir("Bitcoin_Premium/2_1_X_13"); % Create directory for output, if it doesn't exist

% Read Equity Premium data from Excel files for different TTM (Time to Maturity) values
% Q_P_overall_ttm5=readtable("Bitcoin_Premium/2_1_X_13/Q_P_ePDF_FSRSOL_RV_differentNB_OA_ttm5.xlsx");
% Q_P_overall_ttm9=readtable("Bitcoin_Premium/2_1_X_13/Q_P_ePDF_FSRSOL_RV_differentNB_OA_ttm9.xlsx");
% Q_P_overall_ttm14=readtable("Bitcoin_Premium/2_1_X_13/Q_P_ePDF_FSRSOL_RV_differentNB_OA_ttm14.xlsx");
Q_P_overall_ttm27=readtable("Bitcoin_Premium/2_1_X_13/Q_P_ePDF_3287_backward_onlyVR_OA_differentNB_ttm27.xlsx");

ret_simple=Q_P_overall_ttm27.Returns; % Extract simple returns for plotting

%% Plot P with different NB
% Focus on TTM 27
Colors = rainbow(10);  % Generate a rainbow color map with 6 colors
figure;

plot(ret_simple,Q_P_overall_ttm27.P_NB6,'--','Color',Colors(1,:),'LineWidth',2);hold on
plot(ret_simple,Q_P_overall_ttm27.P_NB7,'--','Color',Colors(2,:),'LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.P_NB8,'--','Color',Colors(3,:),'LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.P_NB9,'--','Color',Colors(4,:),'LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.P_NB10,'--','Color',Colors(5,:),'LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.P_NB11,'--','Color',Colors(6,:),'LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.P_NB12,'--','Color',Colors(7,:),'LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.P_NB13,'--','Color',Colors(8,:),'LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.P_NB14,'--','Color',Colors(9,:),'LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.P_NB15,'--','Color',Colors(10,:),'LineWidth',2);
% plot(ret_simple,Q_P_overall_ttm27.Q_overall./Q_P_overall_ttm27.P_NB10,'-.','Color','k','LineWidth',2);
hold off
legend({'NB 6','NB 7','NB 8','NB 9','NB 10','NB 11','NB 12','NB 13','NB 14','NB 15'},'FontSize',15,'Location','northwest')
xticks([-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1])
xlabel('Return')
ylim([0,4])
grid off
% title(['TTM 27 overlapping ePDF (NB=10), E_P(R)=',num2str(0.0604), ...
%     ', E_Q(R)=',num2str(0.0008), ...
%     ', E_P(R)-E_Q(R)=',num2str(0.0594)],'FontSize',20)
% title(['TTM 27, E_P(R)=',num2str(0.0604), ...
%     ', E_Q(R)=',num2str(0.0008), ...
%     ', E_P(R)-E_Q(R)=',num2str(0.0594)],'FontSize',20)
set(gcf,'Position',[0,0,450,300]);  
ax = gca;
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
saveas(gcf,"Bitcoin_Premium/2_1_X_13/P_ePDF_backward_differentNB_OA_ttm27_1by1.png")
%% Plot PK with different NB
% Focus on TTM 27
Colors = rainbow(5);  % Generate a rainbow color map with 6 colors
figure;

plot(ret_simple,Q_P_overall_ttm27.Q_overall./Q_P_overall_ttm27.P_NB9,'-.','Color',Colors(1,:),'LineWidth',2);hold on
plot(ret_simple,Q_P_overall_ttm27.Q_overall./Q_P_overall_ttm27.P_NB10,'-.','Color',addcolor(260),'LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.Q_overall./Q_P_overall_ttm27.P_NB11,'-.','Color',addcolor(49),'LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.Q_overall./Q_P_overall_ttm27.P_NB12,'-.','Color',addcolor(257),'LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.Q_overall./Q_P_overall_ttm27.P_NB13,'-.','Color',addcolor(185),'LineWidth',2);
% plot(ret_simple,Q_P_overall_ttm27.Q_overall./Q_P_overall_ttm27.P_NB10,'-.','Color','k','LineWidth',2);
hold off
legend({'NB 9','NB 10','NB 11','NB 12','NB 13'},'FontSize',15,'Location','southwest')
xticks([-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1])
xlabel('Return')
ylim([0,3])
xlim([-1,1])
grid off
% title(['TTM 27 overlapping ePDF (NB=10), E_P(R)=',num2str(0.0604), ...
%     ', E_Q(R)=',num2str(0.0008), ...
%     ', E_P(R)-E_Q(R)=',num2str(0.0594)],'FontSize',20)
% title(['TTM 27, E_P(R)=',num2str(0.0604), ...
%     ', E_Q(R)=',num2str(0.0008), ...
%     ', E_P(R)-E_Q(R)=',num2str(0.0594)],'FontSize',20)
set(gcf,'Position',[0,0,450,300]);  
ax = gca;
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
saveas(gcf,"Bitcoin_Premium/2_1_X_13/PK_ePDF_backward_differentNB_OA_ttm27_1by1.png")
%% Plot EP with different NB

BP_ttm27=readtable("Bitcoin_Premium/2_1_X_13/BP_SCA_ePDF_3287_backward_onlyVR_OA_differentNB_ttm27.xlsx");

ret_simple=BP_ttm27.Returns; % Extract simple returns for plotting
figure;
% Subplot for TTM 27 with multiple empirical PDF plots using different
% number of bins
plot(nan,nan,'Color',Colors(1,:),'LineWidth',2);hold on
plot(nan,nan,'Color',addcolor(260),'LineWidth',2);
plot(nan,nan,'Color',addcolor(49),'LineWidth',2);
plot(nan,nan,'Color',addcolor(257),'LineWidth',2);
plot(nan,nan,'Color',addcolor(185),'LineWidth',2);

plot(ret_simple,BP_ttm27.BP_NB9,'Color',Colors(1,:),'LineWidth',3);hold on
plot(ret_simple,BP_ttm27.BP_NB10,'Color',addcolor(260),'LineWidth',3);
plot(ret_simple,BP_ttm27.BP_NB11,'Color',addcolor(49),'LineWidth',3);
plot(ret_simple,BP_ttm27.BP_NB12,'Color',addcolor(257),'LineWidth',3);
plot(ret_simple,BP_ttm27.BP_NB13,'Color',addcolor(185),'LineWidth',3);
hold off
xticks([-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1])
xlabel('Return',FontSize=15)
ylim([0,1.2])
legend({'NB 9','NB 10','NB 11','NB 12','NB 13'},'FontSize',15,'Location','northwest')
grid on
% title("TTM 27, Red (NB=10) smoothest",'FontSize',20)
% Final adjustments and saving the figure
set(gcf,'Position',[0,0,450,300]);                                   % Set figure size  
set(gca,'FontSize',15)
% sgtitle(strcat('EP overall, 5full sample overlapping ePDF'),'FontSize',30)  % Super title for the figure
saveas(gcf,"Bitcoin_Premium/2_1_X_13/BP_SCA_ePDF_3287_backward_onlyVR_OA_differentNB_ttm27_1by1.png")

