%% Setup IJK
[i,j,k] = ndgrid(1:10,1:10,1:10);
ijk = [i(:),j(:),k(:)];

%% Test GammaFit
pg = gamrnd(2,1,1000,100); % shape, scale, nvox, nperm
mg = max(gamrnd(2,1,1000,100),[],2); % from a separate random distribution, take the max val over perms.
dlmwrite('pg.txt',[ijk,zeros(1000,1),pg],' '); % test that gamma fit is robust to zero values.
dlmwrite('mg.txt',[ijk,mg],' ');
gammafit('pg.txt','mg.txt','sg.txt'); % input,input,output (function will write output to this filename).

%% Test PoissonFit
pp = poissrnd(2,1000,100); % lambda, nvox, nperm
mp = max(poissrnd(2,1000,100),[],2); % from a separate random distribution, take the max val over perms.
dlmwrite('pp.txt',[ijk,pg],' ');
dlmwrite('mp.txt',[ijk,mg],' ');
poissonfit('pp.txt','mp.txt','sp.txt'); % input,input,output (function will write output to this filename).
