function [varargout]=drawmarkers(ax,varargin)
%DRAWMARKERS    Draw markers in SEIZMO plot deleting any existing ones
%
%    Usage:    drawmarkers(ax)
%              drawmarkers(ax,'option',value,...)
%              [hmark,hflag]=drawmarkers(...)
%
%    Description:
%     DRAWMARKERS(AX) will draw markers (given by header fields A, KA, F,
%     KF, O, KO, T, KT) in the axes given by AX.  The axes must have been
%     drawn by either PLOT0, PLOT1, or RECORDSECTION.  The A marker is
%     green/magenta colored, F is red/cyan, O is orange/blue, and T markers
%     are yellow/blue.  If AX is not given or empty, DRAWMARKERS uses the
%     current axes.
%
%     DRAWMARKERS(AX,'OPTION',VALUE,...) sets certain plotting options for
%     the markers.  Available options are:
%      MARKERACOLOR     -- default is 'g'
%      MARKERFCOLOR     -- default is 'r'
%      MARKEROCOLOR     -- default is [1 .5 0]
%      MARKERTCOLOR     -- default is 'y'
%      MARKERLINEWIDTH  -- default is 1
%      MARKERFONTSIZE   -- default is 6
%      MARKERFONTWEIGHT -- default is 'normal'
%      MARKERFONTNAME   -- default is 'helvetica'
%      MARKERHORZALIGN  -- 'left' (default), 'center', or 'right'
%      MARKERHEIGHT     -- height of marker in % yrange of a record (50%)
%      FLAGMAST         -- flag position on marker in percent (100%)
%
%     [HMARK,HFLAG]=DRAWMARKERS(...) returns the handles to the markers and
%     their flags in HMARK and HFLAG.  Both are cell arrays with as many
%     cells as axes in AX.
%
%    Notes:
%
%    Examples:
%     % draw markers in subplots made by PLOT1
%     ax=plot1(data);
%     drawmarkers(ax)
%
%    See also: PLOT0, PLOT1, RECORDSECTION, SHOWMARKERS, SHOWFLAGS,
%              STRETCHMARKERS, FLIPFLAGS

%     Version History:
%        Sep. 14, 2010 - initial version
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Sep. 14, 2010 at 23:00 GMT

% todo:

% check nargin
error(nargchk(0,inf,nargin));

% use current axes if none given
if(nargin<1 || isempty(ax)); ax=gca; end

% check all inputs are axes
if(isempty(ax) || ~isreal(ax) || any(~ishandle(ax)) ...
        || any(~strcmp('axes',get(ax,'type'))))
    error('seizmo:drawmarkers:badInput',...
        'AXES must be an array of axes handles!');
end

% default/parse options
opt=parse_seizmo_plot_options(varargin{:});

% loop over axes
hmark=cell(numel(ax),1);
hflag=hmark;
for i=1:numel(ax)
    % clear markers in axes
    oldmark=findobj(ax(i),'-regexp','tag','marker$');
    oldflag=findobj(ax(i),'-regexp','tag','flag$');
    delete(oldmark);
    delete(oldflag);
    
    % get marker info
    userdata=get(ax(i),'userdata');
    if(~isstruct(userdata) ...
            || any(~isfield(userdata,{'markers' 'function'})))
        continue;
    end
    
    % action depends on drawing function
    switch lower(userdata.function)
        case {'plot0' 'recordsection'}
            % preallocate handles
            rh=userdata.markers.records;
            nrh=numel(rh);
            grh=ishandle(rh);
            hmark{i}=nan(nrh,13);
            hflag{i}=hmark{i};
            
            % handle plot0 ydir being opposite
            if(strcmpi(userdata.function,'plot0'))
                opt.FLAGMAST=100-opt.FLAGMAST;
            end
            
            % get data ymax/ymin
            range=nan(nrh,2);
            
            % loop over good records
            hold(ax(i),'on');
            for j=find(grh)'
                % get data ymax/ymin
                range(j,1)=min(get(rh(j),'ydata'));
                range(j,2)=max(get(rh(j),'ydata'));
                
                % adjust for marker height
                range(j,:)=sum(range(j,:))/2+[-1 1].*opt.MARKERHEIGHT./200.*diff(range(j,:));
                
                % masted flag position
                fpos=range(j,1)+diff(range(j,:))*opt.FLAGMAST/100;
                
                % draw markers & flags
                hmark{i}(j,1)=plot(ax(i),[userdata.markers.times(j,1); userdata.markers.times(j,1)],range(j,:),...
                    'color',opt.MARKERACOLOR,...
                    'linewidth',opt.MARKERLINEWIDTH);
                hflag{i}(j,1)=text(userdata.markers.times(j,1),fpos,userdata.markers.names{j,1},...
                    'horizontalalignment',opt.MARKERHORZALIGN,...
                    'verticalalignment',opt.MARKERVERTALIGN,...
                    'color',opt.MARKERACOLOR,...
                    'edgecolor',opt.MARKERACOLOR,...
                    'backgroundcolor',invertcolor(opt.MARKERACOLOR,true),...
                    'linewidth',opt.MARKERLINEWIDTH,...
                    'fontsize',opt.MARKERFONTSIZE,...
                    'fontweight',opt.MARKERFONTWEIGHT,...
                    'fontname',opt.MARKERFONTNAME,...
                    'parent',ax(i));
                hmark{i}(j,2)=plot(ax(i),[userdata.markers.times(j,2); userdata.markers.times(j,2)],range(j,:),...
                    'color',opt.MARKERFCOLOR,...
                    'linewidth',opt.MARKERLINEWIDTH);
                hflag{i}(j,2)=text(userdata.markers.times(j,2),fpos,userdata.markers.names{j,2},...
                    'horizontalalignment',opt.MARKERHORZALIGN,...
                    'verticalalignment',opt.MARKERVERTALIGN,...
                    'color',opt.MARKERFCOLOR,...
                    'edgecolor',opt.MARKERFCOLOR,...
                    'backgroundcolor',invertcolor(opt.MARKERFCOLOR,true),...
                    'linewidth',opt.MARKERLINEWIDTH,...
                    'fontsize',opt.MARKERFONTSIZE,...
                    'fontweight',opt.MARKERFONTWEIGHT,...
                    'fontname',opt.MARKERFONTNAME,...
                    'parent',ax(i));
                hmark{i}(j,3)=plot(ax(i),[userdata.markers.times(j,3); userdata.markers.times(j,3)],range(j,:),...
                    'color',opt.MARKEROCOLOR,...
                    'linewidth',opt.MARKERLINEWIDTH);
                hflag{i}(j,3)=text(userdata.markers.times(j,3),fpos,userdata.markers.names{j,3},...
                    'horizontalalignment',opt.MARKERHORZALIGN,...
                    'verticalalignment',opt.MARKERVERTALIGN,...
                    'color',opt.MARKEROCOLOR,...
                    'edgecolor',opt.MARKEROCOLOR,...
                    'backgroundcolor',invertcolor(opt.MARKEROCOLOR,true),...
                    'linewidth',opt.MARKERLINEWIDTH,...
                    'fontsize',opt.MARKERFONTSIZE,...
                    'fontweight',opt.MARKERFONTWEIGHT,...
                    'fontname',opt.MARKERFONTNAME,...
                    'parent',ax(i));
                hmark{i}(j,4:13)=plot(ax(i),[userdata.markers.times(j,4:13); userdata.markers.times(j,4:13)],range(j,:),...
                    'color',opt.MARKERTCOLOR,...
                    'linewidth',opt.MARKERLINEWIDTH);
                for k=0:9
                    hflag{i}(j,4+k)=text(userdata.markers.times(j,4+k),fpos,userdata.markers.names{j,4+k},...
                        'horizontalalignment',opt.MARKERHORZALIGN,...
                        'verticalalignment',opt.MARKERVERTALIGN,...
                        'color',opt.MARKERTCOLOR,...
                        'edgecolor',opt.MARKERTCOLOR,...
                        'backgroundcolor',invertcolor(opt.MARKERTCOLOR,true),...
                        'linewidth',opt.MARKERLINEWIDTH,...
                        'fontsize',opt.MARKERFONTSIZE,...
                        'fontweight',opt.MARKERFONTWEIGHT,...
                        'fontname',opt.MARKERFONTNAME,...
                        'parent',ax(i));
                end
            end
            hold(ax(i),'off');
            
            % tag markers and flags
            set(hmark{i}(grh,1),'tag','amarker');
            set(hflag{i}(grh,1),'tag','aflag');
            set(hmark{i}(grh,2),'tag','fmarker');
            set(hflag{i}(grh,2),'tag','fflag');
            set(hmark{i}(grh,3),'tag','omarker');
            set(hflag{i}(grh,3),'tag','oflag');
            for j=0:9
                set(hmark{i}(grh,4+j),'tag',['t' num2str(j) 'marker']);
                set(hflag{i}(grh,4+j),'tag',['t' num2str(j) 'flag']);
            end
            tmpflag=hflag{i}(grh,:);
            tmpmark=hmark{i}(grh,:);
            tmp.mast=opt.FLAGMAST;
            for j=1:numel(tmpflag)
                tmp.marker=tmpmark(j);
                set(tmpflag(j),'userdata',tmp);
            end
            
            % push markers and flags into the background
            movekids(hflag{i}(grh,:),'back');
            movekids(hmark{i}(grh,:),'back');
        case 'plot1'
            % preallocate handles
            hmark{i}=nan(1,13);
            hflag{i}=hmark{i};
            
            % get data ymax/ymin
            rh=findobj(ax(i),'tag','record');
            if(isempty(rh)); continue; end
            range=[min(get(rh(1),'ydata')) max(get(rh(1),'ydata'))];
            
            % adjust for marker height
            range=sum(range,2)/2+[-1 1].*opt.MARKERHEIGHT./200.*diff(range,1,2);
            
            % masted flag position
            fpos=range(1)+diff(range)*opt.FLAGMAST/100;
            
            % draw markers & flags
            hold(ax(i),'on');
            hmark{i}(1)=plot(ax(i),[userdata.markers.times(1); userdata.markers.times(1)],range,...
                'color',opt.MARKERACOLOR,...
                'linewidth',opt.MARKERLINEWIDTH);
            hflag{i}(1)=text(userdata.markers.times(1),fpos,userdata.markers.names{1},...
                'horizontalalignment',opt.MARKERHORZALIGN,...
                'verticalalignment',opt.MARKERVERTALIGN,...
                'color',opt.MARKERACOLOR,...
                'edgecolor',opt.MARKERACOLOR,...
                'backgroundcolor',invertcolor(opt.MARKERACOLOR,true),...
                'linewidth',opt.MARKERLINEWIDTH,...
                'fontsize',opt.MARKERFONTSIZE,...
                'fontweight',opt.MARKERFONTWEIGHT,...
                'fontname',opt.MARKERFONTNAME,...
                'parent',ax(i));
            hmark{i}(2)=plot(ax(i),[userdata.markers.times(2); userdata.markers.times(2)],range,...
                'color',opt.MARKERFCOLOR,...
                'linewidth',opt.MARKERLINEWIDTH);
            hflag{i}(2)=text(userdata.markers.times(2),fpos,userdata.markers.names{2},...
                'horizontalalignment',opt.MARKERHORZALIGN,...
                'verticalalignment',opt.MARKERVERTALIGN,...
                'color',opt.MARKERFCOLOR,...
                'edgecolor',opt.MARKERFCOLOR,...
                'backgroundcolor',invertcolor(opt.MARKERFCOLOR,true),...
                'linewidth',opt.MARKERLINEWIDTH,...
                'fontsize',opt.MARKERFONTSIZE,...
                'fontweight',opt.MARKERFONTWEIGHT,...
                'fontname',opt.MARKERFONTNAME,...
                'parent',ax(i));
            hmark{i}(3)=plot(ax(i),[userdata.markers.times(3); userdata.markers.times(3)],range,...
                'color',opt.MARKEROCOLOR,...
                'linewidth',opt.MARKERLINEWIDTH);
            hflag{i}(3)=text(userdata.markers.times(3),fpos,userdata.markers.names{3},...
                'horizontalalignment',opt.MARKERHORZALIGN,...
                'verticalalignment',opt.MARKERVERTALIGN,...
                'color',opt.MARKEROCOLOR,...
                'edgecolor',opt.MARKEROCOLOR,...
                'backgroundcolor',invertcolor(opt.MARKEROCOLOR,true),...
                'linewidth',opt.MARKERLINEWIDTH,...
                'fontsize',opt.MARKERFONTSIZE,...
                'fontweight',opt.MARKERFONTWEIGHT,...
                'fontname',opt.MARKERFONTNAME,...
                'parent',ax(i));
            hmark{i}(4:13)=plot(ax(i),[userdata.markers.times(4:13); userdata.markers.times(4:13)],range,...
                'color',opt.MARKERTCOLOR,...
                'linewidth',opt.MARKERLINEWIDTH);
            for j=0:9
                hflag{i}(4+j)=text(userdata.markers.times(4+j),fpos,userdata.markers.names{4+j},...
                    'horizontalalignment',opt.MARKERHORZALIGN,...
                    'verticalalignment',opt.MARKERVERTALIGN,...
                    'color',opt.MARKERTCOLOR,...
                    'edgecolor',opt.MARKERTCOLOR,...
                    'backgroundcolor',invertcolor(opt.MARKERTCOLOR,true),...
                    'linewidth',opt.MARKERLINEWIDTH,...
                    'fontsize',opt.MARKERFONTSIZE,...
                    'fontweight',opt.MARKERFONTWEIGHT,...
                    'fontname',opt.MARKERFONTNAME,...
                    'parent',ax(i));
            end
            hold(ax(i),'off');
            
            % tag markers and flags
            set(hmark{i}(1),'tag','amarker');
            set(hflag{i}(1),'tag','aflag');
            set(hmark{i}(2),'tag','fmarker');
            set(hflag{i}(2),'tag','fflag');
            set(hmark{i}(3),'tag','omarker');
            set(hflag{i}(3),'tag','oflag');
            for j=0:9
                set(hmark{i}(4+j),'tag',['t' num2str(j) 'marker']);
                set(hflag{i}(4+j),'tag',['t' num2str(j) 'flag']);
            end
            set(hmark{i},'tag','marker');
            set(hflag{i},'tag','flag');
            tmp.mast=opt.FLAGMAST;
            for j=1:13
                tmp.marker=hmark{i}(j);
                set(hflag{i}(j),'userdata',tmp);
            end
            
            % push markers and flags into the background
            movekids(hflag{i},'back');
            movekids(hmark{i},'back');
        otherwise
            error('seizmo:drawmarkers:unknownFunction',...
                'I''m not sure how to draw markers for function: %s',...
                userdata.function);
    end
end

% output
if(nargout); varargout={hmark hflag}; end

end