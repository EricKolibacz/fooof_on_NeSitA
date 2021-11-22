%% General parameter
set_parameters
window_size = 10000;
persons = {'s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9', 's10', 's11', 's12', 's13', 's14', 's15', 's16', 's17', 's18', 's19', 's20', 's21', 's22', 's23', 's24', 's25', 's26', 's27', 's28', 's29', 's30', 's31', 's32'};
data_subfolders=get_files([parent_folder persons{1} '/' data_folder], 'just_folder', true);
data_subfolder = data_subfolders{contains(data_subfolders,['w' num2str(window_size) '_s' num2str(step_size)])};


% use standard color map defined by Marius Klug
%load('customized_colormap.mat')
%colormap(myCmap)

time = -max_shift_time:step_size:max_shift_time;
r_squared_adjusted = nan(length(persons),2*max_shift+1);
performance = nan(length(persons),2*max_shift+1);
rmses = nan(length(persons),2*max_shift+1);
significance = zeros(3*4+1,2*max_shift+1);
estimate = zeros(3*4+1,2*max_shift+1);
std_help = nan(length(persons),2*max_shift+1);
std_help2 = nan(length(persons),2*max_shift+1);
for person_i=1:length(persons)
    person = persons{person_i};
    variable = load([parent_folder '/' person '/' data_folder '/' data_subfolder '/linear_models.mat']);
    variable2 = load([parent_folder '/' person '/' data_folder '/' data_subfolder '/T.mat']);
    linear_models_cell = struct2cell(variable.linear_models);
    T_cell = struct2cell(variable2.T);
    for linear_model_i = 1:length(linear_models_cell)
        r_squared_adjusted(person_i, linear_model_i) = linear_models_cell{linear_model_i}.model.Rsquared.Adjusted; % alternative '.MSE'
        rmses(person_i, linear_model_i) = linear_models_cell{linear_model_i}.rmse;
        performance(person_i, linear_model_i) = std(2-exp(T_cell{linear_model_i}.performance));
        significance(:, linear_model_i) = significance(:, linear_model_i) + double(linear_models_cell{linear_model_i}.model.Coefficients.pValue < 0.05);
        estimate(:, linear_model_i) = estimate(:, linear_model_i) + linear_models_cell{linear_model_i}.model.Coefficients.Estimate;
        std_help(person_i,linear_model_i) = std(T_cell{linear_model_i}.performance);
        std_help2(person_i,linear_model_i) = std(2-exp(T_cell{linear_model_i}.performance));
    end
end
estimate = estimate/length(persons);

window_comparison
mean_stds_log = permute(nanmean(stds_log, 2), [1,3,2]);

covariance_analysis


Last = @(L) L{end};
%% Example correlation block bio parameters - performance 
figure(1)
set(gcf,'Name', 'Example Correlation', 'DefaultAxesFontSize',20)
clf;
time = -max_shift_time:step_size:max_shift_time;

current_block_name = change_block_name(block_names(relevant_blocks_idx(1)));
current_block_name = current_block_name{1};
%title_name = sgtitle({'\bfExample Correlation Between Biophsyiological Parameters And Performance',...
%    ['For Both ' current_block_name(1:end-2) ' Trials']}, 'FontSize',28);
for block_i = relevant_blocks_idx(1:2)
    subplot_i = block_i-relevant_blocks_idx(1)+1;
    subplot(3,2,subplot_i)
    
    set(gca,'FontSize',200)
    plot(time/1000,permute(Rs_ap_exponent(subplot_i, :, :), [2,3,1]), 'LineWidth', 2)
    ylim([-1 1])
    xlim([time(1)/1000 time(end)/1000])
    title(['Aperiodic Exponent - Block Half ' num2str(subplot_i)])
    ylabel('R')
    if block_i-relevant_blocks_idx(1)+1 == 1
        legend(cellfun(@(x) Last(split(x, '_')), window_field_names, 'UniformOutput', false), 'Location','best')
    end
    subplot(3,2,subplot_i+2)
    plot(time/1000,permute(Rs_ap_offset(subplot_i, :, :), [2,3,1]), 'LineWidth', 2)
    ylim([-1 1])
    xlim([time(1)/1000 time(end)/1000])
    title(['Aperiodic Offset - Block Half ' num2str(subplot_i)])
    ylabel('R')
    subplot(3,2,subplot_i+4)
    plot(time/1000,permute(Rs_alpha(subplot_i, :, :), [2,3,1]), 'LineWidth', 2)
    ylim([-1 1])
    xlim([time(1)/1000 time(end)/1000])
    title(['Alpha peak power - Block Half ' num2str(subplot_i)])
    xlabel('Shift in s')
    ylabel('R')
end
%%
save_plot
%% Mean correlation
figure(4);
set(gcf,'Name', 'Mean Correlation', 'DefaultAxesFontSize',20);
clf;
hold on
parameters = {Rs_ap_exponent, Rs_ap_offset, Rs_alpha};
parameter_names = {'Exponent', 'Offset', 'Alpha Peak Power'};
line_colour = [0, 0.4470, 0.7410];
for parameter_i=1:length(parameters)
    parameter = parameters{parameter_i};
    parameter_name = parameter_names{parameter_i};
    for cluster_i=1:size(parameter,2)

        subplot(3,4,cluster_i+(parameter_i-1)*4)
        hold on
        Rs_column = reshape(parameter(:,cluster_i,:),[],1);
        time2 = repmat(-max_shift:max_shift,size(parameter,1), 1);
        time_column = reshape(time2,[],1);
        [means,pred,grp] = grpstats(Rs_column,time_column,{'mean','predci','gname'},'Alpha',0.05);

        s = shadedErrorBar(time/1000,means,pred(:,2)-means);%, 'LineWidth', 2)
        set(s.edge,'LineWidth',2,'LineStyle',':')
        s.mainLine.LineWidth = 2;
        s.patch.FaceColor = line_colour;
        s.patch.EdgeColor = line_colour;
        s.patch.MarkerEdgeColor = line_colour;
        s.patch.MarkerFaceColor = line_colour;
        s.mainLine.Color = line_colour;
        plot(time/1000,means, 'Color' ,line_colour, 'LineWidth', 2, 'LineStyle', '-');
        xlim([time(1)/1000 time(end)/1000])
        ylim([-1 1])
        

        
        if cluster_i == 1
            ylabel({['\bf' parameter_name ' '], '\rmR'})
        end
        if parameter_i == 3
            xlabel('Shift in s')
        end
        if parameter_i == 1
            cluster_name = Last(split(window_field_names{cluster_i}, '_'));
            title([upper(cluster_name(1)) cluster_name(2:end)  ' Cluster'])
        end

        %legend(cellfun(@(x) Last(split(x, '_')), window_field_names{cluster_i}, 'UniformOutput', false), 'Location','best')
    end 
end

%sgtitle({'\bfExample Mean and 95% Confidence Intervall of ',...
%'Cross-correlation Between Biophysiological Parameters and Performance',...
%'Across Blocks'}, 'FontSize', 28);

%%
save_plot

%% Plotting example performance prediction
figure(7);
set(gcf,'Name', 'Example Performance Prediction', 'DefaultAxesFontSize',22);
clf;
%[~, idx] = min(rmses(p_idx,:));
shift_to_use = 0;%idx - max_shift - 1;
shift_reference = (strrep(['shift' num2str(shift_to_use)], '-', 'negative'));
variable = load([parent_folder '/' person '/' data_folder '/' data_subfolder '/linear_models.mat']);
variable2 = load([parent_folder '/' person '/' data_folder '/' data_subfolder '/T.mat']);
%title({'Example Performance Prediction',...
%    [' with Window Size ' num2str(window_size/1000) 's and Shift 0s']})
hold on
plot(2-exp(predict(variable.linear_models.(shift_reference).model,variable2.T.(shift_reference))), 'DisplayName', 'Predicted Performance', 'LineWidth', 2)
plot(2-exp(variable2.T.(shift_reference).performance), 'DisplayName', 'Actual Performance', 'LineWidth', 2)
ylim([0 1.1])
xlim([0 size(variable2.T.(shift_reference),1)])
ylabel('Performance in %')
xlabel('Window index')
legend('Location','best')
%%
save_plot
%% Plotting mean regression results with error bar
figure(9);
set(gcf,'Name', 'Mean Accuracy', 'DefaultAxesFontSize',22);
clf;
yyaxis right
hold on
rmses_column = reshape(rmses(:,:),[],1);
time2 = repmat(-max_shift:max_shift,32, 1);
time_column = reshape(time2,[],1);
[means,pred,grp] = grpstats(rmses_column,time_column,{'mean','predci','gname'},'Alpha',0.05);

s = shadedErrorBar(time/1000,means,pred(:,2)-means);
set(s.edge,'LineWidth',2,'LineStyle',':')
s.mainLine.LineWidth = 2;
s.patch.FaceColor = [0.8500, 0.3250, 0.0980];
s.patch.EdgeColor = [0.8500, 0.3250, 0.0980];
s.patch.MarkerEdgeColor = [0.8500, 0.3250, 0.0980];
s.patch.MarkerFaceColor = [0.8500, 0.3250, 0.0980];
s.mainLine.Color = [0.8500, 0.3250, 0.0980];
sd_rv_color = [0.55 0 0];

plot(time/1000,means, 'Color' ,[0.8500, 0.3250, 0.0980], 'LineWidth', 2, 'LineStyle', '-');
plot(time'/1000,mean_stds_log(3,:)', 'LineStyle', '-', 'Color', sd_rv_color, 'LineWidth', 2, 'DisplayName', 'SD Response Variable', 'Marker', 'none')
text(time(end)/1000-(time(end)/1000-time(1)/1000)/7,mean(mean_stds_log(3,:))+0.05*0.135,{'Standard Deviation','Response Variable'}, 'FontSize', 20, 'FontWeight', 'bold', 'Color', sd_rv_color, 'HorizontalAlignment' ,'center')
xlim([time(1)/1000 time(end)/1000])
ylim([0 0.135])
ylabel('RMSE')
xlabel('Shift in s')


yyaxis left
hold on
r_squared_adjusted_column = reshape(r_squared_adjusted(:,:),[],1);
time2 = repmat(-max_shift:max_shift,32, 1);
time_column = reshape(time2,[],1);
[means,pred,grp] = grpstats(r_squared_adjusted_column,time_column,{'mean','predci','gname'},'Alpha',0.05);

s = shadedErrorBar(time/1000,means,pred(:,2)-means); 
set(s.edge,'LineWidth',2,'LineStyle',':')
s.mainLine.LineWidth = 2;
s.patch.FaceColor = [0, 0.4470, 0.7410];
s.patch.EdgeColor = [0, 0.4470, 0.7410];
s.mainLine.Color = [0, 0.4470, 0.7410];
xlim([time(1)/1000 time(end)/1000])
ylim([0 1])
ylabel('R^2_{adjusted}')
xlabel('Shift in s')
plot(time/1000,means, 'Color' ,[0, 0.4470, 0.7410], 'LineWidth', 2, 'LineStyle', '-');

%%
save_plot
%% Plotting mean RRSE
figure(10);
set(gcf,'Name', 'RRSE', 'DefaultAxesFontSize',22);
clf;



hold on
stds_log_w10 = permute(stds_log(3,:,:), [2,3,1]);
%mean_rmses = permute(nanmean(rmses_w, 2), [1,3,2]);
%rmses_column = reshape(rmses./stds_log_w10,[],1);
%time2 = repmat(-max_shift:max_shift,32, 1);
%time_column = reshape(time2,[],1);
%[means,pred,grp] = grpstats(rmses_column,time_column,{'mean','predci','gname'},'Alpha',0.05);

%s = shadedErrorBar(time/1000,means,pred(:,2)-means);
%set(s.edge,'LineWidth',2,'LineStyle',':')
% s.mainLine.LineWidth = 2;
% s.patch.FaceColor = [0.8500, 0.3250, 0.0980];
% s.patch.EdgeColor = [0.8500, 0.3250, 0.0980];
% s.patch.MarkerEdgeColor = [0.8500, 0.3250, 0.0980];
% s.patch.MarkerFaceColor = [0.8500, 0.3250, 0.0980];
% s.mainLine.Color = [0.8500, 0.3250, 0.0980];
% sd_rv_color = [0.55 0 0];
for s_i=1:size(rmses,1)
    plot(time/1000,rmses(s_i,:)./stds_log_w10(s_i,:), 'LineWidth', 2, 'LineStyle', '-', 'DisplayName', ['s' num2str(s_i)]);
end
% plot(time/1000,means, 'Color' ,[0.8500, 0.3250, 0.0980], 'LineWidth', 2, 'LineStyle', '-');
% plot(time'/1000,mean_stds_log(3,:)', 'LineStyle', '-', 'Color', sd_rv_color, 'LineWidth', 2, 'DisplayName', 'SD Response Variable', 'Marker', 'none')
% text(time(end)/1000-(time(end)/1000-time(1)/1000)/7,mean(mean_stds_log(3,:))+0.05*0.135,{'Standard Deviation','Response Variable'}, 'FontSize', 16, 'FontWeight', 'bold', 'Color', sd_rv_color, 'HorizontalAlignment' ,'center')
xlim([time(1)/1000 time(end)/1000])
ylim([0 1.5])
ylabel('RRSE')
xlabel('Shift in s')
%legend('NumColumns', 4, 'Location', 'southeast')


%%
save_plot
%% Plotting 2D-significant parameter/shift plot 
new_order = [1     2     6    10     3     7    11     4     8    12     5     9    13];
figure(11);
set(gcf,'Name', 'Significance Parameter');
clf;

%title(['2D-shift/parameter Estimate plot, Window size:' num2str(window_size/1000) 's'])
h = heatmap(significance(new_order(2:end),:), 'Colormap', autumn);
h.ColorLimits = [0 length(persons)];
h.CellLabelColor = [0 0 0];
h.FontSize = 22;
ylabel('Parameters')
xlabel('Shift in s')
ax = gca;
ax.XData = arrayfun(@(x) num2str(x), time/1000, 'UniformOutput', false);
paramter_ns = cellfun(@(x) mlreportgen.utils.capitalizeFirstChar(strrep(x, '_',' ')), variable.linear_models.shift0.model.CoefficientNames, 'UniformOutput', false);
names = paramter_ns(new_order);
ax.YData = strrep(names(2:end), '_', '-');

%title('Amount of Subjects with Significant Parameter')
%%
save_plot
%% Plotting 2D-Estimate parameter/shift plot 
new_order = [1     2     6    10     3     7    11     4     8    12     5     9    13];
figure(12);
set(gcf,'Name', 'Influence Parameter');
clf;

%title(['2D-shift/parameter Estimate plot, Window size:' num2str(window_size/1000) 's'])
h = heatmap(estimate(new_order(2:end),:), 'Colormap', jet);
h.ColorLimits = [-max(max(abs(estimate(2:end,:)))) max(max(abs(estimate(2:end,:))))];
h.FontSize = 22;
ylabel('Parameters')
xlabel('Shift in s')
ax = gca;
ax.XData = arrayfun(@(x) num2str(x), time/1000, 'UniformOutput', false);
paramter_ns = cellfun(@(x) mlreportgen.utils.capitalizeFirstChar(strrep(x, '_',' ')), variable.linear_models.shift0.model.CoefficientNames, 'UniformOutput', false);
names = paramter_ns(new_order);
ax.YData = strrep(names(2:end), '_', '-');
%title('Parameter Influence on the Performance per Shift')
%%
save_plot
%% Plotting 2D-Estimate parameter/shift plot 
figure(13);
set(gcf,'Name', 'Change in Performance', 'DefaultAxesFontSize',22);
clf;

y_hat = 0:0.001:1;
hold on
delta_y_1 = 0.015;
plot(y_hat*100,100*(2-y_hat-exp(log(2-y_hat)+delta_y_1)), 'LineWidth', 2)
delta_y_2 = -delta_y_1;
plot(y_hat*100,100*(2-y_hat-exp(log(2-y_hat)+delta_y_2)), 'LineWidth', 2)
xlim([0 100])
%ylim([-5 5])

l = legend(['$$(1-\exp(' num2str(delta_y_1) ')) (2-\hat{y}_1) )$$'], ['$$(1-\exp(' num2str(delta_y_2) ')) (2-\hat{y}_1) )$$']);

set(l, 'Interpreter','latex')
ylabel('Change in Performance in Percentage Points')
xlabel('Performance in %')
%%
save_plot
%%



















%% Old Plots
%Plotting window information
%fooof_plot(block_results.dist_pred_fixation_1.window_1.cluster_parietal)

% Plotting aperiodic parameters
%figure(5);
%clf;
%plot_block(block_results.dist_unpred_fixation_2, window_field_names, step_size, window_size, 'exponent', 'performance')

% One example plot
%figure(6);
%clf;
%p_idx = 1;
%title(['VP: ' persons{p_idx} ', Window:' num2str(window_size/1000) 's'])
%hold on
%yyaxis left
%plot(time / 1000, r_squared_adjusted(p_idx,:))
%xlabel('Shift in sec')
%ylabel('R squared adjusted (on full data)')
%yyaxis right
%plot(time / 1000, rmses(p_idx,:))
%ylabel('Root mean squared errors by cross-validation')



% Every block R_squared
figure(2);
clf;
for block_i = relevant_blocks_idx
    subplot(4,4,block_i-relevant_blocks_idx(1)+1)
    
    block_name = block_names{block_i};
    all_windows_of_block = struct2cell(block_results.(block_name));
    r_squared = vertcat(vertcat(vertcat(all_windows_of_block{:}).(field_name)).r_squared);
    
    %time = 0:size(all_windows_of_block,1)-1;
    %time = time' * step_size/1000 + window_size/1000/2;
    
    plot(time,r_squared)
    title(strrep(block_names(block_i), '_', '-'))
    xlabel('Time in s')
    ylabel("Fooof's R Squared")
    xlim([0 max(time)+window_size/1000/2])
    legend(window_field_names)
end
sgtitle("Fooof's R squared per window per block") 


%% Plotting multiple regression results
figure(8);
clf;

for person_i=1:length(persons)
    subplot(2,3, person_i)
    person = persons{person_i};
    title(['VP: ' person ', Window size:' num2str(window_size/1000) 's'])

    hold on
    yyaxis left
    plot(time / 1000, r_squared_adjusted(person_i,:))
    ylim([0 0.3])
    xlabel('Shift in sec')
    ylabel('R squared adjusted (on full data)')
    yyaxis right
    plot(time / 1000, rmses(person_i, :))
    ylim([0.06 0.14])
    ylabel('Root mean squared errors by cross-validation')
end


%% Plotting multiple regression results normalized
figure(8);
clf;
for person_i=1:length(persons)
    subplot(2,3, person_i)
    person = persons{person_i};
    title(['VP: ' person ', Window size:' num2str(window_size/1000) 's'])

    hold on
    yyaxis left
    plot(time / 1000, r_squared_adjusted(person_i,:))
    ylim([0 0.3])
    xlabel('Shift in sec')
    ylabel('R squared adjusted (on full data)')
    yyaxis right
    plot(time / 1000, rmses(person_i, :)./performance(person_i,:))
    ylim([0.6 0.9])
    ylabel('RSME normalized by cross-validation')
end
%%
figure(20);
mean_stds_log = permute(nanmean(stds_log, 2), [1,3,2]);
mean_rmses = permute(nanmean(rmses_w, 2), [1,3,2]);
plot(time/1000, mean_rmses'./mean_stds_log')
title('RSME/std(log(2-performance)) for each shift')
xlabel('Shift in s')
ylabel('RSME/std(log(2-performance))')
xlim([-20 20])
ylim([0 1.5])
legend(arrayfun(@(x) [num2str(x/1000) 's'], windows_to_compare, 'UniformOutput', false), 'Location','best')

% Computation
mean_stds_log = permute(nanmean(stds_log, 2), [1,3,2]);
mean_rmses = permute(nanmean(rmses_w, 2), [1,3,2]);
mean_stds = permute(nanmean(stds, 2), [1,3,2]);
mean_means = permute(nanmean(means_w, 2), [1,3,2]);

[mean_means(:,max_shift+1), mean_stds(:,max_shift+1), mean_stds_log(:,max_shift+1), mean_rmses(:,max_shift+1), mean_rmses(:,max_shift+1)./mean_stds_log(:,max_shift+1)]


