function [FS,IRTsCell] = ReadFS(filename,OutputDir,Nsim,RTbeta)
% <FS> - Nsim x N int matrix
% <IRTsCell> - Nsim x N cell
% <RTbeta> - Repair time uncertainty. Beta of lognormal distribution
% * in the order of table of <filename>
% * For invalid results, FS = MaxFS and IRTs = zeros

MaxFS = 4;

T = readtable(filename);
FS = zeros(Nsim,size(T,1));
IRTsCell = cell(Nsim,size(T,1));

f = waitbar(0,'Please wait...');
for i=1:size(T,1)
    waitbar(i/size(T,1),f,'Reading initial damage states...');
    BldID = T{i,'id'};
    T_loss = readtable(fullfile(OutputDir, ...
        ['BldLoss_bldID_',num2str(BldID),'.csv']), ...
        'ReadRowNames',1);
    if size(T_loss,1)<Nsim
        FS(:,i) = MaxFS;
        IRTsCell(:,i) = num2cell(zeros(size(IRTsCell,1),MaxFS),2);
        continue
    end
    IRTs = T_loss{1:Nsim,["RepairTime","FunctionLossTime","RecoveryTime"]};
    % add uncertainty
    RandomTemp = randn(size(IRTs)).*RTbeta;
    IRTs(IRTs>0) = exp(log(IRTs(IRTs>0))+RandomTemp(IRTs>0));
    % RecoveryTime >= FunctionLossTime >= RepairTime
    IRTs(IRTs(:,2)<IRTs(:,1),2) = IRTs(IRTs(:,2)<IRTs(:,1),1);
    IRTs(IRTs(:,3)<IRTs(:,2),3) = IRTs(IRTs(:,3)<IRTs(:,2),2);
    IRTs = [zeros(size(IRTs,1),1),IRTs];
    IRTsCell(:,i) = num2cell(IRTs,2);
    [~,I] = max([IRTs~=0,true(size(IRTs,1),1)],[],2);
    FS(:,i) = I - 1;
end
close(f);

end