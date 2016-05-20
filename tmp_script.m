
Avg(size(Results,2)) = Results(1);
toCopy = {'subject','cvholdout','finalholdout','lambda','lambda1','LambdaSeq','regularization','bias','normalize'};
toAvg = {'nzv','err1','err2','iter','job'};
for iResult = 1:size(Results,2);
    for iCopy = 1:numel(toCopy)
        field = toCopy{iCopy};
        i = 1;
        while i <= 8 && isempty(Results(i,iResult).(field))
            i = i + 1;
        end
        if i > 8
            Avg(iResult).(field) = 0;
        else
            Avg(iResult).(field) = Results(i,iResult).(field);
        end
    end
    for iAvg = 1:numel(toAvg)
        field = toAvg{iAvg};
        Avg(iResult).(field) = sum([Results(:,iResult).(field)])/nnz([Results(:,iResult).(field)]);
    end
end
Avg = Avg([Avg.subject]>0);
G = findgroups([Avg.finalholdout],[Avg.subject]);
S = @(x1, x2, x3, x4, x5){selectMin(x1, x2, x3, x4, x5)};
Xc = splitapply(S,[Avg.err1],[Avg.finalholdout],[Avg.subject],[Avg.lambda],[Avg.lambda1],G);
X = cell2mat(cellfun(@cell2mat,Xc,'Unif',0)');

Tune(numel(Xc)) = struct('subject',0,'finalholdout',0,'lambda',0','lambda1',0','err1',0);
for iTune = 1:numel(Tune)
    Tune(iTune).err1 = X(iTune,1);
    Tune(iTune).finalholdout = X(iTune,2);
    Tune(iTune).subject = X(iTune,3);
    Tune(iTune).lambda = X(iTune,4);
    Tune(iTune).lambda1 = X(iTune,5);
end
