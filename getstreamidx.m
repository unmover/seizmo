function [idx,streamcode]=getstreamidx(data)
%GETSTREAMIDX    Returns index array for separating dataset into streams
%
%    Usage:    idx=getstreamidx(data)
%              [idx,streamcode]=getstreamidx(data)
%
%    Description: IDX=GETSTREAMIDX(DATA) returns an array of indices that
%     indicate records in SEIZMO structure DATA belonging to a stream.  A
%     stream is defined by the fields KNETWK, KSTNM, KHOLE, and KCMPNM.
%     Only the third character of KCMPNM is allowed to vary between records
%     for a single stream.  This means that sites with multiple sensors
%     will be treated as separate streams as well as sensors that have
%     multiple streams of digitization (ie BH? and HH? channels would
%     be treated as separate streams).
%
%     [IDX,STREAMCODE]=GETSTREAMIDX(DATA) also returns the unique stream
%     codes used to separate the streams.
%
%    Notes:
%     - Case insensitive; all characters are upper-cased.
%
%    Examples:
%     Break a dataset up into separate streams:
%      idx=getstreamidx(data)
%      for i=1:max(idx)
%          streamdata{i}=data(idx==i);
%      end
%
%    See also: getnetworkidx, getstationidx, getcomponentidx

%     Version History:
%        June 28, 2009 - initial version
%
%     Testing Table:
%                                  Linux    Windows     Mac
%        Matlab 7       r14        
%               7.0.1   r14sp1
%               7.0.4   r14sp2
%               7.1     r14sp3
%               7.2     r2006a
%               7.3     r2006b
%               7.4     r2007a
%               7.5     r2007b
%               7.6     r2008a
%               7.7     r2008b
%               7.8     r2009a
%        Octave 3.2.0
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated June 28, 2009 at 23:20 GMT

% todo:

% check nargin
msg=nargchk(1,1,nargin);
if(~isempty(msg)); error(msg); end

% check data structure
msg=seizmocheck(data);
if(~isempty(msg)); error(msg.identifier,msg.message); end

% turn off struct checking
oldseizmocheckstate=get_seizmocheck_state;
set_seizmocheck_state(false);

% check headers
data=checkheader(data);

% get header info
[knetwk,kstnm,khole,kcmpnm]=...
    getheader(data,'knetwk','kstnm','khole','kcmpnm');

% truncate kcmpnm to first 2 characters
kcmpnm=strnlen(kcmpnm,2);

% uppercase
knetwk=upper(knetwk);
kstnm=upper(kstnm);
khole=upper(khole);
kcmpnm=upper(kcmpnm);

% get station groups
[streamcode,idx,idx]=unique(strcat(knetwk,'.',kstnm,'.',khole,'.',kcmpnm));

% toggle checking back
set_seizmocheck_state(oldseizmocheckstate);

end
