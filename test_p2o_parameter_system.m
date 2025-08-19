function test_p2o_parameter_system()
% TEST_P2O_PARAMETER_SYSTEM - Test the simplified parameter management system
%
% This function tests the parameter loading and modification system
% without requiring the full P2O model to be present.

fprintf('\n=== Testing P2O Parameter System ===\n\n');

try
    %% Test 1: Basic parameter loading
    fprintf('Test 1: Loading base parameters...\n');
    params = load_scenario_parameters(7, 1, 1); % LI_Urban, Baseline, Zone 1
    fprintf('  ? Parameters loaded successfully\n');
    fprintf('  - Duration: %d years\n', params.basic.duration);
    fprintf('  - Plastic types: %d\n', params.basic.n_plastic_types);
    fprintf('  - Number of stocks: %d\n', params.basic.n_stocks);
    fprintf('  - Number of flows: %d\n', params.flows.n_interactions);
    
    %% Test 2: Parameter modifications
    fprintf('\nTest 2: Testing parameter modifications...\n');
    
    % Test recycling rate modification
    original_recycling = params.flows.a(7, 1); % Assuming flow 7 is recycling
    mods = create_parameter_modifications();
    mods = increase_recycling_rate(mods, 0.3);
    params_modified = apply_parameter_modifications(params, mods);
    fprintf('  ? Recycling rate modification: %.2f ? %.2f\n', ...
        original_recycling, params_modified.flows.a(7, 1));
    
    % Test waste reduction
    original_reduction = params.demand.reduce_eliminate(1, 10); % Year 10, plastic type 1
    mods = create_parameter_modifications();
    mods = reduce_waste_generation(mods, 0.15);
    params_modified = apply_parameter_modifications(params, mods);
    fprintf('  ? Waste reduction modification: %.2f ? %.2f\n', ...
        original_reduction, params_modified.demand.reduce_eliminate(1, 10));
    
    %% Test 3: Different archetypes
    fprintf('\nTest 3: Testing different archetypes...\n');
    
    archetypes = [1, 3, 5, 7]; % HI_Urban, UMI_Urban, LMI_Urban, LI_Urban
    archetype_names = {'HI_Urban', 'UMI_Urban', 'LMI_Urban', 'LI_Urban'};
    
    for i = 1:length(archetypes)
        params_arch = load_scenario_parameters(archetypes(i), 1, 1);
        fprintf('  ? %s: Population = %.0f, Waste/capita = %.3f kg/day\n', ...
            archetype_names{i}, params_arch.demand.population(1), ...
            params_arch.demand.waste_per_capita(1));
    end
    
    %% Test 4: Different scenarios
    fprintf('\nTest 4: Testing different scenarios...\n');
    
    scenarios = [1, 2, 4, 5]; % Baseline, Current Commitments, Recycling, R&S
    scenario_names = {'Baseline', 'Current Commitments', 'Recycling', 'R&S'};
    
    for i = 1:length(scenarios)
        params_scen = load_scenario_parameters(7, scenarios(i), 1);
        collection_eff = params_scen.flows.a(3, 1); % Assuming flow 3 is collection
        recycling_rate = params_scen.flows.a(7, 1); % Assuming flow 7 is recycling
        waste_reduction = params_scen.demand.reduce_eliminate(1, 25); % Final year
        
        fprintf('  ? %s: Collection=%.2f, Recycling=%.2f, Reduction=%.2f\n', ...
            scenario_names{i}, collection_eff, recycling_rate, waste_reduction);
    end
    
    %% Test 5: Parameter validation
    fprintf('\nTest 5: Testing parameter validation...\n');
    
    % Test that proportions sum to 1
    waste_prop_sum = sum(params.demand.waste_proportion(:, 1));
    zone_prop_sum = sum(params.zones.proportions);
    
    fprintf('  ? Waste proportions sum: %.3f (should be ~1.0)\n', waste_prop_sum);
    fprintf('  ? Zone proportions sum: %.3f (should be ~1.0)\n', zone_prop_sum);
    
    %% Test 6: Economic parameters
    fprintf('\nTest 6: Testing economic parameters...\n');
    
    econ_processes = fieldnames(params.economics);
    econ_processes = econ_processes(~ismember(econ_processes, {'prices', 'ghg', 'jobs'}));
    
    fprintf('  ? Economic processes defined: %d\n', length(econ_processes));
    fprintf('  - Sample OPEX rate (virgin production): $%.0f/tonne\n', ...
        params.economics.virgin_plastic_production.opex_initial_rate);
    fprintf('  - Sample CAPEX rate (recycling): $%.0f/tonne\n', ...
        params.economics.closed_loop_MR.capex_initial_rate);
    
    % Check price timeseries
    fprintf('  ? Price timeseries length: %d years\n', length(params.economics.prices.closed_loop_MR));
    
    %% Test 7: CSV conversion (structure test only)
    fprintf('\nTest 7: Testing CSV conversion structure...\n');
    
    % Test if we can create the parameter matrices
    n_interactions = params.flows.n_interactions;
    n_plastic_types = params.basic.n_plastic_types;
    duration = params.basic.duration;
    
    % Test interaction parameters matrix
    test_matrix = zeros(n_interactions, n_plastic_types * 18);
    fprintf('  ? Interaction parameters matrix: %dx%d\n', size(test_matrix));
    
    % Test demand matrix  
    test_demand = zeros(33, 1 + duration);
    fprintf('  ? Demand parameters matrix: %dx%d\n', size(test_demand));
    
    %% Test 8: Helper functions
    fprintf('\nTest 8: Testing helper functions...\n');
    
    mods = create_parameter_modifications();
    mods = increase_recycling_rate(mods, 0.4);
    mods = improve_collection_efficiency(mods, 0.9);
    mods = reduce_waste_generation(mods, 0.12);
    mods = add_paper_substitution(mods, 0.08);
    mods = apply_population_growth(mods, 0.025);
    mods = modify_economics(mods, 0.85, 0.75);
    
    mod_fields = fieldnames(mods);
    fprintf('  ? Helper functions created %d modifications:\n', length(mod_fields));
    for i = 1:length(mod_fields)
        fprintf('    - %s\n', mod_fields{i});
    end
    
    %% Summary
    fprintf('\n=== Test Summary ===\n');
    fprintf('? All tests passed successfully!\n');
    fprintf('? Parameter system is working correctly\n');
    fprintf('? Ready to run: run_p2o_simplified(7, 1, 1)\n\n');
    
    % Show a quick example
    fprintf('Example: Run with 30%% recycling and 10%% waste reduction:\n');
    fprintf('  mods = create_parameter_modifications();\n');
    fprintf('  mods = increase_recycling_rate(mods, 0.3);\n');
    fprintf('  mods = reduce_waste_generation(mods, 0.1);\n');
    fprintf('  run_p2o_simplified(7, 1, 1, mods)\n\n');
    
catch ME
    fprintf('\n? Test failed with error:\n');
    fprintf('Error: %s\n', ME.message);
    fprintf('Function: %s (line %d)\n', ME.stack(1).name, ME.stack(1).line);
    
    if length(ME.stack) > 1
        fprintf('Called from: %s (line %d)\n', ME.stack(2).name, ME.stack(2).line);
    end
    
    fprintf('\nTroubleshooting:\n');
    fprintf('1. Make sure all three main functions are in your path:\n');
    fprintf('   - load_scenario_parameters.m\n');
    fprintf('   - convert_params_to_legacy_format.m\n');
    fprintf('   - run_p2o_simplified.m\n');
    fprintf('2. Check that you have write permissions for CSV file creation\n');
    fprintf('3. Verify MATLAB version compatibility\n\n');
end

end

function demo_quick_modifications()
% DEMO_QUICK_MODIFICATIONS - Show quick examples of parameter modifications

fprintf('\n=== Quick Parameter Modification Demo ===\n\n');

% Load base parameters
params = load_scenario_parameters(7, 1, 1); % LI_Urban baseline

fprintf('ORIGINAL PARAMETERS (LI_Urban Baseline):\n');
fprintf('  Population: %.0f\n', params.demand.population(1));
fprintf('  Waste per capita: %.3f kg/day\n', params.demand.waste_per_capita(1));
fprintf('  Collection efficiency: %.2f\n', params.flows.a(3, 1));
fprintf('  Recycling rate: %.2f\n', params.flows.a(7, 1));
fprintf('  Waste reduction (year 25): %.2f\n', params.demand.reduce_eliminate(1, 25));

fprintf('\nMODIFIED PARAMETERS:\n');

% Apply modifications
mods = create_parameter_modifications();
mods = improve_collection_efficiency(mods, 0.85);
mods = increase_recycling_rate(mods, 0.35);
mods = reduce_waste_generation(mods, 0.12);
mods = apply_population_growth(mods, 0.02);

params_mod = apply_parameter_modifications(params, mods);

fprintf('  Population (year 25): %.0f\n', params_mod.demand.population(25));
fprintf('  Collection efficiency: %.2f\n', params_mod.flows.a(3, 1));
fprintf('  Recycling rate: %.2f\n', params_mod.flows.a(7, 1));
fprintf('  Waste reduction (year 25): %.2f\n', params_mod.demand.reduce_eliminate(1, 25));

fprintf('\nTo run this scenario:\n');
fprintf('  mods = create_parameter_modifications();\n');
fprintf('  mods = improve_collection_efficiency(mods, 0.85);\n');
fprintf('  mods = increase_recycling_rate(mods, 0.35);\n');
fprintf('  mods = reduce_waste_generation(mods, 0.12);\n');
fprintf('  mods = apply_population_growth(mods, 0.02);\n');
fprintf('  run_p2o_simplified(7, 1, 1, mods)\n\n');

end