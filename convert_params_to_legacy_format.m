function convert_params_to_legacy_format(params, archetype_id, scenario_id, zone_id, output_dir)
% CONVERT_PARAMS_TO_LEGACY_FORMAT - Convert simplified parameters back to CSV files
%
% This function takes the simplified parameter structure and creates all the
% CSV files that the existing P2O model expects, maintaining full compatibility
%
% Usage: convert_params_to_legacy_format(params, archetype_id, scenario_id, zone_id, output_dir)

if nargin < 5
    output_dir = 'config_files';
end

% Create output directory if it doesn't exist
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Get archetype and scenario names
archetype_names = {'HI_Urban', 'HI_Rural', 'UMI_Urban', 'UMI_Rural', ...
                   'LMI_Urban', 'LMI_Rural', 'LI_Urban', 'LI_Rural'};
scenario_names = {'BAUI', 'CurrentCommitments', 'LinearScenario', ...
                  'RecyclingScenario', 'RandSScenario', 'ScenarioX'};

archetype_name = archetype_names{archetype_id};
scenario_name = scenario_names{scenario_id};

% Create basic configuration files
create_basic_info_file(params, output_dir);
create_interaction_parameters_file(params, output_dir);
create_box_conditions_file(params, output_dir);
create_stock_stock_interactions_file(params, output_dir);
create_time_series_file(params, output_dir);
create_capacity_files(params, output_dir);

% Create zone-specific economic files
create_demand_file(params, archetype_name, scenario_name, zone_id, output_dir);
create_costs_file(params, archetype_name, scenario_name, zone_id, output_dir);
create_ghg_jobs_file(params, archetype_name, scenario_name, zone_id, output_dir);
create_prices_file(params, archetype_name, scenario_name, zone_id, output_dir);
create_capex_file(params, archetype_name, scenario_name, zone_id, output_dir);
create_timeseries_files(params, archetype_name, scenario_name, zone_id, output_dir);
create_proportions_file(params, archetype_name, scenario_name, zone_id, output_dir);

fprintf('Legacy format files created successfully in %s\n', output_dir);

end

function create_basic_info_file(params, output_dir)
% Create basic_info.csv file

basic_info = [
    params.basic.duration;                           % Duration
    [params.basic.plastic_types, zeros(1, 10-length(params.basic.plastic_types))]; % Plastic types (padded)
    params.basic.n_MC_iterations;                    % MC iterations
    params.basic.MC_distribution_type;               % Distribution type
    1;                                               % Production calculation type
    1;                                               % Create figures
    2020;                                            % Start date
    params.basic.output_resolution;                 % Output resolution
    params.basic.n_stocks;                          % Number of stocks
    params.basic.production_interaction;             % Production interaction
    params.basic.waste_generated_box_number;        % Waste generated box
    params.basic.imports_interaction;               % Imports interaction
    [params.basic.finite_sinks, zeros(1, 10-length(params.basic.finite_sinks))]; % Finite sinks (padded)
    params.basic.pedigree_values'                   % Pedigree values
];

csvwrite(fullfile(output_dir, 'basic_info.csv'), basic_info);

end

function create_interaction_parameters_file(params, output_dir)
% Create interaction_parameters.csv file

n_interactions = params.flows.n_interactions;
n_plastic_types = params.basic.n_plastic_types;
n_cols_per_type = 18; % Number of parameter columns per plastic type

% Initialize the matrix
interaction_params = zeros(n_interactions, n_plastic_types * n_cols_per_type);

for plastic_type = 1:n_plastic_types
    col_start = (plastic_type - 1) * n_cols_per_type + 1;
    
    % Column assignments based on the original model structure
    interaction_params(:, col_start)     = params.flows.plug(:, plastic_type);
    interaction_params(:, col_start + 1) = params.flows.relative_absolute(:, plastic_type);
    interaction_params(:, col_start + 2) = params.flows.a(:, plastic_type);
    interaction_params(:, col_start + 3) = params.flows.b(:, plastic_type);
    interaction_params(:, col_start + 4) = params.flows.c(:, plastic_type);
    interaction_params(:, col_start + 5) = params.flows.time_series_pedigree(:, plastic_type);
    interaction_params(:, col_start + 6) = params.flows.d(:, plastic_type);
    interaction_params(:, col_start + 7) = zeros(n_interactions, 1); % Intervention start
    interaction_params(:, col_start + 8) = ones(n_interactions, 1) * 25; % Intervention end
    interaction_params(:, col_start + 9) = zeros(n_interactions, 1); % Reserved
    interaction_params(:, col_start + 10) = zeros(n_interactions, 1); % Reserved
    interaction_params(:, col_start + 11) = zeros(n_interactions, 1); % Reserved
    interaction_params(:, col_start + 12) = params.flows.max_annual_flow_rate(:, plastic_type);
    interaction_params(:, col_start + 13) = params.flows.equation_or_timeseries(:, plastic_type);
    interaction_params(:, col_start + 14) = params.flows.enforced_proportion(:, plastic_type);
    interaction_params(:, col_start + 15) = params.flows.processing_rate(:, plastic_type);
    interaction_params(:, col_start + 16) = params.flows.function_type(:, plastic_type);
    interaction_params(:, col_start + 17) = zeros(n_interactions, 1); % Reserved
end

csvwrite(fullfile(output_dir, 'interaction_parameters.csv'), interaction_params);

end

function create_box_conditions_file(params, output_dir)
% Create box_conditions.csv file

box_conditions = [
    params.capacity.mass_multiplier, ...
    params.capacity.mass_CAGR, ...
    params.capacity.mass_t_start, ...
    params.capacity.mass_t_end
];

csvwrite(fullfile(output_dir, 'box_conditions.csv'), box_conditions);

end

function create_stock_stock_interactions_file(params, output_dir)
% Create stock_stock_interactions.csv file with default flow network
% This represents the flow network topology of the model

n_stocks = params.basic.n_stocks;
stock_interactions = zeros(n_stocks, n_stocks);

% Define the basic flow network structure
% This is a simplified version - you may need to adjust based on your specific model
% Flow 1: Production -> Conversion (Box 1 -> Box 2)
stock_interactions(1, 2) = 1;
% Flow 2: Production -> Export (Box 1 -> Box 17) 
stock_interactions(1, 17) = 2;
% Flow 3: Conversion -> Collection (Box 2 -> Box 3)
stock_interactions(2, 3) = 3;
% Flow 4: Conversion -> Informal (Box 2 -> Box 4)
stock_interactions(2, 4) = 4;

% Add more flows based on your model structure
% This is where you'd define the complete flow network
% Each non-zero value represents a flow ID between boxes

csvwrite(fullfile(output_dir, 'stock_stock_interactions.csv'), stock_interactions);

end

function create_time_series_file(params, output_dir)
% Create time_series_imported.csv file

n_plastic_types = params.basic.n_plastic_types;
n_interactions = params.flows.n_interactions;
duration = params.basic.duration;

% Create timeseries data: [flow_id, year1, year2, ..., year25]
% First two rows are headers/indexing
timeseries_data = zeros(2 + n_plastic_types * n_interactions, 1 + duration);

% Set up indexing
for plastic_type = 1:n_plastic_types
    start_row = 3 + (plastic_type - 1) * n_interactions;
    end_row = start_row + n_interactions - 1;
    
    % Flow IDs in first column
    timeseries_data(start_row:end_row, 1) = (1:n_interactions)';
    
    % Time series data
    timeseries_data(start_row:end_row, 2:end) = params.flows.timeseries;
end

csvwrite(fullfile(output_dir, 'time_series_imported.csv'), timeseries_data);

end

function create_capacity_files(params, output_dir)
% Create capacity-related files

% Box flow capacity
flow_capacity = [
    params.capacity.flow_multiplier, ...
    params.capacity.flow_CAGR, ...
    params.capacity.flow_t_start, ...
    params.capacity.flow_t_end
];

csvwrite(fullfile(output_dir, 'box_flow_capacity.csv'), flow_capacity);

end

function create_demand_file(params, archetype_name, scenario_name, zone_id, output_dir)
% Create demand file: e.g., HI_Urban_BAUI_Plastic_2_Zone_1_Demand.csv

duration = params.basic.duration;

% Row structure for demand file:
% 1: Pedigree, 2-26: Population
% 27: Pedigree, 28-52: Waste per capita  
% 53-55: Pedigree + waste proportions for 3 plastic types
% ... (R&S parameters)

demand_data = zeros(33, 1 + duration);

% Population row
demand_data(1, 1) = 2; % Pedigree category
demand_data(1, 2:end) = params.demand.population;

% Waste per capita row  
demand_data(2, 1) = 2; % Pedigree category
demand_data(2, 2:end) = params.demand.waste_per_capita;

% Waste proportion rows
for i = 1:3
    row_idx = 2 + i;
    demand_data(row_idx, 1) = 2; % Pedigree
    demand_data(row_idx, 2:end) = params.demand.waste_proportion(i, :);
end

% R&S parameters (6 rows per plastic type)
rs_params = {'reduce_eliminate', 'reduce_reuse', 'reduce_new_delivery', ...
             'substitute_paper', 'substitute_coated_paper', 'substitute_compostables'};

for plastic_type = 1:3
    for param_idx = 1:6
        row_idx = 5 + (plastic_type - 1) * 6 + param_idx;
        param_name = rs_params{param_idx};
        demand_data(row_idx, 1) = 2; % Pedigree
        demand_data(row_idx, 2:end) = params.demand.(param_name)(plastic_type, :);
    end
end

% Plastic type shifting parameters
demand_data(24, 1) = 2; % Pedigree
demand_data(24, 2:end) = params.demand.shift_multi_to_rigid;

demand_data(25, 1) = 2; % Pedigree  
demand_data(25, 2:end) = params.demand.shift_multi_to_flexible;

demand_data(26, 1) = 2; % Pedigree
demand_data(26, 2:end) = params.demand.shift_flexible_to_rigid;

filename = sprintf('%s_%s_Plastic_2_Zone_%d_Demand.csv', archetype_name, scenario_name, zone_id);
csvwrite(fullfile(output_dir, filename), demand_data);

end

function create_costs_file(params, archetype_name, scenario_name, zone_id, output_dir)
% Create costs file with OPEX and CAPEX parameters

% Get process names
processes = {
    'virgin_plastic_production', 'plastic_conversion', 'formal_collection', ...
    'informal_collection', 'formal_sorting', 'closed_loop_MR', 'open_loop_MR', ...
    'chemical_conversion_P2P', 'chemical_conversion_P2F', 'thermal_treatment', ...
    'engineered_landfills', 'import_sorting', 'reduce_eliminate', 'reduce_reuse', ...
    'reduce_new_delivery', 'substitute_paper', 'substitute_coated_paper', ...
    'substitute_compostables', 'substitute_paper_waste', 'substitute_coated_paper_waste', ...
    'substitute_compostables_waste'
};

n_processes = length(processes);
costs_data = zeros(n_processes, 17);

for i = 1:n_processes
    process = processes{i};
    
    % Column structure: [OPEX_rate, OPEX_rate2, OPEX_pedigree, CAPEX_cost, CAPEX_pedigree, 
    %                   CAPEX_capacity, CAPEX_capacity_pedigree, CAPEX_duration, 
    %                   CAPEX_duration_pedigree, CAPEX_learning, CAPEX_learning_pedigree,
    %                   CAPEX_initial, CAPEX_initial_pedigree, reserved, reserved, 
    %                   CAPEX_initial2, CAPEX_type]
    
    costs_data(i, 1) = params.economics.(process).opex_initial_rate;
    costs_data(i, 2) = params.economics.(process).opex_learning_rate;
    costs_data(i, 3) = params.economics.(process).opex_pedigree;
    costs_data(i, 4) = params.economics.(process).capex_asset_cost;
    costs_data(i, 5) = params.economics.(process).capex_pedigree;
    costs_data(i, 6) = params.economics.(process).capex_asset_capacity;
    costs_data(i, 7) = params.economics.(process).capex_pedigree;
    costs_data(i, 8) = params.economics.(process).capex_asset_duration;
    costs_data(i, 9) = params.economics.(process).capex_pedigree;
    costs_data(i, 10) = params.economics.(process).capex_learning_rate;
    costs_data(i, 11) = params.economics.(process).capex_pedigree;
    costs_data(i, 12) = params.economics.(process).capex_pedigree;
    costs_data(i, 13) = params.economics.(process).capex_initial_rate;
    costs_data(i, 14) = params.economics.(process).capex_pedigree;
    costs_data(i, 15) = params.economics.(process).capex_pedigree;
    costs_data(i, 16) = params.economics.(process).capex_initial_rate;
    costs_data(i, 17) = 1; % CAPEX type
end

filename = sprintf('%s_%s_Plastic_2_Zone_%d_Costs.csv', archetype_name, scenario_name, zone_id);
csvwrite(fullfile(output_dir, filename), costs_data);

end

function create_ghg_jobs_file(params, archetype_name, scenario_name, zone_id, output_dir)
% Create GHG and Jobs file

processes = {
    'virgin_plastic_production', 'plastic_conversion', 'formal_collection', ...
    'informal_collection', 'formal_sorting', 'closed_loop_MR', 'open_loop_MR', ...
    'chemical_conversion_P2P', 'chemical_conversion_P2F', 'thermal_treatment', ...
    'engineered_landfills', 'import_sorting', 'reduce_eliminate', 'reduce_reuse', ...
    'reduce_new_delivery', 'substitute_paper', 'substitute_coated_paper', ...
    'substitute_compostables'
};

n_processes = length(processes);
ghg_jobs_data = zeros(n_processes, 6);

for i = 1:n_processes
    process = processes{i};
    
    % Column structure: [GHG_factor, Jobs_factor, Pedigree, GHG_factor2, Jobs_factor2, Pedigree2]
    ghg_jobs_data(i, 1) = params.economics.ghg.(process)(1); % Use first year value
    ghg_jobs_data(i, 2) = params.economics.jobs.(process)(1); % Use first year value
    ghg_jobs_data(i, 3) = 2; % Pedigree category
    ghg_jobs_data(i, 4) = params.economics.ghg.(process)(1);
    ghg_jobs_data(i, 5) = params.economics.jobs.(process)(1);
    ghg_jobs_data(i, 6) = 2; % Pedigree category
end

filename = sprintf('%s_%s_Plastic_2_Zone_%d_GHGJobs.csv', archetype_name, scenario_name, zone_id);
csvwrite(fullfile(output_dir, filename), ghg_jobs_data);

end

function create_prices_file(params, archetype_name, scenario_name, zone_id, output_dir)
% Create prices file

duration = params.basic.duration;
prices_data = zeros(5, 1 + duration);

% Row structure: [Pedigree, year1, year2, ..., year25]
prices_data(1, 1) = 2; % Pedigree
prices_data(1, 2:end) = params.economics.prices.closed_loop_MR;

prices_data(2, 1) = 2;
prices_data(2, 2:end) = params.economics.prices.open_loop_MR;

prices_data(3, 1) = 2;
prices_data(3, 2:end) = params.economics.prices.chemical_conversion_P2P;

prices_data(4, 1) = 2;
prices_data(4, 2:end) = params.economics.prices.chemical_conversion_P2F;

prices_data(5, 1) = 2;
prices_data(5, 2:end) = params.economics.prices.thermal_treatment_energy;

filename = sprintf('%s_%s_Plastic_2_Zone_%d_Prices.csv', archetype_name, scenario_name, zone_id);
csvwrite(fullfile(output_dir, filename), prices_data);

end

function create_capex_file(params, archetype_name, scenario_name, zone_id, output_dir)
% Create CAPEX timeseries file

duration = params.basic.duration;
capex_data = zeros(6, 1 + duration);

% These correspond to R&S interventions that have time-varying CAPEX
rs_processes = {'reduce_eliminate', 'reduce_reuse', 'reduce_new_delivery', ...
                'substitute_paper', 'substitute_coated_paper', 'substitute_compostables'};

for i = 1:6
    process = rs_processes{i};
    capex_data(i, 1) = 2; % Pedigree
    capex_data(i, 2:end) = ones(1, duration) * params.economics.(process).capex_initial_rate;
end

filename = sprintf('%s_%s_Plastic_2_Zone_%d_CAPEX.csv', archetype_name, scenario_name, zone_id);
csvwrite(fullfile(output_dir, filename), capex_data);

end

function create_timeseries_files(params, archetype_name, scenario_name, zone_id, output_dir)
% Create GHG and Jobs timeseries files

duration = params.basic.duration;

% GHG timeseries
processes_ghg = {
    'virgin_plastic_production', 'plastic_conversion', 'formal_collection', ...
    'formal_sorting', 'closed_loop_MR', 'open_loop_MR', 'chemical_conversion_P2P', ...
    'chemical_conversion_P2F', 'thermal_treatment', 'engineered_landfills', ...
    'open_burning', 'reduce_eliminate', 'reduce_reuse', 'reduce_new_delivery', ...
    'substitute_paper', 'substitute_coated_paper', 'substitute_compostables'
};

ghg_timeseries = zeros(17, 1 + duration);
for i = 1:17
    if i <= length(processes_ghg)
        process = processes_ghg{i};
        ghg_timeseries(i, 1) = 2; % Pedigree
        if isfield(params.economics.ghg, process)
            ghg_timeseries(i, 2:end) = params.economics.ghg.(process);
        else
            ghg_timeseries(i, 2:end) = ones(1, duration) * 1000; % Default value
        end
    end
end

filename = sprintf('%s_%s_Plastic_2_Zone_%d_GHGTimeseries.csv', archetype_name, scenario_name, zone_id);
csvwrite(fullfile(output_dir, filename), ghg_timeseries);

% Jobs timeseries
jobs_timeseries = zeros(17, 1 + duration);
for i = 1:17
    if i <= length(processes_ghg)
        process = processes_ghg{i};
        jobs_timeseries(i, 1) = 2; % Pedigree
        if isfield(params.economics.jobs, process)
            jobs_timeseries(i, 2:end) = params.economics.jobs.(process);
        else
            jobs_timeseries(i, 2:end) = ones(1, duration) * 5; % Default value
        end
    end
end

filename = sprintf('%s_%s_Plastic_2_Zone_%d_JobsTimeseries.csv', archetype_name, scenario_name, zone_id);
csvwrite(fullfile(output_dir, filename), jobs_timeseries);

end

function create_proportions_file(params, archetype_name, scenario_name, zone_id, output_dir)
% Create proportions file

proportions_data = params.zones.proportions';

filename = sprintf('%s_%s_Plastic_2_Zone_%d_Proportions.csv', archetype_name, scenario_name, zone_id);
csvwrite(fullfile(output_dir, filename), proportions_data);

end

function create_stock_names_file(output_dir)
% Create stock names file

stock_names = {
    'Virgin_Production', 'Waste_Generation', 'Formal_Collection', 'Informal_Collection', ...
    'Formal_Sorting', 'Informal_Sorting', 'Closed_Loop_MR', 'Open_Loop_MR', ...
    'Chemical_Conversion_Input', 'Chemical_Conversion_P2P', 'Chemical_Conversion_P2F', ...
    'Thermal_Treatment', 'Engineered_Landfill', 'Import_Sorting', 'Export', ...
    'Unmanaged_Waste_Land', 'Unmanaged_Waste_Water', 'Ocean_Surface', ...
    'Ocean_Column', 'Ocean_Deep', 'Ocean_Sediment', 'Shoreline', 'Remote_Areas'
};

fileID = fopen(fullfile(output_dir, 'stock_names.txt'), 'w');
for i = 1:length(stock_names)
    fprintf(fileID, '%s\n', stock_names{i});
end
fclose(fileID);