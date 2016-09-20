mkdir(SOLUTION_DIR);
for iCond = 1:nCond
    filename = sprintf('%03d_%02d.mni', Avg(iCond).RandomSeed, Avg(iCond).subject);
    filepath = fullfile(SOLUTION_DIR, filename);
    d = [Avg(iCond).xyz,Avg(iCond).nodestrength];
    dlmwrite(filepath, d, ' ');
    filename = sprintf('%03d_%02d_dv.mni', Avg(iCond).RandomSeed, Avg(iCond).subject);
    filepath = fullfile(SOLUTION_DIR, filename);
    d = [Avg(iCond).xyz,Avg(iCond).diagonal_value];
    dlmwrite(filepath, d, ' ');
end
