load('metadata_avg_new.mat');
vis = 1;
sem = 2;
e = zeros(9,2);

%% 
S = metadata(1).targets(3).target;
C = sqrt_truncate_r(S, 0.2);
c = metadata(1).cvind(:,1);

for i = 1:9
  t = c==i;
  e(i,vis) = norm(bsxfun(@minus,C(t,:),mean(C(~t,:))), 'fro') / norm(C(t,:), 'fro');
end

%% Semantic
S = metadata(1).targets(4).target;
C = sqrt_truncate_r(S, 0.3);
c = metadata(1).cvind(:,1);

for i = 1:9
  t = c==i; % test set
  e(i,sem) = norm(bsxfun(@minus,C(t,:),mean(C(~t,:))), 'fro') / norm(C(t,:), 'fro');
end

array2table(e, 'VariableNames', {'visual','semantic'})