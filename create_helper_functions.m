function create_helper_functions()
% Creates all the helper function files automatically

% File contents
files = {
    'create_parameter_modifications.m', {
        'function mods = create_parameter_modifications()',
        '% CREATE_PARAMETER_MODIFICATIONS - Create empty modifications structure',
        'mods = struct();',
        'end'
    };
    
    'increase_recycling_rate.m', {
        'function mods = increase_recycling_rate(mods, rate)',
        '% INCREASE_RECYCLING_RATE - Set closed-loop recycling rate',
        'if rate < 0 || rate > 1',
        '    warning(''Recycling rate should be between 0 and 1. Value %.2f may be invalid.'', rate);',
        'end',
        'mods.recycling_rate = rate;',
        'fprintf(''  Setting recycling rate to %.1f%%\n'', rate*100);',
        'end'
    };
    
    'reduce_waste_generation.m', {
        'function mods = reduce_waste_generation(mods, reduction_fraction)',
        '% REDUCE_WASTE_GENERATION - Reduce waste generation by specified fraction', 
        'if reduction_fraction < 0 || reduction_fraction > 1',
        '    warning(''Reduction fraction should be between 0 and 1. Value %.2f may be invalid.'', reduction_fraction);',
        'end',
        'mods.waste_reduction = reduction_fraction;',
        'fprintf(''  Setting waste reduction to %.1f%%\n'', reduction_fraction*100);',
        'end'
    };
    
    'improve_collection_efficiency.m', {
        'function mods = improve_collection_efficiency(mods, efficiency)',
        '% IMPROVE_COLLECTION_EFFICIENCY - Set formal collection efficiency',
        'if efficiency < 0 || efficiency > 1',
        '    warning(''Collection efficiency should be between 0 and 1. Value %.2f may be invalid.'', efficiency);',
        'end',
        'mods.collection_efficiency = efficiency;',
        'fprintf(''  Setting collection efficiency to %.1f%%\n'', efficiency*100);',
        'end'
    }
};

% Create the files
for i = 1:size(files, 1)
    filename = files{i, 1};
    content = files{i, 2};
    
    fid = fopen(filename, 'w');
    for j = 1:length(content)
        fprintf(fid, '%s\n', content{j});
    end
    fclose(fid);
    
    fprintf('Created: %s\n', filename);
end

fprintf('\nAll helper function files created!\n');
end