% predict_with_LDA - ZZZ
%
% Input:
%   YYY             - YYY
% 
% Output:
%   XXX             - XXX.
%                  
%
% Example usage: XXX
%
% Author: Eric Kolibacz, 2021
%
% See also: -
%           
% This function is free for any kind of distribution and usage!
% ----------------
function eeg_blocks = split_in_blocks(EEG)

    % check if inputs are given and display the help otherwise
    % input check: if no arguments are entered, print the help and stop
    if nargin < 0
        help split_in_blocks
        return
    end
    
    % final variables
    identifier_start = 'startSpawning';
    identifier_end = 'stopSpawnin';
    
    % computation
    allevents = {EEG.event.type}';
    idx_startevents = find(contains(allevents,identifier_start));
    idx_stopevents = find(contains(allevents,identifier_end));
    blocks = {EEG.event(idx_startevents).block}';
    
    if length(idx_startevents) ~= length(idx_stopevents)
        disp(['Number of Start Events:  ' length(idx_startevents)])
        disp(['Number of Stop Events:  ' length(idx_stopevents)])
        error('The amount of starts and ends of blocks are not equal. Something is wrong with the dataset.')
    end
    
    % check if each stop is before the next start
    for stop_i = 1:numel(idx_stopevents)-1
        if EEG.event(idx_stopevents(stop_i)).latency > EEG.event(idx_startevents(stop_i+1)).latency
           error(['Problem with Block: "' blocks{stop_i} '". ' 'Intervalls overlap. Something is wrong with the dataset.']) 
        end
    end
    
    for block_i = 1:numel(blocks)
        block_name = blocks{block_i};
        block_start = floor(EEG.event(idx_startevents(block_i)).latency);
        block_stop = floor(EEG.event(idx_stopevents(block_i)).latency);
        block.data = EEG.data(block_start:block_stop);
        block.events = EEG.event(idx_startevents(block_i):idx_stopevents(block_i));
        eeg_blocks.(strrep(block_name, '-', '_')) = block;
    end
end
