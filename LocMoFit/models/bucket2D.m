classdef bucket2D<geometricModel
    
    % log
    %   - 
    methods
        function obj = bucket2D(varargin)
            obj@geometricModel(varargin{:});
            % Define parameters that can be altered during fitting here:
            obj.name = {'radius', 'theta'}; % parameter names
            obj.fix = [0 0] ;                                                       % fix to a constant or not
            obj.value = [10 60];                                                    % initial guess
            obj.lb = [-inf -inf];                                                   % relative lower bound
            obj.ub = [inf inf];                                                     % relative upper bound
            obj.min = [5 5];                                                        % absolute lower bound
            obj.max = [30 360];                                                     % absolute upper bound
                       
            % Define other properties here:
            obj.modelType = 'discretized';
            obj.modelTypeOption = {'discretized','continuous'};
            obj.dimension = 2;
            
        end
        
        function [model, p]= reference(obj, par, dx)
        % Sample coordinates of the model as reference.
        % --- Syntax ---
        % [model, p]= reference(obj, par, dx)
        % --- Arguments ---
        % -- Input --
        % obj:
        % par: a structure object. Its fieldnames should be the names of
        % parameters, and their correspoinding content should be the
        % parameter values.
        % dx: sampling rate.
        % -- Output --
        % model: a structure object. Its fieldnames should be x, y, z, and
        % n, indicating the xyz position amplitude n of the sampled model
        % points.
        % p: additional information of the model.
        
        % parameters:
        r = par.radius;
        theta = par.theta;

        % 
        if isempty(obj.ParentObject)
            locsPrecFactor = 1;
        else
            locsPrecFactor = min(obj.ParentObject.locsPrecFactor,5);
        end
        
        halfTheta = deg2rad(theta/2);
        xp = r*cos(halfTheta);
        yp = r*sin(halfTheta);
        if theta<=180
            xAnchor = [xp, r, r, xp];
            yAnchor = [yp, yp, -yp, -yp];
        else
            xAnchor = [xp, xp, r, r, xp, xp];
            yAnchor = [yp, r, r, -r, -r, -yp];
        end
        arcLen = arclength(xAnchor,yAnchor);
        nSample = max(round(arcLen/(dx*locsPrecFactor)),1);
        
        pt = interparc(nSample,xAnchor,yAnchor,'linear');
        
        centroidx = mean(pt(:,1));
        model.x = pt(:,1)-centroidx;
        model.y = pt(:,2);
        model.n = ones(size(model.x));
        
        p = [];
        end
        function derivedPars = getDerivedPars(obj, pars)
            derivedPars = [];
        end
    end
end
