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
function [performance, bias] = get_performance(block_results)

    % check if inputs are given and display the help otherwise
    % input check: if no arguments are entered, print the help and stop
    if nargin < 0
        help get_performance
        return
    end
    
    % input parsing settings
    p = inputParser;
    p.CaseSensitive = false;
    
    struct_requirements= @(x) (isa(x, 'struct')) && ~isempty(x);
        
    addRequired(p, 'block_results', struct_requirements);
    
    % parse the input
    parse(p, block_results);
    
    block_results = p.Results.block_results;
    
    % computation
    all_windows_of_block = struct2cell(block_results);
    hits = vertcat(vertcat(all_windows_of_block{:}).hits);
    CRs = vertcat(vertcat(all_windows_of_block{:}).CRs);
    misses = vertcat(vertcat(all_windows_of_block{:}).misses);
    FAs = vertcat(vertcat(all_windows_of_block{:}).FAs);
    performance = (hits + CRs) ./ (hits + CRs + misses + FAs);
    bias = (hits + FAs) ./ (hits + CRs + misses + FAs);
end
