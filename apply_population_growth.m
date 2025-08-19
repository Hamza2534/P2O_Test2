function mods = apply_population_growth(mods, annual_growth_rate)
% APPLY_POPULATION_GROWTH - Apply annual population growth rate
if annual_growth_rate < -0.1 || annual_growth_rate > 0.1
    warning('Population growth rate %.2f seems extreme.', annual_growth_rate);
end
mods.population_growth = annual_growth_rate;
fprintf('  Setting population growth to %.1f%% annually\n', annual_growth_rate*100);
end
