function plot_bldCollapse_3D(Bldfilename,EQfile,Rhr)
% Parameters:
% <Bldfilename> - building file. Use a format similar to BuildignsExample.csv
% <EQfile> - file recording collapse states
% <Rhr> - the ratio of radius to height.

figure

T = readtable(Bldfilename,'PreserveVariableNames',true,'ReadRowNames',true, ...
    'Delimiter',',');
load(EQfile); % DepCell,IRTsCell,FSCell

hold on

for i=1:height(T)
    loc = jsondecode(T.('Footprint'){i});
    x = loc(:,1)';
    y = loc(:,2)';
    Height = T{i,'Height'};
    bldcolor = [0.4660 0.6740 0.1880]; % green
    bldalpha = 1;
    if FSCell{1}(i)==1 % collapse
        bldcolor = [0.6350 0.0780 0.1840]; % red
        bldalpha = 1;
        % cordon area
        polyin = polyshape(x,y);
        [xc,yc] = centroid(polyin);
        FaceAlpha = 0.5;
        plot_circle([xc,yc],Rhr*Height,FaceAlpha);
    end
    CreateBld([x;y]',Height,bldcolor,bldalpha);
end

end

