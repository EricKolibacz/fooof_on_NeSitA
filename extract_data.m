%% Parameters
channels = [85, 87, 89, 90];
parent_folder = '/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/';
file_name = 'all'; % optional; recommended for high number of channels
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
if strcmp(file_name,'')
    file_name = ['extracted_data_channels_' strjoin(arrayfun(@num2str, channels, 'Uniform', false),'_') '.mat'];
end
save([filepath file_name],'-struct', 'extracted_data')
disp('Done extracting ...')