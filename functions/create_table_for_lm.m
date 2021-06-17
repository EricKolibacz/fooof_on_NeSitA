% create_table_for_lm - ZZZ
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
function T = create_table_for_lm(all_windows_of_block, channels, shift)

    % check if inputs are given and display the help otherwise
    % input check: if no arguments are entered, print the help and stop
    if nargin < 2
        help create_table_for_lm
        return
    end
    
    % input parsing settings
    p = inputParser;
    p.CaseSensitive = false;
    
    cell_requirements = @(x) (isa(x, 'cell')) && ~isempty(x);
    double_requirements = @(x) (isa(x, 'double')) && ~isempty(x);
        
    addRequired(p, 'all_windows_of_block', cell_requirements);
    addRequired(p, 'channels', double_requirements);
    addRequired(p, 'shift', double_requirements);
    
    % parse the input
    parse(p, all_windows_of_block, channels, shift);
    
    all_windows_of_block = p.Results.all_windows_of_block;
    channels = p.Results.channels;
    shift = p.Results.shift;
    
    % computation
    if shift < 0
        windows_component = all_windows_of_block(1-shift:end);
        windows_performance = all_windows_of_block(1:end+shift);
    elseif shift > 0
        windows_component = all_windows_of_block(1:end-shift);
        windows_performance = all_windows_of_block(1+shift:end);  
    else
        windows_component = all_windows_of_block;
        windows_performance = all_windows_of_block;
    end
    
    offsets = nan(length(windows_component),length(channels));
    exponents = nan(length(windows_component),length(channels));
    for i_channel = 1:length(channels)
        channel = ['channel_' num2str(channels(i_channel))];
        parameters = vertcat(vertcat(vertcat(windows_component{:}).(channel)).aperiodic_params);
        offsets(:,i_channel) = parameters(:,1);
        exponents(:,i_channel) = parameters(:,2);
    end

    performance = get_performance(windows_performance);
    T_offsets = array2table(offsets);
    T_exponents = array2table(exponents);
    T_performance = table(performance);
    T = [T_offsets T_exponents T_performance];
end
