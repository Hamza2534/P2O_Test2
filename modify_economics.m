function mods = modify_economics(mods, opex_multiplier, capex_multiplier)
% MODIFY_ECONOMICS - Apply economic parameter multipliers
if nargin < 3
    capex_multiplier = opex_multiplier;
end
mods.economic_multipliers = struct();
mods.economic_multipliers.opex_multiplier = opex_multiplier;
mods.economic_multipliers.capex_multiplier = capex_multiplier;
fprintf('  Setting economic multipliers: OPEX=%.2f, CAPEX=%.2f\n', opex_multiplier, capex_multiplier);
end
