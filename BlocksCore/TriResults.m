function Model = TriResults(Partials, Model, Index)
% TriResults   Calculates results on triangular dislocation elements.
%   Model = TriResults(Partials, Model, Partials) updates structure
%   Model with fields corresponding to triangular slip rates and uncertainties,
%   both estimated and as given by Euler pole projections.
%

[Model.trislipS,...
 Model.trislipD,...
 Model.trislipT,...
 Model.trislipSSig,...
 Model.trislipDSig,...
 Model.trislipTSig,...
 Model.trislipSBlock,...
 Model.trislipDBlock,...
 Model.trislipTBlock,...
 Model.trislipSBlockSig,...
 Model.trislipDBlockSig,...
 Model.trislipTBlockSig]                      = deal(zeros(length(Index.triColkeep)/2, 1));
 
% Calculate triangular slip rates as determined by block motion
dEst                                          = Partials.trislip * Model.omegaEstRot(:);
Model.trislipSBlock                           = dEst(1:3:end);
Model.trislipDBlock                           = dEst(2:3:end);
Model.trislipTBlock                           = dEst(3:3:end);

% Calculate block slip rate uncertainties
dEst                                          = sqrt(diag(Partials.trislip*Model.covarianceRot*Partials.trislip'));
Model.trislipSBlockSig                        = dEst(1:3:end);
Model.trislipDBlockSig                        = dEst(2:3:end);
Model.trislipTBlockSig                        = dEst(3:3:end);

% Calculate elastic/partial coupling related slip rates
if numel(Model.omegaEstTriSlip) > 0
   Model.trislipS(Index.triS)                 = Model.omegaEstTriSlip(2*Index.triS-1);
   Model.trislipD(Index.triD)                 = Model.omegaEstTriSlip(2*Index.triD-0);
   Model.trislipT(Index.triT)                 = Model.omegaEstTriSlip(2*Index.triT-0);

   % Calculate triangular slip uncertainties
   dEst                                       = sqrt(diag(Model.covarianceTriSlip));
   Model.trislipSSig(Index.triS)              = dEst(2*Index.triS-1);
   Model.trislipDSig(Index.triD)              = dEst(2*Index.triD-0);
   Model.trislipTSig(Index.triT)              = dEst(2*Index.triT-0);

% Unless full coupling was prescribed, in which case copy block slip rates to elastic
else
   Model.trislipS                             = Model.trislipSBlock;
   Model.trislipD                             = Model.trislipDBlock;
   Model.trislipT                             = Model.trislipTBlock;

   Model.trislipSSig                          = Model.trislipSBlockSig;
   Model.trislipDSig                          = Model.trislipDBlockSig;
   Model.trislipTSig                          = Model.trislipTBlockSig;   
   
   % And assign these values to the slip vector for velocity predictions
   Model.omegaEstTriSlip                      = stack3([Model.trislipS, Model.trislipD, Model.trislipT]);
   Model.omegaEstTriSlip                      = Model.omegaEstTriSlip(Index.triColkeep);
end

% Check for empty tri. slip
if sum(size(Model.omegaEstTriSlip)) == 0
   Model.omegaEstTriSlip = zeros(0, 1); % Match empty format for other unused parameters
end