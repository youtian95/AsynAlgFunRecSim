function [dist,ind] = FindClosestBld(xq,yq,BldFile,n)

addpath('../3rd party/webMercator2LngLat');

T = readtable(BldFile);

% Cartesian coordinates
[x0,y0] = LngLat2webMercator(T.('Longitude')(1),T.('Latitude')(1));
costheta = cos(T.('Latitude')(1)/180*pi);
[x,y] = LngLat2webMercator(T{:,'Longitude'}',T{:,'Latitude'}');
x = (x - x0).*costheta;
y = (y - y0).*costheta;

Dist = sqrt((xq'-x).^2+(yq'-y).^2);
[dist,ind] = sort(Dist,2);
dist = dist(1:n);
ind = ind(1:n);

end

