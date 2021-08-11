%% Parameters
set_parameters;
datafiles_folder = '/media/eric/External/Daten/Data4Pan/Data4Pan';
persons = {'s1', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9', 's10', 's11', 's12', 's13', 's14', 's15', 's16', 's17', 's18', 's19', 's20', 's21', 's22', 's23', 's24', 's25', 's26', 's27', 's28', 's29', 's30', 's31', 's32'};
%persons = {'s22', 's23', 's24', 's25', 's26', 's27', 's28', 's29', 's30', 's31', 's32'};
window_sizes = [7500, 10000, 15000];
step_sizes = [1000];

%% Computation
for person_i=1:length(persons)
    person = persons{person_i}
    for window_i=1:length(window_sizes)
        window_size = window_sizes(window_i)
        for step_size_i=1:length(step_sizes)
            step_size = step_sizes(step_size_i)
            data_subfolder = ['/' 'w' num2str(window_size) '_s' num2str(step_size)];
            disp("Analysing blocks")
            analysis_blocks;
            disp("Performing regression")
            regression;
        end
    end
end