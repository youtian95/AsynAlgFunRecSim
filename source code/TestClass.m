% Test InfrastructureSystem class.
% Run [runtests] in Command Window to run this test.

% public variables
MS = [2,2,2]; % maximum functional states
IRTs = {[0,100],[0,200],[0,300]}; % independent repair time
FS = [1,1,1]; % inital functional states
DeltaT = 5;
MaxT = 600;

%% Test 1: independent, asyn
Dep = []; % Dependency relationship
obj = InfrastructSystem(Dep,MS,IRTs);
obj.SetInitFS(FS);
FShist = obj.AsyRecovSim(DeltaT,MaxT);

assert(FShist(1,20)==1);
assert(FShist(1,21)==2);
assert(FShist(2,40)==1);
assert(FShist(2,41)==2);
assert(FShist(3,60)==1);
assert(FShist(3,61)==2);

%% Test 2: interdependent, asyn, without loops
Dep = [1 1 2 2; 2 1 3 2]; % Dependency relationship
obj = InfrastructSystem(Dep,MS,IRTs);
obj.SetInitFS(FS);
FShist = AsyRecovSim(obj,DeltaT,MaxT);

assert(FShist(1,120)==1);
assert(FShist(1,121)==2);
assert(FShist(2,100)==1);
assert(FShist(2,101)==2);
assert(FShist(3,60)==1);
assert(FShist(3,61)==2);

%% Test 3: independent, syn
Dep = []; % Dependency relationship
obj = InfrastructSystem(Dep,MS,IRTs);
obj.SetInitFS(FS);
FShist = SynRecovSim(obj,DeltaT,MaxT);

assert(FShist(1,20)==1);
assert(FShist(1,21)==2);
assert(FShist(2,40)==1);
assert(FShist(2,41)==2);
assert(FShist(3,60)==1);
assert(FShist(3,61)==2);

%% Test 4: interdependent, syn, without loops
Dep = [1 1 2 2; 2 1 3 2]; % Dependency relationship
obj = InfrastructSystem(Dep,MS,IRTs);
obj.SetInitFS(FS);
FShist = SynRecovSim(obj,DeltaT,MaxT);

assert(FShist(1,120)==1);
assert(FShist(1,121)==2);
assert(FShist(2,100)==1);
assert(FShist(2,101)==2);
assert(FShist(3,60)==1);
assert(FShist(3,61)==2);

%% Test 5: interdependent, syn, bidirectional dependent
% 2->3, 1->2, 2->1
Dep = [2 1 3 2; 1 1 2 2; 2 1 1 2]; % Dependency relationship
obj = InfrastructSystem(Dep,MS,IRTs);
obj.SetInitFS(FS);
FShist = SynRecovSim(obj,DeltaT,MaxT);

assert(FShist(1,MaxT/DeltaT+1)==1);
assert(FShist(2,MaxT/DeltaT+1)==1);
assert(FShist(3,60)==1);
assert(FShist(3,61)==2);

%% Test 6: interdependent, Asyn, bidirectional dependent
% 3->2, 2->1, 1->2
Dep = [2 1 3 2; 1 1 2 2; 2 1 1 2]; % Dependency relationship
obj = InfrastructSystem(Dep,MS,IRTs);
obj.SetInitFS(FS);
FShist = AsyRecovSim(obj,DeltaT,MaxT);

assert(FShist(1,120)==1);
assert(FShist(1,121)==2);
assert(FShist(2,100)==1);
assert(FShist(2,101)==2);
assert(FShist(3,60)==1);
assert(FShist(3,61)==2);

%% Test 7: interdependent, Asyn, looped dependency
% 2->3, 1->2, 3->1
Dep = [3 1 2 2; 2 1 1 2; 1 1 3 2]; % Dependency relationship
obj = InfrastructSystem(Dep,MS,IRTs);
obj.SetInitFS(FS);
FShist = AsyRecovSim(obj,DeltaT,MaxT);

assert(FShist(1,120)==1);
assert(FShist(1,121)==2);
assert(FShist(2,40)==1);
assert(FShist(2,41)==2);
assert(FShist(3,100)==1);
assert(FShist(3,101)==2);

%% Test 8: reusability of obj.SetInitFS(FS);
% 2->3, 1->2, 3->1
Dep = [3 1 2 2; 2 1 1 2; 1 1 3 2]; % Dependency relationship
obj = InfrastructSystem(Dep,MS,IRTs);
obj.SetInitFS(FS);
FShist1 = AsyRecovSim(obj,DeltaT,MaxT);
obj.SetInitFS(FS);
FShist2 = AsyRecovSim(obj,DeltaT,MaxT);
assert(all(FShist1==FShist2,'all'));

%% Test function AsyRecovSim 1: independent
Dep = []; % Dependency relationship
[~,FShist] = AsyRecovSim(Dep,MS,FS,IRTs,DeltaT,MaxT);

assert(FShist(1,20)==1);
assert(FShist(1,21)==2);
assert(FShist(2,40)==1);
assert(FShist(2,41)==2);
assert(FShist(3,60)==1);
assert(FShist(3,61)==2);

%% Test function AsyRecovSim 2: interdependent, without loops
Dep = [1 1 2 2; 2 1 3 2]; % Dependency relationship
[T,FShist] = AsyRecovSim(Dep,MS,FS,IRTs,DeltaT,MaxT);

assert(FShist(1,120)==1);
assert(FShist(1,121)==2);
assert(FShist(2,100)==1);
assert(FShist(2,101)==2);
assert(FShist(3,60)==1);
assert(FShist(3,61)==2);

%% Test function AsyRecovSim 3: multiple simulations
% 2->3, 1->2
Dep = [3 1 2 2; 2 1 1 2]; % Dependency relationship
[~,FShist] = AsyRecovSim(Dep,MS,repmat(FS,2,1),IRTs,DeltaT,MaxT);
assert(all(FShist(:,:,1)==FShist(:,:,2),'all'));

%% Test function AsyRecovSim 4: interdependent, bidirectional dependent
% 3->2, 2->1, 1->2
Dep = [2 1 3 2; 1 1 2 2; 2 1 1 2]; % Dependency relationship
[~,FShist] = AsyRecovSim(Dep,MS,FS,IRTs,DeltaT,MaxT);

assert(FShist(1,120)==1);
assert(FShist(1,121)==2);
assert(FShist(2,100)==1);
assert(FShist(2,101)==2);
assert(FShist(3,60)==1);
assert(FShist(3,61)==2);

%% Test function AsyRecovSim 5: interdependent, looped dependency
% 2->3, 1->2, 3->1
Dep = [3 1 2 2; 2 1 1 2; 1 1 3 2]; % Dependency relationship
[~,FShist] = AsyRecovSim(Dep,MS,FS,IRTs,DeltaT,MaxT);

assert(FShist(1,120)==1);
assert(FShist(1,121)==2);
assert(FShist(2,40)==1);
assert(FShist(2,41)==2);
assert(FShist(3,100)==1);
assert(FShist(3,101)==2);

%% Test function AsyRecovSim 6: interdependent, false loop
% [1* 2  3  4]
%    /   ^   
%   /    | 
%  ^     | 
% [1* 2  3  4]
MS = [4,4]; % maximum functional states
IRTs = {[0,100,200,300],[0,100,200,300]}; % independent repair time
Dep = [1 3 2 3; 2 1 1 2]; % Dependency relationship
FS = [1,1]; % inital functional states
DeltaT = 5;
MaxT = 600;
[~,FShist] = AsyRecovSim(Dep,MS,FS,IRTs,DeltaT,MaxT);

assert(FShist(2,40)==1);
assert(FShist(2,41)==2);
assert(FShist(1,80)==3);
assert(FShist(1,81)==4);

%% Test function SynRecovSim 1: independent
Dep = []; % Dependency relationship
FShist = SynRecovSim(Dep,MS,FS,IRTs,DeltaT,MaxT);

assert(FShist(1,20)==1);
assert(FShist(1,21)==2);
assert(FShist(2,40)==1);
assert(FShist(2,41)==2);
assert(FShist(3,60)==1);
assert(FShist(3,61)==2);

%% Test function SynRecovSim 2: interdependent, without loops
Dep = [1 1 2 2; 2 1 3 2]; % Dependency relationship
FShist = SynRecovSim(Dep,MS,FS,IRTs,DeltaT,MaxT);

assert(FShist(1,120)==1);
assert(FShist(1,121)==2);
assert(FShist(2,100)==1);
assert(FShist(2,101)==2);
assert(FShist(3,60)==1);
assert(FShist(3,61)==2);

%% Test function SynRecovSim 3: multiple simulations
% 2->3, 1->2
Dep = [3 1 2 2; 2 1 1 2]; % Dependency relationship
FShist = SynRecovSim(Dep,MS,repmat(FS,2,1),IRTs,DeltaT,MaxT);
assert(all(FShist(:,:,1)==FShist(:,:,2),'all'));

%% Test function SynRecovSim 4: interdependent, false loop
% [1* 2  3  4]
%    /   ^   
%   /    | 
%  ^     | 
% [1* 2  3  4]
MS = [4,4]; % maximum functional states
IRTs = {[0,100,200,300],[0,100,200,300]}; % independent repair time
Dep = [1 3 2 3; 2 1 1 2]; % Dependency relationship
FS = [1,1]; % inital functional states
DeltaT = 5;
MaxT = 600;
FShist = SynRecovSim(Dep,MS,FS,IRTs,DeltaT,MaxT);

assert(FShist(2,40)==1);
assert(FShist(2,41)==2);
assert(FShist(1,80)==3);
assert(FShist(1,81)==4);
