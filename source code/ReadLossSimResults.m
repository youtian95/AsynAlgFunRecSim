function [AllLossSimResults,ValidBldID] = ReadLossSimResults(...
    filename,LossSimDir)
% AllLossSimResults: table['SimID','RepairCost_Total', 
% 'RepairCost_Struct','RepairCost_NonStruct_DriftSen', 
% 'RepairCost_NonStruct_AccelSen','RepairTime','RecoveryTime',
% 'FunctionLossTime']

Varnames = {'SimID','RepairCost_Total', ...
	'RepairCost_Struct','RepairCost_NonStruct_DriftSen',  ...
	'RepairCost_NonStruct_AccelSen','RepairTime','RecoveryTime',...
	'FunctionLossTime'};
ValidBldID = [];
T = readtable(filename);
AllLossSimResults = table;
f = waitbar(0,'Please wait...');
for i=1:size(T,1)
    waitbar(i/size(T,1),f,'Please wait...');
    BldID = T{i,'id'};
    T_loss = readtable(fullfile(LossSimDir, ...
        ['BldLoss_bldID_',num2str(BldID),'.csv']));
    if any(strcmp(T_loss{:,'DS_Struct'},'UNKNOWN'))
        ValidBldID = [ValidBldID,BldID];
        continue
    end
    T_loss.Properties.VariableNames{'Var1'} = 'SimID';
    T_loss = T_loss(:,Varnames);
    if numel(AllLossSimResults)==0
        AllLossSimResults = T_loss;
    else
        AllLossSimResults{:,2:end} = AllLossSimResults{:,2:end} + ...
            T_loss{:,2:end};
    end
end
close(f);

end

