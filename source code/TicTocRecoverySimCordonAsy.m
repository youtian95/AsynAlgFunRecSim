% Recovery simulaiton of a portfolio of buildings considering the effect of
% collapse cordon.

function [t1,FShistCell] = TicTocRecoverySimCordonAsy(DepCell,IRTsCell,FSCell)
% Parameters:
% <DepCell> - DepCell{i_eq} is a kx4 matrix - dependency relationships. The
% 1st and 3rd columns of DepCell{i_eq} refer to the indices of components.
% The 2nd and 4th columns refer to the numbers of functional states. The
% state Dep(i,2) of component Dep(i,1) is dependent on the state Dep(i,4)
% of component Dep(i,3).
% <FSCell> - FSCell{i_eq} is a Nsim x N int matrix (Nsim: simulation
% number; N: building number) - initial (after earthquake) functional
% states of components. All possible functional states should be 1,2,3 ...
% or M.
% <IRTsCell> - IRTsCell{i_eq} is a 1xN cell - each cell stores the
% independent recovery time correponding to each functional state of a
% component(building). For example, a building has 3 states [1,2,3] and
% corresponding independent recovery time is [0,100,200]. It means that it
% needs 200 days to be completely repaired. Then IRTs(thebld) =
% [0,100,200].
% 
% returns:
% <t1> - average running time
% <FShistCell> - FShistCell{i_eq} - function recovery history. Each cell is
% a 2 x NT matrix. 1st row is time. 2nd row is a function that refers to
% the percent of buildings that have reached the maximum states.

    n = sqrt(numel(FSCell{1}));
    MS = 2.*ones(1,n*n);
    Neq = numel(FSCell);
    
    for i_eq = 1:Neq
        assert(all(cell2mat(IRTsCell{i_eq}')==cell2mat(IRTsCell{1}'),'all'));
        assert(all(DepCell{i_eq}==DepCell{1},'all'));
    end
    
    tic
    
    [~,F_t,DeletedDepCell,~,~] = AsyRecovSim( ...
        DepCell{1},MS,cell2mat(FSCell'),IRTsCell{1});
    FShistCell = F_t;
        
    T = toc;
    t1 = T/Neq;
    
    save(['tempdata/DeletedDepCell_Cordon_n',num2str(n),'.mat'],'DeletedDepCell');
end
