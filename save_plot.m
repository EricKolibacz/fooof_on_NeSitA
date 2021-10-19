current_fig = gcf;
current_fig.Name;
print([parent_folder '/../../Documentation/images/results/' strrep(strrep(current_fig.Name,' ', '_'),'/','')], '-depsc')%,'-opengl')
%saveas(gcf,[parent_folder '/../../Documentation/images/' strrep(strrep(current_fig.Name,' ', '_'),'/','') '.png'])