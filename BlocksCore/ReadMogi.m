function Mogi = ReadMogi(mogifile)
% READMOGI  Reads in coordinates of Mogi sources
%    M = READMOGI(file) reads a 6-column array from the 
%    specified file, of the format:
%
%    name, longitude, latitude, depth (km), toggle, \DeltaV (m^3), \DeltaVSigma (m^3)
%
%    The file is assumed to have a one-line header, and 
%    the columns are assumed to be comma-separated.
%

if ~isempty(mogifile)
   fid        = fopen(mogifile, 'r');
   m          = textscan(fid, '%s %f %f %f %f %f %f\n', 'headerlines', 1, 'delimiter', ',');
   Mogi.name  = char(m{1});
   Mogi.lon   = m{2};
   Mogi.lat   = m{3};
   Mogi.dep   = m{4};
   Mogi.dvtog = m{5};
   Mogi.dv    = m{6};
   Mogi.dvSig = m{7};
   fclose(fid);
else
   Mogi.name  = [];
   Mogi.lon   = [];
   Mogi.lat   = [];
   Mogi.dep   = [];
   Mogi.dvtog = [];
   Mogi.dv    = [];
   Mogi.dvSig = [];
end
