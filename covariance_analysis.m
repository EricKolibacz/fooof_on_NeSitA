%% Covariance analysis
mode = 'performance';
Rs_ap_offset = nan(length(relevant_blocks_idx), length(window_field_names), max_shift_time/step_size*2+1);
ps_ap_offset = nan(length(relevant_blocks_idx), length(window_field_names), max_shift_time/step_size*2+1);
Rs_ap_exponent = nan(length(relevant_blocks_idx), length(window_field_names), max_shift_time/step_size*2+1);
ps_ap_exponent = nan(length(relevant_blocks_idx), length(window_field_names), max_shift_time/step_size*2+1);
for block_name_i = relevant_blocks_idx
    block_name = block_names{block_name_i};
    if isempty(block_results.(block_name))
       continue 
    end
    all_windows_of_block = struct2cell(block_results.(block_name));
    for i_field_name = 1:length(window_field_names)
        field_name = (window_field_names{i_field_name});
        aperiodic_parameters = vertcat(vertcat(vertcat(all_windows_of_block{:}).(field_name)).aperiodic_params);
        [performance, bias] = get_performance(all_windows_of_block);
        
        if strcmp(mode, 'performance')
            comparison_parameter = performance;
        elseif strcmp(mode,'bias')
            comparison_parameter = bias;
        else
           error(['Mode' mode ' is not known']) 
        end
%         if std(comparison_parameter) < 0.05
%             continue
%         end
    
        error = vertcat(vertcat(vertcat(all_windows_of_block{:}).(field_name)).error);
        r_squared = vertcat(vertcat(vertcat(all_windows_of_block{:}).(field_name)).r_squared);
        % median(r_squared)+1.4826 * 3 * mad(r_squared)
        % median(r_squared)-4.4478*mad(r_squared)
        aperiodic_parameters(r_squared > median(r_squared)+1.4826 * 3 * mad(r_squared),:) = nan;
        aperiodic_parameters(r_squared < median(r_squared)-1.4826 * 3 * mad(r_squared),:) = nan;
    
        [~, Rs, ps] = cross_correlation(comparison_parameter, aperiodic_parameters(:,1), max_shift_time/step_size);
        Rs_ap_offset(block_name_i-relevant_blocks_idx(1)+1,i_field_name,:) = Rs;
        ps_ap_offset(block_name_i-relevant_blocks_idx(1)+1,i_field_name,:) = ps;
        
        [ns, Rs, ps] = cross_correlation(comparison_parameter, aperiodic_parameters(:,2), max_shift_time/step_size);
        Rs_ap_exponent(block_name_i-relevant_blocks_idx(1)+1,i_field_name,:) = Rs;
        ps_ap_exponent(block_name_i-relevant_blocks_idx(1)+1,i_field_name,:) = ps;
    end
end