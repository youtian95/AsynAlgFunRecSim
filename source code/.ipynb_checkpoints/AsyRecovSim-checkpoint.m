function [T,FShist] = AsyRecovSim(Dep,MS,FS,IRTs,DeltaT,MaxT)
% 
% Post-earthquake recovery simulation of interdependant infrastructure
% systems. An asynchronous algorithm is used. Initial functional states of
% components should be known.
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
% <IRTs> - 1xN cell - each cell stores the independent recovery time
% correponding to each functional state of a component(building). For
% example, a building has 3 states [1,2,3] and corresponding independent
% recovery time is [0,100,200]. It means that it needs 200 days to be
% completely repaired. Then IRTs(thebld) = [0,100,200].
% 
% Optional for drawing curves:
% <DeltaT> - double - Time step for result recording. Unit: days.
% <MaxT> - double - Maximum time for recovery simulation. Unit: days.
% 
% Returns:
% <T> - Nsim x N cell - recording recovery time for each building. T{i,j}
% is a 1xM vector, where M is the number of functional states.
% 
% Optional for drawing curves:
% <FShist> - Nsim x N x (MaxT/DeltaT) array - history of functional states
% of all components.

Nsim = size(FS,1);
assert(all(size(MS,2)==size(FS,2)));
assert(size(Dep,2)==4);

% number of buildings/components
N = size(FS,2);

% reorganize dependency relationships, Dep, as D{i}{j}.
% D{i}{j} - D{i}{j} is a nx2 matrix, and refers to the i-th building's j-th
% state's dependent buildings and states. The 1st col is building indices
% and 2rd col is the corresonding state indices.
D = cell(1,N);
for i=1:N
    D{i} = cell(1,MS(i));
end
for i=1:size(Dep,1)
    D{Dep(i,1)}{Dep(i,2)} = [D{Dep(i,1)}{Dep(i,2)}; Dep(i,3),Dep(i,4)];
end

% inital states
T = cell(Nsim,N);
for j=1:Nsim
    for i=1:N
        T{j,i} = NaN(1,MS{i});
        T{j,i}(1:FS(i)) = 0;
    end
end

for isim = 1:Nsim
    for i=1:N
        update(i,[],isim);
    end
end

% recovery curves 
if nargin>4
    NT = ceil(MaxT/DeltaT); % total time steps
    N=numel(MS); % total building number
    FShist = zeros(N,NT);
end


%% Local function so that can access variables above
function update(i,iDS,isim)
% Parameters:
% <i> - int - a building index
% <iDS> - 1xn vector - downstream building indices
% <isim> - int - earthquake index

while FS(isim,i)<MS(i)

    % check dependent components
    Dbld = D{i}{FS(isim,i)}; % dependent on these buildings
    if ~isempty(Dbld)
        DFS = zeros(1,size(Dbld,1)); % states of these blds at the moment
        for row = 1:numel(DFS)
            DFS(row) = FS(isim,Dbld(row,1));
        end
        % those dependent components that cannot provide normal services
        Dbool = DFS<(Dbld(:,2))'; 
        Did = find(Dbool);
        % update those buildings
        for id = 1:numel(Did)
            update(Dbld(Did(id),1),iDS,isim);
        end
    end

    % move forward to the next state
    FS(isim,i) = FS(isim,i) + 1;

    % record recovery time
    Tlongest = T{isim,i}(FS(isim,i)-1) +  IRTs{i}(FS(isim,i)) - ...
        IRTs{i}(FS(isim,i)-1); % independent recovery time
    for row = 1:size(Dbld,1)
        Tlongest = max(Tlongest,T{isim,Dbld(row,1)}(Dbld(row,2)));
    end
    T{isim,i}(FS(isim,i)) = Tlongest;
end

end

end




