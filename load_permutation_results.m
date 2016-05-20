% load permutation results
%% Setup env
% Load dependencies
addpath('~/src/WholeBrain_RSA/util');
addpath('~/src/WholeBrain_RSA/dependencies/jsonlab');
addpath('~/src/defineCommonGrid/');

% Set constants
BIAS = false;
TARGET_STRUCTURE = 'visual';
TRIAL_MODALITY = 'visual';
PARAM_SELECTION = 'sample';
ALGORITHM = 'grOWL2';
PERMDIR = 'permtest_rows';
DATA_DIR = fullfile('~','MRI','Manchester','data','avg');
RESULT_DIR = fullfile('~','MRI','Manchester','results','WholeBrain_RSA',...
    TARGET_STRUCTURE,TRIAL_MODALITY,ALGORITHM,PERMDIR,PARAM_SELECTION);
SOLUTION_DIR = fullfile(RESULT_DIR,'solutionmaps','txt');
COORD_FILE = 'coords_avg_adj.mat';
META_FILE = 'metadata_avg.mat';
COND_FILE = 'seed_holdout_subject.csv';

% Load metadata
load(fullfile(DATA_DIR,META_FILE));
load(fullfile(DATA_DIR,COORD_FILE));
seedHoldSubj = csvread(fullfile(RESULT_DIR,COND_FILE));

% Filter coordinates
nSubj = numel(metadata);
XYZ = cell(nSubj,1);
for iSubj = 1:nSubj
    z = [metadata(iSubj).filter.dimension] == 2;
    z = z & strcmp(TRIAL_MODALITY, {metadata(iSubj).filter.subset});
    z1 = z & strcmp('colfilter', {metadata(iSubj).filter.label});
    colfilter = metadata(iSubj).filter(z1).filter;
    XYZ{iSubj} = coords(iSubj).mni(colfilter,:);
end

%% Load Results
% There are too many permutations to load them all comfortably at once.
% Load and process in small batches.
subject = unique(seedHoldSubj(:,3));
cvHoldout = unique(seedHoldSubj(:,2));
randomSeed = unique(seedHoldSubj(:,1));
nHoldout = numel(cvHoldout);

[x,y] = ndgrid(randomSeed,subject);
conds = [x(:),y(:)]; clear x y
nCond = size(conds,1);
Avg(nCond) = struct('W',[],'nodestrength',[],'nzVoxelIndex',[], ...
    'nVoxel',0,'err1',0,'err2',0,'subject',0,'RandomSeed',0);

if ~exist(SOLUTION_DIR,'dir')
  mkdir(SOLUTION_DIR);
end

for iCond = 1:nCond
    fprintf('Batch %d of %d\n',iCond,size(conds,1));
    r = conds(iCond,1);
    s = conds(iCond,2);
    z = seedHoldSubj(:,1) == r;
    z = z & (seedHoldSubj(:,3) == s);
    jobList = arrayfun(@(d) sprintf('%05d',d), find(z)-1, 'UniformOutput', false);
    [Results,Params] = HTCondorLoad(RESULT_DIR,'JobList',jobList,'quiet',true);
    z = [Results.subject]>0;
    Results = Results(z);
    Params = Params(z);
    nResults = numel(Results);
    nzv = any([Results.nz_rows], 2);
    
    if all([Params.bias])
        nzv = nzv(1:end-1);
    end
    if numel(nzv) ~= size(XYZ{s},1)
        disp('skipping...')
        disp([numel(nzv),size(XYZ{s},1)])
        continue
    end
    nzvIndex = find(nzv);
    W = zeros(sum(nzv));
    err1 = 0;
    err2 = 0;
    for iHoldout = 1:numel(cvHoldout)
        h = cvHoldout(iHoldout);
        c = [Results.cvholdout];
        if max(c) == 10 || min(c) == 2;
          c = c - 1;
        end
        z1 = c == h; if ~any(z1); continue; end
        
        nzv1 = Results(z1).nz_rows;
        if all([Params.bias])
            nzv1 = nzv1(1:end-1);
        end
        
        Results(z1).xyz = XYZ{s}(nzv1,:);
        if any(z1)
            U = Results(z1).Uz(nzv,:);
            W = W + (U*U');
            err1 = err1 + Results(z1).err1;
            err2 = err2 + Results(z1).err2;
        end
    end
    Avg(iCond).W = W / nResults;
    ns = sum(abs(Avg(iCond).W));
    dv = diag(Avg(iCond).W);
    Avg(iCond).nodestrength = ns(:);
    Avg(iCond).diagonal_value = dv;
    Avg(iCond).xyz = XYZ{s}(nzvIndex,:);
    Avg(iCond).nzVoxelIndex = nzvIndex;
    Avg(iCond).nVoxel = numel(nzv);
    Avg(iCond).err1 = err1 / nResults;
    Avg(iCond).err2 = err2 / nResults;
    Avg(iCond).subject = s;
    Avg(iCond).RandomSeed = r;

    % Write Node Strength
    % ===================
    % Average
    % -------
    filename = sprintf('%03d_%02d.mni', Avg(iCond).RandomSeed, Avg(iCond).subject);
    filepath = fullfile(SOLUTION_DIR, filename);
    d = [Avg(iCond).xyz,Avg(iCond).nodestrength];
    dlmwrite(filepath, d, ' ');
    % CV
    % ---
    for iHoldout = 1:numel(cvHoldout)
        h = cvHoldout(iHoldout);
        c = [Results.cvholdout];
        if max(c) == 10 || min(c) == 2;
            c = c - 1;
        end
        z1 = c == h; if ~any(z1); continue; end
        
        nzv1 = Results(z1).nz_rows;
        if all([Params.bias])
            nzv1 = nzv1(1:end-1);
        end
        U = Results(z1).Uz(nzv1,:);
        W = (U*U');
        
        filename = sprintf('%03d_%02d_%02d.mni', r, Results(z1).subject, iHoldout);
        filepath = fullfile(SOLUTION_DIR, filename);
        d = [Results(z1).xyz, sum(abs(W),2)];
        dlmwrite(filepath, d, ' ');
    end

    % Write Diagonal Value
    % ====================
    % Average
    % -------
    filename = sprintf('%03d_%02d_dv.mni', Avg(iCond).RandomSeed, Avg(iCond).subject);
    filepath = fullfile(SOLUTION_DIR, filename);
    d = [Avg(iCond).xyz,Avg(iCond).diagonal_value];
    dlmwrite(filepath, d, ' ');
    % CV
    % ---
    for iHoldout = 1:numel(cvHoldout)
        h = cvHoldout(iHoldout);
        c = [Results.cvholdout];
        if max(c) == 10 || min(c) == 2;
            c = c - 1;
        end
        z1 = c == h; if ~any(z1); continue; end
        
        nzv1 = Results(z1).nz_rows;
        if all([Params.bias])
            nzv1 = nzv1(1:end-1);
        end
        U = Results(z1).Uz(nzv1,:);
        W = (U*U');
        
        filename = sprintf('%03d_%02d_%02d_dv.mni', r, Results(z1).subject, iHoldout);
        filepath = fullfile(SOLUTION_DIR, filename);
        d = [Results(z1).xyz, diag(W)];
        dlmwrite(filepath, d, ' ');
    end

    % Write Selection Searchlight
    % ===========================
    % Average
    % -------
    SearchlightCounts = sum(pdist2(Avg(iCond).xyz,XYZ{s})<6);
    z = SearchlightCounts > 0;

    filename = sprintf('%03d_%02d_ss.mni', Avg(iCond).RandomSeed, Avg(iCond).subject);
    filepath = fullfile(SOLUTION_DIR, filename);
    d = [XYZ{s}(z,:), SearchlightCounts(z)'];
    dlmwrite(filepath, d, ' ');
    % CV
    % ---
    for iHoldout = 1:numel(cvHoldout)
        h = cvHoldout(iHoldout);
        c = [Results.cvholdout];
        if max(c) == 10 || min(c) == 2;
            c = c - 1;
        end
        z1 = c == h; if ~any(z1); continue; end
        filename = sprintf('%03d_%02d_%02d_ss.mni', r, Results(z1).subject, iHoldout);
        filepath = fullfile(SOLUTION_DIR, filename);
        SearchlightCounts = sum(pdist2(Results(z1).xyz,XYZ{s})<6);
        z = SearchlightCounts > 0;
        d = [XYZ{s}(z,:), SearchlightCounts(z)'];
        dlmwrite(filepath, d, ' ');
    end
end
