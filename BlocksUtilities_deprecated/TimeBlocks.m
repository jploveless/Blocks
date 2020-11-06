%function TimeBlocks(commandFile)

% start parallel engine
%matlabpool open local 4

% Initial alpha value; need to know to 
alpha = 0.05;

fprintf('Parsing input data...')
runName                                          = GetRunName; % Create new directory for output
Command                                          = ReadCommand(commandFile); % Read command file
load('../timeseries/vels.mat', 'combcut'); % Read station file
Station                                          = combcut;
Station.east                                     = Station.east - repmat(Station.east(:, 1), 1, size(Station.east, 2));
Station.north                                    = Station.north - repmat(Station.north(:, 1), 1, size(Station.north, 2));
if strmatch(Command.unitSigmas, 'yes')
   [Station.eastSig, Station.northSig]           = ones(numel(Station.lon), 1);
end
Segment                                          = ReadSegmentTri(Command.segFileName); % Read segment file
Segment.bDep                                     = zeros(size(Segment.bDep));
Block                                            = ReadBlock(Command.blockFileName); % Read block file
Segment                                          = OrderEndpoints(Segment); % Reorder segment endpoints in a consistent fashion
Patches                                          = struct('c', [], 'v', []);
if ~isempty(Command.patchFileNames)
   Patches                                       = ReadPatches(Command.patchFileNames); % Read triangulated patch files
   Patches                                       = PatchEndAdjust(Patches, Segment); % Adjust patch end coordinates to agree with segment end points
   Patches                                       = PatchCoords(Patches); % Create patch coordinate arrays
   if numel(Command.triSmooth) == 1
      Command.triSmooth                          = repmat(Command.triSmooth, 1, numel(Patches.nEl));
   elseif numel(Command.triSmooth) ~= numel(Patches.nEl)
      error('BLOCKS:SmoothNEqPatches', 'Smoothing magnitude must be a constant or array equal in size to the number of patches.');
   end   
end
[Segment.x1 Segment.y1 Segment.z1]               = sph2cart(DegToRad(Segment.lon1(:)), DegToRad(Segment.lat1(:)), 6371);
[Segment.x2 Segment.y2 Segment.z2]               = sph2cart(DegToRad(Segment.lon2(:)), DegToRad(Segment.lat2(:)), 6371);
[Segment.midLon Segment.midLat]                  = deal((Segment.lon1+Segment.lon2)/2, (Segment.lat1+Segment.lat2)/2);
[Segment.midX Segment.midY Segment.midZ]         = sph2cart(DegToRad(Segment.midLon), DegToRad(Segment.midLat), 6371);
Segment.lDep                                     = LockingDepthManager(Segment.lDep, Segment.lDepSig, Segment.lDepTog, Segment.name, Command.ldTog2, Command.ldTog3, Command.ldTog4, Command.ldTog5, Command.ldOvTog, Command.ldOvValue);
Segment.lDep                                     = PatchLDtoggle(Segment.lDep, Segment.patchFile, Segment.patchTog); % Set locking depth to zero on segments that are associated with patches
Segment                                          = SegCentroid(Segment);
%Station                                          = SelectStation(Station);
[Station.x Station.y Station.z]                  = sph2cart(DegToRad(Station.lon), DegToRad(Station.lat), 6371);
fprintf('done.\n')

% Assign block labels and put sites on the correct blocks
fprintf('Labeling blocks...')
[Segment, Block, Station]                        = BlockLabel(Segment, Block, Station);
fprintf('...done.\n')

fprintf('Applying a priori slip constraints...')
% Build a priori slip rate constraints
for i = 1:numel(Segment.lon1)
   if Segment.ssRateTog(i)==1
      fprintf(1, 'Strike-slip constraint   : rate=%6.2f, sigma=%6.2f %s\n', Segment.ssRate(i), Segment.ssRateSig(i), Segment.name(i,:));
   end
   if Segment.dsRateTog(i)==1
      fprintf(1, 'Dip-slip constraint      : rate=%6.2f, sigma=%6.2f %s\n', Segment.dsRate(i), Segment.dsRateSig(i), Segment.name(i,:));
   end
   if Segment.tsRateTog(i)==1
      fprintf(1, 'Tensile-slip constraint  : rate=%6.2f, sigma=%6.2f %s\n', Segment.tsRate(i), Segment.tsRateSig(i), Segment.name(i,:));
   end
end
Partials.slipCon                                 = GetSlipPartials(Segment, Block);
slipToggle                                       = zeros(1,size(Partials.slipCon, 1));
slipToggle(1:3:end)                              = Segment.ssRateTog(:);
slipToggle(2:3:end)                              = Segment.dsRateTog(:);
slipToggle(3:3:end)                              = Segment.tsRateTog(:);
slipToggle                                       = slipToggle(:);
slipConIdx                                       = find(slipToggle==1);
slipRates                                        = zeros(1,size(Partials.slipCon, 1));
slipRates(1:3:end)                               = Segment.ssRate(:);
slipRates(2:3:end)                               = Segment.dsRate(:);
slipRates(3:3:end)                               = Segment.tsRate(:);
slipRates                                        = slipRates(:);
slipSigs                                         = zeros(1,size(Partials.slipCon, 1));
slipSigs(1:3:end)                                = Segment.ssRateSig(:);
slipSigs(2:3:end)                                = Segment.dsRateSig(:);
slipSigs(3:3:end)                                = Segment.tsRateSig(:);
slipSigs                                         = slipSigs(:);
Partials.slipCon                                 = Partials.slipCon(slipConIdx, :);
fprintf('done.\n')

fprintf('Calculating design matrix components...')
% Check to see if exisiting elastic kernels can be used
if strmatch(Command.reuseElastic, 'yes')
   fprintf('\n  Using existing elastic matrices...')
   Partials = load(Command.reuseElasticFile);
else
   [Partials.elastic, Partials.tri] = deal([]);
end
   % Get Partial derivatives for elastic calculation
   if isempty(Partials.elastic)
      fprintf('\n  Calculating elastic partials...')
      Partials.elastic                              = GetElasticPartials(Segment, Station);
   end
   szelastic                                        = size(Partials.elastic);
   
   % Check whether or not we are saving the partials
   if strcmp(Command.saveKernels, 'yes') == 1;
      save('../timeseries/kernels.mat', '-struct', 'Partials', '-mat');
   end
   
   fprintf('\n  Calculating slip partials...')
   Partials.slip                                    = GetSlipPartials(Segment, Block);
   szslip                                           = size(Partials.slip);
   fprintf('\n  Calculating rotation partials...')
   Partials.rotation                                = GetRotationPartials(Segment, Station, Command, Block);
   szrot                                            = size(Partials.rotation);
   rowkeep                                          = setdiff(1:szrot(1), [3:3:szrot(1)]);
   
   if sum(Segment.patchTog) > 0 & ~isempty(Patches.c) % if patches are involved at all
      if isempty(Partials.tri)
         fprintf('\n  Calculating triangular partials...')
         [Partials.tri,...
          Partials.trizeros,...
          Partials.tristrikes]                      = GetTriPartials(Patches, Station);
         % Check whether or not we are saving the partials
         if strcmp(Command.saveKernels, 'yes') == 1;
            save('../timeseries/kernels.mat', '-struct', 'Partials', 'tri', 'trizeros', 'tristrikes', '-mat', '-append');
         end
      end
   
      % Calculate triangular slip partials
   %   Partials.trislip                              = GetTriSlipPartials(Patches, Block, Segment, Partials.tristrikes);
   
      % determine constraints placed on triangular slips by segment slips
      [Wconss, Wconst]                              = deal(zeros(0, szrot(2)), zeros(0, size(Partials.tri, 2)));
      if Command.triKinCons == 1
         [Wconss, Wconst]                           = PatchSlipConstraint(Partials.slip, Segment, Patches);
      end   
      % set slip partials to zero on segments that are replaced by patches
      %Partials.slip                                = ZeroSlipPartials(Segment.patchFile, Segment.patchTog, Partials.slip);
      szslip                                        = size(Partials.slip);
      
      % adjust triangular partials
      triS                                          = [1:length(Partials.trizeros)]';
      triD                                          = find(Partials.trizeros(:) == 2);
      triT                                          = find(Partials.trizeros(:) == 3);
      colkeep                                       = setdiff(1:size(Partials.tri, 2), [3*triD-0; 3*triT-1]);
      Partials.tri                                  = Partials.tri(:, colkeep); % eliminate the partials that equal zero
      % set up and downdip edges to zero if requested
      if sum(Command.triEdge) ~= 0
         Ztri                                       = ZeroTriEdges(Patches, Command);
      else
         Ztri                                       = zeros(0, size(Partials.tri, 2));
      end
      % adjust the matrix so that constant rake is applied
      if ~isempty(Command.triRake)
         Partials.tri                               = RakeTriPartials(Partials.tri, Partials.tristrikes, Command.triRake, triD, triT);
      end
   end


fprintf('\n  Making the smoothing matrix...')
% Make the triangular smoothing matrix
share                                            = SideShare(Patches.v);
dists                                            = TriDistCalc(share, Patches.xc, Patches.yc, Patches.zc); % distance is calculated in km
[Wtrip, Wseg]                                    = SmoothEdges(share, Patches, Segment, Partials.slip, Command);                 
Wtrip                                            = Wtrip(:, colkeep); % eliminate the entries corresponding to empty partials
Wtrip(3:3:end, :)                                = []; % eliminate vertical velocity components
Wtri                                             = Wtrip./alpha;
Wseg(3:3:end, :)                                 = [];
Wconst                                           = Wconst(:, colkeep);
Wcons                                            = [Wconss Wconst];
Wcons(3:3:end, :)                                = [];
sztri                                            = size(Partials.tri);

% Calculate strain partials based on the method specified in the command file
%fprintf('\n  Calculating strain partials...')
%[Partials.strain, strainBlockIdx]                = deal([]);
%[Model.lonStrain, Model.latStrain]               = deal(zeros(size(Block.interiorLon)));
%switch Command.strainMethod
%   case 1 % use the block centroid
%      [Partials.strain, strainBlockIdx,...
%       Model.lonStrain, Model.latStrain]         = GetStrainCentroidPartials(Block, Station, Segment);
%   case 2 % solve for the reference coordinates
%      [Partials.strain, strainBlockIdx]          = GetStrain56Partials(Block, Station, Segment);
%   case 3 % solve for the reference latitude only
%      [Partials.strain, strainBlockIdx]          = GetStrain34Partials(Block, Station, Segment);
%   case 4 % use the simulated annealing approach to solve for reference coordinates inside the block boundaries
%      [Partials.strain, strainBlockIdx]          = GetStrainSearchPartials(Block, Station, Segment);
%end      

fprintf('\n  Assembling the Jacobians...')
% Assemble Jacobian
R                                                = Partials.rotation - Partials.elastic * Partials.slip;
R                                                = [R -Partials.tri]; % Insert tri. partials ** Negative because they're just like the elastic partials
R                                                = R(rowkeep, :); % Eliminate the vertical velocity components
R                                                = [R ; [Partials.slipCon sparse(size(Partials.slipCon, 1), sztri(2))]]; % Add slip rate constraints
R                                                = [R ; [Wseg, Wtri]]; % Add triangular smoothing matrix
R                                                = [R ; Wcons]; % Add kinematic constraints
R                                                = [R ; [sparse(size(Ztri, 1), szrot(2)) Ztri]]; % Add edge slip constraints
%strainPadding                                    = zeros(size(R, 1)-size(Partials.strain, 1), size(Partials.strain, 2));
%R                                                = [R [Partials.strain;strainPadding]];

% Assemble binary "on" Jacobian
Rp                                               = Partials.rotation - Partials.elastic * Partials.slip;
Rp                                               = [Rp -Partials.tri]; % Insert tri. partials ** Negative because they're just like the elastic partials
Rp                                               = Rp(rowkeep, :); % Eliminate the vertical velocity components
Rp                                               = [Rp ; [Partials.slipCon sparse(size(Partials.slipCon, 1), sztri(2))]]; % Add slip rate constraints
Rp                                               = [Rp ; [Wseg, Wtrip]]; % Add triangular smoothing matrix
Rp                                               = [Rp ; Wcons]; % Add kinematic constraints
Rp                                               = [Rp ; [sparse(size(Ztri, 1), szrot(2)) Ztri]]; % Add edge slip constraints
%strainPadding                                    = zeros(size(R, 1)-size(Partials.strain, 1), size(Partials.strain, 2));
%R                                                = [R [Partials.strain;strainPadding]];

fprintf('done.\n')


fprintf('Building the data vector...')
% Build data vector and weighting matrix
nts                                              = size(Station.east, 2);
d                                                = zeros(3*numel(Station.lon), nts);
d(1:3:end, :)                                    = Station.east;
d(2:3:end, :)                                    = Station.north;
d                                                = d(rowkeep, :); % Eliminate the vertical velocity components
d                                                = [d ; repmat(slipRates(slipConIdx), 1, nts)]; % Add slip rate constraints
d                                                = [d ; sparse(size(Wtri, 1), nts)]; % Add zeros for tri. mesh Laplacian
d                                                = [d ; sparse(size(Wcons, 1), nts)]; % Add zeros for rect. constraints
d                                                = [d ; sparse(size(Ztri, 1), nts)]; % Add zeros for edge slip constraints
fprintf('done.\n')

% Full matrices
[R, Rp, d]                                       = deal(full(R), full(Rp), full(d));

% Call alpha filter
fprintf('Starting the filter...\n')
xinit                                            = zeros(size(R, 2), 1);
alp                                              = [alpha/1e2*ones(size(Wseg, 2), 1); alpha*ones(size(Wseg, 1), 1)];
[xest, est, res, a]                              = adaptivealphanew(d, 1:size(d, 2), R, xinit, alp, 2*numel(Station.lon));

