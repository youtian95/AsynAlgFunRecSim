function varargout = AsyRecovSim(Dep,MS,FS,IRTs, DeltaT,MaxT)
% 
% Post-earthquake recovery simulation of interdependant infrastructure
% systems. An asynchronous algorithm is used. Initial functional states of
% components should be known.
% 
% Syntax:
% [T] = AsyRecovSim(Dep,MS,FS,IRTs)
% [T,DeletedDepCell,Dold,Dnew] = AsyRecovSim(Dep,MS,FS,IRTs)
% [T,F_t,DeletedDepCell,Dold,Dnew] = AsyRecovSim(Dep,MS,FS,IRTs)
% [T,FShist] = AsyRecovSim(..., DeltaT,MaxT)
% [T,FShist,DeletedDepCell,Dold,Dnew] = AsyRecovSim(..., DeltaT,MaxT)
% 
% Parameters:
% <Dep> - kx4 matrix - dependency relationships. The 1st and 3rd columns
% refer to the indices of components. The 2nd and 4th columns refer to the
% numbers of functional states. The state Dep(i,2) of component Dep(i,1) is
% dependent on the state Dep(i,4) of component Dep(i,3).
% <MS> - 1xN int matrix (N: building number) - maximum possible
% funcitonal states for each component.
% <FS> - Nsim x N int matrix (Nsim: simulation number; N: building number)
% - initial (after earthquake) functional states of components. All
% possible functional states should be 1,2,3 ... or M.
% <IRTs> - 1xN cell OR NsimxN cell - each cell stores the independent
% recovery time correponding to each functional state of a
% component(building). For example, a building has 3 states [1,2,3] and
% corresponding independent recovery time is [0,100,200]. It means that it
% needs 200 days to be completely repaired. Then IRTs(thebld) =
% [0,100,200].
% <DeltaT> - double - Time step for result recording. Unit: days.
% <MaxT> - double - Maximum time for recovery simulation. Unit: days.
% 
% Returns:
% <T> - Nsim x N cell - recording recovery time for each building. T{i,j}
% is a 1xM vector, where M is the number of functional states.
% <FShist> -  N x (MaxT/DeltaT) x Nsim array - history of functional states
% of all components.
% <F_t> - 1 x Nsim cell - F_t{i} is a 2 x n matrix. 1st row is time. 2nd
% row is a function that refers to the percent of buildings that have
% reached the maximum states.
% <DeletedDepCell> - 1 x Nsim cell - dependency causing looped dependency
% <Dold> - D{Nsim,N}{j} - D{isim，i}{j} is a nx2 matrix, and refers to the i-th
% building's j-th state's dependent buildings and states. The 1st col is
% building indices and 2rd col is the corresonding state indices.
% <Dnew> - updated D. Those dependency relationships causing looped
% dependency are deleted.

Nsim = size(FS,1);
assert(all(size(MS,2)==size(FS,2)));

if size(IRTs,1)==1
    IRTs = repmat(IRTs,[Nsim,1]);
else
    assert(size(IRTs,1)==Nsim);
end

DeletedDepCell = cell(1,Nsim);

% number of buildings/components
N = size(FS,2);

% reorganize dependency relationships, Dep, as D{isim,i}{j}.
% D{isim,i}{j} - D{isim，i}{j} is a nx2 matrix, and refers to the i-th
% building's j-th state's dependent buildings and states. The 1st col is
% building indices and 2rd col is the corresonding state indices.
D = cell(1,N);
for i=1:N
    D{i} = cell(1,MS(i));
end
for i=1:size(Dep,1)
    D{Dep(i,1)}{Dep(i,2)} = [D{Dep(i,1)}{Dep(i,2)}; Dep(i,3),Dep(i,4)];
end
D = repmat(D,Nsim,1);
Dold = D;

% initial states
T = cell(Nsim,N);
for j=1:Nsim
    for i=1:N
        T{j,i} = NaN(1,MS(i));
        T{j,i}(1:FS(j,i)) = 0;
    end
end

for isim = 1:Nsim
    for i=1:N
        update(i,[],isim);
    end
end

% return updated dependency
Dnew = D;

% recovery curves. F_t
if any(nargout==5) && (nargin==4)
    F_t = cell(1,Nsim);
    temp = zeros(Nsim,N);
    for i=1:Nsim
        for j=1:N
            temp(i,j) = T{i,j}(end);
        end
    end
    Q = quantile(temp',(0:1:100)./100);
    for i=1:Nsim
        F_t{i} = [Q(:,i)'; (0:1:100)./100];
    end
end

% recovery curves 
if any(nargout==[2,5]) && (nargin==6)
    NT = ceil(MaxT/DeltaT); % total time steps
    FShist = zeros(N,NT+1,Nsim);
    for isim = 1:Nsim
        for i=1:N
            
%             temp = (0:NT).*DeltaT - T{isim,i}';
%             temp(temp<0) = nan;
%             [~,I] = min(flipud(temp),[],1);
%             I = size(temp,1) - I + 1;
%             FShist(i,:,isim) = I;
            
%             xt = (0:NT).*DeltaT;
%             rc = T{isim,i};
%             FShist(i,xt<rc(1),isim) = 1;
%             for j=2:numel(rc)
%                 FShist(i,(xt<rc(j))&(xt>=rc(j-1)),isim) = j-1;
%             end
%             FShist(i,xt>=rc(end),isim) = numel(rc);
            
            rc = T{isim,i};
            for j=2:numel(rc)
                tn_1 = ceil(rc(j-1)/DeltaT)+1;
                tn = ceil(rc(j)/DeltaT)+1;
                FShist(i,tn_1:(tn-1),isim) = j-1;
            end
            FShist(i,tn:end,isim) = numel(rc);
        end
    end
end

if (nargout==1) && (nargin==4)
    varargout = {T};
elseif (nargout==4) && (nargin==4)
    varargout = {T,DeletedDepCell,Dold,Dnew};
elseif (nargout==5) && (nargin==4)
    varargout = {T,F_t,DeletedDepCell,Dold,Dnew};
elseif (nargout==2) && (nargin==6)
    varargout = {T,FShist};
elseif (nargout==5) && (nargin==6)
    varargout = {T,FShist,DeletedDepCell,Dold,Dnew};
else
    error('Wrong arguments!');
end

%% Local function 
function update(i,iDS,isim)
% Parameters:
% <i> - int - a building index
% <iDS> - nx2 vector - downstream building and states indices
% <isim> - int - earthquake index

while FS(isim,i)<MS(i)
    
    % iDS
    if ~isempty(iDS)
        if FS(isim,i)>=iDS(end,2)
%             iDS = [];
            return
        end
    end

    % check dependent components
    Dbld = D{isim,i}{FS(isim,i)}; % dependent on these buildings
    if ~isempty(Dbld)
        DFS = FS(isim,Dbld(:,1)'); % states of these blds at the moment
        % those dependent components that cannot provide normal services
        Did = find(DFS<(Dbld(:,2))');
        if ~isempty(Did)
            % iDS. check chain dependency
            if ~isempty(iDS)
                if any(all([i,FS(isim,i)]==iDS,2))
                    Dtemp = D{isim,iDS(end-1,1)}{iDS(end-1,2)}; 
                    Dtemp(all(Dtemp==iDS(end,:),2),:) = [];
                    D{isim,iDS(end-1,1)}{iDS(end-1,2)} = Dtemp;
                    DeletedDepCell{isim} = [DeletedDepCell{isim}; ...
                        iDS(end-1,:),iDS(end,:)];
                    return
                end
            end
            % update those buildings
            for id = Did
                update(Dbld(id,1), ...
                    [iDS;i,FS(isim,i);Dbld(id,1),Dbld(id,2)],isim);
            end
        end
    end

    % move forward to the next state
    FS(isim,i) = FS(isim,i) + 1;

    % record recovery time
    rt = IRTs{isim,i}(FS(isim,i)) - IRTs{isim,i}(FS(isim,i)-1); % repair time
    Tlongest = T{isim,i}(FS(isim,i)-1) + rt; % independent recovery time
    Dbld = D{isim,i}{FS(isim,i)-1}; % dependent on these buildings (updated)
    for row = 1:size(Dbld,1)
        Tlongest = max(Tlongest, T{isim,Dbld(row,1)}(Dbld(row,2)) + rt);
    end
    T{isim,i}(FS(isim,i)) = Tlongest;
end

end

end




