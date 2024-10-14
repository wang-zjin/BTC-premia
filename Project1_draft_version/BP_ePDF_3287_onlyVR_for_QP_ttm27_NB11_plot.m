




% Density analysis
% The script plots Q and P density, P by ePDF (Kernel Density Estimation) with different bandwidths (NB) for Bitcoin Premium 
% It creates a 2x2 subplot for different Time to Maturity (TTM) values, each with multiple ePDF plots using different bandwidths.
%% load data
clear,clc
addpath("m_Files_Color")                 % Add directory to MATLAB's search path for custom color files
addpath("m_Files_Color/colormap")        % Add subdirectory for colormap files
[~,~,~]=mkdir("Bitcoin_Premium/2_1_X_13"); % Create directory for output, if it doesn't exist

% Read Bitcoin Premium data from Excel files for different TTM (Time to Maturity) values
Q_P_c0_ttm27=readtable("Bitcoin_Premium/2_1_X_13/Q_P_ePDF_3287_forward_onlyVR_c0_differentNB_ttm27.xlsx");
Q_P_c1_ttm27=readtable("Bitcoin_Premium/2_1_X_13/Q_P_ePDF_3287_forward_onlyVR_c1_differentNB_ttm27.xlsx");
Q_P_overall_ttm27=readtable("Bitcoin_Premium/2_1_X_13/Q_P_ePDF_3287_forward_onlyVR_OA_differentNB_ttm27.xlsx");

ret_simple=Q_P_overall_ttm27.Returns; % Extract simple returns for plotting

%% Plot Q, P, Q/P for overall
% Focus on TTM 27
shadow_x_negative = [-0.6, -0.2];
shadow_x_positive = [0.2, 0.6];
figure;

plot(nan,nan,'-','Color','k','LineWidth',2);hold on
plot(nan,nan,'--','Color','k','LineWidth',2);
plot(nan,nan,'-.','Color','k','LineWidth',1);

x_shaded = [shadow_x_negative(1), shadow_x_negative(2), shadow_x_negative(2), shadow_x_negative(1)];% x-coordinates of the shaded area
y_shaded = [-0.5, -0.5, 6, 6];                                       % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
x_shaded = [ shadow_x_positive(1), shadow_x_positive(2), shadow_x_positive(2), shadow_x_positive(1)]; % x-coordinates of the shaded area
y_shaded = [-0.5, -0.5, 6, 6];                                       % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'k', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent

plot(ret_simple,Q_P_overall_ttm27.Q_overall,'-','Color','k','LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.P_NB11,'--','Color','k','LineWidth',2);
plot(ret_simple,Q_P_overall_ttm27.Q_overall./Q_P_overall_ttm27.P_NB11,'-.','Color','k','LineWidth',2);
hold off
legend(["$\hat{q}$","$\hat{p}$","$\widehat{PK}$"],'FontSize',15,'Location','northwest','Interpreter','latex','Box','off')
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
saveas(gcf,"Bitcoin_Premium/2_1_X_13/QP_ePDF_3287_forward_onlyVR_NB11_OA_ttm27_1by1.png")
% Compute E_P, E_Q and E_P - E_Q
EP=trapz(ret_simple,ret_simple.*Q_P_overall_ttm27.P_NB11);
EQ=trapz(ret_simple,ret_simple.*Q_P_overall_ttm27.Q_overall);
disp([EP,EQ,EP-EQ])

% Compute P(r< negative shadow upper limit) and P(r< negative shadow lower limit)
index = (ret_simple<shadow_x_negative(2));
P_negative_upper = trapz(ret_simple(index), Q_P_overall_ttm27.P_NB11(index));
disp(['The probability of return <',num2str(shadow_x_negative(2)),' is ',num2str(P_negative_upper)])
index = (ret_simple<shadow_x_negative(1));
P_negative_lower = trapz(ret_simple(index), Q_P_overall_ttm27.P_NB11(index));
disp(['The probability of return <',num2str(shadow_x_negative(1)),' is ',num2str(P_negative_lower)])
% Compute P(r< positive shadow upper limit) and P(r< positive shadow lower limit)
index = (ret_simple<shadow_x_positive(1));
P_positive_lower = trapz(ret_simple(index), Q_P_overall_ttm27.P_NB11(index));
disp(['The probability of return >',num2str(shadow_x_positive(1)),' is ',num2str(P_positive_lower)])
index = (ret_simple>shadow_x_positive(2));
P_positive_upper = trapz(ret_simple(index), Q_P_overall_ttm27.P_NB11(index));
disp(['The probability of return >',num2str(shadow_x_positive(2)),' is ',num2str(P_positive_upper)])

%% Plot q, p, PK, for HV cluster
% Focus on TTM 27
shadow_x_negative = [-0.7, -0.2];
shadow_x_positive = [0.2, 0.7];
figure;

plot(nan,nan,'-','Color','b','LineWidth',2);hold on
plot(nan,nan,'--','Color','b','LineWidth',2);
plot(nan,nan,'-.','Color','b','LineWidth',2);

plot(ret_simple,Q_P_c0_ttm27.Q_cluster0,'-','Color','b','LineWidth',2);
plot(ret_simple,Q_P_c0_ttm27.P_NB11,'--','Color','b','LineWidth',2);
plot(ret_simple,Q_P_c0_ttm27.Q_cluster0./Q_P_c0_ttm27.P_NB11,'-.','Color','b','LineWidth',2);

x_shaded = [shadow_x_negative(1), shadow_x_negative(2), shadow_x_negative(2), shadow_x_negative(1)];% x-coordinates of the shaded area
y_shaded = [-0.5, -0.5, 6, 6];                                       % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'b', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
x_shaded = [ shadow_x_positive(1), shadow_x_positive(2), shadow_x_positive(2), shadow_x_positive(1)];% x-coordinates of the shaded area
y_shaded = [-0.5, -0.5, 6, 6];                                       % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'b', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
hold off
% grid on
legend(["$\hat{q}_{HV}$","$\hat{p}_{HV}$","$\widehat{PK}_{HV}$"],'FontSize',15,'Location','northwest','Interpreter','latex','Box','off')
ylim([0,4])
xlim([-1,1])
xticks([-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1])
xlabel('Return','FontSize',15)
% ylabel('PK','FontSize',15)
set(gcf,'Position',[0,0,450,300]);  
ax = gca;
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
saveas(gcf,"Bitcoin_Premium/2_1_X_13/QP_ePDF_3287_forward_onlyVR_NB11_c0_ttm27_1-by-1.png")
%% Plot q, p, PK, for LV cluster
% Focus on TTM 27
shadow_x_negative = [-0.5, -0.15];
shadow_x_positive = [0.2, 0.35];
figure;

plot(nan,nan,'-','Color','r','LineWidth',2);hold on
plot(nan,nan,'--','Color','r','LineWidth',2);
plot(nan,nan,'-.','Color','r','LineWidth',2);

plot(ret_simple,Q_P_c1_ttm27.Q_cluster1,'-','Color','r','LineWidth',2);
plot(ret_simple,Q_P_c1_ttm27.P_NB11,'--','Color','r','LineWidth',2);
plot(ret_simple,Q_P_c1_ttm27.Q_cluster1./Q_P_c1_ttm27.P_NB11,'-.','Color','r','LineWidth',2);


x_shaded = [shadow_x_negative(1), shadow_x_negative(2), shadow_x_negative(2), shadow_x_negative(1)];% x-coordinates of the shaded area
y_shaded = [-0.5, -0.5, 6, 6];                                       % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'r', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
x_shaded = [ shadow_x_positive(1), shadow_x_positive(2), shadow_x_positive(2), shadow_x_positive(1)];% x-coordinates of the shaded area
y_shaded = [-0.5, -0.5, 6, 6];                                       % y-coordinates of the shaded area
fill(x_shaded, y_shaded, 'r', 'FaceAlpha', 0.05, 'EdgeColor','none'); % 'k' for black color, 10% transparent
hold off
% grid on
legend(["$\hat{q}_{LV}$","$\hat{p}_{LV}$","$\widehat{PK}_{LV}$"],'FontSize',15,'Location','northwest','Interpreter','latex','Box','off')
ylim([0,4])
xlim([-1,1])
xticks([-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1])
xlabel('Return','FontSize',15)
% ylabel('PK','FontSize',15)
set(gcf,'Position',[0,0,450,300]);  
ax = gca;
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
saveas(gcf,"Bitcoin_Premium/2_1_X_13/QP_ePDF_3287_forward_onlyVR_NB11_c1_ttm27_1-by-1.png")
%% EP table
E_P_OA=trapz(ret_simple,ret_simple.*Q_P_overall_ttm27.P_NB11)*365/27;
E_P_c0=trapz(ret_simple,ret_simple.*Q_P_c0_ttm27.P_NB11)*365/27;
E_P_c1=trapz(ret_simple,ret_simple.*Q_P_c1_ttm27.P_NB11)*365/27;
E_Q_density_OA=trapz(ret_simple,ret_simple.*Q_P_overall_ttm27.Q_overall)*365/27;
E_Q_density_c0=trapz(ret_simple,ret_simple.*Q_P_c0_ttm27.Q_cluster0)*365/27;
E_Q_density_c1=trapz(ret_simple,ret_simple.*Q_P_c1_ttm27.Q_cluster1)*365/27;
E_Q_IR0_OA=0;
E_Q_IR0_c0=0;
E_Q_IR0_c1=0;
BP_cluster=nan(3,6);
BP_cluster(1,:)=[E_P_OA,E_P_c0,E_P_c1,E_P_OA,E_P_c0,E_P_c1];
BP_cluster(2,:)=[E_Q_density_OA,E_Q_density_c0,E_Q_density_c1,E_Q_IR0_OA,E_Q_IR0_c0,E_Q_IR0_c1];
BP_cluster(3,:)=BP_cluster(1,:)-BP_cluster(2,:);
BP_cluster = BP_cluster([3,1,2],:);
clear info;
info.rnames = strvcat('.','E_P-E_Q','E_P','E_Q');
info.cnames = strvcat('Overall','Cluster 0','Cluster 1','Overall','Cluster 0','Cluster 1');
info.fmt    = '%10.2f';
mprint(BP_cluster,info)

% close all

%% Plot PK of OA, HV, LV in the same figure
% Focus on TTM 27
figure;

plot(nan,nan,'-.','Color','k','LineWidth',2);hold on
plot(nan,nan,'-.','Color','b','LineWidth',2);
plot(nan,nan,'-.','Color','r','LineWidth',2);

plot(ret_simple,Q_P_overall_ttm27.Q_overall./Q_P_overall_ttm27.P_NB11,'-.','Color','k','LineWidth',2);
plot(ret_simple,Q_P_c0_ttm27.Q_cluster0./Q_P_c0_ttm27.P_NB11,'-.','Color','b','LineWidth',2);
plot(ret_simple,Q_P_c1_ttm27.Q_cluster1./Q_P_c1_ttm27.P_NB11,'-.','Color','r','LineWidth',2);

hold off
% grid on
legend(["$\widehat{PK}_{OA}$","$\widehat{PK}_{HV}$","$\widehat{PK}_{LV}$"],'FontSize',15,'Location','northeast','Interpreter','latex','Box','off')
ylim([0,4])
xlim([-1,1])
xticks([-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1])
xlabel('Return','FontSize',15)
% ylabel('PK','FontSize',15)
set(gcf,'Position',[0,0,450,300]);  
ax = gca;
ax.FontSize = 15;
% ax.YAxis.FontWeight = 'bold'; % Make Y-axis tick labels bold
ax.YAxis.LineWidth = 1; % Increase the line width of the Y-axis
ax.XAxis.LineWidth = 1; % Increase the line width of the Y-axis
saveas(gcf,"Bitcoin_Premium/2_1_X_13/PK_ePDF_3287_forward_onlyVR_NB11_OAc0c1_ttm27_1-by-1.png")
