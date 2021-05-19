person = 's6';
if ~ exist("eeg_blocks", 'var')
    eeg_blocks = load(['/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/' person '/blocks.mat']);
end
load(['/home/eric/Documents/Uni/Master Human Factors/Thesis/Code/data/' person '/srate.mat']);
block_names = fieldnames(eeg_blocks);

aperiodic_offsets = zeros(length(block_names),1);
for block_name_i = 1:length(block_names)
    block_name_i
    [psd, freqs] = pwelch(eeg_blocks.(block_names{block_name_i}).data, srate, [], [], srate);

    % Transpose, to make inputs row vectors
    freqs = freqs';
    psd = psd';

    % FOOOF settings
    settings = struct();  % Use defaults
    f_range = [1, 55];

    % Run FOOOF
    fooof_results = fooof(freqs, psd, f_range, settings);

    aperiodic_offsets(block_name_i) = fooof_results.aperiodic_params(1);
end