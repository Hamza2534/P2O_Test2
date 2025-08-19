function create_all_missing_helpers()
% Creates all the missing helper function files

fprintf('Creating missing helper function files...\n');

% 1. add_paper_substitution.m
fid = fopen('add_paper_substitution.m', 'w');
fprintf(fid, 'function mods = add_paper_substitution(mods, substitution_rate)\n');
fprintf(fid, '%% ADD_PAPER_SUBSTITUTION - Add paper substitution rate\n');
fprintf(fid, 'if substitution_rate < 0 || substitution_rate > 1\n');
fprintf(fid, '    warning(''Substitution rate should be between 0 and 1. Value %%.2f may be invalid.'', substitution_rate);\n');
fprintf(fid, 'end\n');
fprintf(fid, 'mods.paper_substitution = substitution_rate;\n');
fprintf(fid, 'fprintf(''  Setting paper substitution to %%.1f%%%%\\n'', substitution_rate*100);\n');
fprintf(fid, 'end\n');
fclose(fid);

% 2. apply_population_growth.m
fid = fopen('apply_population_growth.m', 'w');
fprintf(fid, 'function mods = apply_population_growth(mods, annual_growth_rate)\n');
fprintf(fid, '%% APPLY_POPULATION_GROWTH - Apply annual population growth rate\n');
fprintf(fid, 'if annual_growth_rate < -0.1 || annual_growth_rate > 0.1\n');
fprintf(fid, '    warning(''Population growth rate %%.2f seems extreme.'', annual_growth_rate);\n');
fprintf(fid, 'end\n');
fprintf(fid, 'mods.population_growth = annual_growth_rate;\n');
fprintf(fid, 'fprintf(''  Setting population growth to %%.1f%%%% annually\\n'', annual_growth_rate*100);\n');
fprintf(fid, 'end\n');
fclose(fid);

% 3. modify_economics.m
fid = fopen('modify_economics.m', 'w');
fprintf(fid, 'function mods = modify_economics(mods, opex_multiplier, capex_multiplier)\n');
fprintf(fid, '%% MODIFY_ECONOMICS - Apply economic parameter multipliers\n');
fprintf(fid, 'if nargin < 3\n');
fprintf(fid, '    capex_multiplier = opex_multiplier;\n');
fprintf(fid, 'end\n');
fprintf(fid, 'mods.economic_multipliers = struct();\n');
fprintf(fid, 'mods.economic_multipliers.opex_multiplier = opex_multiplier;\n');
fprintf(fid, 'mods.economic_multipliers.capex_multiplier = capex_multiplier;\n');
fprintf(fid, 'fprintf(''  Setting economic multipliers: OPEX=%%.2f, CAPEX=%%.2f\\n'', opex_multiplier, capex_multiplier);\n');
fprintf(fid, 'end\n');
fclose(fid);

% 4. set_custom_flow_parameter.m
fid = fopen('set_custom_flow_parameter.m', 'w');
fprintf(fid, 'function mods = set_custom_flow_parameter(mods, parameter_name, values)\n');
fprintf(fid, '%% SET_CUSTOM_FLOW_PARAMETER - Set custom flow parameters directly\n');
fprintf(fid, 'if ~isfield(mods, ''custom_flow_params'')\n');
fprintf(fid, '    mods.custom_flow_params = struct();\n');
fprintf(fid, 'end\n');
fprintf(fid, 'mods.custom_flow_params.(parameter_name) = values;\n');
fprintf(fid, 'fprintf(''  Setting custom flow parameter: %%s\\n'', parameter_name);\n');
fprintf(fid, 'end\n');
fclose(fid);

fprintf('? Created all missing helper function files!\n');
fprintf('Now run: test_p2o_parameter_system\n');

end