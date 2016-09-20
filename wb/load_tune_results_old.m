% load permutation results
%% Setup env
% Load dependencies
addpath('~/src/WholeBrain_RSA/util');
addpath('~/src/WholeBrain_RSA/src');
addpath('~/src/WholeBrain_RSA/dependencies/jsonlab');

% Set constants
LEGACYMODE = false;

TARGET_STRUCTURE = 'kind';
TARGET_TYPE = 'embedding'; % If empty, this level of file tree is skipped.
TRIAL_MODALITY = 'visual';
ALGORITHM = 'growl2';
DATA_DIR = fullfile('~','MRI','Manchester','data','avg');
file_pieces = squeeze({'~','MRI','Manchester','results','WholeBrain_RSA',...
    TARGET_STRUCTURE,TARGET_TYPE,TRIAL_MODALITY,ALGORITHM,'tune'});
RESULT_DIR = fullfile(file_pieces{:});
SOLUTION_DIR = fullfile(RESULT_DIR,'solutionmaps','txt');
COORD_FILE = 'coords_avg_adj.mat';
META_FILE = 'metadata_hack.mat';
COND_FILE = 'holdout_subject.csv';

% Load metadata
load(fullfile(DATA_DIR,META_FILE));
load(fullfile(DATA_DIR,COORD_FILE));

% Filter coordinates
nSubj = numel(metadata);
XYZ = cell(nSubj,1);
for iSubj = 1:nSubj
    z = [metadata(iSubj).filters.dimension] == 2;
    switch TRIAL_MODALITY
      case 'visual'
        z1 = z & strcmp(sprintf('colfilter_%s','vis'), {metadata(iSubj).filters.label});
    end
    colfilter = metadata(iSubj).filters(z1).filter;
    XYZ{iSubj} = coords(iSubj).mni;
end

%% Load Results
[Params,Results] = HTCondorLoad(RESULT_DIR,'legacy',LEGACYMODE);
Results = reshape(Results,8,[]);
Avg(size(Results,2)) = Results(1);
if LEGACYMODE==1
  toCopy = {'subject','cvholdout','finalholdout','lambda','lambda1','LambdaSeq','Gtype','bias','normalize'};
else
  toCopy = {'subject','cvholdout','finalholdout','lambda','lambda1','LambdaSeq','regularization','bias','normalize'};
end
toAvg = {'nzv','err1','err2','iter','job'};Wr
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

Tune.subj(numel(Xc)) = struct('subject',0,'finalholdout',0,'lambda',0','lambda1',0','err1',0);
for iTune = 1:numel(Tune.subj)
    Tune.subj(iTune).err1 = X(iTune,1);
    Tune.subj(iTune).finalholdout = X(iTune,2);
    Tune.subj(iTune).subject = X(iTune,3);
    Tune.subj(iTune).lambda = X(iTune,4);
    Tune.subj(iTune).lambda1 = X(iTune,5);
end

G = findgroups([Avg.finalholdout]);
S = @(x1, x2, x3, x4){selectMin(x1, x2, x3, x4)};
Xc = splitapply(S,[Avg.err1],[Avg.finalholdout],[Avg.lambda],[Avg.lambda1],G);
X = cell2mat(cellfun(@cell2mat,Xc,'Unif',0)');

Tune.samp(numel(Xc)) = struct('subject',0,'finalholdout',0,'lambda',0','lambda1',0','err1',0);
for iTune = 1:numel(Tune.samp)
    Tune.samp(iTune).err1 = X(iTune,1);
    Tune.samp(iTune).finalholdout = X(iTune,2);
    Tune.samp(iTune).lambda = X(iTune,3);
    Tune.samp(iTune).lambda1 = X(iTune,4);
end