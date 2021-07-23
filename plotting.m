%% General parameter
persons = {'s1', 's2', 's3', 's4', 's6', 's7'};
data_subfolders=get_files([parent_folder persons{1} '/' data_folder], 'just_folder', true);
data_subfolder = data_subfolders{contains(data_subfolders,['w' num2str(window_size) '_s' num2str(step_size)])};


% use standard color map defined by Marius Klug
load('customized_colormap.mat')
colormap(myCmap)

time = -max_shift_time:step_size:max_shift_time;
r_squared_adjusted = nan(length(persons),2*max_shift+1);
performance = nan(length(persons),2*max_shift+1);
rmses = nan(length(persons),2*max_shift+1);
significance = zeros(3*4+1,2*max_shift+1);
estimate = zeros(3*4+1,2*max_shift+1);
for person_i=1:length(persons)
    person = persons{person_i};
    variable = load([parent_folder '/' person '/' data_folder '/' data_subfolder '/linear_models.mat']);
    variable2 = load([parent_folder '/' person '/' data_folder '/' data_subfolder '/T.mat']);
    linear_models_cell = struct2cell(variable.linear_models);
    T_cell = struct2cell(variable2.T);
    for linear_model_i = 1:length(linear_models_cell)
        r_squared_adjusted(person_i, linear_model_i) = linear_models_cell{linear_model_i}.model.Rsquared.Adjusted; % alternative '.MSE'
        rmses(person_i, linear_model_i) = linear_models_cell{linear_model_i}.rmse;
        performance(person_i, linear_model_i) = std(2-exp(T_cell{linear_model_i}.performance));
        significance(:, linear_model_i) = significance(:, linear_model_i) + double(linear_models_cell{linear_model_i}.model.Coefficients.pValue < 0.5);
        estimate(:, linear_model_i) = estimate(:, linear_model_i) + linear_models_cell{linear_model_i}.model.Coefficients.Estimate;
    end
end
estimate = estimate/length(persons);

%% Every block Aperiodic exponent
figure(1);
clf;
Last = @(L) L{end};
for block_i = relevant_blocks_idx
    subplot(4,4,block_i-relevant_blocks_idx(1)+1)
    plot(time,permute(Rs_ap_exponent(block_i-relevant_blocks_idx(1)+1, :, :), [2,3,1]))
    ylim([-1 1])
    title(strrep(block_names(block_i), '_', '-'))
    xlabel('Shift in s')
    ylabel('Mean of R')
    if block_i-relevant_blocks_idx(1)+1 == 1
        legend(cellfun(@(x) Last(split(x, '_')), window_field_names, 'UniformOutput', false), 'FontSize',7, 'Location','best')
    end
end
sgtitle('Xcorr between aperiodic exponent and performance') 

%% Every block R_squared
figure(2);
clf;
for block_i = relevant_blocks_idx
    subplot(4,4,block_i-relevant_blocks_idx(1)+1)
    
    block_name = block_names{block_i};
    all_windows_of_block = struct2cell(block_results.(block_name));
    r_squared = vertcat(vertcat(vertcat(all_windows_of_block{:}).(field_name)).r_squared);
    
    time = 0:size(all_windows_of_block,1)-1;
    time = time' * step_size/1000 + window_size/1000/2;
    
    plot(time,r_squared)
    title(strrep(block_names(block_i), '_', '-'))
    xlabel('Time in s')
    ylabel("Fooof's R Squared")
    xlim([0 max(time)+window_size/1000/2])
    legend(window_field_names)
end
sgtitle("Fooof's R squared per window per block") 
%% Every block Aperiodic offset
figure(3);
clf;
for block_i = relevant_blocks_idx
    subplot(4,4,block_i-relevant_blocks_idx(1)+1)
    plot(ns,permute(Rs_ap_offset(block_i-relevant_blocks_idx(1)+1, :, :), [2,3,1]))
    ylim([-1 1])
    title(strrep(block_names(block_i), '_', '-'))
    xlabel('Shift')
    ylabel('mean of R over Blocks')
    legend(window_field_names)
end
sgtitle('Xcorr between aperiodic offset and performance') 
%% Average Rs and ps
figure(4);
subplot(2,2,1)
plot(time,permute(nanmean(Rs_ap_exponent,1),[3,2,1]))
title('Aperiodic exponent')
xlabel('Shift in s')
ylabel('Mean of R over Blocks')
ylim([-1 1])
legend(cellfun(@(x) Last(split(x, '_')), window_field_names, 'UniformOutput', false), 'Location','best')
subplot(2,2,3)
plot(time,permute(nanmean(ps_ap_exponent,1),[3,2,1]))
title('Aperiodic exponent')
xlabel('Shift in s')
ylabel('Mean of p over Blocks')
subplot(2,2,2)
plot(time,permute(nanmean(Rs_ap_offset,1),[3,2,1]))
title('Aperiodic offset')
xlabel('Shift in s')
ylabel('Mean of R over Blocks')
ylim([-1 1])
subplot(2,2,4)
plot(time,permute(nanmean(ps_ap_offset,1),[3,2,1]))
title('Aperiodic offset')
xlabel('Shift in s')
ylabel('Mean of p over Blocks')

sgtitle('Xcorr between aperiodic offset and performance average over blocks') 
%% Plotting aperiodic parameters
figure(5);
clf;
plot_block(block_results.dist_unpred_fixation_2, window_field_names, step_size, window_size, 'exponent', 'performance')


%% Plotting regression results
%% One example plot
figure(6);
clf;
p_idx = 1;
title(['VP: ' persons{p_idx} ', Window:' num2str(window_size/1000) 's'])
hold on
yyaxis left
plot(time / 1000, r_squared_adjusted(p_idx,:))
xlabel('Shift in sec')
ylabel('R squared adjusted (on full data)')
yyaxis right
plot(time / 1000, rmses(p_idx,:))
ylabel('Root mean squared errors by cross-validation')
%% Plotting example performance prediction
figure(7);
clf;
[~, idx] = min(rmses(p_idx,:));
shift_to_use = idx - max_shift - 1;
shift_reference = (strrep(['shift' num2str(shift_to_use)], '-', 'negative'));
variable = load([parent_folder '/' persons{p_idx} '/' data_folder '/' data_subfolder '/linear_models.mat']);
variable2 = load([parent_folder '/' persons{p_idx} '/' data_folder '/' data_subfolder '/T.mat']);
title(['VP: ' person ', Window:' num2str(window_size/1000) 's'])
hold on
plot(2-exp(predict(variable.linear_models.(shift_reference).model,variable2.T.(shift_reference))), 'DisplayName', 'Predicted Performance')
plot(2-exp(variable2.T.(shift_reference).performance), 'DisplayName', 'Actual performance')
ylim([0 1.1])
xlim([0 size(variable2.T.(shift_reference),1)])
ylabel('Performance in %')
xlabel('Blocks')
legend show

%% Plotting multiple regression results
figure(8);
clf;

for person_i=1:length(persons)
    subplot(2,3, person_i)
    person = persons{person_i};
    title(['VP: ' person ', Window size:' num2str(window_size/1000) 's'])

    hold on
    yyaxis left
    plot(time / 1000, r_squared_adjusted(person_i,:))
    ylim([0 0.3])
    xlabel('Shift in sec')
    ylabel('R squared adjusted (on full data)')
    yyaxis right
    plot(time / 1000, rmses(person_i, :))
    ylim([0.06 0.14])
    ylabel('Root mean squared errors by cross-validation')
end
%% Plotting multiple regression results normalized
figure(8);
clf;
for person_i=1:length(persons)
    subplot(2,3, person_i)
    person = persons{person_i};
    title(['VP: ' person ', Window size:' num2str(window_size/1000) 's'])

    hold on
    yyaxis left
    plot(time / 1000, r_squared_adjusted(person_i,:))
    ylim([0 0.3])
    xlabel('Shift in sec')
    ylabel('R squared adjusted (on full data)')
    yyaxis right
    plot(time / 1000, rmses(person_i, :)./performance(person_i,:))
    ylim([0.6 0.9])
    ylabel('RSME normalized by cross-validation')
end

%% Plotting mean regression results
figure(9);
clf;

title(['Mean, Window size:' num2str(window_size/1000) 's'])

hold on
yyaxis left
plot(time / 1000, mean(r_squared_adjusted,1))
ylim([0.00 0.2])
xlabel('Shift in sec')
ylabel('R squared adjusted (on full data)')
yyaxis right
plot(time / 1000, mean(rmses,1))
ylim([0.06 0.14])
ylabel('Root mean squared errors by cross-validation')

%% Plotting 2D-significant parameter/shift plot 
figure(10);
clf;

title(['2D-shift/parameter Estimate plot, Window size:' num2str(window_size/1000) 's'])
h = heatmap(significance(2:end,:), 'Colormap', myCmap);
h.ColorLimits = [0 length(persons)];
ylabel('Parameters')
xlabel('Shift in s')
ax = gca;
ax.XData = arrayfun(@(x) num2str(x), time/1000, 'UniformOutput', false);
names = variable.linear_models.shift0.model.CoefficientNames;
ax.YData = strrep(names(2:end), '_', '-');
%% Plotting 2D-Estimate parameter/shift plot 
figure(11);
clf;

title(['2D-shift/parameter Estimate plot, Window size:' num2str(window_size/1000) 's'])
h = heatmap(estimate(2:end,:), 'Colormap', jet);
h.ColorLimits = [-max(max(abs(estimate(2:end,:)))) max(max(abs(estimate(2:end,:))))];
ylabel('Parameters')
xlabel('Shift in s')
ax = gca;
ax.XData = arrayfun(@(x) num2str(x), time/1000, 'UniformOutput', false);
names = variable.linear_models.shift0.model.CoefficientNames;
ax.YData = strrep(names(2:end), '_', '-');
%% Plotting window information
fooof_plot(block_results.dist_pred_fixation_1.window_1.cluster_parietal)
