function CreateBldFootprint(n,d,HPattern,filename)

% width
w = 20;

fileID = fopen(filename,'w');

% centroid point
[X,Y] = meshgrid(1:1:n);
xVec = reshape(X,1,n*n).*d;
yVec = reshape(Y,1,n*n).*d;

% height
h = repmat(HPattern,n/size(HPattern,1),n/size(HPattern,2));
h = reshape(h,1,[]);

fprintf(fileID,'id,Height,Footprint\n');
for i=1:(n*n)
    id = i;
    Height = h(i);
    % footprint
    Footprint = ['"[[', ...
        num2str(xVec(i)-w/2),',',num2str(yVec(i)-w/2),'],[', ...
        num2str(xVec(i)+w/2),',',num2str(yVec(i)-w/2),'],[', ...
        num2str(xVec(i)+w/2),',',num2str(yVec(i)+w/2),'],[', ...
        num2str(xVec(i)-w/2),',',num2str(yVec(i)+w/2),'],[', ...
        num2str(xVec(i)-w/2),',',num2str(yVec(i)-w/2),']]"'];
    % write
    fprintf(fileID,'%u,%f,%s\n',id,Height,Footprint);
end

fclose(fileID);

end