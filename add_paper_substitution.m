function mods = add_paper_substitution(mods, substitution_rate)
% ADD_PAPER_SUBSTITUTION - Add paper substitution rate
if substitution_rate < 0 || substitution_rate > 1
    warning('Substitution rate should be between 0 and 1. Value %.2f may be invalid.', substitution_rate);
end
mods.paper_substitution = substitution_rate;
fprintf('  Setting paper substitution to %.1f%%\n', substitution_rate*100);
end
