function Samples_all = plot_cdf_regional(AllLossSimResults,DV, ...
    THALossSimResults)
% DS: {'RepairCost_Total', ...
% 	'RepairCost_Struct','RepairCost_NonStruct_DriftSen',  ...
% 	'RepairCost_NonStruct_AccelSen','RepairTime','RecoveryTime',...
% 	'FunctionLossTime'};

Samples_all = AllLossSimResults{:,DV};

figure

hold on;
for i=1:size(Samples_all,2)
    samples = Samples_all(:,i);
    p = plot(sort(samples),(1:numel(samples))./numel(samples), ...
        'LineWidth', 1.5);
end
if nargin>2
    for i=1:size(Samples_all,2)
        samples = Samples_all(:,i);
        x = THALossSimResults{1,DV{i}};
        y = interp1(sort(samples),(1:numel(samples))./numel(samples),x);
        s = scatter(x,y,'LineWidth',1.5,'MarkerEdgeColor','k'); 
    end
end
legendStr = DV;
if nargin>2
    legendStr = [DV,{'THA'}];
end
l = legend(legendStr);
l.Interpreter = 'none';

box on;
% grid on;
xlabel('$\mathrm{DV}$','Interpreter','latex');
ylabel('$\mathrm{CDF}$','Interpreter','latex');
% title(['$S_{a,y}=',num2str(IM_1),'\ \mathrm{g},\ T=', , ...
%     '$'],'Interpreter','latex');
ax = gca; 
ax.FontSize = 14;
ax.FontName = 'Times New Roman';
set(gcf,'Units','centimeters');
set(gcf,'Position',[5 5 10 8]);

end