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
function files = plot_block(block, channels, step_size)

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
        
    addRequired(p, 'block', struct_requirements);
    addRequired(p, 'channels', double_requirements);
    addRequired(p, 'step_size', double_requirements);
    
    % parse the input
    parse(p, block, channels, step_size);
    
    block = p.Results.block;
    channels = p.Results.channels;
    step_size = p.Results.step_size;
    
    % plotting
    for i_channel = 1:length(channels)
        channel = ['channel_' num2str(channels(i_channel))];
        all_windows_of_block = struct2cell(block);
        aperiodic_parameters = vertcat(vertcat(vertcat(all_windows_of_block{:}).(channel)).aperiodic_params);
        performance = (vertcat(vertcat(all_windows_of_block{:}).hits) + vertcat(vertcat(all_windows_of_block{:}).CRs)) ./ ...
        (vertcat(vertcat(all_windows_of_block{:}).hits) + vertcat(vertcat(all_windows_of_block{:}).CRs) + vertcat(vertcat(all_windows_of_block{:}).misses) + vertcat(vertcat(all_windows_of_block{:}).FAs));
        time = 0:size(all_windows_of_block,1)-1;
        time = time' * step_size/1000;

        err = vertcat(vertcat(vertcat(all_windows_of_block{:}).(channel)).error);
        r_squared = vertcat(vertcat(vertcat(all_windows_of_block{:}).(channel)).r_squared);

        subplot(2,2,i_channel);
        hold on
        yyaxis left
        plot(time, aperiodic_parameters(:,2))%fillmissing(aperiodic_parameters(:,2),'linear'), 'DisplayName', block_name);
        ylabel('Aperiodic Exponent')
        % ylim([1.65 1.7])
        yyaxis right
        plot(time, performance);
        ylabel('Performance')
        % ylim([0 1])
        title(['Aperiodic offset for channel ' num2str(channels(i_channel))])
        xlabel('Time in s')
    end
end
