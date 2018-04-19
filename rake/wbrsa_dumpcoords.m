function [] = wbrsa_dumpcoords( resultfilelist, metric, coordtype, varargin)
    p = inputParser;
    p.KeepUnmatched = false;
    addRequired(p, 'resultfilelist');
    addRequired(p, 'metric');
    addRequired(p, 'coordtype');
    addParameter(p, 'by', {}, @iscellstr);
    addParameter(p, 'metadatafile', [], @ischar);

    parse(p, resultfilelist, metric, coordtype, varargin{:});

    resultfilelist = p.Results.resultfilelist;
    metric = p.Results.metric;
    coordtype = p.Results.coordtype;
    by = p.Results.by;
    metadatafile = p.Results.metadatafile;

    if ~any(strcmpi(metric,{'nodestrength','stability'}))
        error('Unrecognized metric "%s". Exiting...', metric);
    end
    if ~any(strcmpi(coordtype,{'orig','mni','tlrc'}))
        error('Unrecognized coordtype "%s". Exiting...', metric);
    end

    resultfiles = import_resultlist(resultfilelist);
    if ~iscell(resultfiles)
        if ischar(resultfiles)
            resultfiles = {resultfiles};
        else
            error('resultfiles must be a string or cell array of strings. Exiting...')
        end
    end

    PERM = 0;
    if isempty(by)
        fmt_c = cell(1,3);
        try
            tmp = dlmread('.RandomSeed.key');
            PERM = 1;
            if size(tmp,2) > 1
                tmp = reshape(permute(tmp,[2,1]), [], 1);
            end
            digits = max(nnz(max(tmp) >= 10.^(0:9)),2);
            fmt_c{1} = sprintf('%%0%dd',digits);
        end
        try
            tmp = dlmread('.subject.key');
            digits = max(nnz(max(tmp) >= 10.^(0:9)),2);
            fmt_c{2}= sprintf('%%0%dd',digits);
        end
        try
            tmp = dlmread('.cvholdout.key');
            digits = max(nnz(max(tmp) >= 10.^(0:9)),2);
            fmt_c{3}= sprintf('%%0%dd.%%s',digits);
        end
        if PERM
            fmt = strjoin(fmt_c,'_');
        else
            fmt = strjoin(fmt_c(2:3),'_');
        end
        dump_all(resultfiles, metadatafile, metric, coordtype, fmt, PERM);
    else
        fmt_c = cell(1,numel(by));
        PERM = strcmpi('RandomSeed',by);
        for i = 1:numel(by)
            tmp = dlmread(sprintf('.%s.key',by{i}));
            digits = max(nnz(max(tmp(:)) >= 10.^(0:9)),2);
            fmt_c{i} = sprintf('%%0%dd',digits);
        end
        fmt = strcat(strjoin(fmt_c,'_'),'.%s');
        dump_avg(resultfiles, metadatafile, metric, coordtype, fmt, by);
    end
end
function [] = dump_all(resultfiles, metadatafile, metric, coordtype, fmt, PERM)
    inc = {'Uz','Uix','coords','subject','cvholdout','bias','nz_rows'};
    outdir = fullfile('solutionmaps','txt',metric,'cv');
    load(metadatafile, 'metadata');
    fid = fopen('.colfilter.key','r');
    tmp = textscan(fid, '%s');
    cflist = tmp{1};
    fclose(fid);
    if ~exist(outdir, 'dir')
        mkdir(outdir)
    end
    for i = 1:numel(resultfiles)
        resultfile = resultfiles{i};
        r = load(resultfile,'results');
        fn = fieldnames(r.results);
        z = ~ismember(fn,inc);
        r = rmfield(r.results, fn(z));
        Uix = get_Uix(r);
        if any(r.bias) && ~issparse(r.Uz)
            Uz = r.Uz(1:end-1,:);
            if size(Uz,1) < max(Uix) || size(Uz,1) < numel(Uix)
                % Uix is assumed to be sorted
                Uix = reshape(Uix(1:end-1),[],1);
            end
        elseif issparse(r.Uz)
            Uz = full(r.Uz(any(r.Uz,2),:));
        end
        if size(Uz,1) > numel(Uix)
            Uz = Uz(Uix,:);
        end

        switch lower(metric)
            case 'nodestrength'
                v = sum(abs(Uz * Uz'));
            otherwise
                error('Unrecognized metric "%s". Exiting...', metric);
            end

            meta = metadata(r.subject);
            cfilter = get_colfilter(meta, cflist(i,:));
            z = strcmpi({meta.coords.orientation},coordtype);
            xyz = meta.coords(z).xyz(cfilter,:);
            xyz = xyz(Uix,:);
            %xyz = r.coords.xyz;
            if PERM
                outfile = sprintf(fmt,r.RandomSeed,r.subject,r.cvholdout,coordtype);
            else
                outfile = sprintf(fmt,r.subject,r.cvholdout,coordtype);
            end
            dlmwrite(fullfile(outdir,outfile), [xyz,v(:)], ' ');
        end
    end
function [] = dump_avg(resultfiles, ~, metric, coordtype, fmt, by)
    outdir = fullfile('solutionmaps','txt',metric);
%     load(metadatafile, 'metadata');
%     fid = fopen('.colfilter.key','r');
%     tmp = textscan(fid, '%s');
%     cflist = tmp{1};
%     fclose(fid);
    iiii = 0;
    %-----
    bycell = cell(numel(resultfiles),numel(by));
%     bycellc = cell(1,numel(by));
    for i = 1:numel(by)
        tmp = dlmread(sprintf('.%s.key',by{i}));
        if isnumeric(tmp(i))
            bycell(:,i) = mat2cell(tmp, ones(numel(resultfiles),1), size(tmp,2));
        else
            bycell(:,i) = tmp;
        end
    end
    bytbl = cell2table(expand_cell([bycell,resultfiles,cell(numel(resultfiles), 3)]),'VariableNames',[by,{'ResultFile','xyz','v','group'}]);
    bytbl.Uix = repmat({uint32([])}, size(bytbl, 1), 1);
    % NB. Should block by y after sorting
    % >> sortrows([x(:),y(:)])
    % ans =
    %      1     1
    %      1     2
    %      2     1
    %      2     2

%     [bytbl,ix] = sortrows(bytbl);
%     for ii = 1:numel(by)
%         bycellc{ii} = bytbl.(by{ii});
%     end
%     tmp = crosstab(bycellc{end:-1:1});
    [~,~,bytbl.group] = unique(bytbl(:,by));
%     byblock = array2table(tabulate(bytbl.group), 'VariableNames', {'Value','Count','Percent'});
%     byblock = tmp(:);
    %-----

%     resultfiles = resultfiles(ix);
%     cflist = cflist(ix,:);

    if ~exist(outdir, 'dir')
        mkdir(outdir)
    end
    inc = {'Uz','Uix','coords','subject','cvholdout','bias','nz_rows','RandomSeed'};
    R_template = cell2struct(cell(numel(inc),1), inc);
    G = max(bytbl.group);
    unique_result_files_prev = {''};
    for i = 1:G
        z = bytbl.group == i;
        bytbl_z = bytbl(z,:);
        ng = nnz(z);
        
        unique_result_files = unique(bytbl_z.ResultFile);
        nrf = numel(unique_result_files);
        cur = 0;
        % Load the results needed for this group
        if ~all(ismember(unique_result_files,unique_result_files_prev));
            for j = 1:numel(unique_result_files);
                tmp = load(unique_result_files{j}, 'results');
                tmp.results = RANDOMSEED_HACK(tmp.results);
                if j == 1
                    fn = fieldnames(tmp.results);
                    nr = numel(tmp.results);
                    R_template = cell2struct(cell(numel(fn), 1), fn);
                    results = repmat(R_template, nr * nrf, 1);
                end
                a = cur + 1;
                b = cur + nr;
                cur = b;
                results(a:b) = tmp.results;
%                 results(a:b) = selectfields(tmp.results, inc);
            end
        end
        unique_result_files_prev = unique_result_files;
        
        R = repmat(R_template, ng, 1);
        x = cell( 2, numel(by) );
        x(1,:) = by;
        for j = 1:ng
            x(2,:) = table2cell(bytbl_z(j, by));
%             R(j) = selectbyfield(results, x{:});
            tmp = selectbyfield(results, x{:},'cvholdout',j);
            if isempty(tmp)
                continue
            end
            R(j) = tmp;
            tmp = R(j).Uix(:);
            Uz = R(j).Uz;
            if R(j).bias
                bytbl_z.Uix{j} = tmp(1:end-1);
                Uz = Uz(1:end-1,:);
            else
                bytbl_z.Uix{j} = tmp;
            end
            coords = selectbyfield( R(j).coords, 'orientation', coordtype );
            bytbl_z.xyz{j} = coords.xyz;
            switch lower(metric)
                case 'nodestrength'
                    v = sum(abs(Uz * Uz'));
                case 'stability'
                    v = any(Uz,2);
                otherwise
                    error('Unrecognized metric "%s". Exiting...', metric);
            end
            if isempty(tmp)
                bytbl_z.v{j} = [];
            else
                bytbl_z.v{j} = v(:);
            end
        end
        Uix = cell2mat(bytbl_z.Uix);
        XYZ = cell2mat(bytbl_z.xyz);
        V   = cell2mat(bytbl_z.v);
        [~,ia,ib] = unique(Uix);
        xyz = XYZ(ia,:);
        iiii = iiii+1;
        disp(iiii);
        if ~isempty(v)
            if numel(R) > 1
                switch lower(metric)
                    case 'nodestrength'
                        v = splitapply(@mean,V,ib);
                    case 'stability'
                        v = splitapply(@sum,V,ib);
                    otherwise
                        error('Unrecognized metric "%s". Exiting...', metric);
                end
            else
                v = V;
            end
            id = cell(1,numel(by));
            for ii = 1:numel(by)
                if isfield(R,by{ii})
                    id{ii} = R(1).(by{ii});
                else
                    id{ii} = bytbl_z.(by{ii})(1);
                end
            end
            outfile = sprintf(fmt,id{:},coordtype);
%             disp(outfile);
            dlmwrite(fullfile(outdir,outfile), [xyz,v(:)], ' ');
        end
    end
end
%     rblock(byblock(1)) = struct('Uix',[],'v',[],'xyz',[]);
%     ir = cell2mat(arrayfun(@(x) 1:x, byblock, 'unif', 0)');
%     ib = 1;
%     for i = 1:numel(resultfiles)
%         resultfile = resultfiles{i};
%         r = load(resultfile,'results');
%         fn = fieldnames(r.results);
%         z = ~ismember(fn,inc);
%         r = rmfield(r.results, fn(z));
%         meta = metadata(r.subject);
%         cfilter = get_colfilter(meta, cflist(i,:));
%         z = strcmpi({meta.coords.orientation},coordtype);
%         xyz = meta.coords(z).xyz(cfilter,:);
%         Uix = get_Uix(r);
%         if any(r.bias) && ~issparse(r.Uz)
%             Uz = r.Uz(1:end-1,:);
%             if size(Uz,1) < max(Uix) || size(Uz,1) < numel(Uix);
%                 % Uix is assumed to be sorted
%                 Uix = reshape(Uix(1:end-1),[],1);
%             end
%         elseif issparse(r.Uz)
%             Uz = r.Uz(any(r.Uz,2),:);
%         end
%         if size(Uz,1) > numel(Uix)
%             Uz = Uz(Uix,:);
%         end
%         switch lower(metric)
%             case 'nodestrength'
%                 v = sum(abs(Uz * Uz'));
%             case 'stability'
%                 v = any(Uz,2);
%             otherwise
%                 error('Unrecognized metric "%s". Exiting...', metric);
%         end
% 
%         rblock(ir(i)).Uix = Uix;
%         rblock(ir(i)).v = v;
%         rblock(ir(i)).xyz = xyz(Uix,:);
%         %rblock(ir(i)).xyz = r.coords.xyz;
%         if i == sum(byblock(1:ib))
%             a = sum(byblock(1:ib)) - byblock(1:ib) + 1;
%             b = sum(byblock(1:ib));
%             Uix_u = unique(cat(1, rblock.Uix));
%             V = zeros(numel(rblock),numel(Uix_u));
%             xyz = zeros(numel(Uix_u), 3);
%             for ii = 1:numel(rblock)
%                 [~,ix] = ismember(rblock(ii).Uix, Uix_u);
%                 V(ii,ix) = rblock(ii).v;
%                 xyz(ix,:) = rblock(ii).xyz; % this may do lots of overwriting.
%             end
%             if all(size(V) > 1)
%                 switch lower(metric)
%                     case 'nodestrength'
%                         v = mean(V);
%                     case 'stability'
%                         v = sum(V);
%                     otherwise
%                         error('Unrecognized metric "%s". Exiting...', metric);
%                 end
%             else
%                 v = V;
%             end
%             id = cell(1,numel(by));
%             for ii = 1:numel(by)
%                 if isfield(r,by{ii})
%                     id{ii} = r.(by{ii});
%                 else
%                     id{ii} = bytbl.(by{ii})(i);
%                 end
%             end
%             outfile = sprintf(fmt,id{:},coordtype);
%             disp(outfile)
%             disp(bytbl(a:b,:));
%             dlmwrite(fullfile(outdir,outfile), [xyz,v(:)], ' ');
%             ib = ib + 1;
%             clear rblock
%             if numel(byblock) >= ib
%                 rblock(byblock(ib)) = struct('Uix',[],'v',[],'xyz',[]);
%             end
%         end
%     end
% end
function cfilter = get_colfilter(meta,cfset)
    if any(strcmp('filters', fieldnames(meta)))
        ff = 'filters';
    else
        ff = 'filter';
    end
    if numel(cfset,2) > 1
        zc = cell(numel(cfset,2),1);
        for ii = 1:numel(cfset,2)
            z = strcmpi({meta.(ff).label}, cfset{ii});
            zc{ii} = reshape(meta.(ff)(z).filter,1,[]);
        end
        cfilter = all(cell2mat(zc));
    else
        z = strcmpi({meta.(ff).label}, cfset{1});
        cfilter = meta.(ff)(z).filter;
    end
end
function Uix = get_Uix(r)
    if ~isfield(r,'Uix') && issparse(r.Uz)
        Uix = reshape(find(any(r.Uz,2)),[],1);
    elseif ~isfield(r,'Uix') && isfield(r,'nz_rows');
        Uix = find(r.nz_rows);
    else
        Uix = reshape(r.Uix,[],1);
    end
end
function s = RANDOMSEED_HACK(s)
    if numel(s) == numel(s(1).RandomSeed)
        for i = 1:numel(s)
            s(i).RandomSeed = s(i).RandomSeed(i);
        end
    end
end