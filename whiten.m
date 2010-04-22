function [data]=whiten(data,width,units,varargin)
%WHITEN    Spectral whitening/normalization of SEIZMO data records
%
%    Usage:    data=whiten(data)
%              data=whiten(data,width)
%              data=whiten(data,width,units)
%              data=whiten(data,width,units,'optionname',optionvalue,...)
%
%    Description: WHITEN(DATA) will perform spectral normalization (aka
%     whitening) on records in the SEIZMO structure DATA.  Normalization is
%     performed by dividing the complex spectrum by a smoothed version of
%     the amplitude spectrum.  Smoothing utilizes a 41-sample sliding mean.
%     This is NOT equivalent to the 'whiten' command in SAC (see function
%     PREWHITEN).  This operation is particularly suited for ambient noise
%     studies.
%
%     WHITEN(DATA,WIDTH) sets the width of the smoothing window.  WIDTH is
%     in Hz.  The default value is 0.001 Hz (1 mHz).  Note this width is
%     converted to number of samples, which may lead to a slightly larger
%     smoothing width.
%
%     WHITEN(DATA,WIDTH,UNITS) provides access to the units of WIDTH.
%     UNITS may be either 'Hz' or 'samples'.  The default is 'Hz'.  If
%     UNITS is 'samples', WIDTH must be a positive integer.  Even integers
%     are rounded up to the next higher odd integer so the window is
%     centered on a point.
%
%     WHITEN(DATA,WIDTH,UNITS,'OPTIONNAME',OPTIONVALUE,...) will pass
%     additional sliding options on to the SLIDINGMEAN call.  See
%     SLIDINGMEAN for more information.
%
%    Notes:
%     - Suggested Reading:
%       - Bensen et al, 2007, Processing Seismic Ambient Noise Data to
%         Obtain Reliable Broad-Band Surface Wave Dispersion Measurements,
%         GJI, Vol. 169, p. 1239-1260
%
%    Header Changes: DEPMIN, DEPMAX, DEPMEN
%
%    Examples:
%     Spectral normalization returns much whiter noise:
%      plot1([data(1) whiten(data(1))])
%
%    See also: SLIDINGMEAN, PREWHITEN, UNPREWHITEN

%     Version History:
%        June  9, 2009 - initial version
%        June 11, 2009 - updated default halfwindow from 2 to 20
%        June 24, 2009 - now transparent to filetype (except ixyz)
%        Dec.  4, 2009 - fixed rlim handling
%        Dec.  7, 2009 - no divide by zero by adding eps to smooth spectra
%        Feb.  3, 2010 - proper SEIZMO handling
%        Apr. 21, 2010 - doc update, need to update code to match
%        Apr. 22, 2010 - code now matches docs
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Apr. 22, 2010 at 10:05 GMT

% todo:

% check number of inputs
msg=nargchk(1,inf,nargin);
if(~isempty(msg)); error(msg); end

% check data structure
msg=seizmocheck(data,'dep');
if(~isempty(msg)); error(msg.identifier,msg.message); end

% turn off struct checking
oldseizmocheckstate=seizmocheck_state(false);

% attempt header check
try
    % check header
    data=checkheader(data);
    
    % turn off header checking
    oldcheckheaderstate=checkheader_state(false);
catch
    % toggle checking back
    seizmocheck_state(oldseizmocheckstate);
    
    % rethrow error
    error(lasterror)
end

% attempt spectral whitening
try
    % number of records
    nrecs=numel(data);
    
    % verbosity
    verbose=seizmoverbose;
    
    % detail message
    if(verbose); disp('Beginning Spectral Whitening of Record(s)'); end
    
    % get some header fields
    leven=getlgc(data,'leven');
    iftype=getenumid(data,'iftype');

    % cannot do xyz records
    if(any(strcmpi(iftype,'ixyz')))
        error('seizmo:whiten:badIFTYPE',...
            ['Record(s):\n' sprintf('%d ', ...
            find(~strcmpi(iftype,'ixyz'))) ...
            '\nInvalid operation on XYZ record(s)!']);
    end

    % cannot do unevenly sampled records
    if(any(strcmpi(leven,'false')))
        error('seizmo:whiten:badLEVEN',...
            ['Record(s):\n' sprintf('%d ',find(strcmpi(leven,'false'))) ...
            '\nInvalid operation on unevenly sampled record(s)!']);
    end
    
    % check window options
    if(nargin<2 || isempty(width)); width=0.001; end
    if(nargin<3 || isempty(units)); units='hz'; end
    if(~isreal(width) || width<=0 || ~any(numel(width)==[1 nrecs]))
        error('seizmo:whiten:badWidth',...
            'WIDTH must be a positive real!');
    end
    if(isscalar(width)); width(1:nrecs,1)=width; end
    if(ischar(units)); units=cellstr(units); end
    if(~iscellstr(units) || ~any(numel(width)==[1 nrecs]) ...
            || any(~ismember(lower(units),{'hz' 'samples'})))
        error('seizmo:whiten:badUnits',...
            'UNITS must be ''Hz'' or ''samples''!');
    end
    if(isscalar(units)); units(1:nrecs,1)=units; end
    hz=strcmpi(units,'hz');

    % get filetype logical arrays
    istime=strcmpi(iftype,'itime');
    isxy=strcmpi(iftype,'ixy');
    isrlim=strcmpi(iftype,'irlim');
    isamph=strcmpi(iftype,'iamph');

    % get amph and rlim type records
    if(any(istime | isxy))
        amph(istime | isxy)=dft(data(istime | isxy));
        data(istime | isxy)=amph2rlim(amph(istime | isxy));
    end
    if(any(isrlim))
        amph(isrlim)=rlim2amph(data(isrlim));
    end
    if(any(isamph))
        amph(isamph)=data(isamph);
        data(isamph)=amph2rlim(data(isamph));
    end
    
    % set halfwidth
    sdelta=getheader(amph,'delta');
    width(hz)=ceil(width(hz)./sdelta(hz)+1);
    width=ceil((width-1)/2);

    % fake amph records as rlim (to get by dividerecords checks/fixes)
    amph=changeheader(amph,'iftype','irlim');

    % get smoothed amplitude records
    amph=slidingmean(amph,width,varargin{:});

    % copy amplitude over phase & add eps to avoid divide by zero
    amph=seizmofun(amph,@(x)x(:,[1:2:end; 1:2:end])+eps);

    % divide complex by smoothed amplitude
    data=dividerecords(data,amph);

    % convert back to original type
    if(any(isamph))
        data(isamph)=rlim2amph(data(isamph));
    end
    if(any(istime | isxy))
        data(istime | isxy)=idft(data(istime | isxy));
    end
    if(any(isxy))
        data(isxy)=changeheader(data(isxy),'iftype','ixy');
    end
    
    % detail message
    if(verbose); disp('Finished Spectral Whitening of Record(s)'); end

    % toggle checking back
    seizmocheck_state(oldseizmocheckstate);
    checkheader_state(oldcheckheaderstate);
catch
    % toggle checking back
    seizmocheck_state(oldseizmocheckstate);
    checkheader_state(oldcheckheaderstate);
    
    % rethrow error
    error(lasterror)
end

end
