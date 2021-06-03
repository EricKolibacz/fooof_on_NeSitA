%% Parameters
parent_folder = '/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/';
window_sizes = [10000,20000,30000,60000];
step_sizes = [1000,2000,4000];

%% Reading data
persons=get_files(parent_folder, 'just_folders', true);
[indx,tf] = listdlg('PromptString',{'Select a person.',...
    'Only one can be selected at a time.',''},...
    'SelectionMode','single',...
    'ListSize',[350,300],...
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
        'ListString',{data_files.name});
    if tf == 0
       error('A person needs to be selected') 
    end
    data_file = data_files(indx);
else
   data_file = data_files; 
end

if ~ exist("eeg_blocks", 'var')
    extracted_data = load([parent_folder person '/' data_file]);
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
        data_folder = data_folders(contains(data_folders,strjoin(arrayfun(@num2str, channels, 'Uniform', false),'_')));
        if ~isempty(data_folder)
            data_subfolders=get_files([parent_folder person '/' data_folder{1}], 'just_folder', true);
            data_subfolder = data_subfolders(contains(data_subfolders,['w' num2str(window_size) '_s' num2str(step_size)]));
            if ~isempty(data_subfolder)
                block_results = load([parent_folder person '/' data_folder{1} '/' data_subfolder{1} '/block_results.mat']);
            end
        end
        if ~exist('block_results', 'var')
            block_names = fieldnames(eeg_blocks);

            aperiodic_offsets = zeros(length(block_names),1);
            for block_name_i = 1:length(block_names)
                block_data = eeg_blocks.(block_names{block_name_i});

                %moving window
                block_result = analysis_with_fooof_and_moving_window(block_data, channels, srate, window_size, step_size);
                block_results.(block_names{block_name_i}) = block_result;
            end
            filepath = [parent_folder person '/channels_' strjoin(arrayfun(@num2str, channels, 'Uniform', false),'_') '/' 'w' num2str(window_size) '_s' num2str(step_size)];
            mkdir(filepath)
            save([filepath '/block_results.mat'],'-struct', 'block_results')
            save([filepath '/window_size.mat'], 'window_size')
            save([filepath '/step_size.mat'], 'step_size')
        end
    end
end
