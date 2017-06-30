%function Model = LoopBlockSolve(Command, R, W, d, Station, Partials, Patches, szslip, sztri, strainBlockIdx)
warning off all
nIter = Command.nIter;

[ssrate, dsrate, tsrate] = deal(zeros(size(Partials.slip, 1)/3, nIter));

for i = 1:nIter
	fprintf('Working on iteration %d of %d...\n', i, nIter)
	sigs = reshape([Station.eastSig Station.northSig]', 2*numel(Station.lon), 1);
	newSigs = sigs.*randn(2*numel(Station.lon), 1);
	d(1:2*numel(Station.lon)) = d(1:2*numel(Station.lon)) + newSigs;

	%Command.triCons = [0 150];
	Command.triCons = [];
	[R, W, d]													 = deal(full(R), full(W), full(d));
	Model.covariance                                 = inv(R'*W*R);
	if isempty(Command.triCons)
		omegaEst													 = Model.covariance*R'*W*d;
	else
		[minconstr, maxconstr]								 = deal(-inf(size(R, 2), 1), inf(size(R, 2), 1));
		minconstr(szslip(2)+1:szslip(2)+sztri(2))		 = Command.triCons(1);
		maxconstr(szslip(2)+1:szslip(2)+sztri(2))		 = Command.triCons(2);
		[omegaEst, resnorm, res, exf, output, lambda] = lsqlin(R, d, [], [], [], [], minconstr, maxconstr);
	end
	
	% extract different parts of the state vector
	omegaEstRot													 = omegaEst(1:size(Partials.slip, 2)); % rotation parameters
	
	
	% Add zeros to the end of partials to account for the field rotation
	% Calculate fault slip rates...
	dEst                                             = Partials.slip * omegaEstRot(:);
	ssrate(:, i)											 = dEst(1:3:end); 
	dsrate(:, i)											 = dEst(2:3:end);	
	tsrate(:, i)											 = dEst(3:3:end);
end

Model.ssRate                                     = mean(ssrate, 2);
Model.dsRate                                     = mean(dsrate, 2);
Model.tsRate                                     = mean(tsrate, 2);

Model.ssRateSig                                  = std(ssrate, 0, 2);
Model.dsRateSig                                  = std(dsrate, 0, 2);
Model.tsRateSig                                  = std(tsrate, 0, 2);


% Calculate all other parameters in the usual way
omegaEstTriSlip										    = omegaEst(szslip(2) + 1:szslip(2) + sztri(2)); % triangular slips
omegaEstStrain												 = omegaEst(szslip(2) + sztri(2) + 1:end); % strain parameters

% extract different parts of the model covariance matrix
Model.covarianceRot										 = Model.covariance(1:szslip(2), 1:szslip(2));
Model.covarianceTriSlip									 = Model.covariance(szslip(2) + 1:szslip(2) + sztri(2), szslip(2) + 1:szslip(2) + sztri(2));
Model.covarianceStrain									 = Model.covariance(szslip(2) + sztri(2) + 1:end, szslip(2) + sztri(2) + 1:end);

% Calculate Euler poles and uncertainties
[Model.rateEuler, Model.lonEuler, Model.latEuler]= OmegaToEuler(omegaEstRot(1:3:end), omegaEstRot(2:3:end), omegaEstRot(3:3:end));
[Model.lonEulerSig Model.latEulerSig Model.rateEulerSig ...
 Model.lonLatCorr Model.lonRateCorr Model.latRateCorr] = OmegaSigToEulerSig(omegaEstRot(1:3:end), omegaEstRot(2:3:end), omegaEstRot(3:3:end), Model.covarianceRot);

% Calculate rotation rates
Model.omegaX                                     = omegaEstRot(1:3:end);
Model.omegaY                                     = omegaEstRot(2:3:end);
Model.omegaZ                                     = omegaEstRot(3:3:end);

 
% Calculate rotation uncertainties
dEst                                             = sqrt(diag(Model.covarianceRot));
Model.omegaXSig                                  = dEst(1:3:end);
Model.omegaYSig                                  = dEst(2:3:end);
Model.omegaZSig                                  = dEst(3:3:end);

% Calculate forward components of velocity field
dEst                                             = (Partials.rotation-Partials.elastic * Partials.slip)*omegaEstRot;
Model.eastVel                                    = dEst(1:3:end);
Model.northVel                                   = dEst(2:3:end);
Model.upVel                                      = dEst(3:3:end);

% Rotational velocities
dEst                                             = Partials.rotation*omegaEstRot;
Model.eastRotVel                                 = dEst(1:3:end);
Model.northRotVel                                = dEst(2:3:end);
Model.upRotVel                                   = dEst(3:3:end);

% Velocities due to elastic strain accumulation on faults
dEst                                             = (Partials.elastic * Partials.slip)*omegaEstRot;
Model.eastDefVel                                 = dEst(1:3:end);
Model.northDefVel                                = dEst(2:3:end);
Model.upDefVel    										 = dEst(3:3:end);

% Calculate triangular slip rates...
[Model.trislipS, Model.trislipD, Model.trislipT] = deal(zeros(size(Patches.v, 1), 1));
[Model.trislipSSig,...
 Model.trislipDSig,...
 Model.trislipTSig]										 = deal(zeros(size(Patches.v, 1), 1));
[Model.eastTriVel,...
 Model.northTriVel,... 
 Model.upTriVel] 											 = deal(zeros(size(Station.lon, 1), 1));     

if numel(omegaEstTriSlip) > 0
	if isempty(Command.triRake)
		Model.trislipS(triS)		  						 = omegaEstTriSlip(2*triS-1);
		Model.trislipD(triD)								 = omegaEstTriSlip(2*triD-0);
		Model.trislipT(triT)								 = omegaEstTriSlip(2*triT-0);
	else
		elrakes											    = Command.triRake - rad2deg(Partials.tristrikes);
		Model.trislipS										 = omegaEstTriSlip.*cosd(elrakes);
		Model.trislipD										 = omegaEstTriSlip.*sind(elrakes);
	end
	% Calculate triangular slip uncertainties
	dEst                                          = sqrt(diag(Model.covarianceTriSlip));
	Model.trislipSSig(triS)						 		 = dEst(2*triS-1);
	Model.trislipDSig(triD)								 = dEst(2*triD-0);
	Model.trislipTSig(triT)								 = dEst(2*triT-0);
	
	% Velocities due to elastic strain accumulation on triangular elements
	dEst                                          = Partials.tri*omegaEstTriSlip;
	Model.eastTriVel                              = dEst(1:3:end);
	Model.northTriVel                             = dEst(2:3:end);
	Model.upTriVel    									 = dEst(3:3:end);
	
	% Modify model velocities
   Model.eastVel                            		 = Model.eastVel - Model.eastTriVel;
   Model.northVel                           		 = Model.northVel - Model.northTriVel;
   Model.upVel                              		 = Model.upVel - Model.upTriVel;
end

% Velocities due to internal block strains
if Command.strainMethod > 0
   dEst                                          = Partials.strain*omegaEstStrain;
   Model.eastStrainVel                           = dEst(1:2:end);
   Model.northStrainVel                          = dEst(2:2:end);
   Model.upStrainVel                             = zeros(size(Model.northStrainVel));
   
   % Modify model velocities
   Model.eastVel                            		 = Model.eastVel + Model.eastStrainVel;
   Model.northVel                           		 = Model.northVel + Model.northStrainVel;
   Model.upVel                              		 = Model.upVel + Model.upStrainVel;
else
   Model.eastStrainVel                           = zeros(size(Station.eastVel));
   Model.northStrainVel                          = zeros(size(Station.eastVel));
   Model.upStrainVel                             = zeros(size(Station.eastVel));
end   

% Calculate the residual velocites (done after consideration of strain components)
Model.eastResidVel                               = Station.eastVel - Model.eastVel;
Model.northResidVel                              = Station.northVel - Model.northVel;
Model.upResidVel                                 = Station.upVel - Model.upVel;

   
% Assign strain rates and uncertianties
Model.lonStrainSig										 = zeros(size(Model.omegaX));
Model.latStrainSig										 = zeros(size(Model.omegaX));
Model.eLonLon                                    = zeros(size(Model.omegaX));
Model.eLonLat                                    = zeros(size(Model.omegaX));
Model.eLatLat                                    = zeros(size(Model.omegaX));
Model.eLonLonSig                                 = zeros(size(Model.omegaX));
Model.eLonLatSig                                 = zeros(size(Model.omegaX));
Model.eLatLatSig                                 = zeros(size(Model.omegaX));
switch Command.strainMethod
	case 1 % 3, 3 parameter estimation 
		dEst                                       = omegaEstStrain;
		m1                                         = dEst(1:3:end);
		m2                                         = dEst(2:3:end);
		m3                                         = dEst(3:3:end);
		dEst                                       = sqrt(diag(Model.covarianceStrain));
		m1Sig                                      = dEst(1:3:end);
		m2Sig                                      = dEst(2:3:end);
		m3Sig                                      = dEst(3:3:end);
		strainBlockIdx                             = strainBlockIdx(3:3:end)/3;
		Model.eLonLon(strainBlockIdx)              = m1;
		Model.eLonLat(strainBlockIdx)              = m2;
		Model.eLatLat(strainBlockIdx)              = m3;
		Model.eLonLonSig(strainBlockIdx)           = m1Sig;
		Model.eLonLatSig(strainBlockIdx)           = m2Sig;
		Model.eLatLatSig(strainBlockIdx)           = m3Sig;
	case 2 % 5, 6 parameter estimation
	   dEst                                       = omegaEstStrain;
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
		strainBlockIdx                             = strainBlockIdx(6:6:end)/6;
%		Model.lonStrain(strainBlockIdx)				 = 
%		Model.latStrain(strainBlockIdx)				 = 
		Model.eLonLon(strainBlockIdx)              = m1.*m2./m4;
		Model.eLonLat(strainBlockIdx)              = m2;
		Model.eLatLat(strainBlockIdx)              = m5;
		Model.eLonLonSig(strainBlockIdx)           = m1Sig.*m2Sig./m4Sig;
		Model.eLonLatSig(strainBlockIdx)           = m2Sig;
		Model.eLatLatSig(strainBlockIdx)           = m5Sig;
	case 3 % 3, 4 parameter estimation
		dEst                                       = omegaEstStrain;
		m1                                         = dEst(1:4:end);
		m2                                         = dEst(2:4:end);
		m3                                         = dEst(3:4:end);
		m4                                         = dEst(4:4:end);
		dEst                                       = sqrt(diag(Model.covarianceStrain));
		m1Sig                                      = dEst(1:4:end);
		m2Sig                                      = dEst(2:4:end);
		m3Sig                                      = dEst(3:4:end);
		m4Sig                                      = dEst(4:4:end);
		strainBlockIdx                             = strainBlockIdx(4:4:end)/4;
		Model.eLonLon(strainBlockIdx)              = m1.*m2./m3;
		Model.eLonLat(strainBlockIdx)              = m2;
		Model.eLatLat(strainBlockIdx)              = m4;
		Model.eLonLonSig(strainBlockIdx)           = m1Sig.*m2Sig./m3Sig;
		Model.eLonLatSig(strainBlockIdx)           = m2Sig;
		Model.eLatLatSig(strainBlockIdx)           = m4Sig;
	case 4 % directed forward search method
	
end

fprintf('Writing output...')
% Write output
WriteOutput(Segment, Patches, Station, Block, Command, Model, Partials.tristrikes);
%save BlocksStore.mat
system(sprintf('cp %s .%s%s%s.', commandFile, filesep, runName, filesep));
if exist('tempkernels.mat') == 2;
	system(sprintf('mv tempkernels.mat .%s%s%skernels.mat', filesep, runName, filesep));
end
fprintf('done.  All files saved to .%s%s.\n', filesep, runName)
