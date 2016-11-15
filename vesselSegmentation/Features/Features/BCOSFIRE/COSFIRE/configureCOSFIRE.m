function operator = configureCOSFIRE(featureImage,keypoint,params)


if strcmp(params.inputfilter.name,'Gabor')
    % Get responses of a Bank of Gabor filters
    input = getGaborResponse(featureImage,params.inputfilter.Gabor,params.inputfilter.Gabor.lambdalist,params.inputfilter.Gabor.thetalist);

elseif strcmp(params.inputfilter.name,'DoG')
    % Get responses of a Bank of DoG filters
    input = getDoGBankResponse(featureImage,params.inputfilter.DoG);
end

%figure; showim(input);

%Suppress the responses that are lower than a given threshold t1 from the maximum response
input(input < params.COSFIRE.t1*max(input(:))) = 0;    

operator.tuples = getCOSFIRETuples(input,keypoint,params);    
operator.params = params;


function tuples = getCOSFIRETuples(input,keypoint,params)

tuples = [];
[sz(1) sz(2) sz(3) sz(4)] = size(input);
maxrho = max(params.COSFIRE.rholist);
supportRadius = ceil(maxrho + (params.COSFIRE.sigma0 + (params.COSFIRE.alpha*maxrho))*3);

% Enlarge the input area
biginput = zeros(sz(1) + (2*supportRadius),sz(2) + (2*supportRadius),sz(3),sz(4));
biginput(supportRadius+1:end-supportRadius,supportRadius+1:end-supportRadius,:,:) = input;
keypoint = keypoint + supportRadius;

biginput(biginput < params.COSFIRE.t2*max(biginput(:))) = 0;
maxInput = max(reshape(biginput,sz(1)+(2*supportRadius),sz(2)+(2*supportRadius),prod(sz(3:end))),[],3);

for r = 1:length(params.COSFIRE.rholist)  
    tuple = getTuples(biginput, maxInput,keypoint,params.COSFIRE.rholist(r),params);
    tuples = [tuples [tuple.param1;tuple.param2;repmat(params.COSFIRE.rholist(r),1,length(tuple.phi));tuple.phi]];
end

function tuple = getTuples(input,maxInput,keypoint,rho,params)

if rho == 0
    if strcmp(params.inputfilter.name,'Gabor')
        centreResponses = reshape(input(keypoint(1),keypoint(2),:),length(params.inputfilter.Gabor.thetalist),length(params.inputfilter.Gabor.lambdalist))';
        [thetaMax, lambdaIndex] = max(centreResponses,[],1);
        thetaIndex = find(thetaMax);
        tuple.param1 = params.inputfilter.Gabor.lambdalist(lambdaIndex(thetaIndex));
        tuple.param2 = params.inputfilter.Gabor.thetalist(thetaIndex);        
    elseif strcmp(params.inputfilter.name,'DoG')
        centreResponses = squeeze(input(keypoint(1),keypoint(2),:,:));
        [polarityMax, sigmaIndex] = max(centreResponses,[],1);
        polarityIndex = find(polarityMax);
        tuple.param1 = params.inputfilter.DoG.polaritylist(polarityIndex);
        tuple.param2 = params.inputfilter.DoG.sigmalist(sigmaIndex(polarityIndex));        
    end
    tuple.phi = zeros(1,length(tuple.param2));        
elseif rho > 0
    tuple.param1 = [];
    tuple.param2 = [];
    tuple.phi    = [];
        
    philist = (1:360) * pi / 180;
    respAlongCircle = maxInput(sub2ind(size(maxInput),round(keypoint(1) - rho*sin(philist)),round(keypoint(2) + rho*cos(philist))));
       
    if length(unique(respAlongCircle)) == 1
        % The input along the circle of the given radius rho is constant      
        return;
    end
    
    BW = bwlabel(imregionalmax(respAlongCircle));
    npeaks = max(BW(:));
    peaks = zeros(1,npeaks);
    for i = 1:npeaks
        peaks(i) = floor(mean(find(BW == i)));
    end    
    
    peaklist = zeros(1,length(philist));
    peaklist(peaks) = respAlongCircle(peaks);
    [peaklist peaklocs] = findpeaks(peaklist,'minpeakdistance',round(params.COSFIRE.eta*180/pi));
    [phivalues uidx] = unique(mod(philist(peaklocs),2*pi));  
    if isempty(phivalues)              
        return;
    end
    if phivalues(1)+(2*pi) - phivalues(end) < params.COSFIRE.eta
        if peaklist(uidx(1)) <= peaklist(uidx(end))
            phivalues(1) = [];
        else
            phivalues(end) = [];
        end
    end
    [x y] = pol2cart(phivalues,rho);    
    for i = 1:length(phivalues)
        if strcmp(params.inputfilter.name,'Gabor')
            responses = reshape(input(keypoint(1)-round(y(i)),keypoint(2)+round(x(i)),:),length(params.inputfilter.Gabor.thetalist),length(params.inputfilter.Gabor.lambdalist))';        
            [thetaMax, lambdaIndex] = max(responses,[],1);
            thetaIndex = find(thetaMax);
            tuple.param1 = [tuple.param1 params.inputfilter.Gabor.lambdalist(lambdaIndex(thetaIndex))];
            tuple.param2 = [tuple.param2 params.inputfilter.Gabor.thetalist(thetaIndex)];
            tuple.phi    = [tuple.phi repmat(phivalues(i),1,length(thetaIndex))];
        elseif strcmp(params.inputfilter.name,'DoG')
            responses = squeeze(input(keypoint(1)-round(y(i)),keypoint(2)+round(x(i)),:,:));
            [polarityMax, sigmaIndex] = max(responses,[],1);
            polarityIndex = find(polarityMax);            
            tuple.param1 = [tuple.param1 params.inputfilter.DoG.polaritylist(polarityIndex)];
            tuple.param2 = [tuple.param2 params.inputfilter.DoG.sigmalist(sigmaIndex(polarityIndex))];            
            tuple.phi    = [tuple.phi repmat(phivalues(i),1,length(polarityIndex))];            
        end
    end    
end