%% Parameters
channels = [89, 88, 29, 80, 25, 99, 20, 85, 84, 27, 76, 23, 95, 18, 64, 65, 39, 60, 36, 69, 33, 112, 11, 115, 10, 113, 106, 15];
parent_folder = '/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/';
channel_name = 'PFRL_cluster'; % optional; recommended for high number of channels
%% Which person
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

%% Extracting
filepath = ['/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/' person '/'];
[ALLEEG, ~, ~, ALLCOM] = eeglab;
EEG = pop_loadset('filename',[person '_cleaned_with_ICA.set'],'filepath', filepath);
[ALLEEG, EEG, ~] = eeg_store( ALLEEG, EEG, 0 );
EEG = pop_eegfiltnew(EEG, 'locutoff',1,'plotfreqz',1);
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
eeg_blocks = split_in_blocks(EEG, channels);
extracted_data.eeg_blocks = eeg_blocks;
extracted_data.srate = EEG.srate(1);
extracted_data.channels = channels;
if strcmp(channel_name,'')
    channel_name = [strjoin(arrayfun(@num2str, channels, 'Uniform', false),'_') '.mat'];
end
file_name = ['extracted_data_channels_' channel_name];
save([filepath file_name],'-struct', 'extracted_data')
disp('Done extracting ...')