function ge_Block(direc, file)
% ge_Block  Writes a .kml file for blocks.
%   ge_Block(DIR, FILE) writes the block geometry contained
%   in results directory DIR to translucent colored polygons 
%   and Euler poles as FILE, a KML file viewable using Google Earth.
%
%   Uses the Matlab "googleearth" toolbox:
%   http://www.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox
%

% Read in geometry files
b = ReadBlock([direc '/Mod.block']);
bc = ReadBlockCoords(direc);

% Make colormap
nblocks = numel(b.interiorLon);
cols = jet(nblocks);
cvec = floor(255*cols);

% Write colored blocks at 75% transparency
kml = [];
for i = 1:nblocks
   kml = strvcat(kml, ge_poly(bc{i}(:, 1), bc{i}(:, 2), 'polyColor', ['4B', reshape(dec2hex(cvec(i, :))', 1, 6)], ...
                              'name', b.name(i, :), 'altitudeMode', 'absolute', 'altitude', 1e4, 'tessellate', 0                              )); 
end

ge_output(file, kml');