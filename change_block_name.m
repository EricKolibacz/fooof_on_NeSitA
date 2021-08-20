function [block_name] = change_block_name(block_name)

    level_names = {'dist', 'indist', 'pred', 'unpred', 'permanent', 'fixation'};
    level_short_names = {'D+', 'D-', 'P+', 'P-', 'V+', 'V-'};
    
    for i=length(level_names):-1:1
        i
        block_name = replace(block_name, level_names{i}, level_short_names{i});
    end
    block_name = replace(block_name, '_', '/');
end

