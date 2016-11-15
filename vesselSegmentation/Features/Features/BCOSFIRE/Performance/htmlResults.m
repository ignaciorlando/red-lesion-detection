function [ output ] = htmlResults(exp_folder, dataset)
    DRIVE = 1;
    STARE = 2;
    CHASE = 3;

    if dataset == DRIVE
        d = dir([exp_folder,'*.','tif']);
    elseif dataset == STARE
        d = dir([exp_folder,'*.','ppm']);
    elseif dataset == CHASE
        d = dir([exp_folder,'*.','tif']);
    end

    rowNames = [];
    results = [];
    for i = 1:size(d, 1)
        if exist([exp_folder, d(i).name, '/result.mat'])
            rowNames = [rowNames; d(i).name];
            r = load([exp_folder, d(i).name, '/result.mat']);
            results = [results; r.result];
        end
    end
    
    accMat = [];
    output = [];
    spMat = [];
    seMat = [];
    
    tot_tp = zeros([1 256]);
    tot_fp = zeros([1 256]);
    totalp = 0;
    totaln = 0;
    
    for i = 1:size(results, 1)
        accMat = [accMat; results(i).data.accuracy];
        spMat = [spMat; results(i).data.specificity];
        seMat = [seMat; results(i).data.sensitivity];
        %all indexes for each image
        [acc ind] = max(results(i).data.accuracy);
        se = results(i).data.sensitivity(ind);
        sp = results(i).data.specificity(ind);
        re = results(i).data.recall(ind);
        pr = results(i).data.precision(ind);
        F = results(i).data.FMeasure(ind);
        AZ = results(i).data.AZ;
        
        tot_tp = tot_tp + results(i).data.truepositives;
        tot_fp = tot_fp + results(i).data.falsepositives;
        totalp = totalp + results(i).data.totalp;
        totaln = totaln + results(i).data.totaln;
        
        output = [output; [se sp re pr F acc AZ] ];
        
        %save segmented image
        
    end;
    %total = cell(1, 4);
    total.tp = tot_tp;
    total.fp = tot_fp;
    total.totalp = totalp;
    total.totaln = totaln;
%    save([exp_folder, 'total_res.mat'], 'total');
    
    
    colNames = {'Se' 'Sp' 'Re' 'Pr' 'F' 'Acc' 'Auc'};
    rowNames = cellstr(rowNames);
    rowNames = [rowNames; 'Avg'];
    
    avgAcc = mean(accMat, 1);
    [avgAcc threshold] = max(avgAcc);
    
    output(:, 6) = accMat(:, threshold);
    
    for i = 1:size(results, 1)
        output(i,1) = results(i).data.sensitivity(threshold);
        output(i,2) = results(i).data.specificity(threshold);
    end
    %threshold
    meanValues = mean(output, 1);
    meanValues(6) = avgAcc;
    output = [output; meanValues];
    
    save([exp_folder, 'totres.mat'], 'output');
    
    html = makeHtmlTable(output, [], rowNames, colNames, [], 4);
    
    fd = fopen([exp_folder, 'results.html'], 'w');
    for i = 1:length(html)
        fprintf(fd, '%s', html{i});
    end
    fclose(fd);
end

