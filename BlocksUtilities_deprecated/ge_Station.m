function ge_Station(Station, file)
% ge_Station  Writes a .kml file for a station structure.
%   ge_Station(STATION, FILE) writes the coordinate information
%   in fields STATION.lon, STATION.lat to FILE, a KML file 
%   viewable using Google Earth.
%
%   Uses the Matlab "googleearth" toolbox:
%   http://www.mathworks.com/matlabcentral/fileexchange/12954-google-earth-toolbox
%

% If a station filename was passed, read it in
if ~isstruct(Station)
   Station = ReadStation(Station);
end
  
kml = [];
for i = 1:length(Station.lon)
   kml = strvcat(kml, ge_point(Station.lon(i), Station.lat(i), 1)); 
end 

ge_output(file, kml');