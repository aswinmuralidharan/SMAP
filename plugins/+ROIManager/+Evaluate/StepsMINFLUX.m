classdef StepsMINFLUX<interfaces.SEEvaluationProcessor
%     
    properties
        peakline
        roihandle
        axstep
        steps
        coord
        range
        index
    end
    methods
        function obj=StepsMINFLUX(varargin)        
                obj@interfaces.SEEvaluationProcessor(varargin{:});
        end
        function out=run(obj, p)
           obj.steps=[];obj.range=[];obj.coord=[];
           if isfield(obj.site.evaluation,obj.name) 
                out=obj.site.evaluation.(obj.name);
                if isfield(obj.site.evaluation.(obj.name),'steps')
                    obj.steps=out.steps;
                end
                if isfield(obj.site.evaluation.(obj.name),'range')
                    obj.range=out.range;
                end                
           end

           %identify all localizations in track
           locs=obj.getLocs({'xnm','ynm','groupindex','tid'},'layer',find(obj.getPar('sr_layerson')),'size',obj.getPar('se_siteroi')/2);
           if isempty(locs.xnm)
                disp('no localizations')
                return
           end
           if contains(p.link.selection,'group')
               fid='groupindex';
           else
               fid='tid';
           end
           id=mode(locs.(fid));
           index=obj.locData.loc.(fid)==id;
           obj.index=index;
            
           %get coordinates
           x=obj.locData.loc.xnm(index);
           y=obj.locData.loc.ynm(index);
           time=obj.locData.loc.time(index);

           if isfield(obj.locData.loc,'znm')
               z=obj.locData.loc.znm(index);
           else
               z=[];
           end

           %find direction     
           [xr,yr]=rotateCenterCoordinates(x,y,time);
%            c = cov(x-mean(x), y-mean(y));
%            [a, ev] = eig(c);
%            [ev,ind] = sort(diag(ev));
%            [xa, ya] = deal(a(1,ind(end)), a(2,ind(end)));
%            angle = cart2pol(xa, ya);
%            [xr,yr]=rotcoord(x-mean(x),y-mean(y),angle);
%            indx=xr<mean(xr);
%            if mean(time(indx))>mean(time(~indx)) %increasing position with time
%                xr=-xr;
%            end

           obj.coord.xr=xr;obj.coord.yr=yr;obj.coord.time=time;obj.coord.timeplot=time-min(time);
           obj.coord.z=z;
          
           if  isempty(obj.steps)
               refit(0,0,obj,1)
           end
           caluclatestepparameters(obj, obj.steps.indstep);
           plotsteps(obj)

           out.statall=caluclatestatistics(obj,index);
           out.stattrack=caluclatestatistics(obj,index,obj.coord.indtime);

           filelist=obj.getPar('filelist_short');
           out.filename=filelist.String{mode(locs.filenumber)};
           plotstatistics(obj)
        end
        function pard=guidef(obj)
            pard=guidef(obj);
        end     
    end

end

function plotstatistics(obj)
index=obj.index;
time=obj.locData.loc.time(index);
dt=diff(time);
dtmin=min(dt(dt>0));
dtmedian=median(dt);
dtmean=mean(dt);
ltime=time-min(time);
ff='%2.1f';
axt=obj.setoutput('time');
bins=dtmin/2:dtmin:quantile(dt,0.995);
if length(bins)<3
    bins=dtmin/2:dtmin/2:dtmin*2;
end
hold(axt,'off')
histogram(axt,dt,bins)
hold(axt,'on')
histogram(axt,dt,bins)
xlabel(axt,'dt (ms)')
ylabel(axt,'frequency')
title(axt,['dtmin = ' num2str(dtmin,ff) ' ms, dtmedian = ' num2str(dtmedian,ff) ' ms, dtmean = ' num2str(dtmean,ff) ' ms.'])

axdt=obj.setoutput('dt');
hold(axdt,'off')
plot(axdt,ltime(2:end),dt)
if ~isempty(obj.range)
    hold(axdt,'on')
    yr=[min(dt) max(dt)];
    plot(axdt,obj.range(1)*[1 1],yr,'k--','HitTest','off')
    plot(axdt,obj.range(2)*[1 1],yr,'k--','HitTest','off')
end

xlabel(axdt,'time (ms)')
ylabel(axdt,'dt (ms)')


plotsimple(obj,'efo')
plotsimple(obj,'cfr')
plotsimple(obj,'eco')
plotsimple(obj,'ecc')

end

function plotsimple(obj,field)
if ~isempty(obj.locData.loc.(field))
    time=obj.locData.loc.time(obj.index);
    ltime=time-min(time);
    axe=obj.setoutput(field);
    yval=obj.locData.loc.(field)(obj.index);
    hold(axe,'off')
    plot(axe,ltime,yval)
    hold(axe,'on')
    if ~isempty(obj.range)
        yr=[min(yval) max(yval)];
        plot(axe,obj.range(1)*[1 1],yr,'k--','HitTest','off')
        plot(axe,obj.range(2)*[1 1],yr,'k--','HitTest','off')
    end
    xlabel(axe,'time (ms)')
    ylabel(axe,field)
    vall=obj.site.evaluation.(obj.name).statall.(field);
    vt=obj.site.evaluation.(obj.name).stattrack.(field);
    title(axe,[field ': ' num2str(vall,'%2.3g') ', ' num2str(vt,'%2.3g') ' (track)'])

end
end

function out=caluclatestatistics(obj,indexin,indind)
if islogical(indexin)
    indexin=find(indexin);
end
if nargin<=2
    indind=true(size(indexin));
end
index=indexin(indind);
time=obj.locData.loc.time(index);

dt=diff(time);
out.dtmin=min(dt);
out.dtmedian=median(dt);
out.dtmean=mean(dt);

out.efo=median(obj.locData.loc.efo(index));
out.cfr=median(obj.locData.loc.cfr(index));
out.eco=median(obj.locData.loc.eco(index));
out.ecc=median(obj.locData.loc.ecc(index));
out.efc=median(obj.locData.loc.efc(index));
out.nlocs=length((index));
out.tracktime=max(time)-min(time);
xh=obj.coord.xr(indind);
out.tracklength=xh(end)-xh(1);
out.velocity=out.tracklength/out.tracktime;
end

function refit(a,b,obj,what)
p=obj.getAllParameters;
%stepfinder
if  ~isempty(obj.range)
    indtime=obj.coord.timeplot>=obj.range(1) & obj.coord.timeplot<=obj.range(2);
else
    indtime=true(size(obj.coord.xr));
end
obj.coord.indtime=indtime;
% p.fitmean=contains(p.fitmode.selection,'mean');
if what==1
    p.stepfunction=p.fitmode.selection;
    indstep=findstepsMINFLUX(obj.coord.xr(indtime),p);
%     try
%     steps=AutoStepfinderRies(obj.coord.xr(indtime),p);
%     catch err
%         steps=[];
%     end
%     if isempty(steps)
%         disp('no steps found')
%         steps.properties.StepSize=10;
%         steps.properties.IndexStep=[];
%     end
%     indstep=[1 ;steps.properties.IndexStep ];      
%     
%     if obj.getSingleGuiParameter('splitmerge')
%         stepsize=p.splitmergestep;
%         if isempty(stepsize)
%             stepsize=median(steps.properties.StepSize);
%         end
%         [indstep,stepvalue]=splitmergefit(obj.coord.xr(indtime),stepsize,p,steps);
%     end
else %refine
     [svalfit, indstep]=fitstepind(obj.coord.xr(indtime),obj.steps.indstep,str2func(p.fitmode.selection));
end

caluclatestepparameters(obj,indstep);

plotsteps(obj)
end

function plotsteps(obj)
try
dcm_obj = datacursormode(obj.axstep.Parent.Parent.Parent);
info=dcm_obj.getCursorInfo;
catch err
    info=[];
end
ax2=obj.setoutput('steps_x');
hold(ax2,'off')
plot(ax2,obj.coord.timeplot,obj.coord.xr,'HitTest','off');
hold(ax2,'on')
xlabel(ax2,'time (ms)')
ylabel(ax2,'position (nm)')
if ~isempty(obj.range)
    plot(ax2,obj.range(1)*[1 1],[min(obj.coord.xr) max(obj.coord.xr)],'k--','HitTest','off')
    plot(ax2,obj.range(2)*[1 1],[min(obj.coord.xr) max(obj.coord.xr)],'k--','HitTest','off')
    tm=obj.range(2);
else
    tm=max(obj.coord.timeplot);
end

mv=obj.steps.stepvalue;
hstep=stairs(ax2,[obj.steps.steptime ;tm],[mv ;mv(end)],'r');
cm = uicontextmenu(ax2.Parent.Parent.Parent);
m = uimenu(cm,'Text','Menu1');
cm.ContextMenuOpeningFcn = @(src,event)disp('Context menu opened');
hstep.ContextMenu = cm;
dmv=diff(mv);
for k=1:length(dmv)
    text(ax2,(obj.steps.steptime(k+1)),mean(mv(k:k+1)),num2str(dmv(k),'%2.1f'),'FontSize',10,'Color','magenta','HitTest','off')
end
obj.axstep=ax2;

if ~isempty(info)
    datatip(hstep,info.Position(1),info.Position(2));
end
%xy plot
goff=median(mod(obj.steps.stepvalue,16),'omitnan');
axxy=obj.setoutput('xy');
hold(axxy,'off')
plot(axxy, obj.coord.xr-goff, obj.coord.yr)
axis(axxy,'equal')
xlabel(axxy,'x (nm)')
ylabel(axxy,'y (nm)')
hold(axxy,'on')
scatter(axxy,obj.steps.stepvalue-goff,obj.steps.possteps.y,'k')
grid(axxy,'on')
axm=-16:-16:axxy.XLim(1);
axxy.XTick=[axm(end:-1:1) 0:16:axxy.XLim(2)];
axxy.YTick=round((axxy.YLim(1):6:axxy.YLim(2))/6)*6;
ff='%2.1f';
sigmax=std(obj.coord.xr);sigmay=std(obj.coord.yr);
sxdetrend=std(diff(obj.coord.xr))/sqrt(2);sydetrend=std(diff(obj.coord.yr))/sqrt(2);
[~, sxrobust]=robustMean(obj.coord.xr); [~, syrobust]=robustMean(obj.coord.yr);
title(axxy,['std(x) = ' num2str(sigmax,ff) ' nm, std(x) detrend = ' num2str(sxdetrend,ff) ' nm.' ' std(y) = ' num2str(sigmay,ff) ' nm, std(y) detrend = ' num2str(sydetrend,ff) ' nm.'])

if ~isempty(obj.coord.z)
    ax3D=obj.setoutput('zxy');
    hold(ax3D,'off')
    plot3(ax3D,obj.coord.xr-goff, obj.coord.yr,obj.coord.z-median(obj.coord.z))
    xlabel(ax3D,'x (nm)')
    ylabel(ax3D,'y (nm)')
    zlabel(ax3D,'z (nm)')
    hold(ax3D,'on')
    scatter3(ax3D,obj.steps.stepvalue-goff,obj.steps.possteps.y,obj.steps.possteps.z-median(obj.coord.z),'k')
    view(ax3D,0,0)
    axis(ax3D,'equal')
    
    axm=-16:-16:ax3D.XLim(1);
    ax3D.XTick=[axm(end:-1:1) 0:16:ax3D.XLim(2)];
%     ax3D.YTick=round((ax3D.YLim(1):25:ax3D.YLim(2))/25)*25;
%     ax3D.ZTick=round((ax3D.ZLim(1):25:ax3D.ZLim(2))/25)*25;
        ax3D.YTick=round((min(obj.coord.yr):25:max(obj.coord.yr))/25)*25;
    ax3D.ZTick=round((min(obj.coord.z-median(obj.coord.z)):25:max(obj.coord.z-median(obj.coord.z)))/25)*25;
%     ax3D.ZLim=[min(obj.coord.z-median(obj.coord.z)) max(obj.coord.z-median(obj.coord.z))];
%     ax3D.DataAspectRatio=[1 1 1];

    grid(ax3D,'on')

end

axsy=obj.setoutput('steps_y');
plot(axsy,obj.coord.timeplot,obj.coord.yr)
axsy.YTick=round((axxy.YLim(1):6:axxy.YLim(2))/6)*6;
try
axsy.XTick=obj.steps.steptime;
catch
end
axsy.XTickLabel=round(obj.steps.steptime);
grid(axsy)

if ~isempty(dmv) && length(dmv)>1
ax3=obj.setoutput('stephist');
histogram(ax3,dmv,min(dmv):.5:max(dmv));
%step time
axstept=obj.setoutput('dwelltime');
dt=max(0.1,round(mean(obj.steps.dwelltime)/5));
histogram(axstept,obj.steps.dwelltime,0:dt:max(obj.steps.dwelltime))
title(axstept,"mean step time = "+ num2str(mean(obj.steps.dwelltime),'%2.1f') + " ms");
end
end

function selectrange(a,b,obj)
obj.range=obj.axstep.XLim;
refit(a,b,obj,1)
 plotstatistics(obj)
end

% function [istepfit,svalfit]=splitmergefit(x,stepsize,p,steps)
% if contains(p.fitmode.selection,'mean')
%     mfun=@mean;
% else
%     mfun=@median;
% end
% 
% istep=[1 ; steps.properties.IndexStep];
% sval=[steps.properties.LevelBefore; steps.properties.LevelAfter(end)];
%     svalfit=sval;
%     istepfit=istep;
% for s=1:10
%     [istepfit, svalfit]=mergesplit(istepfit,svalfit,stepsize);
%     % recalculate sval based on x and istep2
%     [svalfit, istepfit]=fitstepind(x,istepfit,mfun);
%    
% end
% % 
% % if nargin>3 %y passed on
% %     svalfity=stepvalue(y,istepfit,mfun);
% % else 
% %     svalfity=[];
% % end
% end

% function [svalfit, istepfit]=fitstepind(x,istepfit,mfun)
%     for k=1:10
%         svalfit=stepvalue(x,istepfit,mfun);
%         istepfitold=istepfit;
%         istepfit=moveind(x,svalfit,istepfit);   
%         if all(istepfit==istepfitold)
%             k
%             break
%         end
%     end
% end

% function sval=stepvalue(x,istep,fun)
% istep=[istep ;length(x)];
% for k=length(istep)-1:-1:1
%     sval(k,1)=fun(x(istep(k)+1:istep(k+1)));
% end
% end

% function istep=moveind(x,sval,istep)
% istep=[istep; length(x)];
% % d=2;
% 
% % smin=0;splus=0;
% for k=2:length(istep)-1
%     dmin=0;
%     dplus=0;
%     smin=inf;splus=inf;
%     ih=istep(k);
% 
%     if abs(x(ih)-sval(k))<abs(x(ih)-sval(k-1)) %ih>1 && abs(x(ih-1)-sval(k))<abs(x(ih-1)-sval(k-1))
%         smin=abs(x(ih)-sval(k));
%         dmin=-1;
%     elseif ih>1 && abs(x(ih-1)-sval(k))<abs(x(ih-1)-sval(k-1)) %ih>1 && abs(x(ih-1)-sval(k))<abs(x(ih-1)-sval(k-1))
%         dmin=-2;
%         smin=abs(x(ih-1)-sval(k));
% 
% % %         smin=abs(x(ih-1)-sval(k))-abs(x(ih-1)-sval(k-1));
% %     elseif ih>2 && abs(mean(x(ih-2:ih-1)-sval(k)))<abs(mean(x(ih-2:ih-1)-sval(k-1)))
% %         dmin=-2;
% %         smin=abs(mean(x(ih-2:ih-1)-sval(k)))-abs(mean(x(ih-2:ih-1)-sval(k-1)));
%     end
%     if ih<length(x) && abs(x(ih+1)-sval(k-1))<abs(x(ih+1)-sval(k))% ih<length(x) && abs(x(ih)-sval(k))<abs(x(ih)-sval(k-1))
%         dplus=1;
%         splus=abs(x(ih+1)-sval(k-1));
%         
%     elseif ih<length(x)-1 && abs(x(ih+2)-sval(k-1))<abs(x(ih+2)-sval(k))
%         splus=abs(x(ih+2)-sval(k-1));
%         dplus=2;
% %         splus=abs(x(ih)-sval(k))-abs(x(ih)-sval(k-1));
% %     elseif ih<length(x)-1 && abs(mean(x(ih:ih+1)-sval(k)))<abs(mean(x(ih:ih+1)-sval(k-1)))
% %         dplus=2;
% %         splus=abs(mean(x(ih+1:ih+2)-sval(k)))-abs(mean(x(ih+1:ih+2)-sval(k-1)));
%     end
% %         ind=find(abs(x(max(1,ih-d):ih-1)-sval(k))<abs(x(max(1,ih-d):ih-1)-sval(k-1)));
% %         if ~isempty(ind)
% %             dmin=-d-1+min(ind);
% %         end
% %         lx=length(x);
% %         ind=find(abs(x(ih+1:min(lx,ih+d))-sval(k))>abs(x(ih+1:min(lx,ih+d))-sval(k-1)));
% %         if ~isempty(ind)
% %            dplus=max(ind);
% %         end
%      if smin<splus
%          istep(k)=max(1,max(istep(k)+dmin, istep(k-1)+1));
%      else 
%          istep(k)=max(1,min(istep(k)+dplus,istep(k+1)-1));
%      end
% end
% istep=istep(1:end-1);
% end

% function [istep, sval]=mergesplit(istep,sval,stepsize)
% stepv=diff(sval);
% step2=stepv(1:end-1)+stepv(2:end);
% sstep=find(abs(step2)<stepsize*1.4 & abs(stepv(1:end-1))<stepsize*.7);
% k=1;
% sstepc=sstep;
% while k<length(sstepc)
%     ind=find(sstepc==sstepc(k)+1);
%     if ~isempty(ind)
%         sstepc(ind)=[];
%         %k=k+1;
%     end
%     k=k+1;
% end
% istep(sstepc+2)=round((istep(sstepc+1)+istep(sstepc+2))/2);
% istep(sstepc+1)=[];
% sval(sstepc+1)=[];
% bigstep=find(abs(diff(sval))>stepsize*1.4)+1; %later pass on min / max step size
% 
% for k=1:length(bigstep)
%     [sval,istep]=insertstep(sval,istep,bigstep(k));
%     bigstep=bigstep+1; % as inserted, correct indices
% end
% end

% function [sval,istep]=insertstep(sval,istep,insertind)
%     istep=[istep(1:insertind) ;istep(insertind) ;istep(insertind+1:end)];
%     sval=[sval(1:insertind-1) ;(sval(insertind-1)+sval(insertind))/2 ;sval(insertind:end)];  
%     istep(insertind)=istep(insertind)-1;
%     istep(insertind+1)=istep(insertind+1)+1;
% end
% 
function [sval,istep]=removestep(sval,istep,insertind)
if insertind+1<=length(istep)
    istep(insertind+1)=round((istep(insertind)+istep(insertind+1))/2);
end
    istep(insertind)=[];
    sval(insertind)=[];
end

function splitmerge(a,b,obj,what)
dcm_obj = datacursormode(obj.axstep.Parent.Parent.Parent);
info=dcm_obj.getCursorInfo;
if isempty(info)
    warndlg('Select step with the data tip tool first')
    return
end

steps=obj.steps;
[~,insertind]=min(abs(steps.steptime-info.Position(1)));
istep=obj.steps.indstep;
switch what
    case 1 %split
        [sval,istep]=insertstep(obj.steps.stepvalue,obj.steps.indstep,insertind);
    case 2
        [sval,istep]=removestep(obj.steps.stepvalue,obj.steps.indstep,insertind);
    case 3 %left       
        istep(insertind)=istep(insertind)-1;
    case 4 %right
        istep(insertind)=istep(insertind)+1;
end
if what<=2
    [svalfit, istep]=fitstepind(obj.coord.xr(obj.coord.indtime),istep,str2func(obj.getSingleGuiParameter('fitmode').selection));
end
caluclatestepparameters(obj,istep);
plotsteps(obj);
end

function steps=caluclatestepparameters(obj,stepindex)
if  ~isempty(obj.range)
    indtime=obj.coord.timeplot>=obj.range(1) & obj.coord.timeplot<=obj.range(2);
else
    indtime=true(size(obj.coord.xr)); 
end
obj.coord.indtime=indtime;
mfun=str2func(obj.getSingleGuiParameter('fitmode').selection);
x=obj.coord.xr(indtime);
y=obj.coord.yr(indtime);
tv=obj.coord.timeplot(indtime);  
stepv=stepvalue(x,stepindex,mfun);
steps.indstep=stepindex;
steps.steptime=tv(stepindex);
steps.stepvalue=stepv;
steps.stepsize=diff(stepv);
steps.possteps.x=stepv;
steps.possteps.y=stepvalue(y,stepindex,mfun);
if ~isempty(obj.coord.z)
    z=obj.coord.z(indtime);
    steps.possteps.z=stepvalue(z,stepindex,mfun);
end
steps.possteps.time=tv(stepindex);
steps.dwelltime=diff(steps.steptime);
if isfield(obj.site.evaluation,obj.name)
    out=obj.site.evaluation.(obj.name);
end

out.steps=steps;
obj.steps=steps;
out.statall=caluclatestatistics(obj,obj.index);
out.stattrack=caluclatestatistics(obj,obj.index,obj.coord.indtime);
out.range=obj.range;
obj.site.evaluation.(obj.name)=out;
end

function makemovie(a,b,obj)
time=obj.coord.timeplot;
frametime=obj.getSingleGuiParameter('frametime');
if isempty(frametime)
    frametime=mode(diff(time));
end

x=obj.coord.xr;
y=obj.coord.yr;
ts=min(time):frametime:max(time);
f=figure(99);
f.Position(1)=1;f.Position(3)=1280;
ax=gca;

delete(ax.Children)

axis(ax,'equal');

xlim(ax,[min(x)-10 max(x)+10])
ylim(ax,[min(y)-10 max(y)+10])
hold(ax,'on')
plot(ax,[min(x)-5 min(x)+10-5], [min(y)-5 min(y)-5],'k','LineWidth',3)
ax.XTick=[];
ax.YTick=[];
for k=1:length(ts)
    indh=time<=ts(k);
    xh=x(indh);
    yh=y(indh);
    th=time(indh);
%                     hold(ax,'off')
    hd=plot(ax,xh(end),yh(end),'ro','MarkerFaceColor','r','MarkerSize',15);
    hold(ax,'on')
    hb=plot(ax,xh,yh,'bo','MarkerSize',5,'MarkerFaceColor','b'); 
    

    tpassed=ts(k)-ts(1);
    ht=text(ax,double(min(x)),double(max(y)),[num2str(tpassed,'%3.0f') ' ms'],'FontSize',15);
        
    indc=obj.steps.steptime<ts(k);
    cx=obj.steps.possteps.x(indc);
    cy=obj.steps.possteps.y(indc);
%     if ~isempty(cx)
        hc=plot(ax,cx,cy,'m+','MarkerSize',15,'LineWidth',6);
%     end
    hl=plot(ax,xh,yh,'k','LineWidth',1);
    drawnow
    Fr(k)=getframe(ax);
    delete(hd)
    delete(hl)
    delete(ht)
    delete(hb)
    delete(hc)
end
smlfile=obj.getPar('lastSMLFile');
if ~isempty(smlfile)
    pfad=fileparts(smlfile);
else
    pfad=fileparts(obj.locData.files.file(1).name);
end

[file,pfad]=uiputfile([pfad filesep '*.mp4']);
if file
    mysavemovie(Fr,[pfad  file],'FrameRate',20)
end

                  
end

function pard=guidef(obj)
pard.linkt.object=struct('String','Link','Style','text');
pard.linkt.position=[1,3];
pard.link.object=struct('String',{{'group','id'}},'Style','popupmenu');
pard.link.position=[1,3.5];
pard.link.Width=1.5;

pard.overshoott.object=struct('String','Coarsness','Style','text');
pard.overshoott.position=[2,1];
pard.overshoot.object=struct('String','1','Style','edit');
pard.overshoot.position=[2,2];
pard.overshoot.Width=0.5;

pard.fitmodet.object=struct('String','fit using','Style','text');
pard.fitmodet.position=[2,2.5];
pard.fitmode.object=struct('String',{{'mean','median'}},'Style','popupmenu');
pard.fitmode.position=[2,3.5];
pard.fitmode.Width=1.5;

pard.currentrange.object=struct('String','Current Range','Style','pushbutton','Callback',{{@selectrange,obj}});
pard.currentrange.position=[1,1];
pard.currentrange.Width=2;

pard.refit.object=struct('String','Refit','Style','pushbutton','Callback',{{@refit,obj,1}});
pard.refit.position=[5,3];
pard.refit.Width=2;

pard.refine.object=struct('String','Refine','Style','pushbutton','Callback',{{@refit,obj,2}});
pard.refine.position=[5,1];
pard.refine.Width=2;

%auto-fit
p(1).value=0; p(1).on={}; p(1).off={'splitmerget','splitmergestep'};
p(2).value=1; p(2).on=p(1).off; p(2).off={};
pard.splitmerge.object=struct('Value',1,'String','Split and merge','Style','checkbox','Callback',{{@obj.switchvisible,p}});
pard.splitmerge.position=[3,1];
pard.splitmerge.Width=2;
pard.splitmerget.object=struct('String','step','Style','text');
pard.splitmerget.position=[3,3];
pard.splitmergestep.object=struct('String','','Style','edit');
pard.splitmergestep.position=[3,4];

pard.split.object=struct('String','Split','Style','pushbutton','Callback',{{@splitmerge,obj,1}});
pard.split.position=[4,1];
pard.split.Width=1.5;
pard.merge.object=struct('String','Merge','Style','pushbutton','Callback',{{@splitmerge,obj,2}});
pard.merge.position=[4,2.5];
pard.merge.Width=1.5;

pard.left.object=struct('String','<-','Style','pushbutton','Callback',{{@splitmerge,obj,3}});
pard.left.position=[4,4];
pard.left.Width=0.5;

pard.right.object=struct('String','->','Style','pushbutton','Callback',{{@splitmerge,obj,4}});
pard.right.position=[4,4.5];
pard.right.Width=0.5;


pard.makemovie.object=struct('String','Make Movie','Style','pushbutton','Callback',{{@makemovie,obj}});
pard.makemovie.position=[6,1];
pard.makemovie.Width=1.5;

pard.frametimet.object=struct('String','frametime','Style','text');
pard.frametimet.position=[6,3];
pard.frametime.object=struct('String','1','Style','edit');
pard.frametime.position=[6,4];

% pard.dxt.Width=3;
pard.inputParameters={'numberOfLayers','sr_layerson','se_cellfov','se_sitefov','se_siteroi','se_sitepixelsize'};
pard.plugininfo.type='ROI_Evaluate';
pard.plugininfo.description='';
end
