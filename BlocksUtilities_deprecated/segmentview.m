function s = segmentview(s, varargin);
% segmentview  Plots segments in 3D.
%    segmentview(S) plots all segments of structure S in 3D.
%
%    segmentview(S, IDX) plots only those segments of S whose indices
%    are given by IDX.
%
%    segmentview(S, LONRANGE, LATRANGE) plots only those segments of S 
%    whose midpoints lie within a specified geographic range into square 
%    tiles.  LONRANGE and LATRANGE should be as 2-element vectors of the
%    form LONRANGE = [MINLON MAXLON] and LATRANGE = [MINLAT MAXLAT].
%

%%%%%%%%%%%%%%%%
% Check inputs %
%%%%%%%%%%%%%%%%

% Make sure some ancillary information has been calculated
s = OrderEndpoints(s);
[s.midLon s.midLat] = deal((s.lon1+s.lon2)/2, (s.lat1+s.lat2)/2);

% Check for any specified segment subsets
if nargin == 2
   % If one extra argument is given, it's a list of segment indices
   idx = varargin{1};
elseif nargin == 3
   % If 2 extra arguments are given, they specify a geographic range
   lonr = varargin{1};
   latr = varargin{2};
   % Find segments within that geographic range
   idx = find(inpolygon(wrapTo360(s.midLon), s.midLat, wrapTo360(lonr([1 2 2 1])), latr([1 1 2 2])));
else
   % If no extra arguments are given, all segments should be plotted
   idx = 1:length(s.lon1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot specified segments %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

s = structsubset(s, idx);

% Calculate segment strikes
saz = azimuth(s.lat1, s.lon1, s.lat2, s.lon2);

% Make patch coordinate array
top1 = [s.lon1, s.lat1, -s.bDep];
top2 = [s.lon2, s.lat2, -s.bDep];
[ba1, bo1] = reckon(s.lat1, s.lon1, (s.lDep-s.bDep)./tand(s.dip), saz+90, referenceEllipsoid('wgs84', 'km'));
[ba2, bo2] = reckon(s.lat2, s.lon2, (s.lDep-s.bDep)./tand(s.dip), saz+90, referenceEllipsoid('wgs84', 'km'));   
bot1 = [wrapTo360(bo1), ba1, -s.lDep];
bot2 = [wrapTo360(bo2), ba2, -s.lDep];
c = zeros(4*size(top1, 1), 3);
c(1:4:end, :) = top1;
c(2:4:end, :) = bot1;
c(3:4:end, :) = bot2;
c(4:4:end, :) = top2;

% Make patch connection array
v = reshape(1:size(c, 1), 4, size(s.lon1, 1))';

% Plot the segments
patch('Vertices', c, 'faces', v, 'facevertexcdata',  0.5*(s.bDep + s.lDep), 'facecolor', 'flat', 'edgecolor', 'black')

