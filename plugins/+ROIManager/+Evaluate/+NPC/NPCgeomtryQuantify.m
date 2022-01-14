classdef NPCgeomtryQuantify<interfaces.SEEvaluationProcessor
%     Calculates radius, distance between rings and angular shift between
%     rings for the nuclear pore complex (NPC). See: Thevathasan, Jervis
%     Vermal, Maurice Kahnwald, Konstanty Cieśliński, Philipp Hoess,
%     Sudheer Kumar Peneti, Manuel Reitberger, Daniel Heid, et al. “Nuclear
%     Pores as Versatile Reference Standards for Quantitative
%     Superresolution Microscopy.” BioRxiv, March 20, 2019, 582668.
%     https://doi.org/10.1101/582668.
    properties
        savedevals
    end
    methods
        function obj=NPCgeomtryQuantify(varargin)        
                obj@interfaces.SEEvaluationProcessor(varargin{:});
        end
        function makeGui(obj)
            makeGui@interfaces.SEEvaluationProcessor(obj);
%             obj.guihandles.saveimagesb.Callback={@saveimagesb_callback,obj};
        end
        function out=run(obj,p)
            try
            out=runintern(obj,p);
            catch err
                err
                out=[];
            end
         
        end
        
        function pard=guidef(obj)
            pard=guidef;
        end
    end
end

function pard=guidef
pard.Rt.object=struct('Style','text','String','R (nm):');
pard.Rt.position=[1,1];
pard.Rt.Width=1;

pard.R.object=struct('Style','edit','String','50');
pard.R.position=[1,2];
pard.R.Width=1;

pard.dRt.object=struct('Style','text','String','dR:');
pard.dRt.position=[1,3];
pard.dRt.Width=1;

pard.dR.object=struct('Style','edit','String','20');
pard.dR.position=[1,4];
pard.dR.Width=1;

pard.plugininfo.type='ROI_Evaluate';
pard.inputParameters={'numberOfLayers','sr_layerson','se_cellfov','se_sitefov','se_siteroi','layer1_','layer2_','se_sitepixelsize'};
pard.plugininfo.description='Calculates radius, distance between rings and angular shift between rings for the nuclear pore complex (NPC). See: Thevathasan, Jervis Vermal, Maurice Kahnwald, Konstanty Cieśliński, Philipp Hoess, Sudheer Kumar Peneti, Manuel Reitberger, Daniel Heid, et al. “Nuclear Pores as Versatile Reference Standards for Quantitative Superresolution Microscopy.” BioRxiv, March 20, 2019, 582668. https://doi.org/10.1101/582668.';
end


function out=runintern(obj,p)
R=p.R;
dR=p.dR;
legendtheta={};
locs=obj.getLocs({'xnm','ynm','znm','xnmrot','ynmrot','locprecnm','locprecznm','frame'},'layer',1,'size',p.se_siteroi(1)/2);
if isempty(locs.xnm)
    out=[];
    return
end
thetan=-pi:pi/180:pi;
%2D fit
[x0,y0]=fitposring(locs.xnmrot,locs.ynmrot,R);
xm=locs.xnmrot-x0;
ym=locs.ynmrot-y0;
locsfit=locs;
locsfit.xnmrot=xm;
locsfit.ynmrot=ym;
if ~isempty(locs.znm) % evaluate z distance
    templatefit= runNPC3DfittingJ(obj, p,locsfit,[0 0]);
    xm=double(templatefit.locxyz(:,1));
    ym=double(templatefit.locxyz(:,2));
    zm=double(templatefit.locxyz(:,3));
    badind=abs(zm)>100; %too far outside
    r2=xm.^2+ym.^2;
    badind=badind & r2<(p.R-p.dR).^2 & r2>(p.R+p.dR).^2;
    xm(badind)=[];
    ym(badind)=[];
    zm(badind)=[];
    sx=locs.locprecnm(~badind);
    sy=locs.locprecznm(~badind);
    dz=8;
%     z0=median(zm);
    z=(-100:dz:100);
    zr=z;
    hz=hist(zm,z);
    % hz=hz-mean(hz);
    ac=myxcorr(hz,hz);
    hzraw=hist(locs.znm(~badind)-median(locs.znm),zr);
    % if obj.display
    if obj.display
    ax1=obj.setoutput('profile');
%     hold(ax1,'off')
       fitresult=createFit(z, hz,ax1);
    title(ax1,fitresult.d)
%            hold(ax1,'on')
     
     ax1=obj.setoutput('profileraw');
     fitresultraw=createFit(zr, hzraw,ax1);
     title(ax1,fitresultraw.d)
     ax2=obj.setoutput('zcorr');
    plot(ax2,z+z(end),ac)
    else
    fitresult=createFit(z, hz,[]);
     fitresultraw=createFit(zr, hzraw,[]);
    end
    
    % angular cross-correlation between two rings
    inr1=zm<0;
    
    [theta,rhoa]=cart2pol(xm,ym);
    
    ht1=hist(theta(inr1),thetan);
    ht2=hist(theta(~inr1),thetan);
    out.angular.cc12=xcorrangle(ht1-mean(ht1),ht2-mean(ht2));
    out.angular.ac1=xcorrangle(ht1-mean(ht1));
    out.angular.ac2=xcorrangle(ht2-mean(ht2));
    
    locr.x=xm;
    locr.y=zm;
    locr.znm=zm; %in case z color coding
    locr.sx=sx;
    locr.sy=sy;
    posrender=[-p.se_siteroi(1)/2,-100,p.se_siteroi(1),200];
    
    srim=renderallSMAP(locr,obj,'position',posrender,'pixrec',1);
    if obj.display
        ax1=obj.setoutput('render');  
        imagesc(ax1,srim.rangex,srim.rangey,srim.composite)
        axis(ax1,'equal')
        axis(ax1,'tight')
        
        axtheta=obj.setoutput('corrtheta');
        hold(axtheta,'off')
        plot(axtheta,thetan-thetan(1),out.angular.ac1);
        hold(axtheta,'on')
        plot(axtheta,thetan-thetan(1),out.angular.ac2);
        plot(axtheta,thetan-thetan(1),out.angular.cc12);
        legendtheta={'ac1','ac2','cc12'};
        
    end
        if false
        figure(93)
        subplot(1,2,1)
        imagesc(srim.rangex,srim.rangey,srim.composite)
        ax1=gca;
        axis equal
        axis tight
        axis xy
        subplot(1,2,2)
        zp=z(1):1:z(end);
        plot(hz,z,'k',fitresult(zp),zp,'r')
        ax2=gca;
        ax2.Position(4)=ax1.Position(4);
        ax2.Position(3)=.1;
        ylim([-100 100])
%         axh=gca;
%         fitresult=createFit(z, hz,axh);
        
        end
    
    out.profile.ac=ac;
    out.profile.dz=dz;
    out.profile.hist=hz;
    out.profile.z=z;
    out.profile.Gaussfit=copyfields([],fitresult,{'a1','a2','b','c','d'});
    out.profile.Gaussfitraw=copyfields([],fitresultraw,{'a1','a2','b','c','d'});
    out.templatefit=templatefit;
end

%radial analysis
[x0,y0,R0]=fitposring(xm,ym);
if obj.display
ax1=obj.setoutput('ringfit');

plot(ax1,xm-x0,ym-y0,'.')
hold(ax1,'on')
circle(0,0,R0,'Parent',ax1);
hold(ax1,'off')
title(ax1,R0)
end

[theta,rhoa]=cart2pol(xm,ym);
histtheta=hist(theta,thetan);
% histtheta12=hist(theta+pi,thetan+pi);
% tac=myxcorr(histtheta11,histtheta11);
% tac1=tac+myxcorr(histtheta12,histtheta12);
tac1=xcorrangle(histtheta-mean(histtheta));
if obj.display
    legendtheta{end+1}='all';
   axtheta=obj.setoutput('corrtheta');
   plot(axtheta,thetan-thetan(1),tac1);
   legend(axtheta,legendtheta);
end
out.Rfit=R0;
out.angular.actheta=tac1;
out.angular.thetan=thetan-thetan(1);
end


function [fitresult, gof] = createFit(z, hz,ax)

[xData, yData] = prepareCurveData( z, hz );

% Set up fittype and options.
ft = fittype( 'a1*exp(-((x-b)/c)^2/2) + a2*exp(-((x-b+d)/c)^2/2)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [0 0 -Inf 0 -Inf];
mv= sum(hz.*z)/sum(hz);
dh=30;
sp=[max(hz) max(hz) mv+dh 8 dh*2 ];
opts.StartPoint = sp;
fstart=ft(sp(1),sp(2),sp(3),sp(4),sp(5),xData);
% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
if ~isempty(ax)
axes(ax)
xdf=xData(1):1:xData(end);
h = plot(xdf,fitresult(xdf),'r', xData, yData,'b-',xData,fstart,'g');


% legend( h, 'hz vs. z', 'untitled fit 1', 'Location', 'NorthEast' );
% Label axes
xlabel z
ylabel hz
grid on
end

end
