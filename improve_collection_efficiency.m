function mods = improve_collection_efficiency(mods, efficiency)
% IMPROVE_COLLECTION_EFFICIENCY - Set formal collection efficiency
if efficiency < 0 || efficiency > 1
    warning('Collection efficiency should be between 0 and 1. Value %.2f may be invalid.', efficiency);
end
mods.collection_efficiency = efficiency;
fprintf('  Setting collection efficiency to %.1f%%\n', efficiency*100);
end
