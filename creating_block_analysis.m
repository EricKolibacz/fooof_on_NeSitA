%% Parameters
parent_folder = '/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/';
window_sizes = [15000,10000,7500];
step_sizes = [1000];

%% Reading data
persons=get_files(parent_folder, 'just_folders', true);
[indx,tf] = listdlg('PromptString',{'Select a person.',...
    'Only one can be selected at a time.',''},...
    'SelectionMode','single',...
    'ListSize',[350,300],...
    'InitialValue', 2,...
    'ListString',persons);
if tf == 0
   error('A person needs to be selected') 
end
person = persons{indx};
just_files = get_files([parent_folder person], 'just_files', true);
data_files=just_files(contains(just_files, 'extracted_data'))'; 
if length(data_files) > 1
    [indx,tf] = listdlg('PromptString',{'Select a file.',...
        'Only one can be selected at a time.',''},...
        'SelectionMode','single',...
        'ListSize',[350,300],...
        'InitialValue',1,...
        'ListString',data_files);
    if tf == 0
       error('A person needs to be selected') 
    end
    data_file = data_files(indx);
else
   data_file = data_files; 
end

is_clustered = contains(data_file,'cluster');
if is_clustered
    cluster = {'frontal', 'parietal', 'right', 'left'};
    amount_per_cluster = [7, 7, 7, 7];
    disp(['A clustered data set was used. The cluster are set to "' strjoin(cluster, ' ') '" with "' num2str(amount_per_cluster) '" as amount of nodes per cluster.'])
    disp('If you like to change this configuration change variables "cluster" and "amount_per_cluster".')
    window_field_names = strcat('cluster_', cluster);
else
	window_field_names = strcat('channel_', strsplit(num2str(channels),' '));  
end

data_file_splitted = split(data_file{1}, '.');
data_file_splitted = split(data_file_splitted{1},'_');
if ~ exist("eeg_blocks", 'var') || ~isequal(channels, str2double(data_file_splitted(find(strcmp(data_file_splitted,'channels'))+1:end))')
    disp('Reading data...')
    extracted_data = load([parent_folder person '/' data_file{1}]);
end

eeg_blocks = extracted_data.eeg_blocks;
srate = extracted_data.srate;
channels = extracted_data.channels;

%% Computation
for window_i = 1:length(window_sizes)
    window_size = window_sizes(window_i);
    for step_i = 1:length(step_sizes)
        window_size
        step_size = step_sizes(step_i)
        
        clear block_results;
        data_folders=get_files([parent_folder person], 'just_folders', true);
        data_folder = data_folders(contains(data_folders,strjoin(data_file_splitted(3:end),'_')));
        if ~isempty(data_folder)
            data_subfolders=get_files([parent_folder person '/' data_folder{1}], 'just_folder', true);
            data_subfolder = data_subfolders(contains(data_subfolders,['w' num2str(window_size) '_s' num2str(step_size)]));
            if ~isempty(data_subfolder)
                block_results = load([parent_folder person '/' data_folder{1} '/' data_subfolder{1} '/block_results.mat']);
            end
        end
        block_names = fieldnames(eeg_blocks);
        if ~exist('block_results', 'var')

            aperiodic_offsets = zeros(length(block_names),1);
            for block_name_i = 1:length(block_names)
                block_data = eeg_blocks.(block_names{block_name_i});

                %moving window
                block_names{block_name_i}
                if is_clustered
                    block_result = clustered_analysis_with_fooof_and_moving_window(block_data, cluster, amount_per_cluster, srate, window_size, step_size);
                else
                    block_result = analysis_with_fooof_and_moving_window(block_data, channels, srate, window_size, step_size);
                end
                block_results.(block_names{block_name_i}) = block_result;
            end
            filepath = [parent_folder person '/' strjoin(data_file_splitted(3:end),'_') '/' 'w' num2str(window_size) '_s' num2str(step_size)];
            mkdir(filepath)
            save([filepath '/block_results.mat'],'-struct', 'block_results')
            save([filepath '/window_size.mat'], 'window_size')
            save([filepath '/step_size.mat'], 'step_size')
        end
    end
end
