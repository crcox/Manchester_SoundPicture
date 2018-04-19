function tblx = expand_table( tbl )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    c = table2cell(tbl);
    cx = expand_cell(c);
    tblx = cell2table(cx, 'VariableNames', tbl.Properties.VariableNames); 
end

