max_shift = max_shift_time/step_size;

% computation
linear_models = struct;

for shift = -max_shift:1:max_shift
    T_shift = table();
    for block_name_i = relevant_blocks_idx
        block_name = block_names{block_name_i};
        all_windows_of_block = struct2cell(block_results.(block_name));
        T_block = create_table_for_lm(all_windows_of_block, channels, shift);
        T_shift = [T_shift;T_block];
    end
    for i_channel = 1:length(channels)
        T_shift.Properties.VariableNames{['offsets' num2str(i_channel)]} = ['c' num2str(channels(i_channel)) '_offset'];
        T_shift.Properties.VariableNames{['exponents' num2str(i_channel)]} = ['c' num2str(channels(i_channel)) '_exponent'];
    end
    linear_models.(strrep(['shift' num2str(shift)], '-', 'negative')) = fitlm(T_shift);
end

%% Comparison


linear_models_cell = struct2cell(linear_models);
r_squared_adjusted = nan(length(linear_models_cell),1);
for linear_model_i = 1:length(linear_models_cell)
    r_squared_adjusted(linear_model_i,1) = linear_models_cell{linear_model_i}.Rsquared.Adjusted;
end
time = -max_shift_time:step_size:max_shift_time;
plot(time / 1000, r_squared_adjusted)
xlabel('Shift in s')
ylabel('R squared adjusted')
