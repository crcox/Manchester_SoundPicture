addpath('~/src/WholeBrain_RSA/src');

sep = 1:10;
nd = 5:5:50;
dim = 2:8;
X = zeros(numel(dim),numel(nd),100);
for p = 1:100
  for i = 1:numel(dim)
    for j = 1:numel(nd)
      x = [mvnrnd(zeros(1,dim(i)),eye(dim(i)),100-nd(j));mvnrnd(ones(1,dim(i))*5, eye(dim(i)),nd(j))];
      m = mean(x);
      X(i,j,p) = norm(bsxfun(@minus,x,m),'fro')/norm(x,'fro');
    end
  end
end
disp(mean(X,3));



scatter(x(:,1),x(:,2));
hold on
scatter(m(1),m(2));
hold off

