%% Every block Aperiodic exponent
figure(1);
clf;
for block_i = relevant_blocks_idx
    subplot(4,4,block_i-relevant_blocks_idx(1)+1)
    plot(ns,permute(Rs_ap_exponent(block_i-relevant_blocks_idx(1)+1, :, :), [2,3,1]))
    ylim([-1 1])
    title(strrep(block_names(block_i), '_', '-'))
    xlabel('Shift')
    ylabel('mean of R over Blocks')
    legend(window_field_names)
end
sgtitle('Xcorr between aperiodic exponent and performance') 

%% Every block R_squared
figure(2);
clf;
for block_i = relevant_blocks_idx
    subplot(4,4,block_i-relevant_blocks_idx(1)+1)
    
    block_name = block_names{block_i};
    all_windows_of_block = struct2cell(block_results.(block_name));
    r_squared = vertcat(vertcat(vertcat(all_windows_of_block{:}).(channel)).r_squared);
    
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
plot(ns,permute(nanmean(Rs_ap_exponent,1),[3,2,1]))
title('Aperiodic exponent')
xlabel('Shift')
ylabel('mean of R over Blocks')
ylim([-1 1])
legend(window_field_names)
subplot(2,2,3)
plot(ns,permute(nanmean(ps_ap_exponent,1),[3,2,1]))
title('Aperiodic exponent')
xlabel('Shift')
ylabel('mean of p over Blocks')
legend(window_field_names)
subplot(2,2,2)
plot(ns,permute(nanmean(Rs_ap_offset,1),[3,2,1]))
title('Aperiodic offset')
xlabel('Shift')
ylabel('mean of R over Blocks')
ylim([-1 1])
legend(window_field_names)
subplot(2,2,4)
plot(ns,permute(nanmean(ps_ap_offset,1),[3,2,1]))
title('Aperiodic offset')
xlabel('Shift')
ylabel('mean of p over Blocks')
legend(window_field_names)

sgtitle('Xcorr between aperiodic offset and performance average over blocks') 
%% Plotting aperiodic parameters
figure(5);
clf;
plot_block(block_results.dist_pred_permanent_2, window_field_names, step_size, window_size, 'exponent', 'performance')


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

title(['VP: ' person])

hold on
yyaxis left
plot(time / 1000, r_squared_adjusted)
xlabel('Shift in sec')
ylabel('R squared adjusted')
yyaxis right
plot(time / 1000, rmses)
ylabel('Root mean squared errors by cross-validation')
%% Plotting window information
fooof_plot(block_results.indist_pred_permanent_2.window_107.channel_89)