function ge_Tris(p, file)
% ge_Tris  Writes a .kml file for triangle geometry.
%   ge_Tris(P, FILE) writes the triangle structure P
%   as blue filled polygons with a black outline to FILE.
%
%   Uses the Matlab "googleearth" toolbox:
%   http://www.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox
%

% Check file extension
[pa, f, e] = fileparts(file);
if isempty(e)
   file = [file '.kml'];
   e = '.kml';
end

% Write the kml
kml = [];
for i = 1:length(p.v), 
   kml = strvcat(kml, ge_poly(p.c(p.v(i, :), 1), p.c(p.v(i, :), 2), 'polyColor', 'FF40AEFF', ...
                              'lineColor', '00000000', 'altitudeMode', 'relativeToGround', 'altitude', 999, ...
                              'tessellate', 1)); 
end

ends = cumsum(p.nEl);
begs = [1; ends(1:end-1)+1];

for i = 1:length(p.nEl)
   ol = OrderedEdges(p.c, p.v(begs(i):ends(i), :));
   for j = 1:size(ol, 2)
      kml = strvcat(kml, ge_plot(p.c(ol(:, j), 1), p.c(ol(:, j), 2), 'lineColor', 'FF000000', 'lineWidth', 3));
   end
end

% Output kml
ge_output(file, kml');