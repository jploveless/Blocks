function ts = tilesegments(s, sz, varargin);
% tilesegments  Divides segments into square tiles.
%    TS = tilesegments(S, ELSIZE) divides all segments in 
%    the structure S into square tiles as close to ELSIZE as 
%    possible.  ELSIZE as a 2-element vector specifies the size
%    of the tiles in the [strike, dip] directions.  Specifying a
%    zero for either value means no tiling will be done in that
%    direction.
%
%    TS = tilesegments(S, ELSIZE, IDX) divides only those 
%    segments whose indices are given by IDX into square tiles.
%
%    TS = tilesegments(S, ELSIZE, LONRANGE, LATRANGE) divides
%    only those segments of S whose midpoints lie within a specified 
%    geographic range into square tiles.  LONRANGE and LATRANGE should 
%    be as 2-element vectors of the form  LONRANGE = [MINLON MAXLON] 
%    and LATRANGE = [MINLAT MAXLAT].
%

%%%%%%%%%%%%%%%%
% Check inputs %
%%%%%%%%%%%%%%%%

% Make sure some ancillary information has been calculated
s = OrderEndpoints(s);
[s.midLon s.midLat] = deal((s.lon1+s.lon2)/2, (s.lat1+s.lat2)/2);

% Check for any specified segment subsets
if nargin == 3
   % If one extra argument is given, it's a list of segment indices
   idx = varargin{1};
elseif nargin == 4
   % If 2 extra arguments are given, they specify a geographic range
   lonr = varargin{1};
   latr = varargin{2};
   % Find segments within that geographic range
   idx = find(inpolygon(wrapTo360(s.midLon), s.midLat, wrapTo360(lonr([1 2 2 1])), latr([1 1 2 2])));
else
   % If no extra arguments are given, all segments should be tiled
   idx = 1:length(s.lon1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tile specified segments %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate segment lengths
sl = distance(s.lat1(idx), s.lon1(idx), s.lat2(idx), s.lon2(idx), almanac('earth','ellipsoid','kilometers'));
% Calculate segment widths
sw = (s.lDep(idx) - s.bDep(idx))./sind(s.dip(idx));
% Calculate segment strikes
saz = azimuth(s.lat1(idx), s.lon1(idx), s.lat2(idx), s.lon2(idx));
% Determine the number of new tiles to be created
if numel(sz) == 1, sz = sz*ones(1, 2); end
nts = [floor(sl/sz(1)) 2*ones(size(sl))]; % In strike direction
nts = nts(~isinf(nts)); nts = nts(1:length(sl));
ntd = [floor(sw/sz(2)) 2*ones(size(sl))]; % In dip direction
ntd = ntd(~isinf(ntd)); ntd = ntd(1:length(sl));
tidx = [0; cumsum((nts(:)-1).*(ntd(:)-1))]; % Index giving the tiles belonging to each segment
nt = tidx(end); % Total number of tiles

% Determine tile size
%szs = sl/nts; % Size along strike
%szd = sw/ntd; % Size along dip

% Create subset of segments
ts = structsubset(s, setdiff(1:length(s.lon1), idx)); % Copy un-tiled segments to new structure
s = structsubset(s, idx); % Redefine s as just segments to be tiled
t = emptyseg(nt);
t.name = repmat(' ', nt, size(s.name, 2));
fn = fieldnames(t);
fn = setdiff(fn, {'lon1', 'lon2', 'lat1', 'lat2', 'bDep', 'lDep', 'name'});

% Tiling itself needs to be done in a loop
for i = 1:length(idx)
   % Tile longitudes, latitudes, and depths
   lons = linspace(s.lon1(i), s.lon2(i), nts(i));
   lats = linspace(s.lat1(i), s.lat2(i), nts(i));
   deps = linspace(s.bDep(i), s.lDep(i), ntd(i));
   
   % Tile corner coordinates
   lon1 = repmat(lons(1:end-1), ntd(i)-1, 1);
   lon2 = repmat(lons(2:end), ntd(i)-1, 1);
   lat1 = repmat(lats(1:end-1), ntd(i)-1, 1);
   lat2 = repmat(lats(2:end), ntd(i)-1, 1);
   bdep = repmat(deps(1:end-1)', 1, nts(i)-1);
   ldep = repmat(deps(2:end)', 1, nts(i)-1);

   % Project tile top coordinates to account for fault strike and dip
   [lat1, lon1] = reckon(lat1, lon1, bdep./tand(s.dip(i)), (saz(i)+90)*ones(size(bdep)), referenceEllipsoid('wgs84', 'km'));
   [lat2, lon2] = reckon(lat2, lon2, bdep./tand(s.dip(i)), (saz(i)+90)*ones(size(bdep)), referenceEllipsoid('wgs84', 'km'));   
   % Write to new tile structure
   ti = tidx(i)+1:tidx(i+1);
   t.lon1(ti) = wrapTo360(lon1(:));
   t.lon2(ti) = wrapTo360(lon2(:));
   t.lat1(ti) = lat1(:);
   t.lat2(ti) = lat2(:);
   t.bDep(ti) = bdep(:);
   t.lDep(ti) = ldep(:);
   % Copy all other fields from the segment structure
   for j = 1:length(fn)
      t = setfield(t, {1}, fn{j}, {ti}, getfield(s, {1}, fn{j}, {i}));
   end
   t.name(ti, :) = repmat(s.name(i, :), length(ti), 1);
end

ts = structmath(t, ts, 'vertcat');