
config_roc_curves; 
             
figure;
aucs = cell(size(results_files));

% for each of the results files
for i = 1 : length(results_files)
    % load the results
    load(strcat(rootDropbox, filesep, 'Dropbox', filesep, results_files{i}));
    % decide if there is a result per regularizer or if the experiment was
    % made using kernels
    if (exist('results_per_regularizer','var')~=0)
        results = results_per_regularizer{2};
    else
        results = results_kernel;
    end
    % compute the vertical average ROC curve
    [avg_tpr, avg_tnr, auc, stdev_auc] = verticalAvgROC(results);
    % plot the curve
    %plot(1-avg_tnr, avg_tpr);
    %errorbar(1-avg_tnr, avg_tpr, stdev_auc*ones(size(avg_tpr)));
    lineProps.col = colors(i);
    mseb(1-avg_tnr, avg_tpr, stdev_auc*ones(size(avg_tpr)), lineProps, 1);
    
    % round auc and standard deviation to 4 decimals
    auc = round((auc*10000))/10000;
    stdev_auc = round((stdev_auc*10000))/10000;
    aucs{i} = strcat(results_names{i}, '. AUC = ', num2str(auc), '\pm', num2str(stdev_auc));
    hold on
    % remove current results before loading new results
    if (exist('results_per_regularizer','var')~=0)
        clear results_per_regularizer;
    else
        clear results_kernel;
    end
    
end

% add legends and other data to the plot
xlabel('FPR (1 - Sp)');
ylabel('TPR (Se)');
grid on
box on
hold off
legend(aucs,'location','southeast');
ylim([0 1]);

if (strcmp(problem, 'dr-detection'))
   title('DR screening (R0 vs {R1,R2,R3})');
elseif (strcmp(problem, 'need-to-referral'))
   title('Need-to-referral ({R0,R1} vs {R2,R3})');
end