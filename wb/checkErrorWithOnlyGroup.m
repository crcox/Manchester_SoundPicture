addpath('~/src/WholeBrain_RSA/src');

results_root = '/home/chris/MRI/Manchester/results/WholeBrain_RSA';
regularization = 'growl2';
structure = 'semantic';
type = 'similarity';
sim_source = 'featurenorms';
sim_metric = 'cosine';
modality = 'visual';
[params,results] = HTCondorLoad(RESULT_DIR);
results = reshape(results,23,9);
data_root = '/home/chris/MRI/Manchester/data/avg';
load(fullfile(data_root, 'metadata_avg_new.mat'));

%%
Yz = cell(1,23);
for j = 1:23
  filename = sprintf('s%02d_avg.mat',j);
  filepath = fullfile(data_root, filename);
  tmp = load(filepath,'visual');
  X = tmp.visual; clear tmp;
  S = metadata(j).targets(4).target;
  C = sqrt_truncate_r(S, 0.3);
  z = metadata(j).filters(2).filter;
  X = X(:,z);
  cvind = metadata(j).cvind(:,1);
  yz = zeros(size(X,1),size(C,2));
  if results(j,i).bias
    X = [X,ones(size(X,1),1)];
  end
  for i = 1:9
    l2norm = sqrt(sum(results(j,i).Uz.^2, 2));
    m = max(l2norm);
    z = round(l2norm, 8) == round(m, 8);
    yz(cvind==i,:) = X(cvind==i,z) * results(j,i).Uz(z,:);
  end
  Yz{j} = yz;
end
  
errfun = @(Cz) norm(C-Cz,'fro')/norm(C,'fro');
err_group = cellfun(errfun,Yz);


norm(C-Yz{1},'fro')/norm(C,'fro')