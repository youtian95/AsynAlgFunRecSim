BldFile = '../input data/BuildingData/SanFrancisco_buildings_partial.csv';


T = readtable(BldFile);
locSet = {}; % {{loc1,loc2}, ...}
locSetInd = {}; % {[1,2], ...}
for i=1:height(T)
    Footprint=jsondecode(T.('Footprint'){i});
    % loc(i_polygon, i_vertex, i_long/lat)
    loc = Footprint.geometry.coordinates; 
    
    % detect multipolygon
    Num = 0;
    if size(loc,1)>1
        Num = Num+1;
    end
    if Num>0
        warning([Num,' multipolygons exist!']);
    end
    
    % detect duplicate footprint
    BoolExist = false;
    for j=1:numel(locSet)  % {{loc1,loc2}, ...}
        if all(size(locSet{j}{1})==size(loc),'all') ....
                && all(locSet{j}{1}==loc,'all')
            locSet{j} = [locSet{j},loc];
            locSetInd{j} = [locSetInd{j},j];
            BoolExist = true;
            break
        end
    end
    if ~BoolExist
        locSet = [locSet,{{loc}}];
        locSetInd = [locSetInd,{{j}}];
    end
end