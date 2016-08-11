addpath('~/src/WholeBrain_RSA/util');
addpath('~/src/WholeBrain_RSA/dependencies/jsonlab');
results_root = '/home/chris/MRI/Manchester/results/WholeBrain_RSA';
regularization = 'growl2';
structure = 'visual';
type = 'similarity';
sim_source = 'chamfer';
sim_metric = '';
modality = 'visual';
WRITE_CV = 1;
%% Write masks
load('data/avg/metadata_hack.mat')
odir = fullfile('results','WholeBrain_RSA',structure,type,sim_source,sim_metric,modality,regularization,'final','solutionmaps','txt','mask');
if ~exist(odir,'dir')
  mkdir(odir);
end
for i = 1:numel(metadata)
  xyz = metadata(i).coords(1).xyz; % RPI
  ofile = fullfile(odir,sprintf('%02d.mni', i));
  xyz = metadata(i).coords(2).xyz; % RAI
  ofile = fullfile(odir,sprintf('%02d.orig', i));
  dlmwrite(ofile,xyz,' ');
end

%%
toWrite = {};
[Results,Avg,Params] = load_tune_results(regularization,structure,sim_source,sim_metric,modality,type,'resultsroot',results_root,'write',toWrite,'writecv',WRITE_CV);
fields = {'subject','finalholdout','cvholdout','lambda','lambda1','LambdaSeq','regularization','normalize','nzv','err1','err2','nvox','RandomSeed'};
csv_file = sprintf('%s_%s_%s_%s_%s_%s_tune.csv', ...
    regularization, structure, type, sim_source, sim_metric, modality); 
WriteTable(csv_file, Results, 'fields', fields);

%%
toWrite = {'l2norm','nodestrength','stability','selectioncount'};
P = struct(...
  'structure',{'semantic','semantic','semantic','semantic','visual'}, ...
  'modality',{'visual','audio','audvis','average','visual'});
for i = 5:numel(P)
  [~,~,~] = load_permutation_results(...
    regularization,P(i).structure,sim_source,sim_metric,P(i).modality,type, ...
    'resultsroot',results_root,'write',toWrite,'orientation','orig',...
    'writecv',WRITE_CV);
  [~,~,~] = load_final_results(...
    regularization,P(i).structure,sim_source,sim_metric,P(i).modality,type, ...
    'resultsroot',results_root,'write',toWrite,'orientation','orig',...
    'writecv',WRITE_CV);
end
%%

fields = {'subject','cvholdout','lambda','lambda1','LambdaSeq','regularization','normalize','nzv','err1','err2','nvox','RandomSeed'};
csv_file = sprintf('%s_%s_%s_%s_%s_%s_perm.csv', ...
    regularization, structure, type, sim_source, sim_metric, modality); 
WriteTable(csv_file, Avg, 'fields', fields,'overwrite',0);

%%
toWrite = {'l2norm'};
writeCSV = 0;
%toWrite = {};
[Results,Avg,Params] = load_final_results(regularization,structure,sim_source,sim_metric,modality,type,'resultsroot',results_root,'write',toWrite,'writecv',WRITE_CV);
fields = {'subject','cvholdout','lambda','lambda1','LambdaSeq','regularization','normalize','nzv','err1','err2','nvox'};
csv_file = sprintf('%s_%s_%s_%s_%s_%s_final.csv', ...
    regularization, structure, type, sim_source, sim_metric, modality); 
WriteTable(csv_file, Avg, 'fields', fields,'overwrite',0);
