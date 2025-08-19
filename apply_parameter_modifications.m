function params = apply_parameter_modifications(params, modifications)
% APPLY_PARAMETER_MODIFICATIONS - Apply user-specified parameter modifications
%
% This function takes a parameter structure and applies modifications to it
%
% Usage: params = apply_parameter_modifications(params, modifications)

if isempty(modifications) || ~isstruct(modifications)
    return;  % No modifications to apply
end

mod_fields = fieldnames(modifications);

fprintf('Applying parameter modifications:\n');

for i = 1:length(mod_fields)
    field = mod_fields{i};
    
    switch field
        case 'collection_efficiency'
            % Modify formal collection efficiency (assuming flow 3 is formal collection)
            params.flows.a(3, :) = modifications.(field);
            fprintf('  ? Collection efficiency set to %.1f%%\n', modifications.(field)*100);
            
        case 'recycling_rate'
            % Modify closed-loop recycling rate (assuming flow 7 is closed-loop recycling)
            params.flows.a(7, :) = modifications.(field);
            fprintf('  ? Recycling rate set to %.1f%%\n', modifications.(field)*100);
            
        case 'sorting_efficiency'
            % Modify sorting efficiency (assuming flow 5 is sorting)
            params.flows.a(5, :) = modifications.(field);
            fprintf('  ? Sorting efficiency set to %.1f%%\n', modifications.(field)*100);
            
        case 'chemical_recycling_rate'
            % Modify chemical recycling rate (assuming flows 8-9 are chemical recycling)
            params.flows.a(8, :) = modifications.(field) * 0.6;  % P2P
            params.flows.a(9, :) = modifications.(field) * 0.4;  % P2F
            fprintf('  ? Chemical recycling rate set to %.1f%%\n', modifications.(field)*100);
            
        case 'waste_reduction'
            % Apply waste reduction across all years
            for year = 1:25
                params.demand.reduce_eliminate(:, year) = modifications.(field);
            end
            fprintf('  ? Waste reduction set to %.1f%%\n', modifications.(field)*100);
            
        case 'waste_prevention'
            % Apply waste prevention (similar to reduction but different mechanism)
            for year = 1:25
                params.demand.reduce_eliminate(:, year) = ...
                    params.demand.reduce_eliminate(:, year) + modifications.(field);
            end
            fprintf('  ? Waste prevention added: %.1f%%\n', modifications.(field)*100);
            
        case 'single_use_reduction'
            % Target reduction of single-use plastics (affects flexible packaging mostly)
            for year = 1:25
                params.demand.reduce_eliminate(3, year) = modifications.(field);  % Flexible packaging
            end
            fprintf('  ? Single-use reduction set to %.1f%%\n', modifications.(field)*100);
            
        case 'paper_substitution'
            % Apply paper substitution
            for year = 1:25
                params.demand.substitute_paper(:, year) = modifications.(field);
            end
            fprintf('  ? Paper substitution set to %.1f%%\n', modifications.(field)*100);
            
        case 'compostable_substitution'
            % Apply compostable substitution
            for year = 1:25
                params.demand.substitute_compostables(:, year) = modifications.(field);
            end
            fprintf('  ? Compostable substitution set to %.1f%%\n', modifications.(field)*100);
            
        case 'population_growth'
            % Apply population growth rate
            for year = 1:25
                params.demand.population(year) = params.demand.population(1) * (1 + modifications.(field))^(year-1);
            end
            fprintf('  ? Population growth set to %.1f%% annually\n', modifications.(field)*100);
            
        case 'custom_flow_params'
            % Allow direct modification of flow parameters
            custom_params = modifications.(field);
            custom_fields = fieldnames(custom_params);
            for j = 1:length(custom_fields)
                cf = custom_fields{j};
                if isfield(params.flows, cf)
                    params.flows.(cf) = custom_params.(cf);
                    fprintf('  ? Custom flow parameter modified: %s\n', cf);
                end
            end
            
        case 'economic_multipliers'
            % Apply economic parameter multipliers
            econ_mods = modifications.(field);
            processes = fieldnames(params.economics);
            processes = processes(~ismember(processes, {'prices', 'ghg', 'jobs'}));
            
            for j = 1:length(processes)
                process = processes{j};
                if isfield(econ_mods, 'opex_multiplier')
                    params.economics.(process).opex_initial_rate = ...
                        params.economics.(process).opex_initial_rate * econ_mods.opex_multiplier;
                end
                if isfield(econ_mods, 'capex_multiplier')
                    params.economics.(process).capex_initial_rate = ...
                        params.economics.(process).capex_initial_rate * econ_mods.capex_multiplier;
                end
            end
            fprintf('  ? Economic multipliers applied: OPEX=%.2f, CAPEX=%.2f\n', ...
                econ_mods.opex_multiplier, econ_mods.capex_multiplier);
            
        otherwise
            warning('Unknown modification field: %s', field);
    end
end

% Re-validate parameters after modifications
params = validate_parameters_internal(params);

end

function params = validate_parameters_internal(params)
% Internal validation function to avoid conflicts

% Ensure proportions sum to 1 where required
params.demand.waste_proportion = params.demand.waste_proportion ./ ...
    sum(params.demand.waste_proportion, 1);

% Ensure zone proportions sum to 1
params.zones.proportions = params.zones.proportions / sum(params.zones.proportions);

% Ensure all rates are between 0 and 1
rate_fields = {'reduce_eliminate', 'reduce_reuse', 'reduce_new_delivery', ...
               'substitute_paper', 'substitute_coated_paper', 'substitute_compostables'};

for i = 1:length(rate_fields)
    field = rate_fields{i};
    params.demand.(field) = max(0, min(1, params.demand.(field)));
end

% Ensure flow parameters are within reasonable bounds
params.flows.a = max(0, min(1, params.flows.a));
params.flows.processing_rate = max(0, params.flows.processing_rate);

% Check that total reduction + substitution doesn't exceed 100%
for plastic_type = 1:3
    for year = 1:25
        total_reduction = params.demand.reduce_eliminate(plastic_type, year) + ...
                         params.demand.reduce_reuse(plastic_type, year) + ...
                         params.demand.reduce_new_delivery(plastic_type, year) + ...
                         params.demand.substitute_paper(plastic_type, year) + ...
                         params.demand.substitute_coated_paper(plastic_type, year) + ...
                         params.demand.substitute_compostables(plastic_type, year);
        
        if total_reduction > 1
            % Scale down proportionally if total exceeds 100%
            scale_factor = 1 / total_reduction;
            params.demand.reduce_eliminate(plastic_type, year) = ...
                params.demand.reduce_eliminate(plastic_type, year) * scale_factor;
            params.demand.reduce_reuse(plastic_type, year) = ...
                params.demand.reduce_reuse(plastic_type, year) * scale_factor;
            params.demand.reduce_new_delivery(plastic_type, year) = ...
                params.demand.reduce_new_delivery(plastic_type, year) * scale_factor;
            params.demand.substitute_paper(plastic_type, year) = ...
                params.demand.substitute_paper(plastic_type, year) * scale_factor;
            params.demand.substitute_coated_paper(plastic_type, year) = ...
                params.demand.substitute_coated_paper(plastic_type, year) * scale_factor;
            params.demand.substitute_compostables(plastic_type, year) = ...
                params.demand.substitute_compostables(plastic_type, year) * scale_factor;
        end
    end
end

end