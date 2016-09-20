function [] = poissonfit(permfile,meanfile,statfile)
  p = dlmread(permfile,' ');
  p_ijk = p(:,1:3);
  p = p(:,4:end);
  m = dlmread(meanfile,' ');
  m_ijk = m(:,1:3);
  m = m(:,4:end);

  if isequal(m_ijk,p_ijk)
    ijk = m_ijk; clear m_ijk p_ijk;
  else
    error('The IJK coordinates in the permutation and mean files should be identical.');
  end

  [spath,sfile,sext] = fileparts(statfile);
  lambdafile = fullfile(spath,sprintf('%s.lambda%s',sfile,sext));

  [nvox,nperm] = size(p);
  params = zeros(nvox,1);
  pvals = zeros(nvox,1);
  for i = 1:nvox
    params(i,:) = poissfit(p(i,:));
    pvals(i) = poisspdf(m(i,1),params(i,1));
  end
  dlmwrite(statfile,[ijk,pvals],' ');
  dlmwrite(lambdafile,[ijk,params(:,1)],' ');
end
