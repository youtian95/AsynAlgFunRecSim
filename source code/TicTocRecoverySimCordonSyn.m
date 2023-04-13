% Recovery simulaiton of a portfolio of buildings considering the effect of
% collapse cordon.

function [t1,FShistCell] = TicTocRecoverySimCordonSyn(DeltaT,MaxT,DepCell,IRTsCell,FSCell)
% Parameters:
% <DeltaT> - time step
% <MaxT> - max time of simulation
% 
% returns:
% <t1> - average running time
% <FShistCell> - FShistCell{i_eq} - functional states history. Each cell is
% a N x (MaxT/DeltaT) matrix.

    n = sqrt(numel(FSCell{1}));
    MS = 2.*ones(1,n*n);
    Neq = numel(FSCell);
    
    load(['tempdata/DeletedDepCell_Cordon_n',num2str(n),'.mat']);
    
    tic
    
    for isim = 1:Neq
        if ~isempty(DepCell{isim})
            B = DepCell{isim} == reshape(DeletedDepCell{isim}',1,4,[]);
            row = any(all(B,2),3); % B: k x 4 x k'
            DepCell{isim} = DepCell{isim}(~row,:);
        end
    end
    FShist = SynRecovSim(DepCell,MS,cell2mat(FSCell'),IRTsCell{1},DeltaT,MaxT);

    T = toc;
    t1 = T/Neq;
    
    FShistCell = mat2cell(FShist,size(FShist,1), ...
        size(FShist,2), ones(1,size(FShist,3)));
    FShistCell = reshape(FShistCell,1,numel(FShistCell));
    
end
