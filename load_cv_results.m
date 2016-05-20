% load permutation results
%% Setup env
% Load dependencies
addpath('~/src/WholeBrain_RSA/util');
addpath('~/src/WholeBrain_RSA/src');
addpath('~/src/WholeBrain_RSA/dependencies/jsonlab');

% Set constants
TARGET_STRUCTURE = 'visual';
TRIAL_MODALITY = 'visual';
PARAM_SELECTION = 'sample';
ALGORITHM = 'L1L2';
DATA_DIR = fullfile('~','MRI','Manchester','data','avg');
RESULT_DIR = fullfile('~','MRI','Manchester','results','WholeBrain_RSA',...
    TARGET_STRUCTURE,TRIAL_MODALITY,ALGORITHM,'final',PARAM_SELECTION);
SOLUTION_DIR = fullfile(RESULT_DIR,'solutionmaps','txt');
EDGE_DIR = fullfile(RESULT_DIR,'edge_dump');

COORD_FILE = 'coords_avg_adj.mat';
META_FILE = 'metadata_avg.mat';
COND_FILE = 'holdout_subject.csv';

% Load metadata
load(fullfile(DATA_DIR,META_FILE));
load(fullfile(DATA_DIR,COORD_FILE));

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

[Results,Params] = HTCondorLoad(RESULT_DIR);
for iResult = 1:numel(Results)
    s = Results(iResult).subject;
    if isempty(s)
        s = sscanf(Params(iResult).data,'s%02d_avg.mat');
        Results(iResult).subject = s;
    end
    if max([Results.cvholdout]) == 10
        Results(iResult).cvholdout = Results(iResult).cvholdout - 1;
    end
    nzv = Results(iResult).nz_rows;
    nzv = nzv(1:end-1);
    nzvIndex = find(nzv);
    U = Results(iResult).Uz;
    W = U(nzvIndex,:)*U(nzvIndex,:)';
    ns = sum(abs(W));
    Results(iResult).nodestrength = ns(:);
    Results(iResult).xyz = XYZ{s}(nzvIndex,:);
    Results(iResult).nzVoxelIndex = nzvIndex;
    Results(iResult).nVoxel = numel(nzv);
end
