
config_bars_single_prepro_per_chart;

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
for i = 1 : length(cnn_names)
    
    % Prepare the subplot
    fig = figure('Position', [100, 100, 480, 700]);
    %fig = figure;
    
    % Plot the bars with their errors
    b = barweb(auc_values_to_plot(:,i), std_values_to_plot(:,i), [], [], [], [], [], [], [], [], 2, []);

    for j = 1 : length(tranfer_strategy_files)
        b.bars(j).EdgeColor = 'black';
        errors.bars(j).EdgeColor = 'black';
    end
    
    % Assign labels to the axis
    ylim(lim_axis);
    xlabel(cnn_names{i});
    ylabel('Area under the average ROC curve');

    set(gca,'YTick',[lim_axis(1):0.05:lim_axis(2)]) 


    box on
    hline = refline([0 maxValue]);
    hline.Color = 'b';
    set(gca,'XTickLabel',[])
    grid(gca,'on');
    
    set(fig,'Units','Inches');
    pos = get(fig,'Position');
    set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

    %if (i==length(cnn_names))
    if (i==1)
        legend(tranfer_strategy_names, 'Location', 'northwest');
    end  
    
    print(fig,fullfile(outputfolder, strcat(cnn_names{i},'.png')),'-dpng','-r0')
    print(fig,fullfile(outputfolder, strcat(cnn_names{i},'.pdf')),'-dpdf','-r0')
    %close
    %saveas(fig,fullfile(outputfolder, strcat(cnn_names{i},'.pdf')));
    
end