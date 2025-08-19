function mods = set_custom_flow_parameter(mods, parameter_name, values)
% SET_CUSTOM_FLOW_PARAMETER - Set custom flow parameters directly
if ~isfield(mods, 'custom_flow_params')
    mods.custom_flow_params = struct();
end
mods.custom_flow_params.(parameter_name) = values;
fprintf('  Setting custom flow parameter: %s\n', parameter_name);
end
