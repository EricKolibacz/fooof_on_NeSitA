channels = [85, 87, 89, 90];

eeg_blocks = split_in_blocks(EEG, channels);
extracted_data.eeg_blocks = eeg_blocks;
extracted_data.srate = EEG.srate(1);
extracted_data.channels = channels;
save([EEG.filepath 'extracted_data.mat'],'-struct', 'extracted_data')