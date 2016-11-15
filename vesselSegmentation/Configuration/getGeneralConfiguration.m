function [config] = getGeneralConfiguration(config)
% getGeneralConfiguration Prepares the config structure with the
% configuration of features
% [config] = getGeneralConfiguration(config)
% config: prefilled config structure

    % ---------------------------------------------------------------------
    % SOSVM configuration
    config.SOSVM.usePositivityConstraint = 1;
    
    % ---------------------------------------------------------------------
    % Preprocessing
    config.preprocessing.preprocess = 1;
    config.preprocessing.fakepad_extension = ceil( 50 * config.scale_factor );
    config.preprocessing.erosion = 5;
    config.preprocessing.winSize = ceil(40 * config.scale_factor);
    config.preprocessing.enhancement = 'clahe';
    %config.preprocessing.enhancement = 'no';%'clahe';

    % ---------------------------------------------------------------------
    % Model selection metric
    config.modelSelectionMetric = 'fMeasure';

    % ---------------------------------------------------------------------
    % Feature configurations     
    % Intensities
        options.Intensities.winsize = ceil(35 * config.scale_factor);
        options.Intensities.fakepad_extension = config.preprocessing.fakepad_extension;
        options.Intensities.filter = 'median';
    % Nguyen
        options.Nguyen2013.w = ceil(15 * config.scale_factor);   
        options.Nguyen2013.step = ceil(2 * config.scale_factor);
    % Soares
        %options.Soares2006.scales = ceil([2 2*sqrt(2) 3*sqrt(2) 4*sqrt(2) 3] * config.scale_factor);
        options.Soares2006.scales = ceil([2 3 4 5] * config.scale_factor);
        %options.Soares2006.scales = ceil([2 3] * config.scale_factor);
    % Zana
        options.Zana2001.l = ceil(9 * config.scale_factor);
        options.Zana2001.winsize = ceil(7 * config.scale_factor);
        options.Zana2001.Intensities = options.Intensities;
    % Azzopardi
        options.Azzopardi2015.symmetric.sigma0 = 3 * config.scale_factor;
        options.Azzopardi2015.symmetric.sigma = 2.4 * config.scale_factor;
        options.Azzopardi2015.symmetric.len = ceil((0:2:8) * config.scale_factor);
        options.Azzopardi2015.symmetric.alpha = 0.7 * config.scale_factor;
        options.Azzopardi2015.asymmetric.sigma0 = 2 * config.scale_factor;
        options.Azzopardi2015.asymmetric.sigma = 1.8 * config.scale_factor;
        options.Azzopardi2015.asymmetric.len = ceil((0:2:22) * config.scale_factor);
        options.Azzopardi2015.asymmetric.alpha = 0.1 * config.scale_factor;
        
    % RESULTS ------------------------------------------------------------

    % General feature configuration
    config.features.features = {... 
        @Nguyen2013, ...
        @Soares2006, ...
        @Zana2001, ...
        @Azzopardi2015 ...
        };
    config.features.numberFeatures = length(config.features.features);
    config.features.featureNames = {...
        'nguyen', ...
        'soares', ...
        'zana', ...
        'azzopardi' ...
    	};

    % Assign options
    config.features.featureParameters = {...
        options.Nguyen2013, ...
        options.Soares2006, ...
        options.Zana2001 ...
        options.Azzopardi2015 ...
        };
    
    % ---------------------------------------------------------------------
    % CRF configuration
    if strcmp(config.crfVersion,'local-neighborhood-based') % in case the method is local-neighborhood based
        config.learn.theta_p = 0;
    end

    % Theta_p learning
    config.theta_p.values = [3 7 5 15];
    config.theta_p.values = config.theta_p.values * config.scale_factor;

    % ---------------------------------------------------------------------
    % Constants
    config.biasMultiplier = 1;
    
end