function cx  = expand_cell( c )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    if ~iscell(c{1,3})
        c(:,3) = cellfun(@(x) {x}, c(:,3), 'unif', 0);
    end
    n = cellfun('prodofsize', c(1,:));
    expand = n > 1;
    N = max(n);
    
    cx = cell( size(c, 1) * N, size(c, 2) );
    
    
    cur = 0;
    for i = 1:size( c, 1 )
        a = cur + 1;
        b = cur + N;
        cur = b;
        
        for j = 1:size( c, 2 )
            if expand(j)
                if isnumeric(c{i, j})
                    cx(a:b, j) = num2cell(c{i,j});
                else
                    cx(a:b, j) = c(i,j);
                end
            else
                cx(a:b, j) = repmat(c(i,j), N, 1);
            end
        end
    end
end

