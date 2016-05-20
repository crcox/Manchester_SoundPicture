% load permutation results
%% Setup env
% Load dependencies
addpath('~/src/WholeBrain_RSA/util');
addpath('~/src/WholeBrain_RSA/src');
addpath('~/src/WholeBrain_RSA/dependencies/jsonlab');

% Set constants
TARGET_STRUCTURE = 'semantic';
TRIAL_MODALITY = 'visual';
PARAM_SELECTION = 'sample';
ALGORITHM = 'grOWL2';
DATA_DIR = fullfile('~','MRI','Manchester','data','avg');
RESULT_DIR = fullfile('~','MRI','Manchester','results','WholeBrain_RSA',...
    TARGET_STRUCTURE,TRIAL_MODALITY,ALGORITHM,'final',PARAM_SELECTION);
SOLUTION_DIR = fullfile(RESULT_DIR,'solutionmaps_rows','txt');
EDGE_DIR = fullfile(RESULT_DIR,'edge_dump');

COORD_FILE = 'coords_avg_adj.mat';
META_FILE = 'metadata_avg.mat';
COND_FILE = 'holdout_subject.csv';

% Load metadata
load(fullfile(DATA_DIR,META_FILE));
load(fullfile(DATA_DIR,COORD_FILE));
holdSubj = csvread(fullfile(RESULT_DIR,COND_FILE));

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
subject = unique(holdSubj(:,2));
conds = subject;
cvHoldout = unique(holdSubj(:,1));
nHoldout = numel(cvHoldout);

nSubj = numel(subject);
Avg(nSubj) = struct('W',[],'nodestrength',[],'nzVoxelIndex',[], ...
    'nVoxel',0,'err1',0,'err2',0,'subject',0);

for iSubj = 1:nSubj
    fprintf('Batch %d of %d\n',iSubj,size(conds,1));
    s = conds(iSubj,1);
    z = holdSubj(:,2) == s;
    jobList = arrayfun(@(d) sprintf('%03d',d), find(z)-1, 'UniformOutput', false);
    [Results,Params] = HTCondorLoad(RESULT_DIR,'JobList',jobList,'quiet',true);
    z = [Results.subject]>0;
    Results = Results(z);
    Params = Params(z);
    nResults = numel(Results);
    nzv = any([Results.nz_rows], 2);
    nzv = nzv(1:end-1);
    nzvIndex = find(nzv);
    W = zeros(sum(nzv));
    err1 = 0;
    err2 = 0;
    for iHoldout = 1:numel(cvHoldout)
        h = cvHoldout(iHoldout);
        if all([Results.cvholdout]==0)
          ([Results.finalholdout]) == h;
        elseif min([Results.cvholdout])==2
          z1 = ([Results.cvholdout]-1) == h;
        else
          z1 = ([Results.cvholdout]) == h;
        end
        if any(z1)
            Ua = Results(z1).Uz(1:end-1,:);
            U = Ua(nzv,:);
            Ur = Ua(Results(z1).nz_rows(1:end-1),:);
            W = W + (U*U');
            err1 = err1 + Results(z1).err1;
            err2 = err2 + Results(z1).err2;
            Results(z1).nodestrength = sum(abs(Ur*Ur'))';
            Results(z1).xyz = XYZ{s}(Results(z1).nz_rows(1:end-1),:);
            Results(z1).nzVoxelIndex = find(Results(z1).nz_rows(1:end-1));
        end
    end
    if exist('ResultsAll','var')
      ResultsAll = [ResultsAll,Results];
    else
      ResultsAll = Results;
    end
    Avg(iSubj).W = W / nResults;
    ns = sum(abs(Avg(iSubj).W));
    dv = diag(Avg(iSubj).W);
%     maxVal = max(abs(Avg(iSubj).W(:)));
%     ns = sum(abs(Avg(iSubj).W/maxVal));
%     ns_scaled = ns / max(ns);
    %Avg(iSubj).nodestrength = ns_scaled(:);
    Avg(iSubj).nodestrength = ns(:);
    Avg(iSubj).diagonal_value = dv;
    Avg(iSubj).xyz = XYZ{s}(nzvIndex,:);
    Avg(iSubj).nzVoxelIndex = nzvIndex;
    Avg(iSubj).nVoxel = numel(nzv);
    Avg(iSubj).err1 = err1 / nResults;
    Avg(iSubj).err2 = err2 / nResults;
    Avg(iSubj).subject = s;
end

%%% Write to txt
%mkdir(SOLUTION_DIR);
%for iSubj = 1:nSubj
%    filename = sprintf('%02d.mni', Avg(iSubj).subject);
%    filepath = fullfile(SOLUTION_DIR, filename);
%    d = [Avg(iSubj).xyz,Avg(iSubj).nodestrength];
%    dlmwrite(filepath, d, ' ');
%end
%%% Write Masks
%mkdir(SOLUTION_DIR);
%for iSubj = 1:nSubj
%    filename = sprintf('%02d_mask.mni', Avg(iSubj).subject);
%    filepath = fullfile(SOLUTION_DIR, filename);
%    d = XYZ{iSubj};
%    dlmwrite(filepath, d, ' ');
%end
%%% Write Edges
%mkdir(SOLUTION_DIR)
%for iSubj = 1:nSubj
%    disp(iSubj)
%    filename = sprintf('%02d.edge', Avg(iSubj).subject);
%    filepath = fullfile(SOLUTION_DIR, filename);
%    nzvox = numel(Avg(iSubj).nzVoxelIndex);
%    edgeIndex = nchoosek(1:nzvox, 2);
%    maxValue = max(abs(Avg(iSubj).W(:)));
%    f = fopen(filepath,'w');
%    for iEdge = 1:size(edgeIndex,1)
%        i = edgeIndex(iEdge, 1);
%        j = edgeIndex(iEdge, 2);
%        x = Avg(iSubj).nzVoxelIndex(i);
%        y = Avg(iSubj).nzVoxelIndex(j);
%        v = Avg(iSubj).W(i,j);
%        if abs(v) > 0
%            fprintf(f, '%d,%d,%.8f\n', x, y, v/maxValue);
%        end
%    end
%    fclose(f);
%end
