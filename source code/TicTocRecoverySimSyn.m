function [t,F_t,FShistCell] = TicTocRecoverySimSyn(Dep,FS,MS,IRTsCell,DeltaT,MaxT)
% Returns:
% <t> - average running time
% <F_t> - 1 x Nsim cell - F_t{i} is a (2M) x n matrix. The 2i th row is the
% percent of buildings that have reached different functional states. The
% 2i-1 th rows is the corresponding time when the percent is reached.
% <FShistCell> - FShistCell{i_eq} - functional states history. Each cell is
% a N x (MaxT/DeltaT) matrix.


Neq = size(FS,1);

DepCell = repmat({Dep},1,Neq);

% delete loop dependence
load('tempdata/DeletedDepCell_SF.mat');
for isim = 1:Neq
    if ~isempty(DepCell{isim})
        B = DepCell{isim} == reshape(DeletedDepCell{isim}',1,4,[]);
        row = any(all(B,2),3); % B: k x 4 x k'
        DepCell{isim} = DepCell{isim}(~row,:);
    end
end

tic

% FShist: N x (MaxT/DeltaT+1) x Nsim array
FShist = SynRecovSim(DepCell,MS,FS,IRTsCell,DeltaT,MaxT);

% recovery curve F_t
F_t = cell(1,Neq);
% time series
x = (1:size(FShist,2))-1;
x = x.*DeltaT;
% function
M = max(MS,[],'all');
N = size(FShist,1);
for i=1:Neq
    temp = [];
    for im = 1:M
        temp = [temp;x;sum(FShist(:,:,i)>=im,1)./N];
    end
    F_t{i} = temp;
end

T = toc;
t = T/Neq;

FShistCell = mat2cell(FShist,size(FShist,1), ...
    size(FShist,2), ones(1,size(FShist,3)));
FShistCell = reshape(FShistCell,1,numel(FShistCell));


end

