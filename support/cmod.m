function [c]=cmod(a,b)
%CMOD    Returns a centered modulus
%
%    Usage: [c]=cmod(a,b)
%
%    Description: CMOD(A,B) is A-N.*X where N=round(A./B) if B~=0.  Thus
%     CMOD(A,B) is always within the range +/-B/2.  The inputs A and B must
%     be real arrays of the same size, or real scalars.
%
%    Notes:
%     By convention:
%      cmod(A,0) returns A
%      cmod(A,A) returns 0
%
%    Tested on: Matlab r2007b
%
%    Examples:
%     To get longitude values LON within the range of +/-180:
%      LON=cmod(LON,360);
%
%    See also: mod, rem

%     Version History:
%        Mar. 24, 2009 - initial version
%        Apr. 23, 2009 - move usage up
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Apr. 23, 2009 at 22:20 GMT

c=a-round(a./b).*b;
if(isscalar(b))
    if(b==0)
        c=a;
    end
else
    d=b==0;
    c(d)=a(d);
end

end