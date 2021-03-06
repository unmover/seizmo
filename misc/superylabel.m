function [varargout]=superylabel(ax,varargin)
%SUPERYLABEL    Makes a y-axis label spanning multiple axes
%
%    Usage:    superylabel(ax,'text')
%              superylabel(ax,'text','prop','val',...)
%              h=superylabel(...)
%
%    Description:
%     SUPERYLABEL(AX,'TEXT') adds a label to the left of a group of axes
%     given in AX.  All axes in AX must share the same figure!
%
%     SUPERYLABEL(AX,'TEXT','PROP','VAL',...) sets the values for the
%     specified label properties.
%
%     H=SUPERYLABEL(...) returns the handle to the text object used as the
%     label.  To get handle to the invisible axis for the label use
%     GET(H,'PARENT').
%
%    Notes:
%
%    Examples:
%     % make a figure with 4 2x2 groups of subplots and add super
%     % labeling and super colorbars to each group
%     fh=figure;
%     set(fh,'position',get(fh,'position').*[1 1 1.5 1.5]);
%     ax=makesubplots(5,5,submat(lind(5),1:2,[1 2 4 5]),'parent',fh);
%     ax=mat2cell(reshape(ax,4,4),[2 2],[2 2]);
%     for i=1:4
%         supertitle(ax{i},['super title ' num2str(i)]);
%         superxlabel(ax{i},['super xlabel ' num2str(i)]);
%         superylabel(ax{i},['super ylabel ' num2str(i)]);
%         supercolorbar(ax{i},'location','eastoutside');
%     end
%
%    See also: SUPERTITLE, SUPERXLABEL, SUPERCOLORBAR, MAKESUBPLOTS,
%              NOLABELS, NOTICKS, NOTITLES, NOCOLORBARS, AXMOVE, AXEXPAND,
%              AXSTRETCH

%     Version History:
%        Aug.  5, 2010 - initial version
%        Aug.  8, 2010 - move super axis below, tag & userdata used to
%                        replace on subsequent calls
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Aug.  8, 2010 at 12:25 GMT

% todo:

% check nargin
error(nargchk(1,inf,nargin));

% check inputs
if(isempty(ax) || (isreal(ax) && isscalar(ax)) ...
        || ischar(ax) || iscellstr(ax))
    % single or no axis - use ylabel
    h=ylabel(ax,varargin{:});
    set(h,'visible','on');
    return;
elseif(~isreal(ax) || any(~ishandle(ax(:))) ...
        || any(~strcmp('axes',get(ax(:),'type'))) ...
        || ~isscalar(unique(cell2mat(get(ax(:),'parent')))))
    error('seizmo:superylabel:badInput',...
        'AX must be valid axes handles all in the same figure!');
end
p=get(ax(1),'parent');

% get position of new axis
lbwh=get(ax,'position');
if(iscell(lbwh)); lbwh=cat(1,lbwh{:}); end
newpos=[min(lbwh(:,1:2)) max(lbwh(:,1:2)+lbwh(:,3:4))]; % LBRT
newpos(3:4)=newpos(3:4)-newpos(1:2); % LBWH

% create axis, set ylabel, move below & make invisible
sax=findobj(p,'type','axes','tag','super','userdata',ax);
if(isempty(sax))
    sax=axes('position',newpos);
    set(sax,'parent',p);
    h=ylabel(sax,varargin{:});
    kids=get(p,'children');
    set(p,'children',[kids(2:end); kids(1)]);
    set(sax,'visible','off','tag','super','userdata',ax);
    set(h,'visible','on');
else
    % everything should be fine, so just set the ylabel
    h=ylabel(sax,varargin{:});
    set(h,'visible','on');
end

% output
if(nargout); varargout{1}=h; end

end
