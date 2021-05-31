% to_index - ZZZ
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
function time = to_time(index, srate)

    % check if inputs are given and display the help otherwise
    % input check: if no arguments are entered, print the help and stop
    if nargin < 2
        help split_in_blocks
        return
    end
    
    % input parsing settings
    p = inputParser;
    p.CaseSensitive = false;
    
    requirements = @(x) (isa(x, 'double')) && ~isempty(x);
        
    addRequired(p, 'index', requirements);
    addRequired(p, 'srate',requirements);
    
    % parse the input
    parse(p, index, srate);
    
    index = p.Results.index;
    srate = p.Results.srate;
    
    % computation
    time = index*1000/srate;
end
