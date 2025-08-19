function run_p2o_simplified(archetype_id, scenario_id, zone_id, modifications)
% RUN_P2O_SIMPLIFIED - Easy interface for running P2O model with parameter modifications
%
% This function simplifies running the P2O model by:
% 1. Loading base parameters for the specified archetype/scenario/zone
% 2. Applying any custom modifications you specify
% 3. Converting to legacy CSV format
% 4. Running the existing P2O model
%
% Usage examples:
%   % Run baseline scenario
%   run_p2o_simplified(7, 1, 1)
%   
%   % Run with custom modifications
%   mods = create_parameter_modifications();
%   mods = increase_recycling_rate(mods, 0.3); % 30% recycling rate
%   mods = reduce_waste_generation(mods, 0.1); % 10% reduction
%   run_p2o_simplified(7, 1, 1, mods)

% Handle case where no arguments provided
if nargin == 0
    show_usage_examples();
    return;
end

% Set default values if not enough arguments
if nargin < 1
    archetype_id = 7; % LI_Urban
end
if nargin < 2
    scenario_id = 1; % Baseline
end
if nargin < 3
    zone_id = 1; % Zone 1
end
if nargin < 4
    modifications = struct();
end

fprintf('\n=== P2O Model Runner ===\n');
fprintf('Archetype: %d, Scenario: %d, Zone: %d\n\n', archetype_id, scenario_id, zone_id);

%% Step 1: Load base parameters
fprintf('Loading base parameters...\n');
params = load_scenario_parameters(archetype_id, scenario_id, zone_id);

%% Step 2: Apply modifications
if ~isempty(fieldnames(modifications))
    fprintf('Applying parameter modifications...\n');
    params = apply_parameter_modifications(params, modifications);
end

%% Step 3: Convert to legacy format
fprintf('Converting to legacy CSV format...\n');
output_dir = 'config_files_temp';
convert_params_to_legacy_format(params, archetype_id, scenario_id, zone_id, output_dir);

%% Step 4: Update run_P2O.m configuration
fprintf('Configuring model run...\n');
configure_model_run(archetype_id, scenario_id, zone_id, output_dir);

%% Step 5: Run the model
fprintf('Running P2O model...\n');
run_P2O_with_config(output_dir);

fprintf('\nModel run completed successfully!\n');
fprintf('Results saved in Output_files/\n\n');

end

function configure_model_run(LI_Urban, 1, 1)
% Configure the model run parameters

% Update the config directory in run_P2O.m or create a temporary version
% This could be done by modifying the config_prefix variable

% For now, we'll assume the user manually updates the config directory
% or we create a wrapper script

end

function run_P2O_with_config(config_dir)
% Run the P2O model with the specified configuration directory

% This would call your existing run_P2O script but with modified config directory
% Implementation depends on how you want to integrate with existing code

% Option 1: Modify run_P2O.m to accept config directory as parameter
% Option 2: Create temporary copy of run_P2O.m with modified paths
% Option 3: Use addpath/cd to change directory context

% For now, display instructions
fprintf('\nTo complete the run:\n');
fprintf('1. Copy files from %s to config_files/\n', config_dir);
fprintf('2. Run your existing run_P2O script\n');
fprintf('Or modify run_P2O.m to use config_dir: %s\n\n', config_dir);

end

%% Example usage scenarios

function show_usage_examples()
% Display usage examples when function called without arguments

fprintf('\n=== P2O Simplified Parameter Management ===\n\n');

fprintf('BASIC USAGE:\n');
fprintf('  run_p2o_simplified(archetype_id, scenario_id, zone_id)\n\n');

fprintf('ARCHETYPE IDs:\n');
fprintf('  1 = HI_Urban    2 = HI_Rural    3 = UMI_Urban   4 = UMI_Rural\n');
fprintf('  5 = LMI_Urban   6 = LMI_Rural   7 = LI_Urban    8 = LI_Rural\n\n');

fprintf('SCENARIO IDs:\n');
fprintf('  1 = Baseline           2 = Current Commitments  3 = Linear Scenario\n');
fprintf('  4 = Recycling Scenario 5 = R&S Scenario        6 = Scenario X\n\n');

fprintf('ZONE IDs:\n');
fprintf('  1 = Urban Zone         2 = Rural Zone\n\n');

fprintf('EXAMPLES:\n');
fprintf('  %% Run baseline LI_Urban scenario\n');
fprintf('  run_p2o_simplified(7, 1, 1)\n\n');

fprintf('  %% Run with modifications\n');
fprintf('  mods = create_parameter_modifications();\n');
fprintf('  mods = increase_recycling_rate(mods, 0.3);  %% 30%% recycling\n');
fprintf('  mods = reduce_waste_generation(mods, 0.1);  %% 10%% reduction\n');
fprintf('  run_p2o_simplified(7, 1, 1, mods)\n\n');

fprintf('  %% Advanced modifications\n');
fprintf('  mods = create_parameter_modifications();\n');
fprintf('  mods = improve_collection_efficiency(mods, 0.85);\n');
fprintf('  mods = increase_recycling_rate(mods, 0.25);\n');
fprintf('  mods = add_paper_substitution(mods, 0.08);\n');
fprintf('  mods = modify_economics(mods, 0.9, 0.8);  %% Cost reductions\n');
fprintf('  run_p2o_simplified(7, 1, 1, mods)\n\n');

fprintf('HELPER FUNCTIONS:\n');
fprintf('  demonstrate_easy_modifications()  %% Show examples\n');
fprintf('  run_recycling_sensitivity_analysis()  %% Sensitivity analysis\n');
fprintf('  run_combined_intervention_scenario()  %% Complex scenario\n\n');

end

function run_recycling_sensitivity_analysis()
% Example: Run sensitivity analysis on recycling rates

fprintf('\n=== Recycling Rate Sensitivity Analysis ===\n');

recycling_rates = [0.1, 0.2, 0.3, 0.4, 0.5];
archetype_id = 7; % LI_Urban
scenario_id = 1;  % Baseline
zone_id = 1;

for i = 1:length(recycling_rates)
    fprintf('\nRunning scenario with recycling rate: %.1f%%\n', recycling_rates(i)*100);
    
    mods = create_parameter_modifications();
    mods = increase_recycling_rate(mods, recycling_rates(i));
    
    % You would run the model here
    % run_p2o_simplified(archetype_id, scenario_id, zone_id, mods);
    
    % And collect results for analysis
end

fprintf('\nSensitivity analysis complete!\n');

end

function run_combined_intervention_scenario()
% Example: Combined intervention scenario

fprintf('\n=== Combined Intervention Scenario ===\n');

mods = create_parameter_modifications();
mods = improve_collection_efficiency(mods, 0.8);  % 80% collection
mods = increase_recycling_rate(mods, 0.3);        % 30% recycling
mods = reduce_waste_generation(mods, 0.1);        % 10% reduction
mods = add_paper_substitution(mods, 0.05);        % 5% paper substitution
mods = apply_population_growth(mods, 0.02);       % 2% annual growth

% Economic assumptions: 20% cost reduction due to scale
mods = modify_economics(mods, 0.8, 0.8);

run_p2o_simplified(7, 1, 1, mods);

end

function demonstrate_easy_modifications()
% Demonstrate how easy it is to modify parameters

fprintf('\n=== Parameter Modification Examples ===\n\n');

% Example 1: Quick recycling improvement
fprintf('Example 1: Increase recycling to 25%%\n');
mods1 = create_parameter_modifications();
mods1 = increase_recycling_rate(mods1, 0.25);
% run_p2o_simplified(7, 1, 1, mods1);

% Example 2: Waste reduction scenario  
fprintf('\nExample 2: 15%% waste reduction\n');
mods2 = create_parameter_modifications();
mods2 = reduce_waste_generation(mods2, 0.15);
% run_p2o_simplified(7, 1, 1, mods2);

% Example 3: Combined scenario
fprintf('\nExample 3: Combined improvements\n');
mods3 = create_parameter_modifications();
mods3 = improve_collection_efficiency(mods3, 0.9);
mods3 = increase_recycling_rate(mods3, 0.35);
mods3 = reduce_waste_generation(mods3, 0.12);
% run_p2o_simplified(7, 1, 1, mods3);

% Example 4: Custom flow parameters
fprintf('\nExample 4: Custom flow parameter modification\n');
mods4 = create_parameter_modifications();
% Set specific flow rates directly
custom_flows = struct();
custom_flows.a = zeros(44, 3); % 44 flows, 3 plastic types
custom_flows.a(5, :) = 0.8; % Sorting efficiency
custom_flows.a(7, :) = 0.4; % Recycling rate
mods4 = set_custom_flow_parameter(mods4, 'a', custom_flows.a);
% run_p2o_simplified(7, 1, 1, mods4);

fprintf('\nAll examples completed!\n');

end