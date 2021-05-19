egg_blocks = split_in_blocks(EEG);
save([EEG.filepath 'blocks.mat'],'-struct', 'egg_blocks')