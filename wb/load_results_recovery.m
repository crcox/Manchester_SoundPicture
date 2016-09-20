function [Results,Avg,Params] = load_results(RESULT_DIR,SOLUTION_DIR,DATA_DIR,COND_FILE,META_FILE,TRIAL_MODALITY,WRITE,FLAG_WRITECV,CountRadius)
  % Load metadata


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
      end
      colfilter = metadata(iSubj).filters(z1).filter;

      % Select coordinates
      z1 = strcmpi({metadata(iSubj).coords.orientation},'mni');
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
  for iCond = 190:nCond
    fprintf('Batch %d of %d\n',iCond,size(conds,1));
    r = conds(iCond,1);
    s = conds(iCond,2);
    z = seedHoldSubj(:,1) == r;
    z = z & (seedHoldSubj(:,3) == s);
    jobList = fullJobList(z);
    disp(jobList)
    [Params,Results] = HTCondorLoad(RESULT_DIR,'JobList',jobList,'quiet',true);
    z = [Results.subject]>0;
    Results = Results(z);
    Params = Params(z);
    nResults = numel(Results);
    
    if all(cellfun(@isempty,{Results.nz_rows}, 'unif', 1))
      for iR = 1:numel(Results)
        Results(iR).nz_rows = false(Results(iR).nvox,1);
        Results(iR).nz_rows(Results(iR).Uix) = 1;
      end
    end
    if ~isfield(Results,'Uix') || all(cellfun(@isempty,{Results.Uix}, 'unif', 1)) 
      for iR = 1:numel(Results)
        Results(iR).Uix = find(Results(iR).nz_rows);
      end
    end
    if all([Params.bias])
      for iR = 1:numel(Results)
        bias_is_nz = Results(iR).nz_rows(end);
        Results(iR).nz_rows = Results(iR).nz_rows(1:end-1);
        if bias_is_nz
          Results(iR).Uix = Results(iR).Uix(1:end-1);
        end
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
            if max(c) == 10 || min(c) == 2;
                c = c - 1;
            end
            z1 = c == h; if ~any(z1); continue; end

            nzv1 = Results(z1).nz_rows;

            Results(z1).xyz = XYZ{s}(nzv1,:);
            if any(z1)
%               if size(Results(z1).Uz,1) > Results(z1).nzv
%                 U = Results(z1).Uz(nzv,:);
%               else
%                 U = Results(z1).Uz;
%               end
              W = W + (Uc{z1}*Uc{z1}');
            end
        end
        Avg(iCond).W = W / nResults;
        ns = sum(abs(Avg(iCond).W));
        dv = diag(Avg(iCond).W);
        Avg(iCond).nodestrength = ns(:);
        Avg(iCond).diagonal_value = dv;
        Avg(iCond).xyz = XYZ{s}(nzvIndex,:);
        Avg(iCond).nzVoxelIndex = nzvIndex;
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
          filename = sprintf('%03d_%02d.mni', Avg(iCond).RandomSeed, Avg(iCond).subject);
        else
          filename = sprintf('%02d.mni', Avg(iCond).subject);
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
              if size(Results(z1).Uz,1) == numel(nzv1)
                U = Results(z1).Uz(nzv1,:);
              else
                U = Results(z1).Uz;
              end
              W = (U*U');

              if Avg(iCond).RandomSeed
                filename = sprintf('%03d_%02d_%02d.mni', r, Results(z1).subject, iHoldout);
              else
                filename = sprintf('%02d_%02d.mni', Results(z1).subject, iHoldout);
              end
              filepath = fullfile(SOLUTION_DIR, output_code, 'cv', filename);
              d = [Results(z1).xyz, sum(abs(W),2)];
              dlmwrite(filepath, d, ' ');
            end
        end

      case 'diagonalvalue'
        % Write Diagonal Value
        % ====================
        if ~exist(fullfile(SOLUTION_DIR, output_code),'dir')
          mkdir(fullfile(SOLUTION_DIR, output_code));
          mkdir(fullfile(SOLUTION_DIR, output_code,'cv'));
        end
        % Average
        % -------
        if Avg(iCond).RandomSeed
          filename = sprintf('%03d_%02d.mni', Avg(iCond).RandomSeed, Avg(iCond).subject);
        else
          filename = sprintf('%02d.mni', Avg(iCond).subject);
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
              if size(Results(z1).Uz,1) == numel(nzv1)
                U = Results(z1).Uz(nzv1,:);
              else
                U = Results(z1).Uz;
              end
              
              W = (U*U');

              if Avg(iCond).RandomSeed
                filename = sprintf('%03d_%02d_%02d.mni', r, Results(z1).subject, iHoldout);
              else
                filename = sprintf('%02d_%02d.mni', Results(z1).subject, iHoldout);
              end
              filepath = fullfile(SOLUTION_DIR, output_code, 'cv', filename);
              d = [Results(z1).xyz, diag(W)];
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
          filename = sprintf('%03d_%02d.mni', Avg(iCond).RandomSeed, Avg(iCond).subject);
        else
          filename = sprintf('%02d.mni', Avg(iCond).subject);
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
                filename = sprintf('%03d_%02d_%02d.mni', r, Results(z1).subject, iHoldout);
              else
                filename = sprintf('%02d_%02d.mni', Results(z1).subject, iHoldout);
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
