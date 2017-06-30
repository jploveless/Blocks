function out = ColorVelVecGmt(station, outfile, varargin)
%
% COLORVELVECGMT outputs a GMT text file suitable for plotting as
% magnitude-scaled color-coded vectors using PSXY -SV.
%
%   COLORVELVECGMT(STATION, OUTFILE) reads the .sta.data file
%   STATION and outputs its velocity data to OUTFILE, formatted for
%   plotting with GMT's PSXY -SV command.
%
%   COLORVELVECGMT(STATION, OUTFILE, CPT) also writes a companion
%   colormap file based on the GMT colormap specified by CPT.  The
%   limits of the colormap will be defined as the velocity magnitude
%   extrema.
%
%   COLORVELVECGMT(STATION, OUTFILE, CPT, GLIM) will use the velocity
%   magnitude extrema within the geographic region of 
%   GLIM = [LONMIN LONMAX LATMIN LATMAX] to define the colormap.
%
%   OUT = COLORVELVECGMT(...) returns an array containing the numerical
%   content of the written file.
%

% Read the station data
if ischar(station)
   s = ReadStation(station);
elseif isstruct(station)
   s = station;
end
   
% Calculate the azimuth of the stations - need to do this because PSVELO doesn't
% accept magnitude-scaled color-coded vectors and PSXY doesn't accept velocity 
% components.

az = wrapTo360(rad2deg(atan2(s.eastVel, s.northVel)));

% Scale vector lengths
smag = mag([s.eastVel, s.northVel], 2);
if nargin > 2 & isnumeric(varargin{1})
   leng = smag./varargin{1};
elseif nargin > 2 & isnumeric(varargin{2})
   leng = smag./varargin{2};
else
   leng = smag./max(smag);
end
smag(isnan(leng)) = 1;
leng(isnan(leng)) = 1e-6;
leng(leng < 0.045) = 0.05;

% Assemble into a neat array
out = [s.lon(:) s.lat(:) smag(:) az(:) leng(:)];

% Write the text file
fid = fopen(outfile, 'w');
if nargin > 2 & ischar(varargin{1}) & strmatch(varargin{1}, 'none')
   fprintf(fid, '%g %g %g %f\n', [s.lon(:)'; s.lat(:)'; az(:)'; leng(:)']);
else
   fprintf(fid, '%g %g %g %g %f\n', [s.lon(:)'; s.lat(:)'; smag(:)'; az(:)'; leng(:)']);
end
fclose(fid);

% Write the optional .cpt file
if nargin > 2 & ischar(varargin{1}) & ~strmatch(varargin{1}, 'none')
   cpt = varargin{1};
   if nargin == 4 & numel(varargin{2}) == 4
      cut = varargin{2};
      inreg = inpolygon(s.lon(:), s.lat(:), [cut(1) cut(2) cut(2) cut(1)], [cut(3) cut(3) cut(4) cut(4)]);
      [mmin, mmax] = deal(floor(min(smag(inreg))), ceil(max(smag(inreg))));
   else
      [mmin, mmax] = deal(floor(min(smag)), ceil(max(smag)));
   end
   [p, f, x] = fileparts(outfile);
   cptfile = [p filesep f '.cpt'];
   cptcom = sprintf('makecpt -C%s -T%d/%d/1 -Z -D -I > %s', cpt, mmin, mmax, cptfile);
   system(cptcom);
end   
