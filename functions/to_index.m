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
function index = to_index(time, srate)

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
        
    addRequired(p, 'time', requirements);
    addRequired(p, 'srate',requirements);
    
    % parse the input
    parse(p, time, srate);
    
    time = p.Results.time;
    srate = p.Results.srate;
    
    % computation
    index = floor(srate*time/1000);
end
