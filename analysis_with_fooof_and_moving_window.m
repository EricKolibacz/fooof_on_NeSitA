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
    
    dataRequirements = @(x) (isa(x, 'single')) && ~isempty(x);
    requirements = @(x) (isa(x, 'double')) && ~isempty(x);
        
    addRequired(p, 'data', dataRequirements);
    addRequired(p, 'channels', requirements);
    addRequired(p, 'srate', requirements);
    addRequired(p, 'window_size', requirements);
    addOptional(p, 'window_steps', 100 ,requirements);
    
    % parse the input
    parse(p, data, channels, srate, window_size, varargin{:});
    
    data = p.Results.data;
    channels = p.Results.channels;
    srate = p.Results.srate;
    window_size = p.Results.window_size; % window size in ms
    window_index_size = srate*window_size/1000; % window size in # data points
    window_steps = p.Results.window_steps; % step size in ms
    window_index_steps = floor(srate*window_steps/1000); % step size in # data points
    
    results = struct;
    
    if size(data,2) < window_index_size
        warning(['Window size (' num2str(window_size) 'ms) larger than the data (' num2str(length(data)/srate*1000) 'ms). Skipping block...'])
    else
        for data_i = 1:window_index_steps:size(data,2)
            if data_i+window_index_size > size(data,2)
               continue 
            end
            window = ['window_' num2str(floor(data_i/window_index_steps)+1)];
            for channel_i = 1:length(channels)
                [psd, freqs] = pwelch(data(channel_i, data_i:data_i+window_index_size), srate, [], [], srate);

                % Transpose, to make inputs row vectors
                freqs = freqs';
                psd = psd';

                % FOOOF settings
                settings = struct();  % Use defaults
                f_range = [1, 55]; %ToDo with parameters maybe?

                % Run FOOOF
                fooof_results = fooof(freqs, psd, f_range, settings);

                channel = ['channel_' num2str(channels(channel_i))];
                results.(window).(channel) = fooof_results;
            end
        end
    end
end
