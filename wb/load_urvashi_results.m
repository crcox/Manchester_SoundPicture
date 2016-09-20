subjects = [2,4,6,7,8,10,11,12];
nSubj = numel(subjects);
cvHoldout = 1:9;
nHoldout = 9;
SOLUTION_DIR = fullfile('.','solutionmaps','txt');

Avg_size(nSubj) = struct('W',[],'nodestrength',[],'nzVoxelIndex',[], ...
    'nVoxel',0,'subject',0);
for iSubj = 1:nSubj
    fprintf('Batch %d of %d\n',iSubj,nSubj);
    s = subjects(iSubj);
    fname = sprintf('out_%02d.mat', s);
    R = load(fname);
    nzv = R.nz_rows > 0;
    nzvIndex = find(nzv);
    W = zeros(sum(nzv));
    for iHoldout = 1:nHoldout
        U = R.U_predict{iHoldout};
        W = W + (U(nzv,:)*U(nzv,:)');
    end
    Avg_size(iSubj).W = W / nHoldout;
    ns = sum(abs(Avg_size(iSubj).W));
    ns_scaled = ns / max(ns);
    Avg_size(iSubj).nodestrength = ns_scaled(:);
    Avg_size(iSubj).xyz = XYZ{s}(nzvIndex,:);
    Avg_size(iSubj).nzVoxelIndex = nzvIndex;
    Avg_size(iSubj).nVoxel = numel(nzv);
    Avg_size(iSubj).subject = s;
end

%% Write to txt
mkdir(SOLUTION_DIR);
for iSubj = 1:nSubj
    filename = sprintf('%02d.mni', Avg_size(iSubj).subject);
    filepath = fullfile(SOLUTION_DIR, filename);
    d = [Avg_size(iSubj).xyz,Avg_size(iSubj).nodestrength];
    dlmwrite(filepath, d, ' ');
end