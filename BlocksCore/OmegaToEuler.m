function Model = OmegaToEuler(Model)
% OmegaToEuler   Converts Cartesian to spherical coordinates for Euler poles.
%   Model = OmegaToEuler(omegaEst, Model) updates the structure Model with 
%   fields lonEuler, latEuler, and rateEuler, giving Euler pole parameters
%   for each block.
% 
%   Model is also updated with omegaX, omegaY, and omegaZ, the individual
%   Cartesian components.
%

% Separate components
Model.omegaX                       = Model.omegaEstRot(1:3:end);
Model.omegaY                       = Model.omegaEstRot(2:3:end);
Model.omegaZ                       = Model.omegaEstRot(3:3:end);

% Loop over each pole
for cnt = 1:numel(Model.omegaX)
   rrate(cnt)                      = sqrt(Model.omegaX(cnt)^2 + Model.omegaY(cnt)^2 + Model.omegaZ(cnt)^2);
   unit_vec                        = [Model.omegaX(cnt) ; Model.omegaY(cnt) ; Model.omegaZ(cnt)] / rrate(cnt);
   [tlon, tlat]                    = xyz_to_long_lat(unit_vec(1), unit_vec(2), unit_vec(3));
   Elon(cnt)                       = tlon;
   Elat(cnt)                       = tlat;
end

% Convert longitude and latitude from radians to degrees
Model.lonEuler                     = rad_to_deg(Elon);
Model.latEuler                     = rad_to_deg(Elat);

% Make sure we have west longitude
Model.lonEuler(Model.lonEuler < 0) = Model.lonEuler(Model.lonEuler < 0) + 360;

% Convert the rotation rate from rad/yr to degrees per million years
Model.rateEuler                    = 1e6 * rad_to_deg(rrate);
