function CreateBld(loc,Height,facecolor,facealpha)
% Plot a 3D building
%
% Paramters：
% loc - Nx2 matrix. each row is a pair of coordinates [x,y] of a vertex of
% the footprint. The 1st and last vertices should be the same.
% Height 
% facecolor - [0,1,0] is green color
% facealpha -  transparancy
%
% Return：
% p - patch

view(3);
daspect([1 1 1]);
axis off;
xticks([]);
yticks([]);
zticks([]);

vert1 = horzcat(loc,zeros(size(loc,1),1));
vert2 = horzcat(loc,ones(size(loc,1),1).*Height);
vert = [vert1;vert2];

fac = [];
for i=1:(size(loc,1)-1)
    fac = [fac;[i,i+1,i+size(loc,1)+1,i+size(loc,1)]];
end

p = patch('Vertices',vert,'Faces',fac, ...
    'FaceVertexCData',hsv(6),'FaceColor',facecolor, ... %facecolor
    'FaceAlpha',facealpha,'EdgeColor',facecolor.*0.5,'LineWidth',0.2); 

%top
fac_top = 1:size(loc,1); 
vert_top = vert2;
patch('Vertices',vert_top,'Faces',fac_top, ...
    'FaceVertexCData',hsv(6),'FaceColor',facecolor, ...
    'FaceAlpha',facealpha,'EdgeColor',facecolor.*0.5,'LineWidth',0.2);

%bottom
fac_top = 1:size(loc,1); 
vert_top = vert1;
patch('Vertices',vert_top,'Faces',fac_top, ...
    'FaceVertexCData',hsv(6),'FaceColor',facecolor, ...
    'FaceAlpha',facealpha,'EdgeColor',facecolor.*0.5,'LineWidth',0.2);

  
end

