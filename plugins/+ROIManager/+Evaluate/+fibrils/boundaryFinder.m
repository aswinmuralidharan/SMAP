classdef boundaryFinder<interfaces.SEEvaluationProcessor
    % This plug-in is dependent of the BALM_fibril_growth.
    % Green line is the original boundary
    % White line is the refined boundary

    properties
        boundary
    end
    methods
        function obj=boundaryFinder(varargin)        
                obj@interfaces.SEEvaluationProcessor(varargin{:});
        end
        function out=run(obj, inp)
            out=runBoundaryFinder(obj, inp);
        end
     
        function pard=guidef(obj)
            pard=guidef(obj);
        end
    end

end



function pard=guidef(obj)
pard.t_gridRange.object=struct('Style','text','String','Bin size of the grids');
pard.t_gridRange.position=[1,1];
pard.t_gridRange.Width=2;

pard.gridRange.object=struct('Style','edit','String',5);
pard.gridRange.position=[1,3];
pard.gridRange.TooltipString = 'If you set it as 5, it means before the density comparison, every grid will be set to cover a 5-by-5 area in the original coordinates';
            
pard.t_slideStep.object=struct('Style','text','String','Slide step(s)');
pard.t_slideStep.position=[2,1];
pard.t_slideStep.Width=2;

pard.slideStep.object=struct('Style','edit','String',5);
pard.slideStep.position=[2,3];
pard.slideStep.TooltipString = 'If you set it as 5, it means during the density comparison, every grid value will be campared to its following 4 (5 minus 1, which means the reference grid itself) right neighbors';

pard.t_DistFScale.object=struct('Style','text','String','DistF scale');
pard.t_DistFScale.position=[3,1];
pard.t_DistFScale.Width=1;

pard.DistFScale.object=struct('Style','edit','String',7e-2);
pard.DistFScale.position=[3,2];
pard.DistFScale.TooltipString = 'Lower this value to tolerate slower increase of foreground density (Df)';
pard.DistFScale.Width=1;

pard.t_offSetScale.object=struct('Style','text','String','Offset scale');
pard.t_offSetScale.position=[3,3];
pard.t_offSetScale.Width=1;

pard.offSetScale.object=struct('Style','edit','String',1e-1);
pard.offSetScale.position=[3,4];
pard.offSetScale.TooltipString = 'Higher this value to allow higher background density';

pard.t_mergeSteps.object = struct('Style','text','String','Order of merging steps');
pard.t_mergeSteps.position=[4,1];
pard.t_mergeSteps.Width = 2;

pard.mergeSteps.object = struct('Style','edit','String','0 3 1 2 3 1 2 0');
pard.mergeSteps.position=[4,3];
pard.mergeSteps.TooltipString = '0 = clean up; 1 = by space(ambiguous); 2 = by space(small), 3 = by time';

pard.t_minT.object = struct('Style','text','String','Minimum time');
pard.t_minT.position=[5,1];
pard.t_minT.Width = 2;

pard.minT.object = struct('Style','edit','String',5);
pard.minT.position=[5,3];
pard.minT.TooltipString = 'minimum time of a step (arbitrary unit)';

pard.t_minWidth.object = struct('Style','text','String','Minimum width');
pard.t_minWidth.position=[6,1];
pard.t_minWidth.Width = 2;

pard.minWidth.object = struct('Style','edit','String',2);
pard.minWidth.position=[6,3];
pard.minWidth.TooltipString = 'minimum width of a step (arbitrary unit)';

pard.displayOpt.object = struct('Style','checkbox','String','show optimisation');
pard.displayOpt.position=[7,1];
pard.displayOpt.Width = 2;

% pard.dxt.Width=3;
pard.inputParameters={'numberOfLayers','sr_layerson','se_cellfov','se_sitefov','se_siteroi'};
pard.plugininfo.type='ROI_Evaluate';

end



function mathod_callBack(a,b,obj)
    switch obj.getSingleGuiParameter('method').Value
        case 1
            obj.guihandles.contourLevel.Visible = 'on';
            obj.guihandles.std.Visible = 'on';
            obj.guihandles.t_contourLevel.Visible = 'on';
            obj.guihandles.t_std.Visible = 'on';
            obj.guihandles.t_prctile.Visible = 'off';
            obj.guihandles.prctile.Visible = 'off';
        case 2
            obj.guihandles.contourLevel.Visible = 'off';
            obj.guihandles.std.Visible = 'off';
            obj.guihandles.t_contourLevel.Visible = 'off';
            obj.guihandles.t_std.Visible = 'off';
            obj.guihandles.t_prctile.Visible = 'on';
            obj.guihandles.prctile.Visible = 'on';
        case 3
            obj.guihandles.contourLevel.Visible = 'off';
            obj.guihandles.std.Visible = 'off';
            obj.guihandles.t_contourLevel.Visible = 'off';
            obj.guihandles.t_std.Visible = 'off';
            obj.guihandles.t_prctile.Visible = 'off';
            obj.guihandles.prctile.Visible = 'off';
    end
end