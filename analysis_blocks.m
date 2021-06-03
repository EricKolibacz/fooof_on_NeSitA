%% Parameters
parent_folder = '/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/';
window_size = 60000;
step_size = 1000;
max_shift_time = 30000; % longest time reasonable for shifting when computing cross correlation

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
data_folder = data_folders(contains(data_folders,strjoin(arrayfun(@num2str, channels, 'Uniform', false),'_')));
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
        block_result = analysis_with_fooof_and_moving_window(block_data, channels, srate, window_size, step_size);
        block_names{block_name_i}
        block_results.(block_names{block_name_i}) = block_result;
    end
    filepath = [parent_folder person '/channels_' strjoin(arrayfun(@num2str, channels, 'Uniform', false),'_') '/' 'w' num2str(window_size) '_s' num2str(step_size)];
    mkdir(filepath)
    save([filepath '/block_results.mat'],'-struct', 'block_results')
    save([filepath '/window_size.mat'], 'window_size')
    save([filepath '/step_size.mat'], 'step_size')
end

toc
%% Covariance analysis
relevant_blocks_idx = 8:23;
all_Rs = zeros(length(relevant_blocks_idx), length(channels), max_shift_time/step_size*2+1);
all_ps = zeros(length(relevant_blocks_idx), length(channels), max_shift_time/step_size*2+1);
count = 0;
for block_name_i = relevant_blocks_idx
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
        
        error = vertcat(vertcat(vertcat(all_windows_of_block{:}).(channel)).error);
        r_squared = vertcat(vertcat(vertcat(all_windows_of_block{:}).(channel)).r_squared);
        
        aperiodic_parameters(r_squared > 0.7,:) = nan;
    
        [ns, Rs, ps] = cross_correlation(performance, aperiodic_parameters(:,2), max_shift_time/step_size);
        count = count + 1;
        all_Rs(block_name_i-relevant_blocks_idx(1)+1,i_channel,:) = Rs;
        all_ps(block_name_i-relevant_blocks_idx(1)+1,i_channel,:) = ps;
    end
end
figure(1);
clf;
subplot(2,1,1)
plot(ns,permute(nanmean(all_Rs,1),[3,2,1]))
xlabel('Shift')
ylabel('mean of R over Blocks')
legend(split(num2str(channels)))
subplot(2,1,2)
plot(ns,permute(nanmean(all_ps,1),[3,2,1]))
xlabel('Shift')
ylabel('mean of p over Blocks')
legend(split(num2str(channels)))
%% Plotting aperiodic parameters
figure(2);
clf;
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
        
        error = vertcat(vertcat(vertcat(all_windows_of_block{:}).(channel)).error);
        r_squared = vertcat(vertcat(vertcat(all_windows_of_block{:}).(channel)).r_squared);
        
        aperiodic_parameters(r_squared > 0.7,:) = nan;
        %interpolation for plotting
        %X = ~isnan(aperiodic_parameters);
        %Y = cumsum(X-diff([1,X])/2);
        %aperiodic_parameters = interp1(1:nnz(X),V(X),Y);
        subplot(2,2,i_channel);
        hold on
        yyaxis left
        plot(time, fillmissing(aperiodic_parameters(:,2),'linear'), 'DisplayName', block_name);
        ylabel('Aperiodic Exponent')
        % ylim([1.65 1.7])
        yyaxis right
        plot(time, performance, 'DisplayName', block_name);
        ylabel('Performance')
        % ylim([0 1])
        title(['Aperiodic offset for channel ' num2str(channels(i_channel))])
        xlabel('Time in s')
    end
end
