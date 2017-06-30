function Model = MogiResults(Model);

Model.mogiDeltaV = 1e6*Model.omegaEstMogi; % Converting to cubic meters/yr
Model.mogiDeltaVSig = 1e6*sqrt(diag(Model.covarianceMogi)); % Converting to cubic meters/yr