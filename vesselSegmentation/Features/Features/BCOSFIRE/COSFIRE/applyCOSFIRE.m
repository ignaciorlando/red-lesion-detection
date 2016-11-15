function [output] = applyCOSFIRE(inputImage, operatorlist)

tuple = computeTuples(inputImage,operatorlist);
output = cell(1,length(operatorlist));

for opindex = 1:length(operatorlist)
    operator = operatorlist{opindex};

    cosfirefun = @(inputImage,operator,tuple) computeCOSFIRE(inputImage,operator,tuple);                                                  
    scalefun = @(inputImage,operator,tuple) scaleInvariantCOSFIRE(inputImage,operator,tuple,cosfirefun);
    rotationfun = @(inputImage,operator,tuple) rotationInvariantCOSFIRE(inputImage,operator,tuple,scalefun);
    output{opindex} = reflectionInvariantCOSFIRE(inputImage,operator,tuple,rotationfun);                     

    % Suppress values that are less than a fraction t3 of the maximum
    output{opindex}(output{opindex} < operator.params.COSFIRE.t3 * max(output{opindex}(:))) = 0;
end

function [tuple] = computeTuples(inputImage,operator)

if ~iscell(operator)
    operatorlist{1} = operator;
else
    operatorlist = operator;
end

set = cell(0);
index = 1;

for op = 1:length(operatorlist)
    params = operatorlist{op}.params;
    reflectOperator.tuples = operatorlist{op}.tuples;
                 
    for reflection = 1:2^params.invariance.reflection    
        if reflection == 2
            if strcmp(params.inputfilter.name,'Gabor')
                if params.inputfilter.symmetric == 1                
                    reflectOperator.tuples(2,:) = mod(pi - reflectOperator.tuples(2,:),pi);                
                else
                    reflectOperator.tuples(2,:) = mod(pi - reflectOperator.tuples(2,:),2*pi);
                end
            end
            reflectOperator.tuples(4,:) = mod(pi - reflectOperator.tuples(4,:),2*pi);
        end

        rotateOperator = reflectOperator;
        for psiindex = 1:length(params.invariance.rotation.psilist)
            if strcmp(params.inputfilter.name,'Gabor')
                if params.inputfilter.symmetric == 1
                    rotateOperator.tuples(2,:) = mod(reflectOperator.tuples(2,:) + params.invariance.rotation.psilist(psiindex),pi);
                else
                    rotateOperator.tuples(2,:) = mod(reflectOperator.tuples(2,:) + params.invariance.rotation.psilist(psiindex),2*pi);
                end
            end
            rotateOperator.tuples(4,:) = mod(reflectOperator.tuples(4,:) + params.invariance.rotation.psilist(psiindex),2*pi);            

            scaleOperator = rotateOperator;
            for upsilonindex = 1:length(params.invariance.scale.upsilonlist)
                % Scale the values of parameters lambda and rho of every tuple by a given upsilon value
                
                if strcmp(params.inputfilter.name,'Gabor')
                    scaleOperator.tuples(1,:) = rotateOperator.tuples(1,:) * params.invariance.scale.upsilonlist(upsilonindex);   
                elseif strcmp(params.inputfilter.name,'DoG')
                    scaleOperator.tuples(2,:) = rotateOperator.tuples(2,:) * params.invariance.scale.upsilonlist(upsilonindex);   
                end
                
                scaleOperator.tuples(3,:) = rotateOperator.tuples(3,:) * params.invariance.scale.upsilonlist(upsilonindex);

                if strcmp(params.COSFIRE.outputfunction,'weightedgeometricmean')
                    tupleweightsigma = sqrt(-max(scaleOperator.tuples(3,:))^2/(2*log(params.COSFIRE.mintupleweight)));
                    scaleOperator.tuples(5,:) = exp(-scaleOperator.tuples(3,:).^2./(2*tupleweightsigma*tupleweightsigma));
                else
                    scaleOperator.tuples(5,:) = ones(size(scaleOperator.tuples(3,:))); 
                end
                set{index} = scaleOperator.tuples;
                index = index + 1;
            end    
        end
    end
end

S = cell2mat(set);
S = round(S * 10000) / 10000;
inputfilterparams = unique(S(1:2,:)','rows');
tupleparams = unique(S([1:3,5],:)','rows');
sz = size(inputImage);

switch (params.ht)
    case 0        
        inputfilterresponse = zeros(sz(1),sz(2),size(inputfilterparams,1));
        for i = 1:size(inputfilterparams,1)
            inputfilterresponse(:,:,i) = getGaborResponse(inputImage,params,inputfilterparams(i,1),inputfilterparams(i,2));    
        end
        inputfilterresponse(inputfilterresponse < params.COSFIRE.t1*max(inputfilterresponse(:))) = 0;
        
        response = cell(1,size(tupleparams,1));
        for i = 1:size(tupleparams,1)
            index = ismember(inputfilterparams,tupleparams(i,1:2),'rows');
            ifresp = inputfilterresponse(:,:,index);
            
            % Compute the sigma of the 2D Gaussian function that will be
            % used to blur the corresponding output.
            sigma = (params.COSFIRE.sigma0 + (params.COSFIRE.alpha*tupleparams(i,3)));                

            if any(ifresp(:))
                if strcmp(params.COSFIRE.blurringfunction,'max')
                    response{i} = blurshift(ifresp,sigma,0,0);
                elseif strcmp(params.COSFIRE.blurringfunction,'sum')
                    blurfunction = fspecial('gaussian',round([sigma sigma].*6),sigma);
                    response{i} = conv2(ifresp,blurfunction,'same');
                    response{i} = circshift(response{i},[0,0]);
                end
            else
                response{i} = zeros(sz);
            end            

            if strcmp(params.COSFIRE.outputfunction,'weightedgeometricmean')                     
                weight = exp(-tupleparams(i,3)^2/(2*params.COSFIRE.weightingsigma*params.COSFIRE.weightingsigma)); 
                response{i} = response{i} .^ weight;                    
            end
        end
        tuple.response = response;
        tuple.params = tupleparams;          
    case 1
        inputfilterresponse = zeros(size(inputImage,1),size(inputImage,2),size(inputfilterparams,1));
        ninputfilterparams = size(inputfilterparams,1);
        hashkeylist = cell(1,ninputfilterparams);
        hashvaluelist = cell(1,ninputfilterparams);
        
        % Compute the responses of the bank of input filters
        for i = 1:ninputfilterparams
            hashkeylist{i} = getHashkey(inputfilterparams(i,:));
            hashvaluelist{i} = i;
            
            if strcmp(params.inputfilter.name,'Gabor')
                inputfilterresponse(:,:,i) = getGaborResponse(inputImage,params.inputfilter.Gabor,inputfilterparams(i,1),inputfilterparams(i,2));    
            elseif strcmp(params.inputfilter.name,'DoG')
                inputfilterresponse(:,:,i) = getDoG(inputImage,inputfilterparams(i,2), inputfilterparams(i,1), params.inputfilter.DoG.sigmaratio, 0, params.inputfilter.DoG.halfwaverect);
            end
        end
        inputfilterhashtable = containers.Map(hashkeylist,hashvaluelist);
        
        % Threshold the responses by a fraction t1 of the maximum response
        inputfilterresponse(inputfilterresponse < params.COSFIRE.t1*max(inputfilterresponse(:))) = 0;
        
        ntupleparams = size(tupleparams,1);
        hashkeylist = cell(1,ntupleparams);
        hashvaluelist = cell(1,ntupleparams);

        for i = 1:ntupleparams
            rho    = tupleparams(i,3);
            
            index = inputfilterhashtable(getHashkey(tupleparams(i,1:2)));
            hashkeylist{i} = getHashkey(tupleparams(i,1:3));    

            ifresp = inputfilterresponse(:,:,index);
            
            if any(ifresp(:))               
                % Compute the sigma of the 2D Gaussian function that will be
                % used to blur the corresponding output.
                sigma = (params.COSFIRE.sigma0 + (params.COSFIRE.alpha*rho));                
                
                if strcmp(params.COSFIRE.blurringfunction,'max')                    
                    hashvaluelist{i} = blurshift(ifresp,sigma,0,0); 
                elseif strcmp(params.COSFIRE.blurringfunction,'sum')
                    blurfunction = fspecial('gaussian',[1 round(sigma.*6)],sigma);
                    hashvaluelist{i} = conv2(blurfunction,blurfunction,ifresp,'same');
                end
            else
                hashvaluelist{i} = zeros(sz);
            end

            if strcmp(params.COSFIRE.outputfunction,'weightedgeometricmean')                                     
                hashvaluelist{i} = hashvaluelist{i} .^ tupleparams(i,4);                    
            end    
        end
        tuple.hashtable  = containers.Map(hashkeylist,hashvaluelist);  
end

function [output] = reflectionInvariantCOSFIRE(inputImage,operator,tuple,funCOSFIRE)

% Apply the given COSFIRE filter 
output = feval(funCOSFIRE,inputImage,operator,tuple);

if operator.params.invariance.reflection == 1
    % Apply a COSFIRE filter which is selective for a reflected version about the y-axis 
    % of the pattern of interest 
    reflectionDetector = operator;

    if strcmp(operator.params.inputfilter.name,'Gabor')
        if operator.params.inputfilter.symmetric == 1
            reflectionDetector.tuples(2,:) = mod(pi - reflectionDetector.tuples(2,:),pi);
        else
            reflectionDetector.tuples(2,:) = mod(pi - reflectionDetector.tuples(2,:),2*pi);
        end
    end
    reflectionDetector.tuples(4,:) = mod(pi - reflectionDetector.tuples(4,:),2*pi);

    reflectionoutput = feval(funCOSFIRE,inputImage,reflectionDetector,tuple);

    % Take the maximum value of the output of the two COSFIRE filters
    output = max(output, reflectionoutput);
end

function [output] = rotationInvariantCOSFIRE(inputImage,operator,tuple,funCOSFIRE)

output = zeros(size(inputImage));
noriens = length(operator.params.invariance.rotation.psilist);
rotations = zeros([size(inputImage) noriens]);

rotateDetector = operator;
    
for psiindex = 1:noriens 
    % Shift the values of parameters (theta,rho) of every tuple by a given psi value
    if strcmp(operator.params.inputfilter.name,'Gabor')
        if operator.params.inputfilter.symmetric == 1
            rotateDetector.tuples(2,:) = mod(operator.tuples(2,:) + operator.params.invariance.rotation.psilist(psiindex),pi);
        else
            rotateDetector.tuples(2,:) = mod(operator.tuples(2,:) + operator.params.invariance.rotation.psilist(psiindex),2*pi);
        end
    end
    rotateDetector.tuples(4,:) = operator.tuples(4,:) + operator.params.invariance.rotation.psilist(psiindex);            
    
    % Compute the output of COSFIRE for the given psi value
    rotoutput = feval(funCOSFIRE,inputImage,rotateDetector,tuple);    
    
    rotations(:,:, psiindex) = rotoutput;
    
    % Take the maximum over the COSFIRE outputs for all given values of psi
    output = max(rotoutput, output);
end

function [output] = scaleInvariantCOSFIRE(inputImage,operator,tuple,funCOSFIRE)

output = zeros(size(inputImage));
scaleDetector = operator;

for upsilonindex = 1:length(operator.params.invariance.scale.upsilonlist)
    % Scale the values of parameters lambda and rho of every tuple by a given upsilon value
    
    if strcmp(operator.params.inputfilter.name,'Gabor')
        scaleDetector.tuples(1,:) = operator.tuples(1,:) * operator.params.invariance.scale.upsilonlist(upsilonindex);   
    elseif strcmp(operator.params.inputfilter.name,'DoG')
        scaleDetector.tuples(2,:) = operator.tuples(2,:) * operator.params.invariance.scale.upsilonlist(upsilonindex);   
    end
    scaleDetector.tuples(3,:) = operator.tuples(3,:) * operator.params.invariance.scale.upsilonlist(upsilonindex);
        
    % Compute the output of COSFIRE for the given psi value
    scaleoutput = feval(funCOSFIRE,inputImage,scaleDetector,tuple);
    
    % Take the maximum over the COSFIRE outputs for all given values of upsilon
    output = max(output,scaleoutput);
end

function [output] = computeCOSFIRE(inputImage,operator,tuple)       
operator.tuples = round(operator.tuples * 10000) / 10000;       
sz = size(inputImage);
output = ones(sz);
ntuples = size(operator.tuples,2);
tupleoutputs = 0;
% Loop through all tuples (subunits) of the operator
outputs = zeros(sz(1), sz(2), ntuples);
for sindex = 1:ntuples
    % Convert the polar-coordinate shift vector (rho,phi) to image coordinates
    [col row] = pol2cart(operator.tuples(4,sindex),operator.tuples(3,sindex));  
    
    switch (operator.params.ht)
        case 0
            index = ismember(tuple.params,operator.tuples(1:3,sindex)','rows');
            tupleoutput = circshift(tuple.response{index},[fix(row),-fix(col)]);               
        case 1
            hashkey = getHashkey(operator.tuples(1:3,sindex)');            
            tupleoutput = circshift(tuple.hashtable(hashkey),[fix(row),-fix(col)]);
    end
    
    outputs(:,:,sindex) = tupleoutput;
    output = output .* tupleoutput;
    if ~any(output(:))
        output = zeros(sz);
        return;
    end    
end

if strcmp(operator.params.COSFIRE.outputfunction, 'weightedgeometricmean')
    % Compute the COSFIRE output using weighted geometric mean
    tupleweightsigma = sqrt(-max(operator.tuples(3,:))^2/(2*log(operator.params.COSFIRE.mintupleweight)));
    tupleweight = exp(-(operator.tuples(3,:).^2)./(2*tupleweightsigma*tupleweightsigma));    
    output = output .^ (1/sum(tupleweight));    
elseif strcmp(operator.params.COSFIRE.outputfunction, 'geometricmean')
    % Compute the COSFIRE output using geometric mean
    m = output .^ (1/ntuples);
    output = m;
elseif strcmp(operator.params.COSFIRE.outputfunction, 'arithmeticmean')
    output = mean(outputs, 3);
elseif strcmp(operator.params.COSFIRE.outputfunction, 'harmonicmean')
    output = harmmean(outputs, 3);
elseif strcmp(operator.params.COSFIRE.outputfunction, 'trimmedmean')
    mn = min(outputs,[],3);
    ind = mn == 0;
    output = trimmean(outputs, 80, 'weighted', 3);
    output(ind) = 0;
elseif strcmp(operator.params.COSFIRE.outputfunction, 'median')
    mn = min(outputs,[],3);
    ind = mn == 0;
    output = median(outputs, 3);
    output(ind) = 0;
else
    % Other multivariate functions can be used
end