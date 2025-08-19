function params = load_scenario_parameters(archetype_id, scenario_id, zone_id)
% LOAD_SCENARIO_PARAMETERS - Simplified parameter management for P2O model
% 
% This function replaces the complex CSV file system with a hierarchical
% parameter structure that allows easy modification while maintaining
% full model functionality.
%
% Usage: params = load_scenario_parameters(archetype_id, scenario_id, zone_id)
%
% Returns a complete parameter structure for the specified scenario

%% Initialize base parameters structure
params = initialize_base_parameters();

%% Load archetype-specific parameters
params = apply_archetype_parameters(params, archetype_id);

%% Apply scenario-specific modifications
params = apply_scenario_parameters(params, scenario_id);

%% Apply zone-specific parameters
params = apply_zone_parameters(params, zone_id);

%% Validate parameter consistency
params = validate_parameters(params);

end

function params = initialize_base_parameters()
% Initialize all base parameters with default values

% Basic model configuration
params.basic = struct();
params.basic.duration = 25;
params.basic.n_plastic_types = 3;
params.basic.plastic_types = [1, 2, 3];
params.basic.n_MC_iterations = 500;
params.basic.MC_distribution_type = 2; % 1=Normal, 2=Uniform
params.basic.output_resolution = 1;
params.basic.n_stocks = 23;
params.basic.production_interaction = 1;
params.basic.waste_generated_box_number = 2;
params.basic.imports_interaction = 17;
params.basic.finite_sinks = [17, 18, 19, 20, 21, 22, 23];
params.basic.pedigree_values = [1, 5, 10, 20, 50]; % Uncertainty levels

% Demand parameters (population, waste generation, etc.)
params.demand = struct();
params.demand.population = ones(1, 25) * 1000000; % Base population
params.demand.waste_per_capita = ones(1, 25) * 0.1; % kg/person/day
params.demand.waste_proportion = [0.4; 0.35; 0.25] .* ones(3, 25); % Rigid, Multi, Flexible

% Reduction & substitution rates (as fractions of demand)
params.demand.reduce_eliminate = zeros(3, 25);
params.demand.reduce_reuse = zeros(3, 25);
params.demand.reduce_new_delivery = zeros(3, 25);
params.demand.substitute_paper = zeros(3, 25);
params.demand.substitute_coated_paper = zeros(3, 25);
params.demand.substitute_compostables = zeros(3, 25);

% Plastic type shifting proportions
params.demand.shift_multi_to_rigid = zeros(1, 25);
params.demand.shift_multi_to_flexible = zeros(1, 25);
params.demand.shift_flexible_to_rigid = zeros(1, 25);

% Zone proportions (how much of total demand is in each zone)
params.zones = struct();
params.zones.proportions = [0.6, 0.4]; % Urban, Rural

% Flow interaction parameters
params.flows = struct();
params.flows.n_interactions = 44;

% Initialize flow parameters matrices
n_interactions = params.flows.n_interactions;
n_plastic_types = params.basic.n_plastic_types;

params.flows.plug = zeros(n_interactions, n_plastic_types);
params.flows.relative_absolute = ones(n_interactions, n_plastic_types); % 1=relative, 2=absolute
params.flows.equation_or_timeseries = ones(n_interactions, n_plastic_types); % 1=equation, 2=timeseries
params.flows.function_type = ones(n_interactions, n_plastic_types); % Function type for equations
params.flows.time_series_pedigree = ones(n_interactions, n_plastic_types) * 2; % Uncertainty category
params.flows.max_annual_flow_rate = ones(n_interactions, n_plastic_types) * inf;
params.flows.enforced_proportion = zeros(n_interactions, n_plastic_types);
params.flows.processing_rate = ones(n_interactions, n_plastic_types);

% Equation parameters (a, b, c, d for different function types)
params.flows.a = zeros(n_interactions, n_plastic_types);
params.flows.b = zeros(n_interactions, n_plastic_types);
params.flows.c = zeros(n_interactions, n_plastic_types);
params.flows.d = zeros(n_interactions, n_plastic_types);

% Time series data (for flows that use timeseries rather than equations)
params.flows.timeseries = zeros(n_interactions, 25); % 25 years

% Economic parameters
params.economics = initialize_economic_parameters();

% Box capacity parameters
params.capacity = initialize_capacity_parameters();

end

function econ = initialize_economic_parameters()
% Initialize economic parameters structure

% Cost parameters (OPEX and CAPEX for each process)
processes = {
    'virgin_plastic_production', 'plastic_conversion', 'formal_collection', ...
    'informal_collection', 'formal_sorting', 'closed_loop_MR', 'open_loop_MR', ...
    'chemical_conversion_P2P', 'chemical_conversion_P2F', 'thermal_treatment', ...
    'engineered_landfills', 'import_sorting', 'reduce_eliminate', 'reduce_reuse', ...
    'reduce_new_delivery', 'substitute_paper', 'substitute_coated_paper', ...
    'substitute_compostables', 'substitute_paper_waste', 'substitute_coated_paper_waste', ...
    'substitute_compostables_waste'
};

econ = struct();

for i = 1:length(processes)
    process = processes{i};
    
    % OPEX parameters
    econ.(process).opex_initial_rate = 100; % $/tonne
    econ.([process]).opex_learning_rate = 0.05; % Learning curve
    econ.([process]).opex_pedigree = 2; % Uncertainty category
    
    % CAPEX parameters  
    econ.([process]).capex_asset_cost = 1000; % $/tonne/year capacity
    econ.([process]).capex_asset_capacity = 1000; % tonnes/year
    econ.([process]).capex_asset_duration = 10; % years
    econ.([process]).capex_learning_rate = 0.1;
    econ.([process]).capex_initial_rate = 200; % $/tonne
    econ.([process]).capex_pedigree = 2;
end

% Revenue parameters (prices for outputs)
econ.prices = struct();
econ.prices.closed_loop_MR = ones(1, 25) * 800; % $/tonne, varies over time
econ.prices.open_loop_MR = ones(1, 25) * 400;
econ.prices.chemical_conversion_P2P = ones(1, 25) * 600;
econ.prices.chemical_conversion_P2F = ones(1, 25) * 300;
econ.prices.thermal_treatment_energy = ones(1, 25) * 50;

% GHG emission factors (kgCO2eq/tonne)
econ.ghg = struct();
for i = 1:length(processes)
    process = processes{i};
    econ.ghg.([process]) = ones(1, 25) * 1000; % Default 1 tonne CO2eq per tonne plastic
end

% Job creation factors (jobs/1000 tonnes/year)
econ.jobs = struct();
for i = 1:length(processes)
    process = processes{i};
    econ.jobs.([process]) = ones(1, 25) * 5; % Default 5 jobs per 1000 tonnes/year
end

end

function capacity = initialize_capacity_parameters()
% Initialize box capacity parameters

n_stocks = 23;

capacity = struct();

% Mass capacity parameters
capacity.mass_multiplier = ones(n_stocks, 1) * inf; % No limit by default
capacity.mass_CAGR = zeros(n_stocks, 1); % No growth by default
capacity.mass_t_start = zeros(n_stocks, 1);
capacity.mass_t_end = ones(n_stocks, 1) * 25;

% Flow capacity parameters  
capacity.flow_multiplier = ones(n_stocks, 1) * inf;
capacity.flow_CAGR = zeros(n_stocks, 1);
capacity.flow_t_start = zeros(n_stocks, 1);
capacity.flow_t_end = ones(n_stocks, 1) * 25;

end

function params = apply_archetype_parameters(params, archetype_id)
% Apply archetype-specific parameter modifications

switch archetype_id
    case 1 % HI_Urban
        params.demand.population = ones(1, 25) * 2000000;
        params.demand.waste_per_capita = ones(1, 25) * 0.15;
        params.zones.proportions = [0.8, 0.2]; % Mostly urban
        
        % Higher collection efficiency in HI Urban
        params.flows.a(3, :) = 0.8; % Formal collection rate
        params.flows.a(4, :) = 0.1; % Informal collection rate
        
    case 2 % HI_Rural  
        params.demand.population = ones(1, 25) * 500000;
        params.demand.waste_per_capita = ones(1, 25) * 0.12;
        params.zones.proportions = [0.2, 0.8]; % Mostly rural
        
        % Lower collection efficiency in HI Rural
        params.flows.a(3, :) = 0.6;
        params.flows.a(4, :) = 0.2;
        
    case 3 % UMI_Urban
        params.demand.population = ones(1, 25) * 1500000;
        params.demand.waste_per_capita = ones(1, 25) * 0.10;
        params.zones.proportions = [0.7, 0.3];
        
        params.flows.a(3, :) = 0.7;
        params.flows.a(4, :) = 0.15;
        
    case 4 % UMI_Rural
        params.demand.population = ones(1, 25) * 800000;
        params.demand.waste_per_capita = ones(1, 25) * 0.08;
        params.zones.proportions = [0.3, 0.7];
        
        params.flows.a(3, :) = 0.5;
        params.flows.a(4, :) = 0.25;
        
    case 5 % LMI_Urban
        params.demand.population = ones(1, 25) * 1200000;
        params.demand.waste_per_capita = ones(1, 25) * 0.06;
        params.zones.proportions = [0.6, 0.4];
        
        params.flows.a(3, :) = 0.6;
        params.flows.a(4, :) = 0.2;
        
    case 6 % LMI_Rural
        params.demand.population = ones(1, 25) * 600000;
        params.demand.waste_per_capita = ones(1, 25) * 0.05;
        params.zones.proportions = [0.4, 0.6];
        
        params.flows.a(3, :) = 0.4;
        params.flows.a(4, :) = 0.3;
        
    case 7 % LI_Urban
        params.demand.population = ones(1, 25) * 1000000;
        params.demand.waste_per_capita = ones(1, 25) * 0.04;
        params.zones.proportions = [0.5, 0.5];
        
        params.flows.a(3, :) = 0.5;
        params.flows.a(4, :) = 0.25;
        
    case 8 % LI_Rural
        params.demand.population = ones(1, 25) * 400000;
        params.demand.waste_per_capita = ones(1, 25) * 0.03;
        params.zones.proportions = [0.3, 0.7];
        
        params.flows.a(3, :) = 0.3;
        params.flows.a(4, :) = 0.35;
        
    otherwise
        warning('Unknown archetype ID: %d. Using defaults.', archetype_id);
end

end

function params = apply_scenario_parameters(params, scenario_id)
% Apply scenario-specific parameter modifications

switch scenario_id
    case 1 % Baseline
        % No changes - keep archetype defaults
        
    case 2 % Current commitments
        % Modest improvements in collection and recycling
        for i = 1:3 % All plastic types
            params.flows.a(3, i) = min(0.9, params.flows.a(3, i) * 1.2); % 20% improvement in formal collection
            params.flows.a(7, i) = min(0.3, params.flows.a(7, i) + 0.1); % Increase closed-loop recycling
        end
        
    case 3 % Linear Scenario  
        % Gradual improvements over time
        for year = 1:25
            improvement_factor = 1 + (year-1) * 0.02; % 2% annual improvement
            params.demand.reduce_eliminate(:, year) = min(0.1, (year-1) * 0.004); % Up to 10% reduction by year 25
        end
        
    case 4 % Recycling scenario
        % Focus on recycling improvements
        for i = 1:3
            params.flows.a(5, i) = min(0.8, params.flows.a(5, i) * 1.5); % Improve sorting
            params.flows.a(7, i) = min(0.4, params.flows.a(7, i) * 2); % Double closed-loop recycling
            params.flows.a(8, i) = min(0.3, params.flows.a(8, i) * 1.5); % Improve open-loop recycling
        end
        
    case 5 % R&S (Reduce & Substitute) scenario
        % Aggressive reduction and substitution
        for year = 1:25
            linear_growth = (year-1) / 24; % 0 to 1 over 25 years
            params.demand.reduce_eliminate(:, year) = 0.15 * linear_growth; % Up to 15% reduction
            params.demand.substitute_paper(:, year) = 0.1 * linear_growth; % Up to 10% substitution
            params.demand.substitute_compostables(:, year) = 0.05 * linear_growth; % Up to 5% substitution
        end
        
    case 6 % Scenario X (Combined approach)
        % Combine recycling improvements with reduction/substitution
        % Apply recycling improvements
        params = apply_scenario_parameters(params, 4);
        
        % Add reduction/substitution (but less aggressive than scenario 5)
        for year = 1:25
            linear_growth = (year-1) / 24;
            params.demand.reduce_eliminate(:, year) = 0.08 * linear_growth; % Up to 8% reduction
            params.demand.substitute_paper(:, year) = 0.05 * linear_growth; % Up to 5% substitution
        end
        
    otherwise
        warning('Unknown scenario ID: %d. Using defaults.', scenario_id);
end

end

function params = apply_zone_parameters(params, zone_id)
% Apply zone-specific parameter modifications

% Zone 1 is typically urban, Zone 2 is rural
% Most zone-specific parameters are already handled in archetype definition
% This function can be used for zone-specific economic parameters

switch zone_id
    case 1 % Urban zone
        % Higher costs but better efficiency
        processes = fieldnames(params.economics);
        processes = processes(~ismember(processes, {'prices', 'ghg', 'jobs'}));
        
        for i = 1:length(processes)
            process = processes{i};
            if isfield(params.economics.(process), 'opex_initial_rate')
                params.economics.(process).opex_initial_rate = ...
                    params.economics.(process).opex_initial_rate * 1.2; % 20% higher costs
            end
        end
        
    case 2 % Rural zone  
        % Lower costs but potentially lower efficiency
        processes = fieldnames(params.economics);
        processes = processes(~ismember(processes, {'prices', 'ghg', 'jobs'}));
        
        for i = 1:length(processes)
            process = processes{i};
            if isfield(params.economics.(process), 'opex_initial_rate')
                params.economics.(process).opex_initial_rate = ...
                    params.economics.(process).opex_initial_rate * 0.8; % 20% lower costs
            end
        end
        
    otherwise
        warning('Unknown zone ID: %d. Using defaults.', zone_id);
end

end

function params = validate_parameters(params)
% Validate parameter consistency and apply constraints

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

fprintf('Parameter validation complete.\n');

end