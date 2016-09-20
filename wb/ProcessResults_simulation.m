addpath('~/src/WholeBrain_RSA/util');
addpath('~/src/WholeBrain_RSA/dependencies/jsonlab');
results_root = '/home/chris/MRI/Manchester/results/WholeBrain_RSA/simulation';
WRITE_CV = 0;
%%
toWrite = {};
[Results,Avg,Params] = load_tune_results([],[],[],[],[],[],'resultsroot',results_root,'write',toWrite,'writecv',WRITE_CV);
fields = {'subject','finalholdout','cvholdout','lambda','lambda1','LambdaSeq','regularization','normalize','nzv','err1','err2','nvox','RandomSeed'};
csv_file = sprintf('%s_%s_%s_%s_%s_%s_tune.csv', ...
    regularization, structure, type, sim_source, sim_metric, modality); 
WriteTable(csv_file, Results, 'fields', fields);

%%
toWrite = {'stability'};
%toWrite = {};
[Results,Avg,Params] = load_permutation_results(regularization,structure,sim_source,sim_metric,modality,type,'resultsroot',results_root,'write',toWrite,'writecv',WRITE_CV);
fields = {'subject','cvholdout','lambda','lambda1','LambdaSeq','regularization','normalize','nzv','err1','err2','nvox','RandomSeed'};
csv_file = sprintf('%s_%s_%s_%s_%s_%s_perm.csv', ...
    regularization, structure, type, sim_source, sim_metric, modality); 
WriteTable(csv_file, Avg, 'fields', fields,'overwrite',0);

%%
toWrite = {'stability'};
writeCSV = 0;
%toWrite = {};
[Results,Avg,Params] = load_final_results(regularization,structure,sim_source,sim_metric,modality,type,'resultsroot',results_root,'write',toWrite,'writecv',WRITE_CV);
fields = {'subject','cvholdout','lambda','lambda1','LambdaSeq','regularization','normalize','nzv','err1','err2','nvox'};
csv_file = sprintf('%s_%s_%s_%s_%s_%s_final.csv', ...
    regularization, structure, type, sim_source, sim_metric, modality); 
WriteTable(csv_file, Avg, 'fields', fields,'overwrite',0);