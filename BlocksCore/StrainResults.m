function Model = StrainResults(Model, Index, Command)

Model.lonStrainSig                               = zeros(size(Model.omegaX));
Model.latStrainSig                               = zeros(size(Model.omegaX));
Model.eLonLon                                    = zeros(size(Model.omegaX));
Model.eLonLat                                    = zeros(size(Model.omegaX));
Model.eLatLat                                    = zeros(size(Model.omegaX));
Model.eLonLonSig                                 = zeros(size(Model.omegaX));
Model.eLonLatSig                                 = zeros(size(Model.omegaX));
Model.eLatLatSig                                 = zeros(size(Model.omegaX));
switch Command.strainMethod
   case 1 % 3, 3 parameter estimation 
      dEst                                       = Model.omegaEstStrain;
      m1                                         = dEst(1:3:end);
      m2                                         = dEst(2:3:end);
      m3                                         = dEst(3:3:end);
      dEst                                       = sqrt(diag(Model.covarianceStrain));
      m1Sig                                      = dEst(1:3:end);
      m2Sig                                      = dEst(2:3:end);
      m3Sig                                      = dEst(3:3:end);
      Index.strainBlock                          = Index.strainBlock(3:3:end)/3;
      Model.eLonLon(Index.strainBlock)           = m1;
      Model.eLonLat(Index.strainBlock)           = m2;
      Model.eLatLat(Index.strainBlock)           = m3;
      Model.eLonLonSig(Index.strainBlock)        = m1Sig;
      Model.eLonLatSig(Index.strainBlock)        = m2Sig;
      Model.eLatLatSig(Index.strainBlock)        = m3Sig;
   case 2 % 5, 6 parameter estimation
      dEst                                       = Model.omegaEstStrain;
      m1                                         = dEst(1:6:end);
      m2                                         = dEst(2:6:end);
      m3                                         = dEst(3:6:end);
      m4                                         = dEst(4:6:end);
      m5                                         = dEst(5:6:end);
      m6                                         = dEst(6:6:end);
      dEst                                       = sqrt(diag(Model.covarianceStrain));
      m1Sig                                      = dEst(1:6:end);
      m2Sig                                      = dEst(2:6:end);
      m3Sig                                      = dEst(3:6:end);
      m4Sig                                      = dEst(4:6:end);
      m5Sig                                      = dEst(5:6:end);
      m6Sig                                      = dEst(6:6:end);
      Index.strainBlock                          = Index.strainBlock(6:6:end)/6;
      Model.eLonLon(Index.strainBlock)           = m1.*m2./m4;
      Model.eLonLat(Index.strainBlock)           = m2;
      Model.eLatLat(Index.strainBlock)           = m5;
      Model.eLonLonSig(Index.strainBlock)        = m1Sig.*m2Sig./m4Sig;
      Model.eLonLatSig(Index.strainBlock)        = m2Sig;
      Model.eLatLatSig(Index.strainBlock)        = m5Sig;
   case 3 % 3, 4 parameter estimation
      dEst                                       = Model.omegaEstStrain;
      m1                                         = dEst(1:4:end);
      m2                                         = dEst(2:4:end);
      m3                                         = dEst(3:4:end);
      m4                                         = dEst(4:4:end);
      dEst                                       = sqrt(diag(Model.covarianceStrain));
      m1Sig                                      = dEst(1:4:end);
      m2Sig                                      = dEst(2:4:end);
      m3Sig                                      = dEst(3:4:end);
      m4Sig                                      = dEst(4:4:end);
      Index.strainBlock                          = Index.strainBlock(4:4:end)/4;
      Model.eLonLon(Index.strainBlock)           = m1.*m2./m3;
      Model.eLonLat(Index.strainBlock)           = m2;
      Model.eLatLat(Index.strainBlock)           = m4;
      Model.eLonLonSig(Index.strainBlock)        = m1Sig.*m2Sig./m3Sig;
      Model.eLonLatSig(Index.strainBlock)        = m2Sig;
      Model.eLatLatSig(Index.strainBlock)        = m4Sig;
   case 4 % directed forward search method
   
end