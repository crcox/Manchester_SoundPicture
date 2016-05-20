function minRow = selectMinRow(X)
    [~,iRow] = min(X(1,:));
    minRow = X(iRow,:);
end