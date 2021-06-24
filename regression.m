max_shift = max_shift_time/step_size;

% computation
linear_models = struct;


% Cross validation
% inspiration from https://www.mathworks.com/matlabcentral/answers/323449-how-do-i-create-a-cross-validated-linear-regression-model-with-fitlm
% and from crossval function (third option)
% prediction function given training and testing instances
fcn = @(XTRAIN,YTRAIN,XTEST) predict(fitlm(XTRAIN,YTRAIN), XTEST);

for shift = -max_shift:1:max_shift
    disp(shift)
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
    T_shift.performance = log(2 - T_shift.performance);
    
    % Regression on full data
    linear_models.(strrep(['shift' num2str(shift)], '-', 'negative')).model = fitlm(T_shift);
    
    % Cross validation
    T_array = table2array(T_shift);
    X = T_array(:,1:8);
    Y = T_array(:,9);

    % perform cross-validation, and return average MSE across folds
    mse = crossval('mse', X, Y,'Predfun',fcn,'kfold',5);
    linear_models.(strrep(['shift' num2str(shift)], '-', 'negative')).rmse = sqrt(mse); 
end
