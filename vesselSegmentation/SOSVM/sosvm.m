function [model, config, state] = sosvm(config, patterns, labels, oldstate)
% sosvm Learn a model using a SOSVM
% [model, config, state] = sosvm(config, patterns, labels, oldstate)
% OUTPUT: model: learned model
%         config: configuration structure, updated with learning
%         information
%         state: last state
% INPUT: config: configuration structure
%        patterns: cell-array with the training data
%        labels: training labels
%        oldstate: previous state
    
    state = bundler(); % initialize state
    
    % lambda = 1 / C
    state.lambda = 1 ./ (config.SOSVM.C);
    
    % Include additional parameters
    config.SOSVM.convergenceThreshold = 0.001;
    config.SOSVM.formulationType = 'margin';
    config.SOSVM.maxIterations = 40;
    config.SOSVM.minIterations = 10;
    
    % Initially, w has 0s
    config.SOSVM.w = zeros(config.SOSVM.sizePsi,1);
    state.w = config.SOSVM.w;
    
    % Set the positivity contraints
    for i=1 : length(config.SOSVM.posindx);
        % add in the positivity (submodularity) constraints
        phi = zeros(size(config.SOSVM.w));
        phi(config.SOSVM.posindx(i)) = 1;
        b = 0;
        % call bundler with hard constraint argument
        state = bundler(state, phi, b, false);
    end
    config.SOSVM.w = state.w;
    model.w = state.w;

    if (exist('oldstate','var'))
        for i=1:length(oldstate.b)
            if(oldstate.softVariables(i))
                state = bundler(state,oldstate.a(:,i),oldstate.b(i));
            end
        end
    end
    
    numIterations = 0;
    bestPrimalObjective = Inf;
    
    while (((bestPrimalObjective - state.dualObjective)/state.dualObjective > config.SOSVM.convergenceThreshold ...
            || config.SOSVM.minIterations>0 ) && numIterations < config.SOSVM.maxIterations)
        
        numIterations = numIterations + 1;
        config.SOSVM.minIterations = config.SOSVM.minIterations - 1;

        % Margin rescaling
        [phi, b] = computeOneslackMarginConstraint(config, model, patterns, labels);

        primalobjective = (state.lambda / 2) * (state.w' * state.w) + b - dot(state.w, phi);
        if ((primalobjective < bestPrimalObjective) || true)
            bestPrimalObjective = primalobjective;
            bestState = state;
        end
        
        fprintf([' %d primal objective: %f, best primal: %f, dual objective: %f, gap: %f\n'], ...
                   numIterations, primalobjective, bestPrimalObjective, state.dualObjective, ...
                   (bestPrimalObjective - state.dualObjective) / state.dualObjective);

        state = bundler(state, phi, b);
        config.SOSVM.w = state.w;
        model.w = state.w;
        assertPositivity(config, model);
    
    end
    
    config.SOSVM.w = bestState.w;
    model.w = bestState.w;

end


function assertPositivity(param, model)
    if ~isempty(param.SOSVM.posindx)
        assert(sum(model.w(param.SOSVM.posindx) >= ones(length(param.SOSVM.posindx), 1) * -1.0e-6) == length(param.SOSVM.posindx), 'Positivity contraint violated by ');
    end
end


function [phi, b] = computeOneslackMarginConstraint(config,model,X,Y)
    phi = 0;
    b = 0;
    
    % For each pattern
    for i = 1 : length(X);
        [tildeY] = config.SOSVM.findMostViolatedMarginFn(config, model, X{i}, Y{i});
        delta = config.SOSVM.lossFn(config, Y{i}, tildeY);
        deltaPsi = config.SOSVM.psiFn(config, X{i}, Y{i}) - config.SOSVM.psiFn(config, X{i}, tildeY);
        if (dot(model.w,deltaPsi) < delta)
            b = b + delta;
            phi = phi + deltaPsi;
        end
    end
    
end
