function WriteMogi(mogifile, Mogi, Model)
% WRITEMOGI  Writes Mogi sources
%    WRITEMOGI(file) writes a 6-column array to the 
%    specified file, of the format:
%
%    longitude, latitude, depth (km), toggle, \DeltaV (m^3), \DeltaVSigma (m^3)
%
%    The file is given a one-line header, and 
%    the columns are comma-separated.
%


fid        = fopen(mogifile, 'w');
fprintf(fid, 'Name, Longitude, Latitude, Depth, DV_Flag, DV, DVS\n');
for i = 1:numel(Mogi.lon)
   fprintf(fid, '%s, %g, %g, %g, %g, %g, %g\n', strtrim(Mogi.name(i, :)), Mogi.lon(i), Mogi.lat(i), Mogi.dep(i), 1, Model.mogiDeltaV(i), Model.mogiDeltaVSig(i));
end
fclose(fid);