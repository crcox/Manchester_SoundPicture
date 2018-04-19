function s = selectfields( s, selection )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    fn = fieldnames(s);
    z = ismember(fn, selection);
    s = rmfield(s, fn(~z));
end

