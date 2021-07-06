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
function T = create_table_for_lm(all_windows_of_block, window_field_names, shift)

    % check if inputs are given and display the help otherwise
    % input check: if no arguments are entered, print the help and stop
    if nargin < 3
        help create_table_for_lm
        return
    end
    
    % input parsing settings
    p = inputParser;
    p.CaseSensitive = false;
    
    cell_requirements = @(x) (isa(x, 'cell')) && ~isempty(x);
    double_requirements = @(x) (isa(x, 'double')) && ~isempty(x);
        
    addRequired(p, 'all_windows_of_block', cell_requirements);
    addRequired(p, 'window_field_names', cell_requirements);
    addRequired(p, 'shift', double_requirements);
    
    % parse the input
    parse(p, all_windows_of_block, window_field_names, shift);
    
    all_windows_of_block = p.Results.all_windows_of_block;
    window_field_names = p.Results.window_field_names;
    shift = p.Results.shift;
    
    % computation
    if shift < 0
        windows_component = all_windows_of_block(1:end+shift);
        windows_performance = all_windows_of_block(1-shift:end);
    elseif shift > 0
        windows_component = all_windows_of_block(1+shift:end);
        windows_performance = all_windows_of_block(1:end-shift);  
    else
        windows_component = all_windows_of_block;
        windows_performance = all_windows_of_block;
    end
    
    offsets = nan(length(windows_component),length(window_field_names));
    exponents = nan(length(windows_component),length(window_field_names));
    for i_field_name = 1:length(window_field_names)
        field_name = (window_field_names{i_field_name});
        parameters = vertcat(vertcat(vertcat(windows_component{:}).(field_name)).aperiodic_params);
        offsets(:,i_field_name) = parameters(:,1);
        exponents(:,i_field_name) = parameters(:,2);
    end

    performance = get_performance(windows_performance);
    T_offsets = array2table(offsets);
    T_exponents = array2table(exponents);
    T_performance = table(performance);
    T = [T_offsets T_exponents T_performance];
end
