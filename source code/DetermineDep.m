function  Dep = DetermineDep(filename,Rhr,hmin)
% Parameters:
% <Rhr> - ratio ofcordon radius to height
% <hmin> - minimum building height of considering cordon
% 
% Returns
% <Dep> - kx4 matrix - dependency relationships. The 1st and 3rd columns
% refer to the indices of components. The 2nd and 4th columns refer to the
% numbers of functional states. The state Dep(i,2) of component Dep(i,1) is
% dependent on the state Dep(i,4) of component Dep(i,3).

addpath('../3rd party/webMercator2LngLat');
T = readtable(filename);

% buidling height
if any(strcmp(T.Properties.VariableNames,'Height'))
    Height = T{:,'Height'}';
elseif any(strcmp(T.Properties.VariableNames,'NumberOfStories'))
    Height = T{:,'NumberOfStories'}'.*3;
end

% Cartesian coordinates
[x0,y0] = LngLat2webMercator(T.('Longitude')(1),T.('Latitude')(1));
costheta = cos(T.('Latitude')(1)/180*pi);
[x,y] = LngLat2webMercator(T{:,'Longitude'}',T{:,'Latitude'}');
x = (x - x0).*costheta;
y = (y - y0).*costheta;

% distance matrix
Dist = sqrt((x'-x).^2+(y'-y).^2);

% dependency relationship 
Dep = [];
% The 1st and 3rd columns refer to the indices of components. The 2nd and
% 4th columns refer to the numbers of functional states. The state Dep(i,2)
% of component Dep(i,1) is dependent on the state Dep(i,4) of component
% Dep(i,3).
for i=1:size(T,1)
    ind = (Dist(i,:)<(Rhr.*Height)) & (Height>=hmin);
    ind(i) = false;
    Ndep = sum(ind); % total depending buildings
    Dep1 = zeros(3*Ndep,4);
    Dep1(:,1) = i;
    Dep1(1:Ndep,2) = 1;
    Dep1((Ndep+1):(2*Ndep),2) = 2;
    Dep1((2*Ndep+1):(3*Ndep),2) = 3;
    Dep1(:,3) = repmat(find(ind),1,3);
    Dep1(:,4) = 2; % "safe" state
    Dep = [Dep;Dep1];
end

end