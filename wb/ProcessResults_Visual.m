addpath('~/src/WholeBrain_RSA/util');
addpath('~/src/WholeBrain_RSA/dependencies/jsonlab');
regularization = 'growl2';
structure = 'visual';
sim_source = 'chamfer';
sim_metric = [];
modality = 'visual';
type = 'similarity';

[Results,Avg,Params] = load_permutation_results(regularization,structure,sim_source,sim_metric,modality,type,'write',{'nodestrength','selectioncount'},'writecv',1);
%fields = {'subject','finalholdout','lambda','lambda1','LambdaSeq','regularization','normalize','nzv','err1','err2','nvox','RandomSeed'};
% WriteTable('growl2_sem_similarity_vis_perm.csv', Avg, 'fields', fields);

[Results,Avg,Params] = load_final_results(regularization,structure,sim_source,sim_metric,modality,type,'write',{'nodestrength','selectioncount'},'writecv',1);
% fields = {'subject','finalholdout','lambda','lambda1','LambdaSeq','regularization','normalize','nzv','err1','err2','nvox'};
% WriteTable('growl2_sem_similarity_vis_final.csv', Avg, 'fields', fields);