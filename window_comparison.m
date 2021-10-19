%% General parameter
set_parameters
persons = {'s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9', 's10', 's11', 's12', 's13', 's14', 's15', 's16', 's17', 's18', 's19', 's20', 's21', 's22', 's23', 's24', 's25', 's26', 's27', 's28', 's29', 's30', 's31', 's32'};

windows_to_compare = [5000, 7500, 10000, 15000];

stds = nan(length(windows_to_compare), length(persons),2*max_shift+1);
stds_log = nan(length(windows_to_compare), length(persons),2*max_shift+1);
means_w = nan(length(windows_to_compare), length(persons),2*max_shift+1);

time = -max_shift_time:step_size:max_shift_time;

rmses_w = nan(length(windows_to_compare), length(persons),2*max_shift+1);


for window_i=1:length(windows_to_compare)
    window_size = windows_to_compare(window_i)
    for person_i=1:length(persons)
        person = persons{person_i};
        variable = load([parent_folder '/' person '/' data_folder '/' ['w' num2str(window_size) '_s' num2str(step_size)] '/linear_models.mat']);
        variable2 = load([parent_folder '/' person '/' data_folder '/' ['w' num2str(window_size) '_s' num2str(step_size)] '/T.mat']);
        linear_models_cell = struct2cell(variable.linear_models);
        T_cell = struct2cell(variable2.T);
        for linear_model_i = 1:length(linear_models_cell)
            rmses_w(window_i, person_i, linear_model_i) = linear_models_cell{linear_model_i}.rmse;
            stds(window_i, person_i, linear_model_i) = std(2-exp(T_cell{linear_model_i}.performance));
            stds_log(window_i, person_i, linear_model_i) = std(T_cell{linear_model_i}.performance);
            means_w(window_i, person_i, linear_model_i) = mean(2-exp(T_cell{linear_model_i}.performance));
        end
    end
end