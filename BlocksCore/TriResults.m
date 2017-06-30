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

if numel(Model.omegaEstTriSlip) > 0
   Model.trislipS(Index.triS)                 = Model.omegaEstTriSlip(2*Index.triS-1);
   Model.trislipD(Index.triD)                 = Model.omegaEstTriSlip(2*Index.triD-0);
   Model.trislipT(Index.triT)                 = Model.omegaEstTriSlip(2*Index.triT-0);

   % Calculate triangular slip uncertainties
   dEst                                       = sqrt(diag(Model.covarianceTriSlip));
   Model.trislipSSig(Index.triS)              = dEst(2*Index.triS-1);
   Model.trislipDSig(Index.triD)              = dEst(2*Index.triD-0);
   Model.trislipTSig(Index.triT)              = dEst(2*Index.triT-0);
   
   % Calculate triangular slip rates as determined by block motion
   dEst                                       = Partials.trislip * Model.omegaEstRot(:);
   Model.trislipSBlock                        = dEst(1:3:end);
   Model.trislipDBlock                        = dEst(2:3:end);
   Model.trislipTBlock                        = dEst(3:3:end);
   
   % Calculate block slip rate uncertainties
   dEst                                       = sqrt(diag(Partials.trislip*Model.covarianceRot*Partials.trislip'));
   Model.trislipSBlockSig                     = dEst(1:3:end);
   Model.trislipDBlockSig                     = dEst(2:3:end);
   Model.trislipTBlockSig                     = dEst(3:3:end);
end
