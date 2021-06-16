%% Create Table
T = table();
for block_name_i = relevant_blocks_idx
    block_name = block_names{block_name_i};
    all_windows_of_block = struct2cell(block_results.(block_name));
    parameters = vertcat(vertcat(vertcat(all_windows_of_block{:}).channel_85).aperiodic_params);
    c85_offset = parameters(:,1);
    c85_exponent = parameters(:,2);
    parameters = vertcat(vertcat(vertcat(all_windows_of_block{:}).channel_87).aperiodic_params);
    c87_offset = parameters(:,1);
    c87_exponent = parameters(:,2);
    parameters = vertcat(vertcat(vertcat(all_windows_of_block{:}).channel_89).aperiodic_params);
    c89_offset = parameters(:,1);
    c89_exponent = parameters(:,2);
    parameters = vertcat(vertcat(vertcat(all_windows_of_block{:}).channel_90).aperiodic_params);
    c90_offset = parameters(:,1);
    c90_exponent = parameters(:,2);
    performance = get_performance(block_results.(block_name));

    T_block = table(c85_offset, c85_exponent, c87_offset, c87_exponent, c89_offset, c89_exponent, c90_offset, c90_exponent, performance);
    T = [T;T_block];
end

%% Linear Regression
fitlm(T)



