function Blocks(commandFile, varargin)
% Main Blocks function
fprintf('Parsing input data...')
runName                                          = GetRunName; % Create new directory for output
Command                                          = ReadCommand(commandFile); % Read command file
if nargin > 1
   Command                                       = ParseOptCommands(Command, varargin{:}); % Parse optional input arguments
end
Station                                          = ReadStation(Command.staFileName); % Read station file
Sar                                              = ReadSar(Command.sarFileName); % Read SAR file
Segment                                          = ReadSegmentTri(Command.segFileName); % Read segment file
if isfield(Command, 'mshpFileName')
   [Patches, Command]                            = ReadMshp(Command.mshpFileName, Command);
else
   Patches                                       = ReadPatches(Command.patchFileNames);
end   
Station                                          = ProcessStation(Station, Command);
Sar                                              = ProcessSar(Sar, Command);
Segment                                          = ProcessSegment(Segment, Command);
[Patches, Command]                               = ProcessPatches(Patches, Command, Segment);
Block                                            = ReadBlock(Command.blockFileName); % Read block file
Mogi                                             = ReadMogi(Command.mogiFileName); % Read Mogi source file
fprintf('done.\n')

% Assign block labels and put sites on the correct blocks
fprintf('Labeling blocks...')
[Segment, Block, Station]                        = BlockLabel(Segment, Block, Station);
Sar                                              = SarBlockLabel(Sar, Block);
fprintf('done.\n')

% Merge GPS station and SAR velocities and uncertainties so that all observation locations can be used in partials calculations
[Data, Sigma, Index]                             = MergeStaSar(Station, Sar);  

fprintf('Calculating design matrix components...')
% Check to see if exisiting elastic kernels can be used
Partials                                         = CheckExistingKernels(Command, Segment, Patches, Data, Sar);

% Set up a priori constraints on block Euler poles...
[Partials.blockCon, Index, Data, Sigma]          = BlockConstraints(Block, Index, Data, Sigma, Command);
% ...and fault slip rates
[Partials.slipCon, Index, Data, Sigma]           = SlipConstraints(Segment, Block, Index, Data, Sigma, Command);

% Get partial derivatives relating displacement to slip on rectangular dislocations
if isempty(Partials.elastic)
   fprintf('\n  Calculating elastic partials...')
   Partials.elastic                              = GetElasticPartials(Segment, Data);
   [Partials.elastic, Partials.selastic]         = SarPartials(Partials.elastic, Sar);
   fprintf('done.')
end
Index.szelastic                                  = size(Partials.elastic);

% Save elastic partials
SaveKernels(Partials, Command, 'elastic', 'selastic')

% Get partial derivatives relating slip to relative Euler pole rotation
fprintf('\n  Calculating slip partials...')
Partials.slip                                    = GetSlipPartials(Segment, Block);
fprintf('done.')
Index.szslip                                     = size(Partials.slip);

% Get partial derivatives relating displacement to Euler pole rotation
fprintf('\n  Calculating rotation partials...')
Partials.rotation                                = GetRotationPartials(Segment, Data, Command, Block);
[Partials.rotation, Partials.srotation]          = SarPartials(Partials.rotation, Sar);
fprintf('done.')
Index.szrot                                      = size(Partials.rotation);

% Determine which rows to keep (eliminate vertical components)
Index                                            = staRowKeep(Data, Index);

% Calculate partial derivatives relating displacement to slip on triangular dislocation elements
if sum(Segment.patchTog) > 0 & ~isempty(Patches.c) % if patches are involved at all
   if isempty(Partials.tri)
      fprintf('\n  Calculating triangular partials...')
      [Partials.tri, ~, Patches]                 = GetTriCombinedPartials(Patches, Data, [1 0]);
      [Partials.tri, Partials.stri]              = SarPartials(Partials.tri, Sar);
      fprintf('done.')
      % Incremental save of partials
      SaveKernels(Partials, Command, 'tri', 'stri')
   end
   
   % Adjust triangular partials
   Index                                         = triColKeep(Patches, Index);

   % Calculate triangular slip partials for a posteriori determination of coupling coefficients
   [Partials.trislip, Patches]                   = GetTriSlipPartials(Patches, Block, Segment);
   
   % Calculate all triangular constraints: 
   % - Laplacian smoothing
   % - Constraining up-, down-dip, and lateral edges to be creeping or fully coupled
   [Partials, Data, Sigma, Index]                = AllTriConstraints(Patches, Command, Partials, Data, Sigma, Index);

else
   % If no triangles are involved, generate blank arrays
   [Partials, Data, Sigma, Index]                = emptyTriArrays(Partials, Data, Sigma, Index);

end
Index.sztri                                      = size(Partials.tri);

% Calculate strain partials based on the method specified in the command file
fprintf('\n  Calculating strain partials...')
[Partials.strain, Index, Model]                  = GetStrainPartials(Block, Data, Segment, Command, Index);
[Partials.strain, Partials.sstrain]              = SarPartials(Partials.strain, Sar);
fprintf('done.\n')

% Calculate SAR ramp partials based on the order specified in the command file
[Partials.sramp, Index]                          = GetSarRampPartials(Sar, Command, Index);

% Calculate Mogi source partials
Partials.mogi                                    = GetMogiPartials(Mogi, Data);
[Partials.mogi, Partials.smogi]                  = SarPartials(Partials.mogi, Sar);

% Assemble Jacobian
fprintf('\n  Assembling design matrix, data vector, and weighting matrix...')
[R, d, W, Partials, Index]                       = AssembleMatrices(Partials, Data, Sigma, Index);
fprintf('done.\n')

% Estimate rotation vectors, triangular slip rates, and strain tensors

% TODO OCT 16, 2015: BJM - Add alternative estimation methods
% All of these should be specified from the .command file
% 2) Ridge regression
% 3) Full SVD (just for fun)
% 4) Truncated SVD

switch Command.solutionMethod
    case 'backslash'
        fprintf(1, '%s\n', Command.solutionMethod);
        fprintf(1, 'Doing the inversion via backslash...');
        Model.covariance = (R'*W*R)\eye(size(R, 2));
        Model.omegaEst = Model.covariance*R'*W*d;
        fprintf(1, 'Done.\n');

    case 'fullinverse'
        fprintf(1, '%s\n', Command.solutionMethod);
        fprintf(1, 'Doing the inversion via full inverse...');
        Model.covariance = inv(R'*W*R);
        Model.omegaEst = Model.covariance*R'*W*d;
        fprintf(1, 'Done.\n');

    case 'ridge'
        fprintf(1, '%s\n', Command.solutionMethod);
        fprintf(1, 'Doing the inversion via ridge regression...\n');
        fprintf(1, 'ridge regression weighting parameter = %5.3f\n', Command.ridgeParam);
        Model.covariance = inv(R'*W*R + Command.ridgeParam * eye(size(R,2)));
        Model.omegaEst = Model.covariance*R'*W*d;
        fprintf(1, 'Done.\n');

    % case 'svd'
    %     Command.svdKeep = 400;
    %     fprintf(1, '%s\n', Command.solutionMethod);
    %     fprintf(1, 'Doing the inversion via svd...\n');
    %     fprintf(1, 'Keep %d largest eigenvalues\n', Command.svdKeep);
    %     [U, S, V] = svd(R'*W*R);
    %     Model.covariance = V * inv(S) * U'; % Not yet truncated....
    %     Model.omegaEst = Model.covariance*R'*W*d;
    %     fprintf(1, 'Done.\n');

    otherwise
        fprintf(1, 'No solution method of type: %s\n', Command.solutionMethod);
end



% Extract different parts of the state vector
fprintf('Calculating model results...')
Model                                            = ExtractStateVector(Model, Index);

% extract different parts of the model covariance matrix
Model                                            = ExtractCovariance(Model, Index);

% Calculate Euler poles and uncertainties.  Cartesian components of rotation vectors and uncertainties are also extracted.
Model                                            = OmegaToEuler(Model); % Updates Model structure with Euler pole lon., lat., and rotation rate
Model                                            = OmegaSigToEulerSig(Model); % Updates Model structure with Euler pole parameter uncertainties

% Calculate fault slip rates...
Model                                            = SlipResults(Partials, Model);

% Calculate triangular slip rates...
Model                                            = TriResults(Partials, Model, Index);

% Assign strain rates and uncertianties
Model                                            = StrainResults(Model, Index, Command);

% Assign Mogi source volume change rates and uncertainties
Model                                            = MogiResults(Model);

% Calculate forward components of velocity field
Model                                            = ModelVels(Partials.rotation - Partials.elastic * Partials.slip, Model.omegaEstRot, 'Vel', Model);

% Rotational velocities
Model                                            = ModelVels(Partials.rotation, Model.omegaEstRot, 'RotVel', Model);

% Velocities due to elastic strain accumulation on faults
Model                                            = ModelVels(Partials.elastic * Partials.slip, Model.omegaEstRot, 'DefVel', Model);

% Velocities due to slip on triangular dislocation elements
Model                                            = ModelVels(Partials.tri(:, Index.triColkeep), Model.omegaEstTriSlip, 'TriVel', Model, 'Vel', -1);

% Velocities due to internal block strains
Model                                            = ModelVels(Partials.strain, Model.omegaEstStrain, 'StrainVel', Model, 'Vel');

% Velocities due to Mogi source volume change rates
Model                                            = ModelVels(Partials.mogi, Model.omegaEstMogi, 'MogiVel', Model, 'Vel');

% Calculate SAR velocities
Model                                            = ModelSarVels(Partials, Model, Index);

% Calculate the residual velocites (done after consideration of strain components)
Model.eastResidVel                               = Station.eastVel - Model.eastVel;
Model.northResidVel                              = Station.northVel - Model.northVel;
Model.upResidVel                                 = Station.upVel - Model.upVel;
Model.SarResid                                   = Sar.data - Model.Sar;
           
fprintf('done.\n')

fprintf('Writing output...')
% Write output
runName = WriteOutput(Segment, Patches, Station, Sar, Block, Command, Model, Mogi);
fprintf('done.  All files saved to .%s%s.\n', filesep, runName)
%save 'new.mat'

if strcmp(Command.dumpall, 'yes')
   save(sprintf('./%s%s.mat', runName, runName(1:end-1)), '-v7.3');
end
