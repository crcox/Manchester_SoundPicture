mkdir(SOLUTION_DIR);
for iSubj = 1:nSubj
    filename = sprintf('%02d.mni', Avg(iSubj).subject);
    filepath = fullfile(SOLUTION_DIR, filename);
    d = [Avg(iSubj).xyz,Avg(iSubj).nodestrength];
    dlmwrite(filepath, d, ' ');
    
    filename = sprintf('%02d_dv.mni', Avg(iSubj).subject);
    filepath = fullfile(SOLUTION_DIR, filename);
    d = [Avg(iSubj).xyz,Avg(iSubj).diagonal_value];
    dlmwrite(filepath, d, ' ');
end
