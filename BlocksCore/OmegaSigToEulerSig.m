function Model = OmegaSigToEulerSig(Model)
% OmegaSigToEulerSig   Converts rotation uncertainties from Cartesian to spherical coordinates.
%    Model = OmegaSigToEulerSig(omegaEst, Model) updates structure Model with fields
%    lonEulerSig, latEulerSig, rateEulerSig, lonLatCorr, lonRateCorr, latRateCorr, 
%    giving estimated uncertainties on each Euler pole component, as well as correlations
%    between components.
%
%    Model is also updated with omegaXSig, omegaYSig, and omegaZSig, the uncertainties
%    on the Cartesian rotation components.
%

% Declare variables
A                                                     = zeros(3 * length(Model.omegaX));

% Loop over each set of estimates
for cnt = 1 : numel(Model.omegaX)
   crnt_idx                                           = (cnt - 1) * 3 + 1;
   x                                                  = Model.omegaX(cnt);
   y                                                  = Model.omegaY(cnt);
   z                                                  = Model.omegaZ(cnt);

   % Calculate the partial derivatives
   dlat_dx                                            = -z / (x^2 + y^2)^(3/2) / (1 + z^2 / (x^2 + y^2)) * x;
   dlat_dy                                            = -z / (x^2 + y^2)^(3/2) / (1 + z^2 / (x^2 + y^2)) * y;
   dlat_dz                                            = 1 / (x^2 + y^2)^(1/2) / (1 + z^2 / (x^2 + y^2));
   dlon_dx                                            = -y / x^2 / (1 + (y / x)^2);
   dlon_dy                                            = 1 / x / (1 + (y / x)^2);
   dlon_dz                                            = 0;
   dmag_dx                                            = x / sqrt(x^2 + y^2 + z^2);
   dmag_dy                                            = y / sqrt(x^2 + y^2 + z^2);
   dmag_dz                                            = z / sqrt(x^2 + y^2 + z^2);

   % Organize them into a matrix
   A_small                                            = [ dlat_dx, dlat_dy, dlat_dz ; dlon_dx, dlon_dy, dlon_dz ; dmag_dx, dmag_dy, dmag_dz ];
   
   % Put the small set of partials into the big set
   A(crnt_idx : crnt_idx+2, crnt_idx : crnt_idx+2)    = A_small;
end

% Propagate the uncertainties and the new covariance matrix
Cov_epoles                                            = A * Model.covarianceRot * A';

% Organize data for the return
diag_vec                                              = diag(Cov_epoles);
Euler_lat_sig                                         = sqrt(diag_vec(1 : 3 : end));
Euler_lon_sig                                         = sqrt(diag_vec(2 : 3 : end));
rotation_rate_sig                                     = sqrt(diag_vec(3 : 3 : end));

% Get the correlations
Model.lonLatCorr                                      = zeros(length(Model.omegaX), 1);
Model.lonRateCorr                                     = zeros(length(Model.omegaX), 1);
Model.latRateCorr                                     = zeros(length(Model.omegaX), 1);

% Convert longitude and latitude from radians to degrees
Model.lonEulerSig                                     = rad_to_deg(Euler_lon_sig);
Model.latEulerSig                                     = rad_to_deg(Euler_lat_sig);

% Convert the rotation rate from rad/yr to degrees per million years
Model.rateEulerSig                                    = 1e6 * rad_to_deg(rotation_rate_sig);

% Extract individual components of uncertainties
dEst                                                  = sqrt(diag(Model.covarianceRot));
Model.omegaXSig                                       = dEst(1:3:end);
Model.omegaYSig                                       = dEst(2:3:end);
Model.omegaZSig                                       = dEst(3:3:end);
