function plot_bld_DS(filename,LossSimDir,Type,isim)

% Type: DS_Struct/DS_NonStruct_DriftSen/DS_NonStruct_AccelSen

if nargin<=3
    isim = 1;
end

addpath('../3rd party/webMercator2LngLat');
T = readtable(filename);

% read result files
Loss_results = {};
f = waitbar(0,'Reading results...');
for i=1:height(T)
    waitbar(i/size(T,1),f,'Reading results...');
    BldID = T{i,'id'};
    T_loss = readtable(fullfile(LossSimDir, ...
        ['BldLoss_bldID_',num2str(BldID),'.csv']), ...
        'ReadRowNames',1);
    Loss_results{i} = T_loss;
end
close(f);

figure

% green blue yellow red
facecolor = [0.4660 0.6740 0.1880; ... %green
    0.3010 0.7450 0.9330; ... % light blue
    0 0.4470 0.7410; ... %blue 
    0.9290 0.6940 0.1250; ... % yellow
    0.6350 0.0780 0.1840; ... % red
    213/255 202/255 189/255]; %grey

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
    DS = Loss_results{i}{isim,Type};
    if strcmp(DS,'None')
        C = facecolor(1,:); 
    elseif strcmp(DS,'Slight')
        C = facecolor(2,:); 
    elseif strcmp(DS,'Moderate')
        C = facecolor(3,:); 
    elseif strcmp(DS,'Extensive')
        C = facecolor(4,:); 
    elseif strcmp(DS,'Complete')
        C = facecolor(5,:); 
    elseif strcmp(DS,'UNKNOWN')
        C = facecolor(6,:); 
    else
        error(['Wrong damage states! ', ...
            'id: ', num2str(T{i,'id'}), '; ' ...
            'DS: ', DS]);
    end
    patch(x,y,C);
end
% close(f);
axis off

% Placeholder patches
hold on;
for il = 1:size(facecolor,1)
    hl(il) = patch(NaN, NaN, facecolor(il,:));
end
label = {'None','Slight','Moderate','Extensive','Complete'};
lgd = legend(hl,label);
lgd.Title.String = 'Damage states';
lgd.Title.FontSize = 10;
lgd.Box = 'off';
lgd.FontName = 'Times New Roman';

end

