% get_files - ZZZ
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
function plot_block(block, channels, step_size, window_size, varargin)

    % check if inputs are given and display the help otherwise
    % input check: if no arguments are entered, print the help and stop
    if nargin < 0
        help split_in_blocks
        return
    end
    
    % input parsing settings
    p = inputParser;
    p.CaseSensitive = false;
    
    struct_requirements = @(x) (isa(x, 'struct')) && ~isempty(x);
    double_requirements = @(x) (isa(x, 'double')) && ~isempty(x);
    string_requirements = @(x) (isa(x, 'char')) && ~isempty(x);
        
    addRequired(p, 'block', struct_requirements);
    addRequired(p, 'channels', double_requirements);
    addRequired(p, 'step_size', double_requirements);
    addRequired(p, 'window_size', double_requirements);
    addOptional(p, 'parameter', 'component', string_requirements);
    addOptional(p, 'performance_measure', 'performance', string_requirements);
    
    % parse the input
    parse(p, block, channels, step_size, window_size, varargin{:});
    
    block = p.Results.block;
    channels = p.Results.channels;
    step_size = p.Results.step_size;
    window_size = p.Results.window_size;
    parameter = p.Results.parameter;
    performance_measure = p.Results.performance_measure;
    if strcmp(p.Results.parameter,'component')
        parameter_idx = 1;
    elseif strcmp(p.Results.parameter,'offset')
        parameter_idx = 2;
    else
       error(['The parameter ' p.Results.parameter ' if not know']) 
    end
    
    % plotting
    for i_channel = 1:length(channels)
        channel = ['channel_' num2str(channels(i_channel))];
        all_windows_of_block = struct2cell(block);
        aperiodic_parameters = vertcat(vertcat(vertcat(all_windows_of_block{:}).(channel)).aperiodic_params);
        [performance, bias] = get_performance(block);
        
        if strcmp(performance_measure, 'performance')
            comparison_parameter = performance;
        elseif strcmp(performance_measure,'bias')
            comparison_parameter = bias;
        else
           error(['Mode' mode ' is not known']) 
        end
        time = 0:size(all_windows_of_block,1)-1;
        time = time' * step_size/1000 + window_size/1000/2;

        % Error calculation if needed
        % err = vertcat(vertcat(vertcat(all_windows_of_block{:}).(channel)).error);
        % r_squared = vertcat(vertcat(vertcat(all_windows_of_block{:}).(channel)).r_squared);
        % Outlayer removal if needed
        % aperiodic_parameters(r_squared > median(r_squared)+1.4826 * 3 * mad(r_squared),:) = nan;
        % aperiodic_parameters(r_squared < median(r_squared)-1.4826 * 3 * mad(r_squared),:) = nan;

        subplot(2,2,i_channel);
        hold on
        yyaxis left
        plot(time, aperiodic_parameters(:,parameter_idx))
        % if nan values present
        %fillmissing(aperiodic_parameters(:,2),'linear'), 'DisplayName', block_name);
        ylabel(['Aperiodic ' parameter])
        yyaxis right
        plot(time, comparison_parameter);
        ylabel(mlreportgen.utils.capitalizeFirstChar(performance_measure))
        title(['Aperiodic ' parameter ' for channel ' num2str(channels(i_channel))])
        xlabel('Time in s')
        xlim([0 max(time)+window_size/1000/2])
    end
end
