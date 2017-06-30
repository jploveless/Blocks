function Sar = ProcessSar(Sar, Command)
% ProcessSar  Does preprocessing of SAR data.
%   SAR = ProcessSar(SAR, COMMAND) processes the SAR structure according
%   to options in the COMMAND structure.
%

% Assign uniform uncertainties if not specified
if ~isfield(Sar, 'dataSig')
	Sar.dataSig                                = ones(size(Sar.lon));
end

% Add a "dep" field of all zeros, to be used with ProjectTriCoords
Sar.dep                                       = 0*Sar.lon;

% Set the uncertainties to reflect the weights specified in the command file
% In constructing the data weight vector, the value is 1./Sar.dataSig.^2, so
% the adjustment made here is Sar.dataSig./sqrt(Command.sarWgt)
Sar.dataSig                                   = Sar.dataSig./sqrt(Command.sarWgt);

% Convert spherical to Cartesian coordinates
[Sar.x, Sar.y, Sar.z]                         = sph2cart(DegToRad(Sar.lon), DegToRad(Sar.lat), 6371);


