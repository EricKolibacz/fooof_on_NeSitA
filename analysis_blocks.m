%% Parameters
person = 's6';
window_size = 30000;
window_step = 4000;

%% Reading data
if ~ exist("eeg_blocks", 'var')
    extracted_data = load(['/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/' person '/blocks.mat']);
end

eeg_blocks = extracted_data.eeg_blocks;
srate = extracted_data.srate;
channels = extracted_data.channels;


%% Analysing data
block_names = fieldnames(eeg_blocks);

aperiodic_offsets = zeros(length(block_names),1);
for block_name_i = 13:14% (block_names)
    block_data = eeg_blocks.(block_names{block_name_i});
    
    %moving window
    block_result = analysis_with_fooof_and_moving_window(block_data, channels, srate, window_size, window_step);
    block_names{block_name_i}
    block_results.(block_names{block_name_i}) = block_result;
end



%% Plotting aperiodic parameters
figure(1);
for block_name_i = 13:14%length(block_names)
    block_name = block_names{block_name_i};
    if isempty(block_results.(block_name))
       continue 
    end
    for i_channel = 1:length(channels)
        channel = ['channel_' num2str(channels(i_channel))];
        all_windows_of_block = struct2cell(block_results.(block_name));
        aperiodic_parameters = vertcat(vertcat(vertcat(all_windows_of_block{:}).(channel)).aperiodic_params);
        performance = (vertcat(vertcat(all_windows_of_block{:}).hits) + vertcat(vertcat(all_windows_of_block{:}).CRs)) ./ ...
        (vertcat(vertcat(all_windows_of_block{:}).hits) + vertcat(vertcat(all_windows_of_block{:}).CRs) + vertcat(vertcat(all_windows_of_block{:}).misses) + vertcat(vertcat(all_windows_of_block{:}).FAs));
        time = 0:size(all_windows_of_block,1)-1;
        time = time' * window_steps/1000;
        
        subplot(2,2,i_channel);
        hold on
        yyaxis left
        plot(time, aperiodic_parameters(:,1), 'DisplayName', block_name);
        % ylim([0 5])
        yyaxis right
        plot(time, performance, 'DisplayName', block_name);
        ylim([0 1])
        title(['Aperiodic offset for channel ' num2str(channels(i_channel))])
        ylabel('Performance')
        xlabel('Time in s')
    end
end
