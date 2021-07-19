%% General parameter
time = -max_shift_time:step_size:max_shift_time;
time = time/1000;

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
figure(6);
clf;

linear_models_cell = struct2cell(linear_models);
r_squared_adjusted = nan(length(linear_models_cell),1);
rmses = nan(length(linear_models_cell),1);
for linear_model_i = 1:length(linear_models_cell)
    r_squared_adjusted(linear_model_i,1) = linear_models_cell{linear_model_i}.model.Rsquared.Adjusted; % alternative '.MSE'
    rmses(linear_model_i,1) = linear_models_cell{linear_model_i}.rmse;
end
time = -max_shift_time:step_size:max_shift_time;

title(['VP: ' person ', Window:' num2str(window_size/1000) 's, clustered:' num2str(is_clustered)])

hold on
yyaxis left
plot(time / 1000, r_squared_adjusted)
xlabel('Shift in sec')
ylabel('R squared adjusted (on full data)')
yyaxis right
plot(time / 1000, rmses)
ylabel('Root mean squared errors by cross-validation')
%% Plotting window information
figure(7);
clf;
[~, idx] = min(rmses);
shift_to_use = idx - max_shift - 1;
shift_reference = (strrep(['shift' num2str(shift_to_use)], '-', 'negative'));

title(['VP: ' person ', Window:' num2str(window_size/1000) 's, clustered:' num2str(is_clustered)])
hold on
plot(2-exp(predict(linear_models.(shift_reference).model,T.(shift_reference))), 'DisplayName', 'Predicted Performance')
plot(2-exp(T.(shift_reference).performance), 'DisplayName', 'Actual performance')
ylim([0 1.1])
xlim([0 size(T.(shift_reference),1)])
ylabel('Performance in %')
xlabel('Blocks')
legend show

%% Plotting window information
fooof_plot(block_results.dist_pred_fixation_1.window_1.cluster_parietal)
