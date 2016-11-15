function stats = getStatsData(img,truthseg,mask,span)
img = rescaleImage(img.*mask,min(span),max(span));
positiveimage = truthseg & mask;
negativeimage = ~truthseg & mask;

stats.totalp = sum(positiveimage(:));
stats.totaln = sum(negativeimage(:));

tp = histc(img(positiveimage(:)), span);
tp = cumsum(tp(end:-1:1)');
tp = tp(end:-1:1);

fp = histc(img(negativeimage(:)), span);
fp = cumsum(fp(end:-1:1)');
fp = fp(end:-1:1);

fn = stats.totalp - tp;
tn = stats.totaln - fp;

se = tp ./ (tp + fn);
sp = tn ./ (tn + fp);
re = tp ./ (tp + fn);
pr = tp ./ (tp + fp);
F = (2 .* pr .* re) ./ (pr + re);

stats.truepositives = tp;
stats.falsepositives  = fp;
stats.truenegatives = tn;
stats.falsenegatives = fn;
stats.sensitivity = se;
stats.specificity = sp;
stats.recall = re;
stats.precision = pr;
stats.FMeasure = F;
stats.accuracy = (tp + tn) ./ (tp + tn + fp + fn);

N = tp + fn + tn + fp;
S = (tp + fn) ./ N;
P = (tp + fp) ./ N;
stats.mcc = (tp ./ N - S .* P)./sqrt(P.*S.*(1-S).*(1-P)); 
    
stats.AZ = rocarea(fp',tp', stats.totalp, stats.totaln);

[mx ind] = max(stats.accuracy);
stats.result = (img .* mask) > ind + 1;