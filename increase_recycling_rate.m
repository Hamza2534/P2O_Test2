function mods = increase_recycling_rate(mods, rate)
% INCREASE_RECYCLING_RATE - Set closed-loop recycling rate
if rate < 0 || rate > 1
    warning('Recycling rate should be between 0 and 1. Value %.2f may be invalid.', rate);
end
mods.recycling_rate = rate;
fprintf('  Setting recycling rate to %.1f%%\n', rate*100);
end
