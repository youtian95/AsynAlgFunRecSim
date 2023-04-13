function FShist = SynRecovSim(Dep,MS,FS,IRTs,DeltaT,MaxT)
% A synchronous algorithm
% 
% Parameters:
% 
% <Dep> - Dependency relationships
% (1) kx4 matrix - The 1st and 3rd columns refer to the indices of
% components. The 2nd and 4th columns refer to the numbers of functional
% states. The state Dep(i,2) of component Dep(i,1) is dependent on the
% state Dep(i,4) of component Dep(i,3).
% (2) 1 x Nsim cell - Dep{isim} is a kx4 matrix
% (3) Nsim x N cell - D{isim，i}{j} is a nx2 matrix, and refers to the i-th
% building's j-th state's dependent buildings and states. The 1st col is
% building indices and 2rd col is the corresonding state indices.
% 
% <MS> - 1xN int matrix (N: building number) - maximum possible
% funcitonal states for each component.
% 
% <FS> - Nsim x N int matrix (Nsim: simulation number; N: building number)
% - initial (after earthquake) functional states of components. All
% possible functional states should be 1,2,3 ... or M.
% 
% <IRTs> - 1xN cell OR NsimxN cell - each cell stores the independent
% recovery time correponding to each functional state of a
% component(building). For example, a building has 3 states [1,2,3] and
% corresponding independent recovery time is [0,100,200]. It means that it
% needs 200 days to be completely repaired. Then IRTs(thebld) =
% [0,100,200].
% 
% <DeltaT> - double - Time step for result recording. Unit: days.
% 
% <MaxT> - double - Maximum time for recovery simulation. Unit: days.
% 
% 
% Returns:
% 
% <FShist> -  N x (MaxT/DeltaT) x Nsim array - history of functional states
% of all components.

Nsim = size(FS,1);
assert(all(size(MS,2)==size(FS,2)));

% number of buildings/components
N = size(FS,2);

if size(IRTs,1)==1
    IRTs = repmat(IRTs,[Nsim,1]);
else
    assert(size(IRTs,1)==Nsim);
end

% Reorganize dependency relationships, Dep, as D{isim,i}{j}. D{isim,i}{j}
% is a nx2 matrix, and refers to the i-th building's j-th state's dependent
% buildings and states. The 1st col is building indices and 2rd col is the
% corresonding state indices.
if iscell(Dep) && (Nsim==size(Dep,1)) && (N==size(Dep,2))
    D = Dep;
elseif iscell(Dep) && (1==size(Dep,1)) && (Nsim==size(Dep,2))
    D = cell(Nsim,N);
    for isim=1:Nsim
        D(isim,:) = Dmat2Dcell(Dep{isim});
    end
else % matrix
    D = repmat(Dmat2Dcell(Dep),Nsim,1);
end

    % turn a kx4 matrix to a cell
    function Dcell = Dmat2Dcell(Dmat)
        Dcell = cell(1,N);
        for i=1:N
            Dcell{i} = cell(1,MS(i));
        end
        for i=1:size(Dmat,1)
            Dcell{Dmat(i,1)}{Dmat(i,2)} = [Dcell{Dmat(i,1)}{Dmat(i,2)}; ...
                Dmat(i,3),Dmat(i,4)];
        end
    end

% inital cumulative repair time
cumulRT = zeros(Nsim,N);
for isim = 1:Nsim
    for i_bld=1:N
        cumulRT(:,i_bld) = IRTs{isim,i_bld}(FS(:,i_bld));
    end
end

NT = ceil(MaxT/DeltaT); % total time steps
FShist = zeros(N,NT+1,Nsim);
FShist(:,1,:) = FS';

for isim = 1:Nsim
    for i_t=1:NT
        % stop this simulation if all repairs are done
        if all(FShist(:,i_t,isim)'==MS)
            FShist(:,(i_t+1):end,isim) = ...
                repmat(MS',1,NT+1-i_t);
            break
        end
        for i_bld=1:N
            % if this component is finished, continue to the next one
            if FShist(i_bld,i_t,isim)>=MS(i_bld)
                FShist(i_bld,i_t+1,isim) = MS(i_bld);
                continue
            end
            % check the states of all components that the state of
            % this obj is dependent on
            Dbld = D{isim,i_bld}{FShist(i_bld,i_t,isim)}; % dependent on these buildings
            if ~isempty(Dbld)
                DFS = FShist(Dbld(:,1)',i_t,isim); % states of these blds at the moment
                % Whenever there are any surporting states that have not
                % been reached, this building cannnot be being repaired.
                if any(DFS<(Dbld(:,2)))
                    FShist(i_bld,i_t+1,isim) = FShist(i_bld,i_t,isim);
                    continue
                end
            end
            % repair process moves on
            cumulRT(isim,i_bld) = cumulRT(isim,i_bld) + DeltaT;
            if cumulRT(isim,i_bld)>=IRTs{isim,i_bld}(FShist(i_bld,i_t,isim)+1)
                FShist(i_bld,i_t+1,isim) = FShist(i_bld,i_t,isim) + 1;
            else
                FShist(i_bld,i_t+1,isim) = FShist(i_bld,i_t,isim);
            end
        end
    end
end


end