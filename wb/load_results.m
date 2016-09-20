function [AllResults,Avg,Params] = load_results(RESULT_DIR,SOLUTION_DIR,DATA_DIR,COND_FILE,META_FILE,TRIAL_MODALITY,WRITE,FLAG_WRITECV,ORIENTATION,CountRadius)
  % Load metadata
  load(fullfile(DATA_DIR,META_FILE));
  disp(RESULT_DIR)
  seedHoldSubj = csvread(fullfile(RESULT_DIR,COND_FILE));
  
  if size(seedHoldSubj, 2) < 3
    tmp = zeros(size(seedHoldSubj,1),3);
    a = 3 - size(seedHoldSubj,2) + 1;
    tmp(:,a:end) = seedHoldSubj;
    seedHoldSubj = tmp;
  end

  % Filter coordinates
  nSubj = numel(metadata);
  XYZ = cell(nSubj,1);
  for iSubj = 1:nSubj
      % Select column filter
      z = [metadata(iSubj).filters.dimension] == 2;
%      z = z & strcmp(TRIAL_MODALITY, {metadata(iSubj).filters.subset});
      switch TRIAL_MODALITY
      case 'visual'
        z1 = z & strcmp('colfilter_vis', {metadata(iSubj).filters.label});
      case 'audio'
        z1 = z & strcmp('colfilter_aud', {metadata(iSubj).filters.label});
      case 'audvis'
        z1 = z & strcmp('colfilter_audvis', {metadata(iSubj).filters.label});
      case 'average'
        z1 = z & strcmp('colfilter_sem', {metadata(iSubj).filters.label});
      end
      colfilter = metadata(iSubj).filters(z1).filter;

      % Select coordinates
      z1 = strcmpi({metadata(iSubj).coords.orientation},ORIENTATION);
      XYZ{iSubj} = metadata(iSubj).coords(z1).xyz(colfilter,:);
  end

  %% Load Results
  % There are too many permutations to load them all comfortably at once.
  % Load and process in small batches.
  subject = unique(seedHoldSubj(:,3));
  cvHoldout = unique(seedHoldSubj(:,2));
  randomSeed = unique(seedHoldSubj(:,1));
  
  nHoldout = numel(cvHoldout);

  [x,y] = ndgrid(randomSeed,subject);
  conds = [x(:),y(:)]; clear x y
  nCond = size(conds,1);
  Avg(nCond) = struct('W',[],'nodestrength',[],'nzVoxelIndex',[], ...
      'nVoxel',0,'err1',0,'err2',0,'subject',0,'RandomSeed',0);

  if ~exist(SOLUTION_DIR,'dir')
    mkdir(SOLUTION_DIR);
  end

  tmp = dir(RESULT_DIR);
  tmp = cellfun(@(x) regexp(x, '^[0-9]+$','match','once'), {tmp.name}, 'Unif', 0);
  fullJobList = tmp(~cellfun(@isempty, tmp));
  [a,b] = deal(0);
  for iCond = 1:nCond
    fprintf('Batch %d of %d\n',iCond,size(conds,1));
    r = conds(iCond,1);
    s = conds(iCond,2);
    z = seedHoldSubj(:,1) == r;
    z = z & (seedHoldSubj(:,3) == s);
    jobList = fullJobList(z);
    disp(jobList)
    [Params,Results] = HTCondorLoad(RESULT_DIR,'JobList',jobList,'quiet',true);
    if iCond == 1
      fnames = fieldnames(Results)';
      tmp = [fnames;cell(1,numel(fnames))];
      AllResults(numel(fullJobList)) = struct(tmp{:});
    end
    a = b + 1;
    b = b + numel(Results);
    AllResults(a:b) = Results;
    z = [Results.subject]>0;
    Results = Results(z);
    Params = Params(z);
    nResults = numel(Results);

    bias_is_nz = false(1,numel(Results));
    if ~isfield(Results,'nz_rows') || all(cellfun(@isempty,{Results.nz_rows}, 'unif', 1))
      for iR = 1:numel(Results)
        s = Results(iR).subject;
        Uix = Results(iR).Uix;
        nvox = size(XYZ{s},1);
        if any(Uix>nvox)
          bias_is_nz(iR) = 1;
          Uix = Uix(Uix <= nvox);
        end
        Results(iR).nz_rows = false(nvox,1);
        Results(iR).nz_rows(Uix) = 1;
        Results(iR).Uix = Uix;
      end
    else
      for iR = 1:numel(Results)
        s = Results(iR).subject;
        nvox = size(XYZ{s},1);
        nz_rows = Results(iR).nz_rows;
        if numel(nz_rows) > nvox
          bias_is_nz(iR) = 1;
          Results(iR).nz_rows = nz_rows(1:nvox);
        end
      end
    end
    if ~isfield(Results,'Uix') || all(cellfun(@isempty,{Results.Uix}, 'unif', 1)) 
      for iR = 1:numel(Results)
        s = Results(iR).subject;
        nz_rows = Results(iR).nz_rows;
        nvox = size(XYZ{s},1);
        if numel(nz_rows) > nvox
          bias_is_nz(iR) = 1;
          nz_rows = nz_rows(1:nvox);
        end
        Results(iR).Uix = find(nz_rows);
        Results(iR).nz_rows = nz_rows;
      end
    else
      for iR = 1:numel(Results)
        s = Results(iR).subject;
        Uix = Results(iR).Uix;
        nvox = size(XYZ{s},1);
        if any(Uix > nvox)
          bias_is_nz(iR) = 1;
          Results(iR).Uix = Uix(Uix <= nvox);
        end
      end
    end
    
    for iR = 1:numel(Results)
      if bias_is_nz(iR)
        Results(iR).Uz = Results(iR).Uz(1:end-1,:);
      end
    end
      
    nzv = any([Results.nz_rows], 2);

    if any([Params.SmallFootprint] == 0)
        if numel(nzv) ~= size(XYZ{s},1)
            disp('skipping...')
            disp([numel(nzv),size(XYZ{s},1)])
            continue
        end
        nzvIndex = find(nzv);
        W = zeros(sum(nzv));
        U = zeros(sum(nzv),size(Results(1).Uz,2));
        [dg,dv,l2n,ns] = deal(zeros(sum(nzv), 1));
        Uc = cell(1, nResults);
        for iR = 1:nResults
            Uc{iR} = zeros(numel(nzvIndex), size(Results(iR).Uz,2));
            [~,ix] = ismember(Results(iR).Uix,nzvIndex);
            try
              Uc{iR}(ix,:) = Results(iR).Uz;
            catch ME
              Uc{iR}(ix,:) = Results(iR).Uz(Results(iR).nz_rows,:);
            end
        end

        for iHoldout = 1:numel(cvHoldout)
            h = cvHoldout(iHoldout);
            c = [Results.cvholdout];
            cp = [Params.cvholdout];
            c(cp>0) = cp(cp>0);

            z1 = c == h; if ~any(z1); continue; end

            nzv1 = Results(z1).nz_rows;

            Results(z1).xyz = XYZ{s}(nzv1,:);
            if any(z1)
              u = Uc{z1}; %(nzv,:);
              U = U + u;
              w = u*u';
              W = W + w;
              
              dg = dg + sum(abs(w)>0, 2);
              dv = dv + diag(w);
              l2n = l2n + sum(sqrt(u.^2), 2);
              ns = ns + sum(abs(w), 2);
            end
        end
        z = any(W);
        stability = sum([Results.nz_rows],2);
        stability = stability(stability>0);
        
        Avg(iCond).W = W(z,z) / nResults;
        Avg(iCond).U = U(z,:) / nResults;
        Avg(iCond).degree = dg(:) / nResults;
        Avg(iCond).diagonal_value = dv / nResults;
        Avg(iCond).l2norm = l2n(:) / nResults;
        Avg(iCond).nodestrength = ns(:) / nResults;
        Avg(iCond).stability = stability;
        Avg(iCond).xyz = XYZ{s}(nzvIndex(z),:);
        Avg(iCond).nzVoxelIndex = nzvIndex(z);
        Avg(iCond).nVoxel = numel(nzv);
    end

      
    Avg(iCond).err1 = mean([Results.err1]);
    Avg(iCond).err2 = mean([Results.err2]);
    Avg(iCond).subject = s;
    Avg(iCond).RandomSeed = r;

    for iWrite = 1:numel(WRITE)
      output_code = lower(WRITE{iWrite});
      switch output_code
      case 'nodestrength'
        if ~exist(fullfile(SOLUTION_DIR, output_code),'dir')
          mkdir(fullfile(SOLUTION_DIR, output_code));
          mkdir(fullfile(SOLUTION_DIR, output_code,'cv'));
        end
        % Write Node Strength
        % ===================
        % Average
        % -------
        if Avg(iCond).RandomSeed
          filename = sprintf('%03d_%02d.%s', Avg(iCond).RandomSeed, Avg(iCond).subject, ORIENTATION);
        else
          filename = sprintf('%02d.%s', Avg(iCond).subject, ORIENTATION);
        end
        filepath = fullfile(SOLUTION_DIR, output_code, filename);
        d = [Avg(iCond).xyz,Avg(iCond).nodestrength];
        dlmwrite(filepath, d, ' ');
        % CV
        % ---
        if FLAG_WRITECV
            for iHoldout = 1:numel(cvHoldout)
              h = cvHoldout(iHoldout);
              c = [Results.cvholdout];
              if max(c) == 10 || min(c) == 2;
                  c = c - 1;
              end
              z1 = c == h; if ~any(z1); continue; end

              nzv1 = Results(z1).nz_rows;
              if abs(size(Results(z1).Uz,1) - numel(nzv1)) < 2
                U = Results(z1).Uz(nzv1,:);
              else
                U = Results(z1).Uz;
              end
              W = (U*U');

              if Avg(iCond).RandomSeed
                filename = sprintf('%03d_%02d_%02d.%s', r, Results(z1).subject, iHoldout, ORIENTATION);
              else
                filename = sprintf('%02d_%02d.%s', Results(z1).subject, iHoldout, ORIENTATION);
              end
              filepath = fullfile(SOLUTION_DIR, output_code, 'cv', filename);
              d = [Results(z1).xyz, sum(abs(W),2)];
              dlmwrite(filepath, d, ' ');
            end
        end
        
      case 'l2norm'
        if ~exist(fullfile(SOLUTION_DIR, output_code),'dir')
          mkdir(fullfile(SOLUTION_DIR, output_code));
          mkdir(fullfile(SOLUTION_DIR, output_code,'cv'));
        end
        % Write Node Strength
        % ===================
        % Average
        % -------
        if Avg(iCond).RandomSeed
          filename = sprintf('%03d_%02d.%s', Avg(iCond).RandomSeed, Avg(iCond).subject, ORIENTATION);
        else
          filename = sprintf('%02d.%s', Avg(iCond).subject, ORIENTATION);
        end
        filepath = fullfile(SOLUTION_DIR, output_code, filename);
        d = [Avg(iCond).xyz,Avg(iCond).l2norm];
        dlmwrite(filepath, d, ' ');
        % CV
        % ---
        if FLAG_WRITECV
            for iHoldout = 1:numel(cvHoldout)
              h = cvHoldout(iHoldout);
              c = [Results.cvholdout];
              if max(c) == 10 || min(c) == 2;
                  c = c - 1;
              end
              z1 = c == h; if ~any(z1); continue; end

              nzv1 = Results(z1).nz_rows;
              if abs(size(Results(z1).Uz,1) - numel(nzv1)) < 2
                U = Results(z1).Uz(nzv1,:);
              else
                U = Results(z1).Uz;
              end
              l2norm = sqrt(sum(U.^2, 2));
              if Avg(iCond).RandomSeed
                filename = sprintf('%03d_%02d_%02d.%s', r, Results(z1).subject, iHoldout, ORIENTATION);
              else
                filename = sprintf('%02d_%02d.%s', Results(z1).subject, iHoldout, ORIENTATION);
              end
              filepath = fullfile(SOLUTION_DIR, output_code, 'cv', filename);
              xyz = XYZ{Results(z1).subject}(Results(z1).nz_rows,:);
              d = [xyz, l2norm];
              dlmwrite(filepath, d, ' ');
            end
        end
        
      case 'stability'
        if ~exist(fullfile(SOLUTION_DIR, output_code),'dir')
          mkdir(fullfile(SOLUTION_DIR, output_code));
          mkdir(fullfile(SOLUTION_DIR, output_code,'cv'));
        end
        % Write Stability
        % ===================
        % Average --- this is the only thing that makes sense/is possible.
        % -------
        if Avg(iCond).RandomSeed
          filename = sprintf('%03d_%02d.%s', Avg(iCond).RandomSeed, Avg(iCond).subject, ORIENTATION);
        else
          filename = sprintf('%02d.%s', Avg(iCond).subject, ORIENTATION);
        end
        filepath = fullfile(SOLUTION_DIR, output_code, filename);
        d = [Avg(iCond).xyz,Avg(iCond).stability];
        dlmwrite(filepath, d, ' ');

      case 'degree'
        if ~exist(fullfile(SOLUTION_DIR, output_code),'dir')
          mkdir(fullfile(SOLUTION_DIR, output_code));
          mkdir(fullfile(SOLUTION_DIR, output_code,'cv'));
        end
        % Write Node Strength
        % ===================
        % Average
        % -------
        if Avg(iCond).RandomSeed
          filename = sprintf('%03d_%02d.%s', Avg(iCond).RandomSeed, Avg(iCond).subject, ORIENTATION);
        else
          filename = sprintf('%02d.%s', Avg(iCond).subject, ORIENTATION);
        end
        filepath = fullfile(SOLUTION_DIR, output_code, filename);
        d = [Avg(iCond).xyz,Avg(iCond).degree];
        dlmwrite(filepath, d, ' ');
        % CV
        % ---
        if FLAG_WRITECV
            for iHoldout = 1:numel(cvHoldout)
              h = cvHoldout(iHoldout);
              c = [Results.cvholdout];
              if max(c) == 10 || min(c) == 2;
                  c = c - 1;
              end
              z1 = c == h; if ~any(z1); continue; end

              nzv1 = Results(z1).nz_rows;
              if size(Results(z1).Uz,1) == numel(nzv1)
                U = Results(z1).Uz(nzv1,:);
              else
                U = Results(z1).Uz;
              end
              W = (U*U');

              if Avg(iCond).RandomSeed
                filename = sprintf('%03d_%02d_%02d.%s', r, Results(z1).subject, iHoldout, ORIENTATION);
              else
                filename = sprintf('%02d_%02d.%s', Results(z1).subject, iHoldout, ORIENTATION);
              end
              filepath = fullfile(SOLUTION_DIR, output_code, 'cv', filename);
              xyz = XYZ{Results(z1).subject}(Results(z1).nz_rows,:);
              d = [xyz, sum(abs(W),2)];
%              d = [Results(z1).xyz, sum(abs(W),2)];
              dlmwrite(filepath, d, ' ');
            end
        end

      case 'ksstat'
        % Write Diagonal Value
        % ====================
        if ~exist(fullfile(SOLUTION_DIR, output_code),'dir')
          mkdir(fullfile(SOLUTION_DIR, output_code));
          mkdir(fullfile(SOLUTION_DIR, output_code,'cv'));
        end
        % Average
        % -------
        if Avg(iCond).RandomSeed
          filename = sprintf('%03d_%02d.%s', Avg(iCond).RandomSeed, Avg(iCond).subject, ORIENTATION);
        else
          filename = sprintf('%02d.%s', Avg(iCond).subject, ORIENTATION);
        end
        filepath = fullfile(SOLUTION_DIR, output_code, filename);
        d = [Avg(iCond).xyz,Avg(iCond).diagonal_value];
        dlmwrite(filepath, d, ' ');
        % CV
        % ---
        if FLAG_WRITECV
            for iHoldout = 1:numel(cvHoldout)
              h = cvHoldout(iHoldout);
              c = [Results.cvholdout];
              if max(c) == 10 || min(c) == 2;
                  c = c - 1;
              end
              z1 = c == h; if ~any(z1); continue; end

              nzv1 = Results(z1).nz_rows;
              if abs(size(Results(z1).Uz,1) - numel(nzv1)) < 2
                U = Results(z1).Uz(nzv1,:);
              else
                U = Results(z1).Uz;
              end
              
              W = (U*U');

              if Avg(iCond).RandomSeed
                filename = sprintf('%03d_%02d_%02d.%s', r, Results(z1).subject, iHoldout, ORIENTATION);
              else
                filename = sprintf('%02d_%02d.%s', Results(z1).subject, iHoldout, ORIENTATION);
              end
              filepath = fullfile(SOLUTION_DIR, output_code, 'cv', filename);
              xyz = XYZ{Results(z1).subject}(Results(z1).nz_rows,:);
              d = [xyz, diag(W)];
              %d = [Results(z1).xyz, diag(W)];
              dlmwrite(filepath, d, ' ');
            end
        end

      case 'selectioncount'
        if ~exist(fullfile(SOLUTION_DIR, output_code),'dir')
          mkdir(fullfile(SOLUTION_DIR, output_code));
          mkdir(fullfile(SOLUTION_DIR, output_code,'cv'));
        end
        % Write Selection Searchlight
        % ===========================
        % Average
        % -------
        SearchlightCounts = sum(pdist2(Avg(iCond).xyz,XYZ{s})<CountRadius);
        z = SearchlightCounts > 0;

        if Avg(iCond).RandomSeed
          filename = sprintf('%03d_%02d.%s', Avg(iCond).RandomSeed, Avg(iCond).subject, ORIENTATION);
        else
          filename = sprintf('%02d.%s', Avg(iCond).subject, ORIENTATION);
        end
        filepath = fullfile(SOLUTION_DIR, output_code, filename);
        d = [XYZ{s}(z,:), SearchlightCounts(z)'];
        dlmwrite(filepath, d, ' ');
        % CV
        % ---
        if FLAG_WRITECV
            for iHoldout = 1:numel(cvHoldout)
              h = cvHoldout(iHoldout);
              c = [Results.cvholdout];
              if max(c) == 10 || min(c) == 2;
                  c = c - 1;
              end
              z1 = c == h; if ~any(z1); continue; end

              if Avg(iCond).RandomSeed
                filename = sprintf('%03d_%02d_%02d.%s', r, Results(z1).subject, iHoldout, ORIENTATION);
              else
                filename = sprintf('%02d_%02d.%s', Results(z1).subject, iHoldout, ORIENTATION);
              end
              filepath = fullfile(SOLUTION_DIR, output_code, 'cv', filename);
              SearchlightCounts = sum(pdist2(Results(z1).xyz,XYZ{s})<CountRadius);
              z = SearchlightCounts > 0;
              d = [XYZ{s}(z,:), SearchlightCounts(z)'];
              dlmwrite(filepath, d, ' ');
            end
        end
      end
    end
  end
end
