% predict_with_LDA - ZZZ
%
% Input:
%   YYY             - YYY
% 
% Output:
%   XXX             - XXX.
%   window_size     - Window size is measured in milliseconds.
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
function results = analysis_with_fooof_and_moving_window(data, channels, srate, window_size, varargin)

    % check if inputs are given and display the help otherwise
    % input check: if no arguments are entered, print the help and stop
    if nargin < 3
        help extract_numeric_and_cell_data_from_table
        return
    end
    
    % input parsing settings
    p = inputParser;
    p.CaseSensitive = false;
    
    dataRequirements = @(x) (isa(x, 'struct')) && ~isempty(x);
    requirements = @(x) (isa(x, 'double')) && ~isempty(x);
        
    addRequired(p, 'data', dataRequirements);
    addRequired(p, 'channels', requirements);
    addRequired(p, 'srate', requirements);
    addRequired(p, 'window_size', requirements);
    addOptional(p, 'window_steps', 100 ,requirements);
    
    % parse the input
    parse(p, data, channels, srate, window_size, varargin{:});
    
    data = p.Results.data;
    eeg_data = data.data;
    events = data.events;
    channels = p.Results.channels;
    srate = p.Results.srate;
    
    start_time_index = events.latency;
    window_size = p.Results.window_size; % window size in ms
    window_index_size = to_index(window_size, srate); % window size in # data points
    window_steps = p.Results.window_steps; % step size in ms
    window_index_steps = to_index(window_steps, srate); % step size in # data points
    
    results = struct;
    
    if size(eeg_data,2) < window_index_size
        warning(['Window size (' num2str(window_size) 'ms) larger than the data (' num2str(length(eeg_data)/srate*1000) 'ms). Skipping block...'])
    else
        for data_i = 1:window_index_steps:size(eeg_data,2)
            end_window = data_i+window_index_size-1;
            if end_window > size(eeg_data,2)
               continue 
            end
            window = ['window_' num2str(floor(data_i/window_index_steps)+1)];
            
            % analysing eeg date via fooof
            for channel_i = 1:length(channels)
                [psd, freqs] = pwelch(eeg_data(channel_i, data_i:end_window), srate, [], [], srate);

                % Transpose, to make inputs row vectors
                freqs = freqs';
                psd = psd';

                % FOOOF settings
                settings = struct();  % Use defaults
                f_range = [3, 35]; %ToDo with parameters maybe?

                % Run FOOOF
                [~,fooof_results] = evalc('fooof(freqs, psd, f_range, settings, true);');

                channel = ['channel_' num2str(channels(channel_i))];
                
                results.(window).(channel) = fooof_results;
            end
            
            % analysing performance
            window_start_time = start_time_index + data_i;
            window_end_time = start_time_index + end_window;
            
            window_events = events(1,cell2mat({events.latency}') > window_start_time & cell2mat({events.latency}') < window_end_time);
            window_destruction_events = window_events(contains({window_events.type}','sphereDestruction'));
            window_hit_events = window_destruction_events(contains({window_destruction_events.performance}','hit'));
            window_CR_events = window_destruction_events(contains({window_destruction_events.performance}','correctRejection'));
            window_miss_events = window_destruction_events(contains({window_destruction_events.performance}','miss'));
            window_FA_events = window_destruction_events(contains({window_destruction_events.performance}','falseAlarm'));
            
            if length(window_destruction_events)~=length(window_hit_events)+length(window_CR_events)+length(window_miss_events)+length(window_FA_events)
                warning('Some logical error ocurred while calculating the performance...')
            end
            
            results.(window).hits = length(window_hit_events);
            results.(window).CRs = length(window_CR_events);
            results.(window).misses = length(window_miss_events);
            results.(window).FAs = length(window_FA_events);
        end
    end
end
