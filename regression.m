max_shift = max_shift_time/step_size;
peak_alpha = 11;
%% pre computation
entire_block_fooof = struct();
for block_name_i = 1:length(block_names)
    block_data = eeg_blocks.(block_names{block_name_i});

    %moving window
    block_names{block_name_i}

    
    for cluster_i = 1:length(cluster)
        indices = [sum(amount_per_cluster(1:cluster_i-1))+1:sum(amount_per_cluster(1:cluster_i))];
        [psd, freqs] = pwelch(eeg_blocks.(block_names{block_name_i}).data(indices, :)', srate, [], [], srate);


        psd = geomean([psd(:,1) psd],2);

        % FOOOF settings
        settings = struct();  % Use defaults
        f_range = [3, 35]; %ToDo with parameters maybe?

        % Run FOOOF
        [~,fooof_results] = evalc('fooof(freqs, psd, f_range, settings, true);');

        entire_block_fooof.(block_names{block_name_i}).(['cluster_' cluster{cluster_i}]) = fooof_results;
    end
end

%% Testing
for block_name_i = 1:length(block_names)

    peaks = vertcat(entire_block_fooof.(block_names{block_name_i}).(['cluster_' cluster{cluster_i}]).peak_params);
    
    peak_found = 0;
    for peak_i = 1:size(peaks,1)
        if peaks(peak_i,1) < 15 && peaks(peak_i,1) > 9
           peak_found = 1;
        end
    end
    if ~peak_found
       disp("No alpha found")
       block_names{block_name_i}
       peaks
    end
end
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
