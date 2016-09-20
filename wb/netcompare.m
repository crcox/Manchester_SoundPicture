function [ h, p, stat, permlist ] = netcompare( A, B, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
  p = inputParser();
  addRequired(p, 'A');
  addRequired(p, 'B');
  addOptional(p, 'Afilter', []);
  addOptional(p, 'Bfilter', []);
  addParameter(p, 'alpha', 0.05);
  addParameter(p, 'nperm', 10000);
  parse(p, A, B, varargin{:});
  
  A = p.Results.A;
  B = p.Results.B;
  Afilter = p.Results.Afilter;
  Bfilter = p.Results.Bfilter;
  alpha = p.Results.alpha;
  nperm = p.Results.nperm;
  
  na = numel(A);
  nb = numel(B);
  if na == nb 
    n = na;  
  else
    error('Arrays differ in length.');
  end
  
  %% Setup logical vectors
  for i = 1:n
    nvox = A(i).nVoxel;
    nzv = A(i).nzVoxelIndex;
    x = false(1, nvox);
    x(nzv) = true;
    if ~isempty(Afilter);
      a = false(1, numel(Afilter{i}));
      a(Afilter{i}) = x;
    else
      a = x;
    end
    A(i).nzv = a;
    
    nvox = B(i).nVoxel;
    nzv = B(i).nzVoxelIndex;
    x = false(1, nvox);
    x(nzv) = true;
    if ~isempty(Bfilter);
      b = false(1, numel(Bfilter{i}));
      b(Bfilter{i}) = x;
    else
      b = x;
    end
    B(i).nzv = b;
    clear x nzv;
  end
  
  %% Run permutations
  permlist = zeros(1,nperm);
  for iperm = 1:nperm
    x = rand(1, n); % sample 23 numbers from a [0, 1] uniform distribution
    flip = x < 0.5;

    % initialize with the properly sorted values;
    A_flip = A;
    B_flip = B;

    % swap in the other network type when flip == true;
    A_flip(flip) = B(flip);
    B_flip(flip) = A(flip);

    r = zeros(1, n);
    for i = 1:n
      a = A_flip(i).nzv;
      b = B_flip(i).nzv;

      INTER = a & b;
      UNION = a | b;

      r(i) = nnz(INTER) / nnz(UNION);
    end
    permlist(iperm) = mean(r);
  end
  
  %% Compute real result
  r = zeros(1, n);
  for i = 1:n
    a = A(i).nzv;
    b = B(i).nzv;

    INTER = a & b;
    UNION = a | b;

    r(i) = nnz(INTER) / nnz(UNION);
  end
  
  %% Derive statistics
  stat = mean(r);
  p = nnz(permlist > stat) / nperm;
  h = p < alpha;
end

