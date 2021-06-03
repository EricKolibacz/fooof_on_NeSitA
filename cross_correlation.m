% cross_correlation - ZZZ
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
function [ns, Rs, ps] = cross_correlation(x, y, varargin)

    % check if inputs are given and display the help otherwise
    % input check: if no arguments are entered, print the help and stop
    if nargin < 2
        help split_in_blocks
        return
    end
    
    % input parsing settings
    p = inputParser;
    p.CaseSensitive = false;
    
    double_requirements = @(x) (isa(x, 'double')) && ~isempty(x);
        
    addRequired(p, 'x', double_requirements);
    addRequired(p, 'y', double_requirements);
    addOptional(p, 'max_shift', -1 ,double_requirements);
    
    % parse the input
    parse(p, x, y, varargin{:});
    
    x = p.Results.x;
    y = p.Results.y;
    if length(x) ~= length(y)
       error('This function just supports cross correlation for vectors of same size') 
    end
    max_shift = p.Results.max_shift;
    if max_shift == -1
        max_shift = length(x) - 2;
    end
    
    % computation
    vector_length = max_shift*2+1;
    ns = zeros(vector_length,1);
    Rs = zeros(vector_length,1);
    ps = zeros(vector_length,1);
    
    % negative shift
    for shift = -max_shift:1:-1
        [R,p] = corr(x(1:end+shift),y(1-shift:end), 'rows', 'complete');
        ns((vector_length+1)/2+shift) = shift;
        Rs((vector_length+1)/2+shift) = R;
        ps((vector_length+1)/2+shift) = p;
    end

    [R,p] = corr(x,y, 'rows', 'complete');
    ns((vector_length+1)/2) = 0;
    Rs((vector_length+1)/2) = R;
    ps((vector_length+1)/2) = p;
    
    % positive shift
    for shift = 1:1:max_shift
        [R,p] = corr(x(1+shift:end),y(1:end-shift), 'rows', 'complete');
        ns((vector_length+1)/2+shift) = shift;
        Rs((vector_length+1)/2+shift) = R;
        ps((vector_length+1)/2+shift) = p;
    end    
end
