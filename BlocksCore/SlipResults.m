function Model = SlipResults(Partials, Model)
% SlipResults   Projects block rotations onto faults to give slip rates.
%   Model = SlipRates(Partials, Model) updated structure 
%   Model with slip rate components and uncertainties given by multiplying
%   Partials.slip by Model.omegaEstRot.
%

% Calculate slip rates
dEst                                             = Partials.slip * Model.omegaEstRot(:);
Model.ssRate                                     = dEst(1:3:end);
Model.dsRate                                     = dEst(2:3:end);
Model.tsRate                                     = dEst(3:3:end);
% ...and uncertainties
dEst                                             = sqrt(diag(Partials.slip*Model.covarianceRot*Partials.slip'));
Model.ssRateSig                                  = dEst(1:3:end);
Model.dsRateSig                                  = dEst(2:3:end);
Model.tsRateSig                                  = dEst(3:3:end);
