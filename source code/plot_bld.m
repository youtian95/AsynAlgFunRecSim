function plot_bld(filename,facecolor,alpha)

addpath('../3rd party/webMercator2LngLat');
T = readtable(filename);

figure

hold on

[x0,y0] = LngLat2webMercator(T.('Longitude')(1),T.('Latitude')(1));
costheta = cos(T.('Latitude')(1)/180*pi);
% f = waitbar(0,'Please wait...');
for i=1:height(T)
%     waitbar(i/height(T),f,'Loading your data');
    Footprint=jsondecode(T.('Footprint'){i});
    loc = Footprint.geometry.coordinates;
    [x,y] = LngLat2webMercator(loc(1,:,1),loc(1,:,2));
    x = (x - x0).*costheta;
    y = (y - y0).*costheta;
    patch(x,y,facecolor,'FaceAlpha',alpha,'EdgeAlpha',alpha);

%     % centroid
%     [xc,yc] = LngLat2webMercator(T.('Longitude')(i),T.('Latitude')(i));
%     xc = (xc - x0).*costheta;
%     yc = (yc - y0).*costheta;
%     scatter(xc,yc);
end
% close(f);
axis off

end

