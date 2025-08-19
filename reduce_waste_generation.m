function mods = reduce_waste_generation(mods, reduction_fraction)
% REDUCE_WASTE_GENERATION - Reduce waste generation by specified fraction
if reduction_fraction < 0 || reduction_fraction > 1
    warning('Reduction fraction should be between 0 and 1. Value %.2f may be invalid.', reduction_fraction);
end
mods.waste_reduction = reduction_fraction;
fprintf('  Setting waste reduction to %.1f%%\n', reduction_fraction*100);
end
