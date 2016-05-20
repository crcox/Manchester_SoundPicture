% load permutation results
%% Setup env
% Load dependencies
addpath('~/src/WholeBrain_RSA/util');
addpath('~/src/WholeBrain_RSA/src');
addpath('~/src/WholeBrain_RSA/dependencies/jsonlab');

% Set constants
LEGACYMODE = false;
TARGET_STRUCTURE = 'visual';
TRIAL_MODALITY = 'visual';
ALGORITHM = 'grOWL_linear';
DATA_DIR = fullfile('~','MRI','Manchester','data','avg');
RESULT_DIR = fullfile('~','MRI','Manchester','results','WholeBrain_RSA',...
    TARGET_STRUCTURE,TRIAL_MODALITY,ALGORITHM,'tune_more/tune');
SOLUTION_DIR = fullfile(RESULT_DIR,'solutionmaps','txt');
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
    XYZ{iSubj} = coords(iSubj).mni;
end

%% Load Results
[Results,Params] = HTCondorLoad(RESULT_DIR,'legacy',LEGACYMODE);
Results = reshape(Results,8,[]);
Avg(size(Results,2)) = Results(1);
if LEGACYMODE
  toCopy = {'subject','cvholdout','finalholdout','lambda','lambda1','LambdaSeq','Gtype','bias','normalize'};
else
  toCopy = {'subject','cvholdout','finalholdout','lambda','lambda1','LambdaSeq','regularization','bias','normalize'};
end
toAvg = {'nzv','err1','err2','iter','job'};
for iResult = 1:size(Results,2);
    for iCopy = 1:numel(toCopy)
        field = toCopy{iCopy};
        i = 1;
        while i <= 8 && isempty(Results(i,iResult).(field))
            i = i + 1;
        end
        if i > 8
            Avg(iResult).(field) = 0;
        else
            Avg(iResult).(field) = Results(i,iResult).(field);
        end
    end
    for iAvg = 1:numel(toAvg)
        field = toAvg{iAvg};
        Avg(iResult).(field) = sum([Results(:,iResult).(field)])/nnz([Results(:,iResult).(field)]);
    end
end
Avg = Avg([Avg.subject]>0);
G = findgroups([Avg.finalholdout],[Avg.subject]);
S = @(x1, x2, x3, x4, x5){selectMin(x1, x2, x3, x4, x5)};
Xc = splitapply(S,[Avg.err1],[Avg.finalholdout],[Avg.subject],[Avg.lambda],[Avg.lambda1],G);
X = cell2mat(cellfun(@cell2mat,Xc,'Unif',0)');

Tune(numel(Xc)) = struct('subject',0,'finalholdout',0,'lambda',0','lambda1',0','err1',0);
for iTune = 1:numel(Tune)
    Tune(iTune).err1 = X(iTune,1);
    Tune(iTune).finalholdout = X(iTune,2);
    Tune(iTune).subject = X(iTune,3);
    Tune(iTune).lambda = X(iTune,4);
    Tune(iTune).lambda1 = X(iTune,5);
end
%%
%for iSubj = 1:nSubj
%    fprintf('Batch %d of %d\n',iSubj,size(conds,1));
%    s = conds(iSubj,1);
%    z = holdSubj(:,2) == s;
%    jobList = arrayfun(@(d) sprintf('%03d',d), find(z)-1, 'UniformOutput', false);
%    [Results,Params] = HTCondorLoad(RESULT_DIR,'JobList',jobList,'quiet',true);
%    z = [Results.subject]>0;
%    Results = Results(z);
%    Params = Params(z);
%    nResults = numel(Results);
%    nzv = any([Results.nz_rows], 2);
%    nzvIndex = find(nzv);
%    W = zeros(sum(nzv));
%    err1 = 0;
%    err2 = 0;
%    for iHoldout = 1:numel(cvHoldout)
%        h = cvHoldout(iHoldout);
%        z1 = ([Results.cvholdout]-1) == h;
%        if any(z1)
%            U = Results(z1).Uz(nzv,:);
%            W = W + (U*U');
%            err1 = err1 + Results(z1).err1;
%            err2 = err2 + Results(z1).err2;
%        end
%    end
%    Avg(iSubj).W = W / nResults;
%    ns = sum(abs(Avg(iSubj).W));
%    ns_scaled = ns / max(ns);
%    Avg(iSubj).nodestrength = ns_scaled(:);
%    Avg(iSubj).xyz = XYZ{s}(nzvIndex,:);
%    Avg(iSubj).nzVoxelIndex = nzvIndex;
%    Avg(iSubj).nVoxel = numel(nzv);
%    Avg(iSubj).err1 = err1 / nResults;
%    Avg(iSubj).err2 = err2 / nResults;
%    Avg(iSubj).subject = s;
%end

%% Add coords
% for iCond = 1:nCond
%     Avg(iCond).xyz = XYZ{Avg(iCond).subject}(Avg(iCond).nzVoxelIndex,:);
%     Avg(iCond).nodestrength = Avg(iCond).nodestrength';
% end

%% Write to txt
%mkdir(SOLUTION_DIR);
%for iSubj = 1:nSubj
%    filename = sprintf('%02d.mni', Avg(iSubj).subject);
%    filepath = fullfile(SOLUTION_DIR, filename);
%    d = [Avg(iSubj).xyz,Avg(iSubj).nodestrength];
%    dlmwrite(filepath, d, ' ');
%end
%mkdir(SOLUTION_DIR);
%for iSubj = 1:nSubj
%    filename = sprintf('%02d_mask.mni', Avg(iSubj).subject);
%    filepath = fullfile(SOLUTION_DIR, filename);
%    d = XYZ{iSubj};
%    dlmwrite(filepath, d, ' ');
%end
