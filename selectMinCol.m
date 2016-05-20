function minSet = selectMin(x, varargin)
    nargin = numel(varargin);
    [vMin,iMin] = min(x);
    minSet = cell(1, nargin+1);
    minSet{1} = vMin;
    for iArg = 1:nargin
        x = vargin{iArg};
        if iscell(x)
            minSet{iArg+1} = x{iMin};
        else
            minSet{iArg+1} = x(iMin);
        end
    end
end