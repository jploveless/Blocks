function p = SegmentParamsGeo(B, far);
% Extract/calculate some segment parameters for use with Okada codes.

B.bDep                    = 0*B.bDep;

p.delta                   = B.dip;
p.strike                  = azimuth(B.lat1, B.lon1, B.lat2, B.lon2);
%p.strike                  = wrapTo360(p.strike);
sp                        = abs(B.lDep./tand(B.dip));  % Surface projection length, in m
p.xot                     = B.lon1;
p.yot                     = B.lat1;
[p.yob, p.xob]            = reckon(p.yot, p.xot, sp, p.strike+sign(tand(B.dip)).*90, almanac('earth','ellipsoid','kilometers'));
p.xft                     = B.lon2;
p.yft                     = B.lat2;
[p.yfb, p.xfb]            = reckon(p.yft, p.xft, sp, p.strike+sign(tand(B.dip)).*90, almanac('earth','ellipsoid','kilometers'));
p.cx                      = (p.xot+p.xft+p.xob+p.xfb)./4;
p.cy                      = (p.yot+p.yft+p.yob+p.yfb)./4;
p.zot                     = -abs(B.bDep);
p.zob                     = B.lDep;
p.zft                     = -abs(B.bDep);
p.zfb                     = B.lDep;
p.cz                      = p.zob/2;

if exist('far', 'var')
   p.xof                  = p.xob - far(1)*cosd(p.strike);
   p.yof                  = p.yob + far(1)*sind(p.strike);
   p.zof                  = far(2)*ones(size(p.xot));
   p.xff                  = p.xfb - far(1)*cosd(p.strike);
   p.yff                  = p.yfb + far(1)*sind(p.strike);
   p.zff                  = far(2)*ones(size(p.xot));
end

% A few more arrays for use with meshview
p.coords = zeros(4*length(p.xot), 3);
if size(p.coords, 1) > 0
   p.coords(1:4:end, :) = [p.xot p.yot p.zot]; 
   p.coords(2:4:end, :) = [p.xft p.yft p.zft]; 
   p.coords(3:4:end, :) = [p.xfb p.yfb p.zfb]; 
   p.coords(4:4:end, :) = [p.xob p.yob p.zob];
   p.vtx = reshape(1:(4*length(p.xot)), 4, length(p.xot))';
end