function Station = ProcessStation(Station, Command)
% ProcessStation   Carries out preliminary station processing

% Assign unit uncertainties, if requested
if strmatch(Command.unitSigmas, 'yes')
   [Station.eastSig, Station.northSig]           = ones(numel(Station.lon), 1);
end

% Add a "dep" field of all zeros, to be used with ProjectTriCoords
Station.dep                                      = 0*Station.lon;

% Find stations that are toggled on
Station                                          = SelectStation(Station);

% Convert spherical to Cartesian coordinates
[Station.x Station.y Station.z]                  = sph2cart(DegToRad(Station.lon), DegToRad(Station.lat), 6371);
