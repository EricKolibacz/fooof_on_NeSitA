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
function files = get_files(path, varargin)

    % check if inputs are given and display the help otherwise
    % input check: if no arguments are entered, print the help and stop
    if nargin < 0
        help split_in_blocks
        return
    end
    
    % input parsing settings
    p = inputParser;
    p.CaseSensitive = false;
    
    string_requirements = @(x) (isa(x, 'char')) && ~isempty(x);
    bool_requirements = @(x) (isa(x, 'logical')) && ~isempty(x);
        
    addRequired(p, 'path', string_requirements);
    addOptional(p, 'just_folders', false ,bool_requirements);
    addOptional(p, 'just_files', false ,bool_requirements);
    
    % parse the input
    parse(p, path, varargin{:});
    
    path = p.Results.path;
    just_folders = p.Results.just_folders;
    just_files = p.Results.just_files;
    
    % computation
    files = dir(path);
    dirFlags = [files.isdir];
    if just_folders
        files = files(dirFlags);
    end
    if just_files
        files = files(~dirFlags);
    end
    files=setdiff({files.name},{'.','..'})'; 
end
