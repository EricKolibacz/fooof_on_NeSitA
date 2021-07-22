set_parameters;
persons = {'s4', 's6', 's7'}; %00 's5', 's4', 's7', 's8', 's9', 's10', 's11', 's12', 's13', 's14', 's15', 's16', 's17', 's18', 's19', '20'};
for person_i=1:length(persons)
    person = persons{person_i}
    analysis_blocks;
    regression;
    save([parent_folder person '/' data_folder{1} '/' data_subfolder{1} '/linear_models.mat'], 'linear_models')
    save([parent_folder person '/' data_folder{1} '/' data_subfolder{1} '/T.mat'], 'T')
end