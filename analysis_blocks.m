%% Parameters
parent_folder = '/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/';
window_size = 10000;
step_size = 1000;
max_shift_time = 44000; % longest time reasonable for shifting when computing cross correlation
relevant_blocks_idx = 8:23;

%% Reading data
persons=get_files(parent_folder, 'just_folders', true);
[indx,tf] = listdlg('PromptString',{'Select a person.',...
    'Only one can be selected at a time.',''},...
    'SelectionMode','single',...
    'ListSize',[350,300],...
    'InitialValue', 30,...
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


%% Analysing data
tic
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

toc
%% Covariance analysis
mode = 'performance';
Rs_ap_offset = nan(length(relevant_blocks_idx), length(window_field_names), max_shift_time/step_size*2+1);
ps_ap_offset = nan(length(relevant_blocks_idx), length(window_field_names), max_shift_time/step_size*2+1);
Rs_ap_exponent = nan(length(relevant_blocks_idx), length(window_field_names), max_shift_time/step_size*2+1);
ps_ap_exponent = nan(length(relevant_blocks_idx), length(window_field_names), max_shift_time/step_size*2+1);
for block_name_i = relevant_blocks_idx
    block_name = block_names{block_name_i};
    if isempty(block_results.(block_name))
       continue 
    end
    all_windows_of_block = struct2cell(block_results.(block_name));
    for i_field_name = 1:length(window_field_names)
        field_name = (window_field_names{i_field_name});
        aperiodic_parameters = vertcat(vertcat(vertcat(all_windows_of_block{:}).(field_name)).aperiodic_params);
        [performance, bias] = get_performance(all_windows_of_block);
        
        if strcmp(mode, 'performance')
            comparison_parameter = performance;
        elseif strcmp(mode,'bias')
            comparison_parameter = bias;
        else
           error(['Mode' mode ' is not known']) 
        end
%         if std(comparison_parameter) < 0.05
%             continue
%         end
    
        error = vertcat(vertcat(vertcat(all_windows_of_block{:}).(field_name)).error);
        r_squared = vertcat(vertcat(vertcat(all_windows_of_block{:}).(field_name)).r_squared);
        % median(r_squared)+1.4826 * 3 * mad(r_squared)
        % median(r_squared)-4.4478*mad(r_squared)
        aperiodic_parameters(r_squared > median(r_squared)+1.4826 * 3 * mad(r_squared),:) = nan;
        aperiodic_parameters(r_squared < median(r_squared)-1.4826 * 3 * mad(r_squared),:) = nan;
    
        [~, Rs, ps] = cross_correlation(comparison_parameter, aperiodic_parameters(:,1), max_shift_time/step_size);
        Rs_ap_offset(block_name_i-relevant_blocks_idx(1)+1,i_field_name,:) = Rs;
        ps_ap_offset(block_name_i-relevant_blocks_idx(1)+1,i_field_name,:) = ps;
        
        [ns, Rs, ps] = cross_correlation(comparison_parameter, aperiodic_parameters(:,2), max_shift_time/step_size);
        Rs_ap_exponent(block_name_i-relevant_blocks_idx(1)+1,i_field_name,:) = Rs;
        ps_ap_exponent(block_name_i-relevant_blocks_idx(1)+1,i_field_name,:) = ps;
    end
end