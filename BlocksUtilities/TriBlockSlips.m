function s = TriBlockSlips(direc, stype, varargin);
%
% TRIBLOCKSLIPS resolves relative block motion onto the triangular mesh.
%   S = TRIBLOCKSLIPS(DIR, TYPE) uses the Mod.block and Mod.patch within DIR
%   to calculate relative motion at triangle element centroids in one of two ways:
%   For TYPE = 1, the strike and dip-slip components of the relative block motion
%   resolved onto the triangular mesh are returned, and if TYPE = 2, the east and
%   north components of surface velocity are returned.  The output array S is an 
%   n-by-2 array containing either [STRIKE DIP] or [EAST NORTH] components of motion.
%
%   TRIBLOCKSLIPS(DIR, TYPE, OUTFILE) will write the results to a GMT formatted file
%   named OUTFILE, which can be plotted using psxy -SV.
%

% Load data
if direc == '.'
   direc = pwd;
end   
fs = strfind(direc, filesep);
prepath = direc(1:fs(end));   
Block = ReadBlock([direc filesep 'Mod.block']);
[Station.lon, Station.lat] = deal(0);
Segment = ReadSegmentTri([direc filesep 'Mod.segment']);
[Segment.midLon Segment.midLat] = deal((Segment.lon1+Segment.lon2)/2, (Segment.lat1+Segment.lat2)/2);
[Segment, Block, Station] = BlockLabel(Segment, Block, Station);
% Need to read in the patches and do the coords
cf = dir([direc filesep '*.command']);
c = ReadCommand([direc filesep cf.name]);
Patches = c.patchFileNames;
cd(prepath)
Patches = ReadPatches(Patches);
Patches = PatchCoords(Patches);

% Determine type of rotation
if stype == 1 % Resolving slips onto the elements
   % Load the pre-calculated strikes
   ef = c.reuseElasticFile;
   load(ef, 'tristrikes');
else % Resolving onto just the centroids
   % Set all depths to be zero
   Patches.c(:, 3) = 0;
   tristrikes = zeros(size(Patches.v, 1), 1);
end

% Get the partials
[G, Patches] = GetTriSlipPartials(Patches, Block, Segment, tristrikes);
% Calculate Cartesian components of Euler pole
[x, y, z] = EulerToOmega(Block.eulerLon, Block.eulerLat, Block.rotationRate*1e6);
omega = zeros(size(G, 2), 1);
omega(1:3:end) = x; omega(2:3:end) = y; omega(3:3:end) = z;
% Do the multiplication to yield velocities
s = G*omega;

% Parse velocities for output
s = [s(1:3:end) s(2:3:end)];

% Optionally write the output file
if nargin == 3
   if stype == 1 % If resolved onto triangles, calculate azimuth through TriAzGmt.m
      TriAzGmt(Patches.lonc, Patches.latc, s(:, 1), s(:, 2), tristrikes, varargin{:});
   else
      % Convert velocities to mag. and azimuth
      smag = mag(s, 2);
      leng = 0.5*smag./max(smag);
      saz = wrapTo360(rad2deg(atan2(s(:, 1), s(:, 2))));
      fid = fopen(varargin{:}, 'w');
      fprintf(fid, '%g %g %g %g %g\n', [Patches.lonc(:)'; Patches.latc(:)'; smag(:)'; saz(:)'; leng(:)']);
      fclose(fid);
   end
end
cd(direc)