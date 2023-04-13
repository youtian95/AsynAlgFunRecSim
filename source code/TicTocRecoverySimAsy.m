function [t,F_t,T] = TicTocRecoverySimAsy(Dep,FS,MS,IRTsCell)
% Returns:
% <t> - average time for each time of recovery simulation
% <F_t> - 1 x Nsim cell - F_t{i} is a (2M) x n matrix. The 2i th row is the
% percent of buildings that have reached different functional states. The
% 2i-1 th rows is the corresponding time when the percent is reached.
% <T> - Nsim x N cell - recording recovery time for each building. T{i,j}
% is a 1xM vector, where M is the number of functional states.

Neq = size(FS,1);

tic

[T,DeletedDepCell,~,~] = AsyRecovSim(Dep,MS,FS,IRTsCell);
F_t = SummarizeTime(T);

Ttot = toc;
t = Ttot/Neq;

save('tempdata/DeletedDepCell_SF.mat','DeletedDepCell');

end