%% General parameter
windows_to_compare = [5000, 7500, 10000, 15000];
persons = {'s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9', 's10', 's11', 's12', 's13', 's14', 's15', 's16', 's17', 's18', 's19', 's20', 's21', 's22', 's23', 's24', 's25', 's26', 's27', 's28', 's29', 's30', 's31', 's32'};


stds = nan(length(windows_to_compare), length(persons),2*max_shift+1);
stds_log = nan(length(windows_to_compare), length(persons),2*max_shift+1);
means = nan(length(windows_to_compare), length(persons),2*max_shift+1);

time = -max_shift_time:step_size:max_shift_time;

rmses = nan(length(windows_to_compare), length(persons),2*max_shift+1);


for window_i=1:length(windows_to_compare)
    window_size = windows_to_compare(window_i)
    data_subfolders=get_files([parent_folder persons{1} '/' data_folder], 'just_folder', true);
    data_subfolder = data_subfolders{contains(data_subfolders,['w' num2str(window_size) '_s' num2str(step_size)])};
    for person_i=1:length(persons)
        person = persons{person_i};
        variable = load([parent_folder '/' person '/' data_folder '/' data_subfolder '/linear_models.mat']);
        variable2 = load([parent_folder '/' person '/' data_folder '/' data_subfolder '/T.mat']);
        linear_models_cell = struct2cell(variable.linear_models);
        T_cell = struct2cell(variable2.T);
        for linear_model_i = 1:length(linear_models_cell)
            rmses(window_i, person_i, linear_model_i) = linear_models_cell{linear_model_i}.rmse;
            stds(window_i, person_i, linear_model_i) = std(2-exp(T_cell{linear_model_i}.performance));
            stds_log(window_i, person_i, linear_model_i) = std(T_cell{linear_model_i}.performance);
            means(window_i, person_i, linear_model_i) = mean(2-exp(T_cell{linear_model_i}.performance));
        end
    end
end
%%
figure(20);
mean_stds_log = permute(nanmean(stds_log, 2), [1,3,2]);
mean_rmses = permute(nanmean(rmses, 2), [1,3,2]);
plot(time/1000, mean_rmses'./mean_stds_log')
title('RSME/std(log(2-performance)) for each shift')
xlabel('Shift in s')
ylabel('RSME/std(log(2-performance))')
xlim([-20 20])
ylim([0 1.5])
legend(arrayfun(@(x) [num2str(x/1000) 's'], windows_to_compare, 'UniformOutput', false), 'Location','best')


%% Computation
mean_stds_log = permute(nanmean(stds_log, 2), [1,3,2]);
mean_rmses = permute(nanmean(rmses, 2), [1,3,2]);
mean_stds = permute(nanmean(stds, 2), [1,3,2]);
mean_means = permute(nanmean(means, 2), [1,3,2]);

[mean_means(:,max_shift+1), mean_stds(:,max_shift+1), mean_stds_log(:,max_shift+1), mean_rmses(:,max_shift+1), mean_rmses(:,max_shift+1)./mean_stds_log(:,max_shift+1)]

