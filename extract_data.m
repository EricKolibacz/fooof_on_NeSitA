%% Extracting
filepath = [data_folder '/' person '/'];
[ALLEEG, ~, ~, ALLCOM] = eeglab;
EEG = pop_loadset('filename',[person '_cleaned_with_ICA.set'],'filepath', filepath);
[ALLEEG, EEG, ~] = eeg_store( ALLEEG, EEG, 0 );
EEG = pop_eegfiltnew(EEG, 'locutoff',1,'plotfreqz',1);
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
eeg_blocks = split_in_blocks(EEG, channels);
extracted_data.eeg_blocks = eeg_blocks;
extracted_data.srate = EEG.srate(1);
extracted_data.channels = channels;
save([parent_folder '/' person '/extracted_data_' data_folder],'-struct', 'extracted_data')
disp('Done extracting ...')