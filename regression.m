max_shift = max_shift_time/step_size;
peak_alpha = 11;

% get clostest frequ to peak_alpha
freqs = block_results.(block_names{relevant_blocks_idx(1)}).window_1.(window_field_names{1}).freqs;
[~,i] = min(abs(peak_alpha - freqs));
freqs(i);


%% computation
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
        data = block_names{block_name_i};
        all_windows_of_block = struct2cell(block_results.(data));
        T_block = create_table_for_lm(all_windows_of_block, window_field_names, shift);
        T_shift = [T_shift;T_block];
    end
    for i_window_field_names = 1:length(window_field_names)
        field_name_splitted = split(window_field_names{i_window_field_names},'_');
        T_shift.Properties.VariableNames{['offsets' num2str(i_window_field_names)]} = ['c' field_name_splitted{2} '_offset'];
        T_shift.Properties.VariableNames{['exponents' num2str(i_window_field_names)]} = ['c' field_name_splitted{2} '_exponent'];
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
