function plot_circle(C,R,FaceAlpha)
% <C> - centroid - [x,y]
% <R> - circus 

r=linspace(0,R,2); 
theta=linspace(0,2*pi,30); 
[R1,the]=meshgrid(r,theta); 
[x,y]=pol2cart(the,R1); 
x = x + C(1);
y = y + C(2);
z = zeros(size(x))+0.001;
cordonColor = [0.8500 0.3250 0.0980];
fill3(x,y,z,cordonColor,'EdgeColor',[0 0 0],'EdgeAlpha',0.5, ...
    'FaceAlpha',FaceAlpha,'LineWidth',0.2);

end

