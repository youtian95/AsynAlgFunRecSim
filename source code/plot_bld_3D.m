function plot_bld_3D(filename,facecolor,facealpha,iBld,Rhr)
% Parameters:
% <filename> - building file. Use a format similar to BuildignsExample.csv
% <facecolor> - building color
% <facealpha> - transparancy
% 
% Optional:
% <iBld> - the center building index
% <Rhr> - the ratio of radius to height.

addpath('../3rd party/webMercator2LngLat');

T = readtable(filename,'PreserveVariableNames',true,'ReadRowNames',true, ...
    'Delimiter',',');

% origin of coordinates
if isstruct(jsondecode(T.('Footprint'){1}))
    [x0,y0] = LngLat2webMercator(T.('Longitude')(1),T.('Latitude')(1));
    costheta = cos(T.('Latitude')(1)/180*pi);
end

figure

for i=1:height(T)
    loc = jsondecode(T.('Footprint'){i});
    if isstruct(loc)
        [x,y] = LngLat2webMercator( ...
            loc.geometry.coordinates(1,:,1),loc.geometry.coordinates(1,:,2));
        x = (x - x0).*costheta;
        y = (y - y0).*costheta;
    else
        x = loc(:,1)';
        y = loc(:,2)';
    end
    if any(strcmp(T.Properties.VariableNames,'Height'))
        Height = T{i,'Height'};
    elseif any(strcmp(T.Properties.VariableNames,'NumberOfStories'))
        Height = T{i,'NumberOfStories'}*3;
    end
    bldcolor = facecolor;
    bldalpha = facealpha;
    if nargin > 3 && strcmp(T.Properties.RowNames{i},num2str(iBld))
        bldcolor = [0.6350 0.0780 0.1840];
        bldalpha = 1;
    end
    CreateBld([x;y]',Height,bldcolor,bldalpha);
end

% plot cordon area
if nargin > 3
    hold on
    loc = jsondecode(T.('Footprint'){iBld});
    if isstruct(loc)
        [x,y] = LngLat2webMercator( ...
            loc.geometry.coordinates(1,:,1),loc.geometry.coordinates(1,:,2));
        x = (x - x0).*costheta;
        y = (y - y0).*costheta;
    else
        x = loc(:,1)';
        y = loc(:,2)';
    end
    if any(strcmp(T.Properties.VariableNames,'Height'))
        Height = T{iBld,'Height'};
    elseif any(strcmp(T.Properties.VariableNames,'NumberOfStories'))
        Height = T{iBld,'NumberOfStories'}*3;
    end
    polyin = polyshape(x,y);
	[xc,yc] = centroid(polyin);
    FaceAlpha = 0.5;
    plot_circle([xc,yc],Rhr*Height,FaceAlpha);
end

end

