function [] = gammafit(permfile,meanfile,statfile)
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
  shapefile = fullfile(spath,sprintf('%s.shape%s',sfile,sext));
  scalefile = fullfile(spath,sprintf('%s.scale%s',sfile,sext));

  [nvox,nperm] = size(p);
  params = zeros(nvox,2);
  pvals = zeros(nvox,1);
  warning('off','stats:gamfit:ZerosInData');
  for i = 1:nvox
    params(i,:) = gamfit(p(i,:));
    pvals(i) = gampdf(m(i,1),params(i,1), params(i,2));
  end
  warning('on','stats:gamfit:ZerosInData');
  dlmwrite(statfile,[ijk,pvals],' ');
  dlmwrite(shapefile,[ijk,params(:,1)],' ');
  dlmwrite(scalefile,[ijk,params(:,2)],' ');
end
