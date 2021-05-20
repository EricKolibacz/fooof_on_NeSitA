%% Reading data
person = 's6';
if ~ exist("eeg_blocks", 'var')
    eeg_blocks = load(['/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/' person '/blocks.mat']);
end
load(['/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/' person '/srate.mat']);
block_names = fieldnames(eeg_blocks);

aperiodic_offsets = zeros(length(block_names),1);
for block_name_i = 10:13%length(block_names)
    block_data = eeg_blocks.(block_names{block_name_i}).data;
    
    %moving window
    block_result = analysis_with_fooof_and_moving_window(block_data, srate, 10000, 1000);
    block_names{block_name_i}
    block_results.(block_names{block_name_i}) = block_result;
end

%% Plotting aperiodic parameters
figure(1);
for block_name_i = 10:13%length(block_names)
    block_name = block_names{block_name_i};
    if isempty(block_results.(block_name))
       continue 
    end
    aperiodic_parameters = vertcat(block_results.(block_name).aperiodic_params)
    plot(aperiodic_parameters(:,1), 'DisplayName', block_name);
    
hold on
    title('Aperiodic offset')
end
legend;
