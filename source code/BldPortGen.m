function [DepCell,IRTsCell,FSCell] = BldPortGen(n,Neq,P,hmin,hmax,Rhr,d, ...
    RTperM, HPattern)
% generation of a portfolio of buildings
% 
% returns:
% <DepCell> - cell(Neq)
% <IRTsCell> - cell(Neq)
% <FSCell> - cell(Neq)

    DepCell = {};
    IRTsCell = {};
    FSCell = {};

    % distance matrix
    % 3x3 index is like [1,4,7;2,5,8;3,6,9]
    [X,Y] = meshgrid(1:1:n);
    xVec = reshape(X,1,n*n).*d;
    yVec = reshape(Y,1,n*n).*d;
    Dist = sqrt((repmat(xVec,n*n,1)-repmat(xVec',1,n*n)).^2 ...
        + (repmat(yVec,n*n,1)-repmat(yVec',1,n*n)).^2);
  
    
    parfor i_eq = 1:Neq
        if isempty(HPattern)
            h = HeightExp(hmin,hmax,n); % building height
        else
            h = repmat(HPattern,n/size(HPattern,1),n/size(HPattern,2));
        end
        RT = RTperM.*h; % repair time
        IfC = rand(n)<P; % whether collapse
        
        % dependency relationship 
        % 3x3 index is like [1,4,7;2,5,8;3,6,9]
        lind = 1:(n*n);
        Dep = [];
        for i=1:(n*n)
            col = Dist(i,:)<(Rhr.*reshape(h,1,numel(h)));
            col(i) = false;
            Dep1 = ones(sum(col),4);
            Dep1(:,1) = i;
            Dep1(:,3) = lind(col);
            Dep1(:,4) = 2;
            Dep = [Dep;Dep1];
        end
        DepCell{i_eq} = Dep;
        
        IRTs = mat2cell([zeros(n*n,1),reshape(RT,n*n,1)],ones(n*n,1),2)';
        IRTsCell{i_eq} = IRTs;
        
        FS = 2.*ones(1,n*n);
        FS(reshape(IfC,1,n*n)) = 1;
        FSCell{i_eq} = FS;
    end
    
end
