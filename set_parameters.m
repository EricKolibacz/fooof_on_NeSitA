%% Parameters
channels = [89, 88, 29, 80, 25, 99, 20, 85, 84, 27, 76, 23, 95, 18, 64, 65, 39, 60, 36, 69, 33, 112, 11, 115, 10, 113, 106, 15];
channel_name = 'PFRL_cluster'; % optional; recommended for high number of channels
parent_folder = '/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/';
window_size = 10000;
step_size = 1000;
max_shift_time = 60000; % longest time reasonable for shifting when computing cross correlation
relevant_blocks_idx = 8:23;
% regression parameters
alpha_peak_range = [10 13];
% relevant_blocks = ['dpp', 'dpf', 'dup', 'duf', 'ipp', 'ipf', 'iup', 'iuf']; % all blokcs
relevant_blocks = ['duf', 'ipf', 'iup', 'iuf']; % just low performance
%% Automatically generated
max_shift = max_shift_time/step_size;
if strcmp(channel_name,'')
    channel_name = [strjoin(arrayfun(@num2str, channels, 'Uniform', false),'_') '.mat'];
end
data_folder = ['extracted_data_channels_' channel_name];
data_subfolder = {['/' 'w' num2str(window_size) '_s' num2str(step_size)]};