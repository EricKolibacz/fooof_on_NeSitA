%% Every block Aperiodic component
figure(1);
clf;
for block_i = relevant_blocks_idx
    subplot(4,4,block_i-relevant_blocks_idx(1)+1)
    plot(ns,permute(Rs_ap_component(block_i-relevant_blocks_idx(1)+1, :, :), [2,3,1]))
    ylim([-1 1])
    title(strrep(block_names(block_i), '_', '-'))
    xlabel('Shift')
    ylabel('mean of R over Blocks')
    legend(split(num2str(channels)))
end
sgtitle('Xcorr between aperiodic component and performance') 
%% Every block Aperiodic offset
figure(2);
clf;
for block_i = relevant_blocks_idx
    subplot(4,4,block_i-relevant_blocks_idx(1)+1)
    plot(ns,permute(Rs_ap_offset(block_i-relevant_blocks_idx(1)+1, :, :), [2,3,1]))
    ylim([-1 1])
    title(strrep(block_names(block_i), '_', '-'))
    xlabel('Shift')
    ylabel('mean of R over Blocks')
    legend(split(num2str(channels)))
end
sgtitle('Xcorr between aperiodic offset and performance') 
%% Average Rs and ps
figure(3);
subplot(2,2,1)
plot(ns,permute(nanmean(Rs_ap_component,1),[3,2,1]))
title('Aperiodic component')
xlabel('Shift')
ylabel('mean of R over Blocks')
legend(split(num2str(channels)))
subplot(2,2,3)
plot(ns,permute(nanmean(ps_ap_component,1),[3,2,1]))
title('Aperiodic component')
xlabel('Shift')
ylabel('mean of p over Blocks')
legend(split(num2str(channels)))
subplot(2,2,2)
plot(ns,permute(nanmean(Rs_ap_offset,1),[3,2,1]))
title('Aperiodic offset')
xlabel('Shift')
ylabel('mean of R over Blocks')
legend(split(num2str(channels)))
subplot(2,2,4)
plot(ns,permute(nanmean(ps_ap_offset,1),[3,2,1]))
title('Aperiodic offset')
xlabel('Shift')
ylabel('mean of p over Blocks')
legend(split(num2str(channels)))

sgtitle('Xcorr between aperiodic offset and performance average over blocks') 
%% Plotting aperiodic parameters
figure(4);
clf;
plot_block(block_results.dist_pred_permanent_2, channels, step_size, window_size, 'component')

%% Plotting window information
fooof_plot(block_results.indist_pred_permanent_2.window_107.channel_89)