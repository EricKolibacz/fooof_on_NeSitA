% get_performance - ZZZ
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
function [performance, bias] = get_performance(all_windows_of_block)

    % check if inputs are given and display the help otherwise
    % input check: if no arguments are entered, print the help and stop
    if nargin < 1
        help get_performance
        return
    end
    
    % input parsing settings
    p = inputParser;
    p.CaseSensitive = false;
    
    cell_requirements= @(x) (isa(x, 'cell')) && ~isempty(x);
        
    addRequired(p, 'all_windows_of_block', cell_requirements);
    
    % parse the input
    parse(p, all_windows_of_block);
    
    all_windows_of_block = p.Results.all_windows_of_block;
    
    % computation
    hits = vertcat(vertcat(all_windows_of_block{:}).hits);
    CRs = vertcat(vertcat(all_windows_of_block{:}).CRs);
    misses = vertcat(vertcat(all_windows_of_block{:}).misses);
    FAs = vertcat(vertcat(all_windows_of_block{:}).FAs);
    performance = (hits + CRs) ./ (hits + CRs + misses + FAs);
    bias = (hits + FAs) ./ (hits + CRs + misses + FAs);
end
