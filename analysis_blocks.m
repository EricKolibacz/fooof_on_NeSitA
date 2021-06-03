%% Parameters
window_size = 80000;
step_size = 60000;

%% Reading data
files = dir('/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/');
dirFlags = [files.isdir];
subFolders = files(dirFlags);
persons=setdiff({subFolders.name},{'.','..'})'; 
[indx,tf] = listdlg('PromptString',{'Select a person.',...
    'Only one can be selected at a time.',''},...
    'SelectionMode','single',...
    'ListSize',[350,300],...
    'ListString',persons);
if tf == 0
   error('A person needs to be selected') 
end
person = persons{indx};
files = dir(['/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/'  person]);
dirFlags = [files.isdir];
just_files = files(~dirFlags);
data_files=just_files(contains({just_files.name}, 'extracted_data'))'; 
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
    data_file = data_files(indx).name;
else
   data_file = data_files.name; 
end

if ~ exist("eeg_blocks", 'var')
    extracted_data = load(['/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/' person '/' data_file]);
end

eeg_blocks = extracted_data.eeg_blocks;
srate = extracted_data.srate;
channels = extracted_data.channels;


%% Analysing data
tic
clear block_results;
files = dir(['/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/' person]);
dirFlags = [files.isdir];
subFolders = files(dirFlags);
data_folders=setdiff({subFolders.name},{'.','..'})';
data_folder = data_folders(contains(data_folders,strjoin(arrayfun(@num2str, channels, 'Uniform', false),'_')));
if ~isempty(data_folder)
    files = dir(['/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/' person '/' data_folder{1}]);
    dirFlags = [files.isdir];
    subFolders = files(dirFlags);
    data_subfolders=setdiff({subFolders.name},{'.','..'})';
    data_subfolder = data_subfolders(contains(data_subfolders,['w' num2str(window_size) '_s' num2str(step_size)]));
    if ~isempty(data_subfolder)
        block_results = load(['/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/' person '/' data_folder{1} '/' data_subfolder{1} '/block_results.mat']);
    end
end

if ~exist('block_results', 'var')
    block_names = fieldnames(eeg_blocks);

    aperiodic_offsets = zeros(length(block_names),1);
    for block_name_i = 1:length(block_names)
        block_data = eeg_blocks.(block_names{block_name_i});

        %moving window
        block_result = analysis_with_fooof_and_moving_window(block_data, channels, srate, window_size, step_size);
        block_names{block_name_i}
        block_results.(block_names{block_name_i}) = block_result;
    end
    filepath = ['/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/' person '/channels_' strjoin(arrayfun(@num2str, channels, 'Uniform', false),'_') '/' 'w' num2str(window_size) '_s' num2str(step_size)];
    mkdir(filepath)
    save([filepath '/block_results.mat'],'-struct', 'block_results')
end

toc

%% Plotting aperiodic parameters
figure(1);
for block_name_i = 9:9%length(block_names)
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
        time = time' * step_size/1000;
        
        subplot(2,2,i_channel);
        hold on
        yyaxis left
        plot(time, aperiodic_parameters(:,2), 'DisplayName', block_name);
        % ylim([0 5])
        yyaxis right
        plot(time, performance, 'DisplayName', block_name);
        ylabel('Offset')
        % ylim([0 1])
        title(['Aperiodic offset for channel ' num2str(channels(i_channel))])
        ylabel('Performance')
        xlabel('Time in s')
    end
end
