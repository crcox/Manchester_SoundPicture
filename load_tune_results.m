function [Results,Avg,Params] = load_tune_results(regularization,structure,sim_source,sim_metric,modality,type,varargin)
  p = inputParser();
  p.CaseSensitive = 0;
  p.FunctionName = 'load_tune_results';
  p.KeepUnmatched = 0;
  p.PartialMatching = 1;
  p.StructExpand = 0;
  addRequired(p, 'regularization');
  addRequired(p, 'structure');
  addRequired(p, 'sim_source');
  addRequired(p, 'sim_metric');
  addRequired(p, 'modality');
  addRequired(p, 'type');
  addParameter(p, 'write',[],@iscellstr);
  addParameter(p, 'writecv',0,@isbool);
  addParameter(p, 'orientation','mni', @ischar);
  addParameter(p, 'metafile','metadata_new.mat', @ischar);
  addParameter(p, 'datadir', '~/MRI/Manchester/data/avg', @ischar);
  addParameter(p, 'resultsroot', '~/MRI/Manchester/results/WholeBrain_RSA', @ischar);
  addParameter(p, 'countradius',6, @isscalar);
  parse(p,regularization,structure,sim_source,sim_metric,modality,type,varargin{:});

  REGULARIZATION = lower(p.Results.regularization);
  TARGET_STRUCTURE = lower(p.Results.structure);
  TARGET_TYPE = lower(p.Results.type);
  SIM_SOURCE = p.Results.sim_source;
  SIM_METRIC = p.Results.sim_metric;
  TRIAL_MODALITY = lower(p.Results.modality);
  DATA_DIR = p.Results.datadir;
  RESULT_ROOT = p.Results.resultsroot;
  META_FILE = p.Results.metafile;
  COORD_ORIENT = p.Results.orientation;
  WRITE = p.Results.write;
  FLAG_WRITECV = p.Results.writecv;
  CountRadius = p.Results.countradius;

  % Set constants
  COND_FILE = [];
  file_pieces = squeeze({RESULT_ROOT,...
    TARGET_STRUCTURE,TARGET_TYPE,SIM_SOURCE,SIM_METRIC,TRIAL_MODALITY, ...
    REGULARIZATION,'tune'});
  RESULT_DIR = fullfile(file_pieces{:});
  SOLUTION_DIR = fullfile(RESULT_DIR,'solutionmaps','txt');
  
  [Results,Avg,Params] = load_results_tmp(RESULT_DIR,SOLUTION_DIR,DATA_DIR,COND_FILE,META_FILE,TRIAL_MODALITY,COORD_ORIENT,WRITE,FLAG_WRITECV,CountRadius);
end

function b = isbool(x)
  if islogical(x) || any(x==[0,1])
    b = 1;
  else
    b = 0;
  end
end
