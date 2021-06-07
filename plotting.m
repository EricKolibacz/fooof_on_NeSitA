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
%% Plotting aperiodic parameters
figure(4);
clf;
plot_block(block_results.indist_pred_fixation_2, channels, step_size)

%% 
figure(4);
clf;
for i = 1:4
    subplot(2,2,i)
    plot(EEG.data(channels(i),:))
end
%% 
for i = 1:4
    % Calculate a power spectrum with Welch's method
    [psd, freqs] = pwelch(eeg_blocks.dist_unpred_permanent_1.data(i,:), srate, [], [], srate);

    % Transpose, to make inputs row vectors
    freqs = freqs';
    psd = psd';

    % FOOOF settings
    settings = struct();  % Use defaults
    f_range = [1, 55];

    % Run FOOOF, also returning the model
    fooof_results = fooof(freqs, psd, f_range, settings, true);

    % Plot the resulting model
    fooof_plot(fooof_results)
end