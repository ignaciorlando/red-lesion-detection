
tag = 'without-vessel-subtraction-without-od  - k=';
k = 40:20:180;
scale_ranges_for_plot = 3:3:30;

figure(1);

legends_strings = cell(length(k), 1);
for i = 1 : length(k)
    
    % load data
    load(strcat(tag, num2str(k(i)), '.mat'));
    % plot the sensitivity curve
    plot(scale_ranges_for_plot, per_lesion_sensitivity(1:length(scale_ranges_for_plot)), 'o-', 'LineWidth', 1.5);
    hold on
    legends_strings{i} = strcat('k=', num2str(k(i)));
    
end
%scale_ranges_for_plot = scale_ranges;
legend(legends_strings, 'location', 'best');
xlim([scale_ranges_for_plot(1) scale_ranges_for_plot(end)]);
ylim([0 1]);
set(gca,'XTick',scale_ranges_for_plot(1):3:scale_ranges_for_plot(end));
xlabel('L value');
ylabel('Per lesion sensitivity');
box on
grid on
hold off


figure(2);

for i = 1 : length(k)
    
    % load data
    load(strcat(tag, num2str(k(i)), '.mat'));
    % plot the sensitivity curve
    plot(scale_ranges_for_plot, fpi(1:length(scale_ranges_for_plot)), 'o-', 'LineWidth', 1.5)
    hold on
    
end
%scale_ranges_for_plot = scale_ranges;
legend(legends_strings, 'location', 'best');
xlim([scale_ranges_for_plot(1) scale_ranges_for_plot(end)]);
set(gca,'XTick',scale_ranges_for_plot(1):3:scale_ranges_for_plot(end));
xlabel('L value');
ylabel('FPI');
box on
grid on
hold off