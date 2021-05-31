eeg_blocks = split_in_blocks(EEG, [85, 87, 89, 90]);
save([EEG.filepath 'blocks.mat'],'-struct', 'eeg_blocks')

srate = EEG.srate(1);
save([EEG.filepath 'srate.mat'], 'srate')