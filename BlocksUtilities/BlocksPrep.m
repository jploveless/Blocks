function [Segment, Block, Station, Patches] = BlocksPrep(command);
% BLOCKSPREP prepares the geometry files for a blocks run.
%   [SEGMENT, BLOCK, STATION, PATCHES] = BLOCKSPREP(COMMAND) returns the necessary control
%   structures for a blocks run, given the input command file COMMAND.
%

fprintf('Parsing input data...')
runName                                          = GetRunName; % Create new directory for output
Command                                          = ReadCommand(commandFile); % Read command file
Station                                          = ReadStation(Command.staFileName); % Read station file
if strmatch(Command.unitSigmas, 'yes')
   [Station.eastSig, Station.northSig]           = ones(numel(Station.lon), 1);
end
Segment                                          = ReadSegmentTri(Command.segFileName); % Read segment file
%Segment.bDep                                     = zeros(size(Segment.bDep));
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
Station                                          = SelectStation(Station);
[Station.x Station.y Station.z]                  = sph2cart(DegToRad(Station.lon), DegToRad(Station.lat), 6371);
fprintf('done.\n')

% Assign block labels and put sites on the correct blocks
fprintf('Labeling blocks...')
[Segment, Block, Station]                        = BlockLabel(Segment, Block, Station);
fprintf('...done.\n')