function ge_Segments(s, file)
% ge_Segments  Writes a .kml file for segment geometry.
%   ge_Segments(SEGMENT, FILE) writes segment geometry to
%   the KML file FILE. Vertical segments appear as white
%   lines and dipping segments are filled in red. 
%
%   Uses the Matlab "googleearth" toolbox:
%   http://www.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox
%

if ~isstruct(s)
   s = ReadSegmentTri(s);
end

% Check file extension
[p, f, e] = fileparts(file);
if isempty(e)
   file = [file '.kml'];
   e = '.kml';
end

% Calculate corner coordinates for dipping fault use
figure
[xcorn, ycorn] = PlotDips(s.lon1, s.lat1, s.lon2, s.lat2, s.dip, s.lDep, s.bDep);
close 

% Write the kml
kml = [];
for i = 1:length(s.lon1), 
   if s.dip(i) == 90 % Vertical segment
      kml = strvcat(kml, ge_plot([s.lon1(i), s.lon2(i)], [s.lat1(i), s.lat2(i)], ...
                                 'lineWidth', 3, 'lineColor', 'FFFFFFFF', ...
                                 'name', sprintf('Dip = %g', s.dip(i)) ));
   else
      % Order endpoints and calculate corner coordinates
      kml = strvcat(kml, ge_poly(xcorn(i, :)', ycorn(i, :)', ...
                   'lineWidth', 3, 'lineColor', 'FFFFFFFF', ...
                   'polyColor', 'FFFF0000', ...
                   'altitudeMode', 'relativeToGround', 'altitude', 1e3, ...
                              'tessellate', 1, ...
                   'name', sprintf('Dip = %g', s.dip(i)) ));
   end
end 

% Output kml
ge_output(file, kml');