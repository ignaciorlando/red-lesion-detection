
config_bars_compare_preprocessing;

% Prepare values to plot
auc_values_to_plot = zeros(length(tranfer_strategy_files), length(cnn_names));
std_values_to_plot = zeros(length(tranfer_strategy_files), length(cnn_names));

for i = 1 : length(tranfer_strategy_files)
    
    % For each cnn type
    for j = 1 : length(cnn_names)
        
        % Load results
        load(strcat(foldertag, filesep, cnn_names_in_files{j}, '-', tranfer_strategy_files{i}, filesep, filetag));
        % Store results in values_to_plot
        [~, ~, auc_values_to_plot(i,j), std_values_to_plot(i,j)] = verticalAvgROC(results_kernel);
        
    end
    
end

maxValue = max(auc_values_to_plot(:));

% Prepare the subplot
fig = figure;
for i = 1 : length(tranfer_strategy_files)
    
    % Prepare the subplot
    %fig = figure('Position', [100, 100, 200, 300]);
    
    % Plot the bars with their errors
    subplot(1, length(tranfer_strategy_files), i)
    b = barweb(auc_values_to_plot(i,:)', std_values_to_plot(i,:)', [], [], [], [], [], [], [], [], 2, []);

    for j = 1 : length(cnn_names)
        b.bars(j).EdgeColor = 'black';
        errors.bars(j).EdgeColor = 'black';
    end
    
    % Assign labels to the axis
    ylim(lim_axis);
    xlabel(tranfer_strategy_names{i});
    %ylabel('AUC values');
    set(gca,'YTick',[lim_axis(1):0.05:lim_axis(2)]) 


    box on
    hline = refline([0 maxValue]);
    hline.Color = 'b';
    set(gca,'XTickLabel',[])
    grid(gca,'on');
    
    set(fig,'Units','Inches');
    pos = get(fig,'Position');
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

    if (i==length(tranfer_strategy_files))
        legend(cnn_names);
    end
    
end