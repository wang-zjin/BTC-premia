%% Convert Q densities into Q matrix
% want to output Q-density matrix: x-axis time, y-axis return
%

clear,clc
[~,~,~]=mkdir("Q_plots/moneyness");
daily_price = readtable("Data/BTC_USD_Quandl_2015_2022.csv");

%% Filter density
ttm = 5;
[~,~,~]=mkdir(strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S1_nonnegative"));
[~,~,~]=mkdir(strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S2_monotonic"));
[~,~,~]=mkdir(strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S3_momoent"));

IV_matrx = readtable(strcat("IR0/moneyness/interpolated_IV",num2str(ttm),"_060.csv"));
dates_list = sort(IV_matrx.Var1(2:end));

dateset_yyyymmdd = string(datetime(dates_list,"Format","yyyyMMdd"));
dateset_yyyymmdd = sortrows(dateset_yyyymmdd);

Q_array = nan(numel(-1:0.001:1),numel(dates_list));
Q_array_d15 = nan(numel(-0.15:0.001:0.15),numel(dates_list));
for i = 1:numel(dates_list)
    fprintf("%2d\n",i)
    date = datestr(dates_list(i),'yyyy-mm-dd');
    a = strcat('Q_from_pure_SVI/moneyness/ttm',num2str(ttm),'/btc_Q_',date,'.csv');
    Q_density = readtable(a);

    if max(Q_density.ret)==1 && min(Q_density.ret)==-1
        Q_array(:,i) = interp1(Q_density.ret, Q_density.spdy, -1:0.001:1);
        Q_array_d15(:,i) = interp1(Q_density.ret, Q_density.spdy, -0.15:0.001:0.15);
    end

end

figure;
plot(-1:0.001:1, Q_array);
saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/raw_all_density.png"))


% Check if there is any negative density values
if sum(any(Q_array<0)) > 0
    fprintf("There are negative Q density values\n")
end

% Check if there is any NaN values
if sum(any(isnan(Q_array))) > 0
    fprintf("There are NaN Q density values\n")
end

ind_nonnega = find(min(Q_array)>=0);

figure;
plot(-1:0.001:1, Q_array(:,ind_nonnega));
xlim([-1, 1])
ylim([0, ceil(max(max(Q_array(:, ind_nonnega))))])
hold on
xticks(-1:0.2:1)
saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S1_nonnegative/all_nonnegative_density.png"))
close all

for i = 1:length(ind_nonnega)

    i_ind = ind_nonnega(i);
    figure;
    plot(-1:0.001:1, Q_array(:,i_ind));
    xlim([-1, 1])
    ylim([0, ceil(max(max(Q_array(:, ind_nonnega))))])
    hold on
    xticks(-1:0.2:1)
    saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S1_nonnegative/",datestr(dates_list(i_ind),"yyyy-mm-dd"),".png"))
    close all
end

% Check if there is any density with non-monotonic values before or behind
% the maximum value
ind_mono = ind_nonnega;
for i = 1:length(ind_nonnega)

    i_ind = ind_nonnega(i);
    [~, max_ind] = max(Q_array(:,i_ind));
    if any(diff(Q_array(1:max_ind, i_ind)) < 0 ) || any(diff(Q_array(max_ind:end, i_ind)) > 0 ) 
        ind_mono(i) = nan;
    end
end
ind_mono = ind_nonnega(~isnan(ind_mono));

% Plot all densities satisfying monotonic condition
figure;
plot(-1:0.001:1, Q_array(:,ind_mono));
xlim([-1, 1])
ylim([0, ceil(max(max(Q_array(:, ind_mono))))])
hold on
xticks(-1:0.2:1)
saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S2_monotonic/all_nonnegative_density.png"))
close all

% Plot each density satisfying monotomic condition separately
for i = 1:length(ind_mono)

    i_ind = ind_mono(i);
    figure;
    plot(-1:0.001:1, Q_array(:,i_ind));
    xlim([-1, 1])
    ylim([0, ceil(max(max(Q_array(:, ind_mono))))])
    hold on
    xticks(-1:0.2:1)
    saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S2_monotonic/",datestr(dates_list(i_ind),"yyyy-mm-dd"),".png"))
    close all
end

% Check the moments of the densities
moments = nan(length(ind_mono), 4);
for i = 1:length(ind_mono)

    i_ind = ind_mono(i);
    moments(i,:) = density_moments((-1:0.001:1)', Q_array(:,i_ind), ttm)';
end

% Create a timetable using the valid dates from ind_mono
valid_dates = datetime(dates_list(ind_mono), 'InputFormat', 'yyyy-MM-dd');
moments_timetable = timetable(valid_dates, moments(:, 1), moments(:, 2), moments(:, 3), moments(:, 4), ...
    'VariableNames', {'Mean', 'Variance', 'Skewness', 'Kurtosis'});
% Save the timetable to a file
writetable(timetable2table(moments_timetable), ...
    strcat("Q_plots/moneyness/ttm", num2str(ttm), "/S2_monotonic/moments_timetable.csv"));

% % Display the timetable
% disp('Timetable of Moments with Valid Dates:');
% disp(moments_timetable);

summary(moments_timetable)

% Convert the timetable to a table for easier plotting
moments_table = timetable2table(moments_timetable);
% Reshape the data for boxchart
moment_data = moments_table{:, 2:end}; % Extract numeric data (Mean, Variance, Skewness, Kurtosis)
moment_names = moments_table.Properties.VariableNames(2:end); % Moment names
% Specify the desired order of moments
desired_order = {'Mean', 'Variance', 'Skewness', 'Kurtosis'};
% Repeat moment names for each row
num_rows = size(moment_data, 1);
group_labels = repmat(moment_names, num_rows, 1); % Create repeated labels
group_labels = group_labels(:); % Convert to a single column
% Stack the data into a single column
stacked_data = moment_data(:);
% Create categorical labels in the specified order
group_labels = categorical(group_labels, desired_order);
% Create a box chart
figure;
boxchart(categorical(group_labels), stacked_data);
% Customize the plot
xlabel('Moments');
ylabel('Values');
title('Box Plot of Moments (Mean, Variance, Skewness, Kurtosis)');
grid on;
% Save the box plot
saveas(gcf, strcat("Q_plots/moneyness/ttm", num2str(ttm), "/S2_monotonic/moments_boxplot.png"));

% Define thresholds based on your analysis of moments
mean_range = [-10, 10];
variance_range = [0, 10];
skewness_threshold = 10; % Absolute skewness should not exceed 2
kurtosis_range = [-5, 30]; % Typical range for density kurtosis
% Identify valid densities based on moments
valid_by_moments = ...
    (moments(:, 1) >= mean_range(1) & moments(:, 1) <= mean_range(2)) & ...
    (moments(:, 2) >= variance_range(1) & moments(:, 2) <= variance_range(2)) & ...
    (abs(moments(:, 3)) <= skewness_threshold) & ...
    (moments(:, 4) >= kurtosis_range(1) & moments(:, 4) <= kurtosis_range(2));
% Filter densities based on valid moments
ind_moments_filtered = ind_mono(valid_by_moments);
Q_array_final = Q_array(:, ind_moments_filtered);
dates_final = dateset_yyyymmdd(ind_moments_filtered);

% Save and plot the final filtered densities
figure;
plot(-1:0.001:1, Q_array_final);
xlim([-1, 1]);
ylim([0, ceil(max(max(Q_array(:, ind_moments_filtered))))])
xticks(-1:0.2:1);
saveas(gcf, strcat("Q_plots/moneyness/ttm", num2str(ttm), "/S3_momoent/all_filtered_density.png"));

% Plot each density satisfying monotomic condition separately
for i = 1:length(ind_moments_filtered)

    i_ind = ind_moments_filtered(i);
    figure;
    plot(-1:0.001:1, Q_array(:,i_ind));
    xlim([-1, 1])
    ylim([0, ceil(max(max(Q_array(:, ind_moments_filtered))))])
    hold on
    xticks(-1:0.2:1)
    saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S3_momoent/",datestr(dates_list(i_ind),"yyyy-mm-dd"),".png"))
    close all
end


% Save final Q matrix
Return = array2table((-1:0.001:1)',"VariableNames",{'Return'});
Q_table = array2table(Q_array_final,"VariableNames",dates_final);
Q_table = [Return,Q_table];
writetable(Q_table,strcat("Q_from_pure_SVI/moneyness/Q_matrix_",num2str(ttm),"day.csv"))

% Save Q matrix within -0.15 and 0.15 return range
Return = array2table((-0.15:0.001:0.15)',"VariableNames",{'Return'});
Q_table = array2table(Q_array_d15(:,ind_moments_filtered),"VariableNames",dates_final);
Q_table = [Return,Q_table];
writetable(Q_table,strcat("Q_from_pure_SVI/moneyness/Q_matrix_",num2str(ttm),"day_d15.csv"))

%% Iterate for ttm = 9, 14, 27
ttm = 9;

[~,~,~]=mkdir(strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S1_nonnegative"));
[~,~,~]=mkdir(strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S2_monotonic"));
[~,~,~]=mkdir(strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S3_momoent"));

IV_matrx = readtable(strcat("IR0/moneyness/interpolated_IV",num2str(ttm),"_060.csv"));
dates_list = sort(IV_matrx.Var1(2:end));

dateset_yyyymmdd = string(datetime(dates_list,"Format","yyyyMMdd"));
dateset_yyyymmdd = sortrows(dateset_yyyymmdd);

Q_array = nan(numel(-1:0.001:1),numel(dates_list));
Q_array_d15 = nan(numel(-0.15:0.001:0.15),numel(dates_list));
for i = 1:numel(dates_list)
    fprintf("%2d\n",i)
    date = datestr(dates_list(i),'yyyy-mm-dd');
    a = strcat('Q_from_pure_SVI/moneyness/ttm',num2str(ttm),'/btc_Q_',date,'.csv');
    Q_density = readtable(a);

    if max(Q_density.ret)==1 && min(Q_density.ret)==-1
        Q_array(:,i) = interp1(Q_density.ret, Q_density.spdy, -1:0.001:1);
        Q_array_d15(:,i) = interp1(Q_density.ret, Q_density.spdy, -0.15:0.001:0.15);
    end

end

figure;
plot(-1:0.001:1, Q_array);
saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/raw_all_density.png"))


% Check if there is any negative density values
if sum(any(Q_array<0)) > 0
    fprintf("There are negative Q density values\n")
end

% Check if there is any NaN values
if sum(any(isnan(Q_array))) > 0
    fprintf("There are NaN Q density values\n")
end

ind_nonnega = find(min(Q_array)>=0);

figure;
plot(-1:0.001:1, Q_array(:,ind_nonnega));
xlim([-1, 1])
ylim([0, ceil(max(max(Q_array(:, ind_nonnega))))])
hold on
xticks(-1:0.2:1)
saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S1_nonnegative/all_nonnegative_density.png"))
close all

for i = 1:length(ind_nonnega)

    i_ind = ind_nonnega(i);
    figure;
    plot(-1:0.001:1, Q_array(:,i_ind));
    xlim([-1, 1])
    ylim([0, ceil(max(max(Q_array(:, ind_nonnega))))])
    hold on
    xticks(-1:0.2:1)
    saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S1_nonnegative/",datestr(dates_list(i_ind),"yyyy-mm-dd"),".png"))
    close all
end

% Check if there is any density with non-monotonic values before or behind
% the maximum value
ind_mono = ind_nonnega;
for i = 1:length(ind_nonnega)

    i_ind = ind_nonnega(i);
    [~, max_ind] = max(Q_array(:,i_ind));
    if any(diff(Q_array(1:max_ind, i_ind)) < 0 ) || any(diff(Q_array(max_ind:end, i_ind)) > 0 ) 
        ind_mono(i) = nan;
    end
end
ind_mono = ind_nonnega(~isnan(ind_mono));

% Plot all densities satisfying monotonic condition
figure;
plot(-1:0.001:1, Q_array(:,ind_mono));
xlim([-1, 1])
ylim([0, ceil(max(max(Q_array(:, ind_mono))))])
hold on
xticks(-1:0.2:1)
saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S2_monotonic/all_nonnegative_density.png"))
close all

% Plot each density satisfying monotomic condition separately
for i = 1:length(ind_mono)

    i_ind = ind_mono(i);
    figure;
    plot(-1:0.001:1, Q_array(:,i_ind));
    xlim([-1, 1])
    ylim([0, ceil(max(max(Q_array(:, ind_mono))))])
    hold on
    xticks(-1:0.2:1)
    saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S2_monotonic/",datestr(dates_list(i_ind),"yyyy-mm-dd"),".png"))
    close all
end

% Check the moments of the densities
moments = nan(length(ind_mono), 4);
for i = 1:length(ind_mono)

    i_ind = ind_mono(i);
    moments(i,:) = density_moments((-1:0.001:1)', Q_array(:,i_ind), ttm)';
end

% Create a timetable using the valid dates from ind_mono
valid_dates = datetime(dates_list(ind_mono), 'InputFormat', 'yyyy-MM-dd');
moments_timetable = timetable(valid_dates, moments(:, 1), moments(:, 2), moments(:, 3), moments(:, 4), ...
    'VariableNames', {'Mean', 'Variance', 'Skewness', 'Kurtosis'});
% Save the timetable to a file
writetable(timetable2table(moments_timetable), ...
    strcat("Q_plots/moneyness/ttm", num2str(ttm), "/S2_monotonic/moments_timetable.csv"));

% % Display the timetable
% disp('Timetable of Moments with Valid Dates:');
% disp(moments_timetable);

summary(moments_timetable)

% Convert the timetable to a table for easier plotting
moments_table = timetable2table(moments_timetable);
% Reshape the data for boxchart
moment_data = moments_table{:, 2:end}; % Extract numeric data (Mean, Variance, Skewness, Kurtosis)
moment_names = moments_table.Properties.VariableNames(2:end); % Moment names
% Specify the desired order of moments
desired_order = {'Mean', 'Variance', 'Skewness', 'Kurtosis'};
% Repeat moment names for each row
num_rows = size(moment_data, 1);
group_labels = repmat(moment_names, num_rows, 1); % Create repeated labels
group_labels = group_labels(:); % Convert to a single column
% Stack the data into a single column
stacked_data = moment_data(:);
% Create categorical labels in the specified order
group_labels = categorical(group_labels, desired_order);
% Create a box chart
figure;
boxchart(categorical(group_labels), stacked_data);
% Customize the plot
xlabel('Moments');
ylabel('Values');
title('Box Plot of Moments (Mean, Variance, Skewness, Kurtosis)');
grid on;
% Save the box plot
saveas(gcf, strcat("Q_plots/moneyness/ttm", num2str(ttm), "/S2_monotonic/moments_boxplot.png"));

% Define thresholds based on your analysis of moments
mean_range = [-10, 10];
variance_range = [0, 10];
skewness_threshold = 10; % Absolute skewness should not exceed 2
kurtosis_range = [-5, 30]; % Typical range for density kurtosis
% Identify valid densities based on moments
valid_by_moments = ...
    (moments(:, 1) >= mean_range(1) & moments(:, 1) <= mean_range(2)) & ...
    (moments(:, 2) >= variance_range(1) & moments(:, 2) <= variance_range(2)) & ...
    (abs(moments(:, 3)) <= skewness_threshold) & ...
    (moments(:, 4) >= kurtosis_range(1) & moments(:, 4) <= kurtosis_range(2));
% Filter densities based on valid moments
ind_moments_filtered = ind_mono(valid_by_moments);
Q_array_final = Q_array(:, ind_moments_filtered);
dates_final = dateset_yyyymmdd(ind_moments_filtered);

% Save and plot the final filtered densities
figure;
plot(-1:0.001:1, Q_array_final);
xlim([-1, 1]);
ylim([0, ceil(max(max(Q_array(:, ind_moments_filtered))))])
xticks(-1:0.2:1);
saveas(gcf, strcat("Q_plots/moneyness/ttm", num2str(ttm), "/S3_momoent/all_filtered_density.png"));

% Plot each density satisfying monotomic condition separately
for i = 1:length(ind_moments_filtered)

    i_ind = ind_moments_filtered(i);
    figure;
    plot(-1:0.001:1, Q_array(:,i_ind));
    xlim([-1, 1])
    ylim([0, ceil(max(max(Q_array(:, ind_moments_filtered))))])
    hold on
    xticks(-1:0.2:1)
    saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S3_momoent/",datestr(dates_list(i_ind),"yyyy-mm-dd"),".png"))
    close all
end


% Save final Q matrix
Return = array2table((-1:0.001:1)',"VariableNames",{'Return'});
Q_table = array2table(Q_array_final,"VariableNames",dates_final);
Q_table = [Return,Q_table];
writetable(Q_table,strcat("Q_from_pure_SVI/moneyness/Q_matrix_",num2str(ttm),"day.csv"))

% Save Q matrix within -0.15 and 0.15 return range
Return = array2table((-0.15:0.001:0.15)',"VariableNames",{'Return'});
Q_table = array2table(Q_array_d15(:,ind_moments_filtered),"VariableNames",dates_final);
Q_table = [Return,Q_table];
writetable(Q_table,strcat("Q_from_pure_SVI/moneyness/Q_matrix_",num2str(ttm),"day_d15.csv"))

%% Iterate for ttm = 9, 14, 27
ttm = 14;

[~,~,~]=mkdir(strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S1_nonnegative"));
[~,~,~]=mkdir(strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S2_monotonic"));
[~,~,~]=mkdir(strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S3_momoent"));

IV_matrx = readtable(strcat("IR0/moneyness/interpolated_IV",num2str(ttm),"_060.csv"));
dates_list = sort(IV_matrx.Var1(2:end));

dateset_yyyymmdd = string(datetime(dates_list,"Format","yyyyMMdd"));
dateset_yyyymmdd = sortrows(dateset_yyyymmdd);

Q_array = nan(numel(-1:0.001:1),numel(dates_list));
Q_array_d15 = nan(numel(-0.15:0.001:0.15),numel(dates_list));
for i = 1:numel(dates_list)
    fprintf("%2d\n",i)
    date = datestr(dates_list(i),'yyyy-mm-dd');
    a = strcat('Q_from_pure_SVI/moneyness/ttm',num2str(ttm),'/btc_Q_',date,'.csv');
    Q_density = readtable(a);

    if max(Q_density.ret)==1 && min(Q_density.ret)==-1
        Q_array(:,i) = interp1(Q_density.ret, Q_density.spdy, -1:0.001:1);
        Q_array_d15(:,i) = interp1(Q_density.ret, Q_density.spdy, -0.15:0.001:0.15);
    end

end

figure;
plot(-1:0.001:1, Q_array);
saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/raw_all_density.png"))


% Check if there is any negative density values
if sum(any(Q_array<0)) > 0
    fprintf("There are negative Q density values\n")
end

% Check if there is any NaN values
if sum(any(isnan(Q_array))) > 0
    fprintf("There are NaN Q density values\n")
end

ind_nonnega = find(min(Q_array)>=0);

figure;
plot(-1:0.001:1, Q_array(:,ind_nonnega));
xlim([-1, 1])
ylim([0, ceil(max(max(Q_array(:, ind_nonnega))))])
hold on
xticks(-1:0.2:1)
saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S1_nonnegative/all_nonnegative_density.png"))
close all

for i = 1:length(ind_nonnega)

    i_ind = ind_nonnega(i);
    figure;
    plot(-1:0.001:1, Q_array(:,i_ind));
    xlim([-1, 1])
    ylim([0, ceil(max(max(Q_array(:, ind_nonnega))))])
    hold on
    xticks(-1:0.2:1)
    saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S1_nonnegative/",datestr(dates_list(i_ind),"yyyy-mm-dd"),".png"))
    close all
end

% Check if there is any density with non-monotonic values before or behind
% the maximum value
ind_mono = ind_nonnega;
for i = 1:length(ind_nonnega)

    i_ind = ind_nonnega(i);
    [~, max_ind] = max(Q_array(:,i_ind));
    if any(diff(Q_array(1:max_ind, i_ind)) < 0 ) || any(diff(Q_array(max_ind:end, i_ind)) > 0 ) 
        ind_mono(i) = nan;
    end
end
ind_mono = ind_nonnega(~isnan(ind_mono));

% Plot all densities satisfying monotonic condition
figure;
plot(-1:0.001:1, Q_array(:,ind_mono));
xlim([-1, 1])
ylim([0, ceil(max(max(Q_array(:, ind_mono))))])
hold on
xticks(-1:0.2:1)
saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S2_monotonic/all_nonnegative_density.png"))
close all

% Plot each density satisfying monotomic condition separately
for i = 1:length(ind_mono)

    i_ind = ind_mono(i);
    figure;
    plot(-1:0.001:1, Q_array(:,i_ind));
    xlim([-1, 1])
    ylim([0, ceil(max(max(Q_array(:, ind_mono))))])
    hold on
    xticks(-1:0.2:1)
    saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S2_monotonic/",datestr(dates_list(i_ind),"yyyy-mm-dd"),".png"))
    close all
end

% Check the moments of the densities
moments = nan(length(ind_mono), 4);
for i = 1:length(ind_mono)

    i_ind = ind_mono(i);
    moments(i,:) = density_moments((-1:0.001:1)', Q_array(:,i_ind), ttm)';
end

% Create a timetable using the valid dates from ind_mono
valid_dates = datetime(dates_list(ind_mono), 'InputFormat', 'yyyy-MM-dd');
moments_timetable = timetable(valid_dates, moments(:, 1), moments(:, 2), moments(:, 3), moments(:, 4), ...
    'VariableNames', {'Mean', 'Variance', 'Skewness', 'Kurtosis'});
% Save the timetable to a file
writetable(timetable2table(moments_timetable), ...
    strcat("Q_plots/moneyness/ttm", num2str(ttm), "/S2_monotonic/moments_timetable.csv"));

% % Display the timetable
% disp('Timetable of Moments with Valid Dates:');
% disp(moments_timetable);

summary(moments_timetable)

% Convert the timetable to a table for easier plotting
moments_table = timetable2table(moments_timetable);
% Reshape the data for boxchart
moment_data = moments_table{:, 2:end}; % Extract numeric data (Mean, Variance, Skewness, Kurtosis)
moment_names = moments_table.Properties.VariableNames(2:end); % Moment names
% Specify the desired order of moments
desired_order = {'Mean', 'Variance', 'Skewness', 'Kurtosis'};
% Repeat moment names for each row
num_rows = size(moment_data, 1);
group_labels = repmat(moment_names, num_rows, 1); % Create repeated labels
group_labels = group_labels(:); % Convert to a single column
% Stack the data into a single column
stacked_data = moment_data(:);
% Create categorical labels in the specified order
group_labels = categorical(group_labels, desired_order);
% Create a box chart
figure;
boxchart(categorical(group_labels), stacked_data);
% Customize the plot
xlabel('Moments');
ylabel('Values');
title('Box Plot of Moments (Mean, Variance, Skewness, Kurtosis)');
grid on;
% Save the box plot
saveas(gcf, strcat("Q_plots/moneyness/ttm", num2str(ttm), "/S2_monotonic/moments_boxplot.png"));

% Define thresholds based on your analysis of moments
mean_range = [-10, 10];
variance_range = [0, 10];
skewness_threshold = 10; % Absolute skewness should not exceed 2
kurtosis_range = [-5, 30]; % Typical range for density kurtosis
% Identify valid densities based on moments
valid_by_moments = ...
    (moments(:, 1) >= mean_range(1) & moments(:, 1) <= mean_range(2)) & ...
    (moments(:, 2) >= variance_range(1) & moments(:, 2) <= variance_range(2)) & ...
    (abs(moments(:, 3)) <= skewness_threshold) & ...
    (moments(:, 4) >= kurtosis_range(1) & moments(:, 4) <= kurtosis_range(2));
% Filter densities based on valid moments
ind_moments_filtered = ind_mono(valid_by_moments);
Q_array_final = Q_array(:, ind_moments_filtered);
dates_final = dateset_yyyymmdd(ind_moments_filtered);

% Save and plot the final filtered densities
figure;
plot(-1:0.001:1, Q_array_final);
xlim([-1, 1]);
ylim([0, ceil(max(max(Q_array(:, ind_moments_filtered))))])
xticks(-1:0.2:1);
saveas(gcf, strcat("Q_plots/moneyness/ttm", num2str(ttm), "/S3_momoent/all_filtered_density.png"));

% Plot each density satisfying monotomic condition separately
for i = 1:length(ind_moments_filtered)

    i_ind = ind_moments_filtered(i);
    figure;
    plot(-1:0.001:1, Q_array(:,i_ind));
    xlim([-1, 1])
    ylim([0, ceil(max(max(Q_array(:, ind_moments_filtered))))])
    hold on
    xticks(-1:0.2:1)
    saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S3_momoent/",datestr(dates_list(i_ind),"yyyy-mm-dd"),".png"))
    close all
end


% Save final Q matrix
Return = array2table((-1:0.001:1)',"VariableNames",{'Return'});
Q_table = array2table(Q_array_final,"VariableNames",dates_final);
Q_table = [Return,Q_table];
writetable(Q_table,strcat("Q_from_pure_SVI/moneyness/Q_matrix_",num2str(ttm),"day.csv"))

% Save Q matrix within -0.15 and 0.15 return range
Return = array2table((-0.15:0.001:0.15)',"VariableNames",{'Return'});
Q_table = array2table(Q_array_d15(:,ind_moments_filtered),"VariableNames",dates_final);
Q_table = [Return,Q_table];
writetable(Q_table,strcat("Q_from_pure_SVI/moneyness/Q_matrix_",num2str(ttm),"day_d15.csv"))

%% Iterate for ttm = 9, 14, 27
ttm = 27;

[~,~,~]=mkdir(strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S1_nonnegative"));
[~,~,~]=mkdir(strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S2_monotonic"));
[~,~,~]=mkdir(strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S3_momoent"));

IV_matrx = readtable(strcat("IR0/moneyness/interpolated_IV",num2str(ttm),"_060.csv"));
dates_list = sort(IV_matrx.Var1(2:end));

dateset_yyyymmdd = string(datetime(dates_list,"Format","yyyyMMdd"));
dateset_yyyymmdd = sortrows(dateset_yyyymmdd);

Q_array = nan(numel(-1:0.001:1),numel(dates_list));
Q_array_d15 = nan(numel(-0.15:0.001:0.15),numel(dates_list));
for i = 1:numel(dates_list)
    fprintf("%2d\n",i)
    date = datestr(dates_list(i),'yyyy-mm-dd');
    a = strcat('Q_from_pure_SVI/moneyness/ttm',num2str(ttm),'/btc_Q_',date,'.csv');
    Q_density = readtable(a);

    if max(Q_density.ret)==1 && min(Q_density.ret)==-1
        Q_array(:,i) = interp1(Q_density.ret, Q_density.spdy, -1:0.001:1);
        Q_array_d15(:,i) = interp1(Q_density.ret, Q_density.spdy, -0.15:0.001:0.15);
    end

end

figure;
plot(-1:0.001:1, Q_array);
saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/raw_all_density.png"))


% Check if there is any negative density values
if sum(any(Q_array<0)) > 0
    fprintf("There are negative Q density values\n")
end

% Check if there is any NaN values
if sum(any(isnan(Q_array))) > 0
    fprintf("There are NaN Q density values\n")
end

ind_nonnega = find(min(Q_array)>=0);

figure;
plot(-1:0.001:1, Q_array(:,ind_nonnega));
xlim([-1, 1])
ylim([0, ceil(max(max(Q_array(:, ind_nonnega))))])
hold on
xticks(-1:0.2:1)
saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S1_nonnegative/all_nonnegative_density.png"))
close all

for i = 1:length(ind_nonnega)

    i_ind = ind_nonnega(i);
    figure;
    plot(-1:0.001:1, Q_array(:,i_ind));
    xlim([-1, 1])
    ylim([0, ceil(max(max(Q_array(:, ind_nonnega))))])
    hold on
    xticks(-1:0.2:1)
    saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S1_nonnegative/",datestr(dates_list(i_ind),"yyyy-mm-dd"),".png"))
    close all
end

% Check if there is any density with non-monotonic values before or behind
% the maximum value
ind_mono = ind_nonnega;
for i = 1:length(ind_nonnega)

    i_ind = ind_nonnega(i);
    [~, max_ind] = max(Q_array(:,i_ind));
    if any(diff(Q_array(1:max_ind, i_ind)) < 0 ) || any(diff(Q_array(max_ind:end, i_ind)) > 0 ) 
        ind_mono(i) = nan;
    end
end
ind_mono = ind_nonnega(~isnan(ind_mono));

% Plot all densities satisfying monotonic condition
figure;
plot(-1:0.001:1, Q_array(:,ind_mono));
xlim([-1, 1])
ylim([0, ceil(max(max(Q_array(:, ind_mono))))])
hold on
xticks(-1:0.2:1)
saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S2_monotonic/all_nonnegative_density.png"))
close all

% Plot each density satisfying monotomic condition separately
for i = 1:length(ind_mono)

    i_ind = ind_mono(i);
    figure;
    plot(-1:0.001:1, Q_array(:,i_ind));
    xlim([-1, 1])
    ylim([0, ceil(max(max(Q_array(:, ind_mono))))])
    hold on
    xticks(-1:0.2:1)
    saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S2_monotonic/",datestr(dates_list(i_ind),"yyyy-mm-dd"),".png"))
    close all
end

% Check the moments of the densities
moments = nan(length(ind_mono), 4);
for i = 1:length(ind_mono)

    i_ind = ind_mono(i);
    moments(i,:) = density_moments((-1:0.001:1)', Q_array(:,i_ind), ttm)';
end

% Create a timetable using the valid dates from ind_mono
valid_dates = datetime(dates_list(ind_mono), 'InputFormat', 'yyyy-MM-dd');
moments_timetable = timetable(valid_dates, moments(:, 1), moments(:, 2), moments(:, 3), moments(:, 4), ...
    'VariableNames', {'Mean', 'Variance', 'Skewness', 'Kurtosis'});
% Save the timetable to a file
writetable(timetable2table(moments_timetable), ...
    strcat("Q_plots/moneyness/ttm", num2str(ttm), "/S2_monotonic/moments_timetable.csv"));

% % Display the timetable
% disp('Timetable of Moments with Valid Dates:');
% disp(moments_timetable);

summary(moments_timetable)

% Convert the timetable to a table for easier plotting
moments_table = timetable2table(moments_timetable);
% Reshape the data for boxchart
moment_data = moments_table{:, 2:end}; % Extract numeric data (Mean, Variance, Skewness, Kurtosis)
moment_names = moments_table.Properties.VariableNames(2:end); % Moment names
% Specify the desired order of moments
desired_order = {'Mean', 'Variance', 'Skewness', 'Kurtosis'};
% Repeat moment names for each row
num_rows = size(moment_data, 1);
group_labels = repmat(moment_names, num_rows, 1); % Create repeated labels
group_labels = group_labels(:); % Convert to a single column
% Stack the data into a single column
stacked_data = moment_data(:);
% Create categorical labels in the specified order
group_labels = categorical(group_labels, desired_order);
% Create a box chart
figure;
boxchart(categorical(group_labels), stacked_data);
% Customize the plot
xlabel('Moments');
ylabel('Values');
title('Box Plot of Moments (Mean, Variance, Skewness, Kurtosis)');
grid on;
% Save the box plot
saveas(gcf, strcat("Q_plots/moneyness/ttm", num2str(ttm), "/S2_monotonic/moments_boxplot.png"));

% Define thresholds based on your analysis of moments
mean_range = [-10, 10];
variance_range = [0, 10];
skewness_threshold = 10; % Absolute skewness should not exceed 2
kurtosis_range = [-5, 30]; % Typical range for density kurtosis
% Identify valid densities based on moments
valid_by_moments = ...
    (moments(:, 1) >= mean_range(1) & moments(:, 1) <= mean_range(2)) & ...
    (moments(:, 2) >= variance_range(1) & moments(:, 2) <= variance_range(2)) & ...
    (abs(moments(:, 3)) <= skewness_threshold) & ...
    (moments(:, 4) >= kurtosis_range(1) & moments(:, 4) <= kurtosis_range(2));
% Filter densities based on valid moments
ind_moments_filtered = ind_mono(valid_by_moments);
Q_array_final = Q_array(:, ind_moments_filtered);
dates_final = dateset_yyyymmdd(ind_moments_filtered);

% Save and plot the final filtered densities
figure;
plot(-1:0.001:1, Q_array_final);
xlim([-1, 1]);
ylim([0, ceil(max(max(Q_array(:, ind_moments_filtered))))])
xticks(-1:0.2:1);
saveas(gcf, strcat("Q_plots/moneyness/ttm", num2str(ttm), "/S3_momoent/all_filtered_density.png"));

% Plot each density satisfying monotomic condition separately
for i = 1:length(ind_moments_filtered)

    i_ind = ind_moments_filtered(i);
    figure;
    plot(-1:0.001:1, Q_array(:,i_ind));
    xlim([-1, 1])
    ylim([0, ceil(max(max(Q_array(:, ind_moments_filtered))))])
    hold on
    xticks(-1:0.2:1)
    saveas(gcf,strcat("Q_plots/moneyness/ttm",num2str(ttm),"/S3_momoent/",datestr(dates_list(i_ind),"yyyy-mm-dd"),".png"))
    close all
end


% Save final Q matrix
Return = array2table((-1:0.001:1)',"VariableNames",{'Return'});
Q_table = array2table(Q_array_final,"VariableNames",dates_final);
Q_table = [Return,Q_table];
writetable(Q_table,strcat("Q_from_pure_SVI/moneyness/Q_matrix_",num2str(ttm),"day.csv"))

% Save Q matrix within -0.15 and 0.15 return range
Return = array2table((-0.15:0.001:0.15)',"VariableNames",{'Return'});
Q_table = array2table(Q_array_d15(:,ind_moments_filtered),"VariableNames",dates_final);
Q_table = [Return,Q_table];
writetable(Q_table,strcat("Q_from_pure_SVI/moneyness/Q_matrix_",num2str(ttm),"day_d15.csv"))

%% Function to calculate density moments
function Moments_summary = density_moments(ret, density, ttm)
Moments = zeros(4,1);
Moments(1,1) = trapz(ret, density.*ret);% 1th moment
Moments(2,1) = trapz(ret, density.*(ret-Moments(1,1)).^2);% 2th central moment
Moments(3,1) = trapz(ret, density.*(ret-Moments(1,1)).^3);% 3th central moment
Moments(4,1) = trapz(ret, density.*(ret-Moments(1,1)).^4);% 4th central moment

Mean = Moments(1,1)*365/ttm;
Variance = Moments(2,1)*365/ttm;
Skewness = Moments(3,1)/Moments(2,1)^1.5;
Kurtosis = Moments(4,1)/Moments(2,1)^2-3;

Moments_summary = [Mean;Variance;Skewness;Kurtosis];
end