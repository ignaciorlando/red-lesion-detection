
% performance of the classifiers
classifiers = {'L1', 'L2', 'k-sup', 'RF'};
performances = [0.3049, 0.2049, 0.3529, 0.5108];

% Plot
figure, bar(performances)
ax = gca;
set(ax, 'XTickLabels', classifiers)
ylabel('FROC score')
xlabel('Classifiers')
text(1:4,performances,num2str(performances','%0.4f'),...
    'HorizontalAlignment','center',...
    'VerticalAlignment','bottom')
grid on