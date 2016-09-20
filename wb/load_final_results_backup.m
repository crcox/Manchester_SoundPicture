function [Results,Avg,Params] = load_final_results(regularization,structure,modality,type,varargin)
  p = inputParser();
  p.CaseSensitive = 0;
  p.FunctionName = 'load_permutation_results';
  p.KeepUnmatched = 0;
  p.PartialMatching = 1;
  p.StructExpand = 0;
  addRequired(p, 'regularization');
  addRequired(p, 'structure');
  addRequired(p, 'modality');
  addRequired(p, 'type');
  addParameter(p, 'write',[],@iscellstr);
  addParameter(p, 'writecv',0,@isbool);
  addParameter(p, 'metafile','metadata_new.mat', @ischar);
  addParameter(p, 'parameterselectionmethod', [], @ischar);
  addParameter(p, 'datadir', '~/MRI/Manchester/data/avg', @ischar);
  addParameter(p, 'resultsroot', '~/MRI/Manchester/results/WholeBrain_RSA', @ischar);
  addParameter(p, 'countradius',6, @isscalar);
  parse(p,regularization,structure,modality,type,varargin{:});

  REGULARIZATION = lower(p.Results.regularization);
  TARGET_STRUCTURE = lower(p.Results.structure);
  TARGET_TYPE = lower(p.Results.type);
  TRIAL_MODALITY = lower(p.Results.modality);
  PARAM_SELECTION = lower(p.Results.parameterselectionmethod);
  DATA_DIR = p.Results.datadir;
  RESULT_ROOT = p.Results.resultsroot;
  META_FILE = p.Results.metafile;
  WRITE = p.Results.write;
  CountRadius = p.Results.countradius;

  % Set constants
  COND_FILE = 'holdout_subject.csv';
  file_pieces = squeeze({RESULT_ROOT,...
    TARGET_STRUCTURE,TARGET_TYPE,TRIAL_MODALITY,REGULARIZATION,'final',PARAM_SELECTION});
  RESULT_DIR = fullfile(file_pieces{:});
  SOLUTION_DIR = fullfile(RESULT_DIR,'solutionmaps','txt');

  % Load metadata
  load(fullfile(DATA_DIR,META_FILE));
  holdSubj = csvread(fullfile(RESULT_DIR,COND_FILE));

  % Filter coordinates
  nSubj = numel(metadata);
  XYZ = cell(nSubj,1);
  for iSubj = 1:nSubj
      % Select column filter
      z = [metadata(iSubj).filters.dimension] == 2;
%      z = z & strcmp(TRIAL_MODALITY, {metadata(iSubj).filters.subset});
      switch modality
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
  subject = unique(holdSubj(:,2));
  conds = subject;
  cvHoldout = unique(holdSubj(:,1));
  nHoldout = numel(cvHoldout);

  nSubj = numel(subject);
  Avg(nSubj) = struct('W',[],'nodestrength',[],'nzVoxelIndex',[], ...
      'nVoxel',0,'err1',0,'err2',0,'subject',0);

  if ~exist(SOLUTION_DIR,'dir')
    mkdir(SOLUTION_DIR);
  end

  for iSubj = 1:nSubj
    fprintf('Batch %d of %d\n',iSubj,size(conds,1));
    s = conds(iSubj,1);
    z = holdSubj(:,2) == s;
    jobList = arrayfun(@(d) sprintf('%03d',d), find(z)-1, 'UniformOutput', false);
    [Params,Results] = HTCondorLoad(RESULT_DIR,'JobList',jobList,'quiet',true);
    z = [Results.subject]>0;
    if all(cellfun(@isempty,{Results.nz_rows}, 'unif', 1))
      for iR = 1:numel(Results)
        Results(iR).nz_rows = false(Results(iR).nvox,1);
        Results(iR).nz_rows(Results(iR).Uix) = 1;
      end
    end
    Results = Results(z);
    Params = Params(z);
    nResults = numel(Results);
    nzv = any([Results.nz_rows], 2);
    
    if any([Params.SmallFootprint] == 0)
        if all([Params.bias])
            nzv = nzv(1:end-1);
        end
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
            Uc{iR}(ix,:) = Results(iR).Uz;
        end
    
        for iHoldout = 1:numel(cvHoldout)
            h = cvHoldout(iHoldout);
            c = [Results.cvholdout];
            if max(c) == 10 || min(c) == 2;
                c = c - 1;
            end
            z1 = c == h; if ~any(z1); continue; end

            nzv1 = Results(z1).nz_rows;
            if all([Params.bias])
                nzv1(end) = 0;
            end

            Results(z1).xyz = XYZ{s}(nzv1,:);
            if any(z1)
                U = Results(z1).Uz;
                W = W + (Uc{z1}*Uc{z1}');
                Results(z1).nodestrength = sum(abs(U*U'))';
                Results(z1).xyz = XYZ{s}(Results(z1).nz_rows(1:end-1),:);
                Results(z1).nzVoxelIndex = find(Results(z1).nz_rows(1:end-1));
            end
        end
        Avg(iSubj).W = W / nResults;
        ns = sum(abs(Avg(iSubj).W));
        dv = diag(Avg(iSubj).W);
        Avg(iSubj).nodestrength = ns(:);
        Avg(iSubj).diagonal_value = dv;
        Avg(iSubj).xyz = XYZ{s}(nzvIndex,:);
        Avg(iSubj).nzVoxelIndex = nzvIndex;
        Avg(iSubj).nVoxel = numel(nzv);
    end
    if exist('ResultsAll','var')
        ResultsAll = [ResultsAll,Results];
    else
        ResultsAll = Results;
    end

    Avg(iSubj).err1 = mean([Results.err1]);
    Avg(iSubj).err2 = mean([Results.err2]);
    Avg(iSubj).subject = s;

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
        filename = sprintf('%02d.mni',  Avg(iSubj).subject);
        filepath = fullfile(SOLUTION_DIR, output_code, filename);
        d = [Avg(iSubj).xyz,Avg(iSubj).nodestrength];
        dlmwrite(filepath, d, ' ');
        % CV
        % ---
        for iHoldout = 1:numel(cvHoldout)
          h = cvHoldout(iHoldout);
          c = [Results.cvholdout];
          if max(c) == 10 || min(c) == 2;
              c = c - 1;
          end
          z1 = c == h; if ~any(z1); continue; end

          nzv1 = Results(z1).nz_rows;
          if all([Params.bias])
              nzv1 = nzv1(1:end-1);
          end
          U = Results(z1).Uz;
          W = (U*U');

          filename = sprintf('%02d_%02d.mni', Results(z1).subject, iHoldout);
          filepath = fullfile(SOLUTION_DIR, output_code, 'cv', filename);
          d = [Results(z1).xyz, sum(abs(W),2)];
          dlmwrite(filepath, d, ' ');
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
        filename = sprintf('%02d.mni', Avg(iSubj).subject);
        filepath = fullfile(SOLUTION_DIR, output_code, filename);
        d = [Avg(iSubj).xyz,Avg(iSubj).diagonal_value];
        dlmwrite(filepath, d, ' ');
        % CV
        % ---
        for iHoldout = 1:numel(cvHoldout)
          h = cvHoldout(iHoldout);
          c = [Results.cvholdout];
          if max(c) == 10 || min(c) == 2;
              c = c - 1;
          end
          z1 = c == h; if ~any(z1); continue; end

          nzv1 = Results(z1).nz_rows;
          if all([Params.bias])
              nzv1 = nzv1(1:end-1);
          end
          U = Results(z1).Uz(nzv1,:);
          W = (U*U');

          filename = sprintf('%02d_%02d.mni', Results(z1).subject, iHoldout);
          filepath = fullfile(SOLUTION_DIR, output_code, 'cv', filename);
          d = [Results(z1).xyz, diag(W)];
          dlmwrite(filepath, d, ' ');
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
        SearchlightCounts = sum(pdist2(Avg(iSubj).xyz,XYZ{s})<CountRadius);
        z = SearchlightCounts > 0;

        filename = sprintf('%02d.mni', Avg(iSubj).subject);
        filepath = fullfile(SOLUTION_DIR, output_code, filename);
        d = [XYZ{s}(z,:), SearchlightCounts(z)'];
        dlmwrite(filepath, d, ' ');
        % CV
        % ---
        for iHoldout = 1:numel(cvHoldout)
          h = cvHoldout(iHoldout);
          c = [Results.cvholdout];
          if max(c) == 10 || min(c) == 2;
              c = c - 1;
          end
          z1 = c == h; if ~any(z1); continue; end
          filename = sprintf('%02d_%02d.mni', Results(z1).subject, iHoldout);
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

function b = isbool(x)
  if islogical(x) || any(x==[0,1])
    b = 1;
  else
    b = 0;
  end
end
