function hh = uitabdemo(option)

% UITABDEMO  This script demostrates the use of UITABPANEL.

% Author: Shiying Zhao (zhao@arch.umsl.edu)
% Version: 1.0
% First created: May 02, 2006
% Last modified: May 20, 2006

if nargin<1, option = 1; end
switch option
  case 1
    style1 = 'popup';
    style2 = 'lefttop';
    style3 = 'rightbottom';
  case 2
    style1 = 'popup';
    style2 = 'righttop';
    style3 = 'leftbottom';
  otherwise
    style1 = 'popup';
    style2 = 'centertop';
    style3 = 'centerbottom';
end

width = 0;
hfig = figure(...
  'Name','uitabpanel demo',...
  'NumberTitle','off', ...
  'Menubar','none',...
  'Toolbar','none');

%--------------------------------------------------------------------------
% Creating the tabs
%--------------------------------------------------------------------------
htab(1) = uitabpanel(...
  'Parent',hfig,...
  'Style',style1,...
  'Units','normalized',...
  'Position',[0,0,0.3,1],...
  'FrameBackgroundColor',[0.4314,0.5882,0.8431],...
  'FrameBorderType','etchedin',...
  'Title',{'This is popup tab','Click me!','See also','About'},...
  'PanelHeights',[8,30,10,10],...
  'HorizontalAlignment','left',...
  'FontWeight','bold',...
  'TitleBackgroundColor',[0.9255 0.9490 0.9765],...
  'TitleForegroundColor',[0.1294,0.3647,0.8510],...
  'PanelBackgroundColor',[0.7725,0.8431,0.9608],...
  'PanelBorderType','line',...
  'CreateFcn',@CreateTab1);

htab(2) = uitabpanel(...
  'Parent',hfig,...
  'TabPosition',style2,...
  'Position',[0.3,0.5,0.7,0.5],...
  'Margins',{[0,-1,1,0],'pixels'},...
  'PanelBorderType','line',...
  'Title',{'Introduction','Syntax','Features','Todo'},...
  'CreateFcn',@CreateTab2);

htab(3) = uitabpanel(...
  'Parent',hfig,...
  'TitlePosition',style3,...
  'Position',[0.3,0,0.7,0.5],...
  'Margins',{[0,1,1,0],'pixels'},...
  'Title',{'The Earth','The Globe','More Styles'},...
  'CreateFcn',@CreateTab3,...
  'SelectedItem',3);

if nargout, hh = htab; end

%--------------------------------------------------------------------------
  function CreateTab1(htab,evdt,hpanel,hstatus)
    uicontrol(...
      'Parent',hpanel(1),...
      'Units','normalized',...
      'Position',[.1,.1,.9,.8],...
      'BackgroundColor',get(hpanel(3),'BackgroundColor'),...
      'HorizontalAlignment','left',...
      'Style','text',...
      'String',[...
      'Popup panel is another   '
      'type of UITABPANEL       '
      'with the ''Style''         '
      'property set to ''Popup''. '
      'Click on its title bar   '
      'toggle open/close of the '
      'popup panel.             ']);

    uicontrol(...
      'Parent',hpanel(2),...
      'Units','normalized',...
      'Position',[.1,.02,.8,.95],...
      'BackgroundColor',get(hpanel(3),'BackgroundColor'),...
      'HorizontalAlignment','left',...
      'Style','text',...
      'String',[...
      'Here is a long panel. '
      'Using the vertical    '
      'slider to scroll up   '
      'and down for the rest '
      'of content in this    '
      'popup panel.          '
      '                      '
      'All popup panels have '
      'the same vertical     '
      'layout.               '
      '                      '
      'The length of each    '
      'panel in the group can'
      'be specified using the'
      'the property          '
      '''PanelHeights'' at     '
      'creation time, which  '
      'should be a numeric   '
      'array with the same   '
      'length of ''Title'' in  '
      'the unit of           '
      '''Characters''.         '
      '                      '
      'Interactive change of '
      'the length of a panel '
      'in the group can only '
      'be done when it is    '
      'deactivated.          ']);

    uicontrol(...
      'Parent',hpanel(3),...
      'Units','normalized',...
      'Position',[.1,.1,.8,.82],...
      'BackgroundColor',get(hpanel(3),'BackgroundColor'),...
      'HorizontalAlignment','left',...
      'Style','text',...
      'String',[...
      'tabpanel, by Dirk Tenne '
      'Tab panel example, by   '
      '  Bill York             '
      'TabPanel Constructor    '
      '  v1.3, by Elmar Tarajan'
      'Tab Panel (Yet another  '
      '  one), by Laine Berhane'
      '  Kahsay                '
      'in File Exchange Site.  ']);

    uicontrol(...
      'Parent',hpanel(4),...
      'Units','normalized',...
      'Position',[.1,.1,.8,.76],...
      'BackgroundColor',get(hpanel(3),'BackgroundColor'),...
      'Style','text',...
      'String',[...
      '     UITABPANEL     '
      '     version 1.0    '
      '                    '
      '     Created by     '
      '    Shiying Zhao    '
      '(zhao@arch.umsl.edu)'
      '                    '
      '    May 20, 2006    ']);

    uicontrol(...
      'Parent',hstatus,...
      'Units','normalized',...
      'Position',[0,0,1,.3],...
      'BackgroundColor',get(hstatus,'BackgroundColor'),...
      'ForegroundColor',[0.6,1,1],...
      'HitTest','off',...
      'Style','text',...
      'String',[...
      ' Copyright(c) 2006  ' 
      '   Shiying Zhao     '
      'All rights reserved.']);

    set(htab,'ResizeFcn',@TabResize1);
  end

%--------------------------------------------------------------------------
  function CreateTab2(htab,evdt,hpanel,hstatus)
    uicontrol(...
      'Parent',hpanel(1),...
      'Units','normalized',...
      'Position',[.1,.1,.8,.8],...
      'BackgroundColor',get(hpanel(1),'BackgroundColor'),...
      'ForegroundColor','w',...
      'HorizontalAlignment','left',...
      'FontSize',12,...
      'Style','text',...
      'String',[ ...
      'UITABPANEL creates a group of tabbed     '
      'panels with a consistent look and feel to'
      'the builtin MATLAB UI objects.           '
      '                                         '
      'A special type of UITABPANEL is the      '
      'popup tabpanel as shown on the left-hand '
      'side of this figure.                     ']);

    uicontrol(...
      'Parent',hpanel(2),...
      'Units','normalized',...
      'Position',[.1,.1,.8,.8],...
      'BackgroundColor','w',...
      'HorizontalAlignment','left',...
      'Style','text',...
      'String',[...
      '                                                                '
      '   The syntax of using UITABPANEL is the same as                '
      '   UIPANEL except a few property changes. For a complete        '
      '   description, see the online help of UITABPANEL and the       '
      '   MATLAB script of this demo. Examples:                        '
      '                                                                '
      '     htab = uitabpanel( ''Title'',{''A'',''B'',''C'',''D''} )             '
      '     htab = uitabpanel( ''Title'',{''A'',''B''},''Style'',''righttop'' )  '
      '     htab = uitabpanel( ''Title'',{''A'',''B'',''C''},''Position'',my_pos,'
      '                ''CreateFcn'',@my_fun1,''ResizeFcn'',@my_fun2)      ']);
    
    uicontrol(...
      'Parent',hpanel(3),...
      'Units','normalized',...
      'Position',[.1,.1,.8,.8],...
      'BackgroundColor','w',...
      'HorizontalAlignment','left',...
      'Style','text',...
      'String',[...
      '                                                             '
      '   The following is a brief summary of some advanced features'
      '   of the current implementation of UITABPANEL:              '
      '   1. UITABPANEL can be resizable if ''ResizeFcn'' is set.     '
      '   2. A callback routine ''SelectionChangeFcn'' can be defined '
      '      through ''set/getappdata'', which will be executed when  '
      '      the selected tab changes.                              '
      '   3. An empty UICONTAINER in each UITABPANEL is             '
      '      designed mainly for a functional purpose, but is can be'
      '      used by users for other purposes in a number of ways.  ']);

    uicontrol(...
      'Parent',hpanel(4),...
      'Units','normalized',...
      'Position',[.1,.1,.8,.8],...
      'BackgroundColor','w',...
      'HorizontalAlignment','left',...
      'Style','text',...
      'String',[...
      '                                                            '
      '   Although the current implementation of UITABPANEL works  '
      '   well for small number of tabs, many improvements and new '
      '   features are still desirable.                            '
      '                                                            '
      '   An immediate task is to add more styles, such as vertical'
      '   tabs and multi-row tabs. However, the most desirable     '
      '   improvement to me is to rewrite UITABPANEL as a          '
      '   MATLAB class, so that it will behave in the same way as  '
      '   the builtin MATLAB user interface (UI) objects.          ']);

    uicontrol(...
      'Parent',hstatus,...
      'Units','normalized',...
      'Position',[0,0.1,1,.68],...
      'BackgroundColor',get(hstatus,'BackgroundColor'),...
      'ForegroundColor','k',...
      'HitTest','off',...
      'Style','text',...
      'String',['This is ',style2,' tab']);
    setappdata(htab,'SelectionChangeFcn',@TabStatus2);

    set(htab,'ResizeFcn',{@TabResize2,[0.5,0.5]});
  end

%--------------------------------------------------------------------------
  function CreateTab3(htab,evdt,hpanel,hstatus)
    uicontrol(...
      'Parent',hpanel(3),...
      'Units','normalized',...
      'Position',[.3,.1,.6,.6],...
      'BackgroundColor',get(hpanel(1),'BackgroundColor'),...
      'ForegroundColor','w',...
      'HorizontalAlignment','left',...
      'FontSize',12,...
      'Style','text',...
      'String',[...
      'Run this demo with the optional '
      'argument 1, 2, and 3 to view all'
      'implemented styles.             ']);
      
    load('topo.mat','topo','topomap1');
    axes('Parent',hpanel(1));
    PlotTheEarth(topo,topomap1);

    axes('Parent',hpanel(2),'Position',[0,.1,.8,.8]);
    axis square off
    uicontrol(...
      'Parent',hpanel(2),...
      'Units','normalized',...
      'Position',[0.7,.4,.2,.1],...
      'Style','pushbutton',...
      'Callback',{@PlotTheGlobel,topo},...
      'String','Create it!');
    uicontrol(...
      'Parent',hpanel(2),...
      'Units','normalized',...
      'Position',[0.7,.2,.2,.1],...
      'Style','pushbutton',...
      'Callback','cla',...
      'String','Remove it!');

    uicontrol(...
      'Parent',hstatus,...
      'Units','normalized',...
      'Position',[0,0.1,1,.68],...
      'BackgroundColor',get(hstatus,'BackgroundColor'),...
      'ForegroundColor','k',...
      'HitTest','off',...
      'Style','text',...
      'String',['This is ',style3,' tab']);

    set(htab,'ResizeFcn',{@TabResize2,[0,0.5]});
  end

%--------------------------------------------------------------------------
  function TabResize1(hobj,evdt)
    figpos = get(hfig,'Position');
    tabpos = get(hobj,'Position');
    tabpos(4) = figpos(4);
    set(hobj,'Position',tabpos);

    width = tabpos(3)/figpos(3);
  end

%--------------------------------------------------------------------------
  function TabResize2(hobj,evdt,ysiz)
    figpos = get(hfig,'Position');
    tabpos = get(hobj,'Position');
    tabpos([1,3]) = [width,1-width]*figpos(3)+[1,0];
    tabpos([2,4]) = ysiz*figpos(4)+[1,0];
    set(hobj,'Position',tabpos);
  end

%--------------------------------------------------------------------------
  function TabStatus2(hobj,evdt)
    set(get(evdt.Status,'Children'),'String',['page ',num2str(evdt.NewValue)]);
  end

%--------------------------------------------------------------------------
  function PlotTheEarth(topo,topomap1)
    contour(0:359,-89:90,topo,[0 0],'b')
    axis equal
    box on
    set(gca,'XLim',[0 360],'YLim',[-90 90], ...
      'XTick',[0 60 120 180 240 300 360], ...
      'YTick',[-90 -60 -30 0 30 60 90]);
    hold on
    image([0 360],[-90 90],topo,'CDataMapping', 'scaled');
    colormap(topomap1);
  end

%--------------------------------------------------------------------------
  function PlotTheGlobel(hobj,evdt,topo)
    [x,y,z] = sphere(50);
    props.AmbientStrength = 0.1;
    props.DiffuseStrength = 1;
    props.SpecularColorReflectance = .5;
    props.SpecularExponent = 20;
    props.SpecularStrength = 1;
    props.FaceColor= 'texture';
    props.EdgeColor = 'none';
    props.FaceLighting = 'phong';
    props.Cdata = topo;
    surface(x,y,z,props);
    light('position',[-1 0 1]);
    light('position',[-1.5 0.5 -0.5], 'color', [.6 .2 .2]);
  end

%--------------------------------------------------------------------------

end
