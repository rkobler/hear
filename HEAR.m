%
% high-variance electrode artifact removal (HEAR) algorithm
% reference implementation
%
% by Reinmar Kobler
% University of Technology Graz
% Institute of Neural Engineering
% Laboratory of Brain-Computer Interfaces
% 8010 Graz, Austria

classdef HEAR < handle
    %HEAR Class to fit and apply acausal/causal transinet, high-variance
    %articat detection/correction
    
    properties
        %% general class attributes
        fs = NaN;
        exp_lambda = NaN;
        is_causal = true;
        
        %% variance detector attributes
        ref_mag = NaN;
        mag_est_win = 0.25; % s      
        
        mag_art_mu = 3.0; % times the ref magnitude
        mag_art_sigma = 1.0; % times the ref magnitude

        state_havg = NaN;
        state_ref_mag = NaN;
        
        %% interpolation specific attributes
        D = NaN;
        
    end
    %% METHODS
    methods
        %% constructor
        function obj = HEAR(fs, is_causal, mag_art_mu, mag_est_win, D)
        
            if nargin < 2
                is_causal = true;
            end
            if nargin < 3 || isempty(mag_art_mu)
                mag_art_mu = 3;
            end    
            if nargin < 4 || isempty(mag_est_win)
                mag_est_win = 0.25; % s
            end      
            if nargin < 5 || isempty(D)
                warning('No channel interpolation matrix specified!\nOnly outlier detection possible!');
                D = NaN;
            end              

            obj.fs = fs;
            obj.is_causal = is_causal;
            obj.mag_art_mu = mag_art_mu;            
            obj.mag_est_win = mag_est_win;
            obj.D = D;
            
            % compute exponential smoothing factor so that
            % that 'mag_est_win * fs' famples have 'p' % of the weights 
            p = 0.9;
            obj.exp_lambda = (1-p)^(1/(obj.mag_est_win * fs));
        end 
        
        %% model fitting
        function train(obj, data)
            
            % create averaging filter based on exponential smoothing factor
            obj.state_havg = dfilt.df2t([1-obj.exp_lambda], [1 -obj.exp_lambda]);    
            obj.state_havg.persistentMemory = 0;
            
            if ~obj.is_causal

                % get the envelope of the error-Signal (smoothed)
                % forward filter
                data_mag = filter(obj.state_havg, data(:,:).^2,2);
                % backward filter (=> zero-phase distortion)
                data_mag = sqrt(flip(filter(obj.state_havg, flip(data_mag,2),2),2));
            else
                % get the envelope of the error-Signal (smoothed)
                data_mag = sqrt(filter(obj.state_havg, data(:,:).^2,2));
                
                % set the filter memory to be persistent for causal filtering
                obj.state_havg.persistentMemory = 1;
            end

            % get the reference magnitude
            obj.state_ref_mag = mean(data_mag,2);            

            % and initialize the states with the refrence magnitudes
            obj.state_havg.States = obj.state_ref_mag';
        end
        
        %% inverse filter model application
        function varargout = apply(obj, data)
            
            [n_chans, ~] = size(data);            
            
            % check if the model is calibrated to the correct number of channels
            assert(n_chans == size(obj.state_ref_mag,1));
            
            if obj.is_causal
            
                % get the power of the error signal
                data_mag = sqrt(filter(obj.state_havg, data.^2, 2));
            else
                warning('Applying filtfilt! => transient artifacts at beginning and end of data chunks!');
                data_mag = filter(obj.state_havg, data(:,:).^2,2);
                % backward filter (=> zero-phase distortion)
                data_mag = sqrt(flip(filter(obj.state_havg, flip(data_mag,2),2),2));
            end
            
            % normalize the power with the reference magnitude
            ths_mu = obj.state_ref_mag * obj.mag_art_mu;
            
            x = bsxfun(@minus, data_mag, ths_mu);
            x = bsxfun(@rdivide, x, obj.mag_art_sigma * obj.state_ref_mag);
            
            % query the cdf of a gaussian distribution
            p_art_ext = normcdf(x);
            
            p_art = max(p_art_ext, [], 1);
            
            varargout{1} = p_art;
            
            if (any(isnan(obj.D(:))) || ~ismatrix(obj.D) || ...
                diff(size(obj.D)) ~= 0 || n_chans ~= size(obj.D,1))  ...
                && nargout > 1

                error('Expecting corrected output without a valid channel interpolation matrix.');
            elseif nargout > 1
                
                % estimate the probability that an artifact contaminated channel can not be
                % corrected by its neighbors
                varargout{2} = max(p_art_ext.*(obj.D*p_art_ext),[],1);
                
                % do the correction steop
                data_c = p_art_ext .* (obj.D * data(:,:)) + (1 - p_art_ext) .* data(:,:);
                varargout{3} = data_c;
            end
        end
    end   
end

