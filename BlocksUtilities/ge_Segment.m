function ge_Segment(s, file)
% ge_Segment  Writes a .kml file for a segment structure.
%   ge_Station(SEGMENT, FILE) writes the coordinate information
%   in fields SEGMENT.lon1, SEGMENT.lat1, SEGMENT.lon1, SEGMENT.lat1
%   to FILE, a KML file viewable using Google Earth.
%
%   Uses the Matlab "googleearth" toolbox:
%   http://www.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox
%

kml = [];
for i = 1:length(s.lon1), 
   kml = strvcat(kml, ge_plot([s.lon1(i), s.lon2(i)], [s.lat1(i), s.lat2(i)])); 
end 

ge_output(file, kml');