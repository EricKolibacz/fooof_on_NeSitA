%% Parameters
set_parameters;
data_folder = '/media/eric/External/Daten/Data4Pan/Data4Pan';
persons = {'s1', 's2', 's3', 's4'}; % 's5', 's4', 's7', 's8', 's9', 's10', 's11', 's12', 's13', 's14', 's15', 's16', 's17', 's18', 's19', '20'};
window_sizes = [7500];
step_sizes = [1000];

%% Computation
for person_i=1:length(persons)
    person = persons{person_i}
    for window_i=1:length(window_sizes)
        window_size = window_sizes(window_i)
        for step_size_i=1:length(step_sizes)
            step_size = step_sizes(step_size_i)
            disp("Analysing blocks")
            analysis_blocks;
            disp("Performing regression")
            regression;
        end
    end
end