eeg_blocks = split_in_blocks(EEG);
save([EEG.filepath 'blocks.mat'],'-struct', 'eeg_blocks')

srate = EEG.srate(1);
save([EEG.filepath 'srate.mat'], 'srate')