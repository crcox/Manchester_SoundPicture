mkdir(SOLUTION_DIR);
for iResults = 1:numel(Results)
    filename = sprintf('%02d_%02d.mni', Results(iResults).subject, Results(iResults).cvholdout);
    filepath = fullfile(SOLUTION_DIR, filename);
    d = [Results(iResults).xyz,Results(iResults).nodestrength];
    dlmwrite(filepath, d, ' ');
    filename = sprintf('%02d_%02d.1D', Results(iResults).subject, Results(iResults).cvholdout);
    filepath = fullfile(SOLUTION_DIR, filename);
    d = [Results(iResults).nzVoxelIndex,Results(iResults).nodestrength];
    dlmwrite(filepath, d, ' ');
end
