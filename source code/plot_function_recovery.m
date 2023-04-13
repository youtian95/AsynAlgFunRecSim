function plot_function_recovery(x,y,IndColor,PlotMean,MeanColor)
% x: 1 x N
% y: Neq X N

if nargin<3
    IndColor = [0.6 0.6 0.6];
end
if nargin<4
    PlotMean = false;
end
if nargin<5
    MeanColor = [0.6350 0.0780 0.1840];
end

hold on;

p = plot(x,y,'LineWidth',0.5,'Color',IndColor);
if PlotMean
    plot(x,mean(y,1),'LineWidth',0.5,'Color',MeanColor);
end

box on;
% grid on;
xlabel('$\mathrm{Time\ (days)}$','Interpreter','latex');
ylabel('$\mathrm{Function}$','Interpreter','latex');
% title(['$S_{a,y}=',num2str(IM_1),'\ \mathrm{g},\ T=', , ...
%     '$'],'Interpreter','latex');
ax = gca; 
ax.FontSize = 12;
ax.FontName = 'Times new roman';
ax.TickLength = [0.02 0.035].*1.5;
% ylim([0 1]);
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 6 5]);

end

