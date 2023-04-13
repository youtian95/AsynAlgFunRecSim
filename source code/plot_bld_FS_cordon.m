function plot_bld_FS_cordon(filename,RT,t,Rhr,D)
% <RT> - 1 x N cell - recording recovery time for each building. T{i,j}
% is a 1xM vector, where M is the number of functional states.
% <t> - time after earthquakes
% <D> - D{1,N}{j} - D{isim，i}{j} is a nx2 matrix, and refers to the i-th
% building's j-th state's dependent buildings and states. The 1st col is
% building indices and 2rd col is the corresonding state indices.

DefaultBldFaceAlpha = 1;
DefaultBldEdgeAlpha = 0;
DefaultEdgeColor = [0,0,0];

addpath('../3rd party/webMercator2LngLat');
T = readtable(filename);

figure

% green blue yellow red
facecolor = [0.4660 0.6740 0.1880; ... %green
    0 0.4470 0.7410; ... %blue 
    0.9290 0.6940 0.1250; ... % yellow
    0.6350 0.0780 0.1840]; % red

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
    ind = find(t>=RT{1,i});
    FS = ind(end);
    if FS==1
        C = facecolor(4,:); 
    elseif FS==2
        C = facecolor(3,:); 
    elseif FS==3
        C = facecolor(2,:); 
    elseif FS==4
        C = facecolor(1,:); 
    else
        error(['Wrong damage states! ', ...
            'id: ', num2str(T{i,'id'}), '; ' ...
            'DS: ', FS]);
    end

    BldFaceAlpha = DefaultBldFaceAlpha;
    BldEdgeAlpha = DefaultBldEdgeAlpha;
    EdgeColor = DefaultEdgeColor;
    
%     % check dependent buldings 
%     if FS<4
%         dep1 = D{1,i}{FS};
%         for idep = 1:size(dep1,1)
%             ind1 = find(t>=RT{1,dep1(idep,1)});
%             FS1 = ind1(end);
%             if FS1<dep1(idep,2)
%                 EdgeColor = 'r';
%                 BldEdgeAlpha = 1;
%                 break
%             end
%         end
%     end
    % plot
    patch(x,y,C,'FaceAlpha',BldFaceAlpha, ...
        'EdgeAlpha',BldEdgeAlpha,'EdgeColor',EdgeColor);
    % cordon area
    if FS==1
        hold on
        % cordon area
        [xc,yc] = LngLat2webMercator(T.('Longitude')(i),T.('Latitude')(i));
        xc = (xc - x0).*costheta;
        yc = (yc - y0).*costheta;
        FaceAlpha = 0.5;
        if any(strcmp(T.Properties.VariableNames,'Height'))
            Height = T{i,'Height'};
        elseif any(strcmp(T.Properties.VariableNames,'NumberOfStories'))
            Height = T{i,'NumberOfStories'}*3;
        end
        plot_circle([xc,yc],Rhr*Height,FaceAlpha);
    end
end
% close(f);
axis off

% Placeholder patches
hold on;
for il = 1:size(facecolor,1)
    hl(il) = patch(NaN, NaN, facecolor(il,:), ...
        'FaceAlpha',DefaultBldFaceAlpha, ...
        'EdgeAlpha',DefaultBldEdgeAlpha,'EdgeColor',DefaultEdgeColor);
end
label = {'Normal','Functional','Safe','Unsafe'};
lgd = legend(hl,label);
lgd.Title.String = 'Functional states';
lgd.Title.FontSize = 10;
lgd.Box = 'off';
lgd.FontName = 'Times New Roman';

end

