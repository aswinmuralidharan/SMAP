classdef UseSitesInROI<interfaces.DialogProcessor&interfaces.SEProcessor
%     Selects only those sites (ROIs) for further analysis that are insied
%     a user-defined ROI in the main SMAP superresolution figure
    methods
        function obj=UseSitesInROI(varargin)        
                obj@interfaces.DialogProcessor(varargin{:});
            obj.inputParameters={'se_sitefov','se_cellpixelsize','se_siteroi'};
        end
        
        function out=run(obj,p)  
          hroi=obj.getPar('sr_roihandle');
          imbw=hroi.createMask;
          pos=getFieldAsVectorInd(obj.SE.sites,'pos');
          pr=obj.getPar('sr_pixrec');
          srpos=obj.getPar('sr_pos');
          srsize=obj.getPar('sr_size');
          prel=(pos(:,1:2)-(srpos(1:2)-srsize))/pr;
          ing=withinmask(imbw,prel(:,1),prel(:,2));
          for k=1:length(obj.SE.sites)
              obj.SE.sites(k).annotation.use=ing(k);
          end
          out=[];
        end
        function pard=guidef(obj)
            pard=guidef;
        end
    end
end




function pard=guidef

pard.plugininfo.type='ROI_Analyze';
pard.plugininfo.description='Selects only those sites (ROIs) for further analysis that are insied a user-defined ROI in the main SMAP superresolution figure ';
end
