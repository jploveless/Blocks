function varargout = BlocksForward(x, y, outdir, notri)
%
% BLOCKSFORWARD calculates the predicted velocities at stations for 
% a given BLOCKS model run.
%    BLOCKSFORWARD(X, Y, OUTDIR) calculates the predicted velocity 
%    components at station coordinates (X, Y) given the results of
%    a BLOCKS run contained in OUTDIR.
%
%    V = BLOCKSFORWARD(...) outputs the predicted velocities to a single
%    vector V with structure [E1; N1; U1; ... ; EN; NN; UN].
%
%    [VB, VD, VT, VS] = BLOCKSFORWARD(...) returns individual vectors 
%    containing the constituent parts of the velocity field due to 
%    block motion (VB), elastic deformation (VD), triangular deformation
%    (VT), and intrablock strain (VS).  The total velocity field is given
%    by VB - (VD + VT) + VS.
%

% Read in the necessary files
cmname                                           = dir([outdir filesep '*.command']);
Command                                          = ReadCommand([outdir filesep cmname(1).name]);
Segment                                          = ReadSegmentTri([outdir filesep 'Mod.segment']);
%%Segment                                          = ProcessSegment(Segment, Command);
% revert to old blocks forward line for testing
Segment                                          = OrderEndpoints(Segment); % Reorder segment endpoints in a consistent fashion
[Segment.x1 Segment.y1 Segment.z1]               = sph2cart(DegToRad(Segment.lon1(:)), DegToRad(Segment.lat1(:)), 6371);
[Segment.x2 Segment.y2 Segment.z2]               = sph2cart(DegToRad(Segment.lon2(:)), DegToRad(Segment.lat2(:)), 6371);
[Segment.midLon Segment.midLat]                  = deal((Segment.lon1+Segment.lon2)/2, (Segment.lat1+Segment.lat2)/2);
[Segment.midX Segment.midY Segment.midZ]         = sph2cart(DegToRad(Segment.midLon), DegToRad(Segment.midLat), 6371);
Segment.lDep                                     = PatchLDtoggle(Segment.lDep, Segment.patchFile, Segment.patchTog, Command.patchFileNames); % Set locking depth to zero on segments that are associated with patches
Segment                                          = SegCentroid(Segment);

Block                                            = ReadBlock([outdir filesep 'Mod.block']);
[Patches.c, Patches.v, Patches.s]                = PatchData([outdir filesep 'Mod.patch']);
Patches.nc                                       = size(Patches.c, 1);
Patches.nEl                                      = size(Patches.v, 1);

%revert to old blocks forward for testing 
Patches                                          = PatchCoords(Patches);

%%if Patches.nc ~= 0
%%   Patches                                       = PatchCoords(Patches);
%%end

Command                                          = [];

if exist('notri', 'var')
    Segment.patchTog = 0; %revert to old bloks forward for testing
%   Segment.patchTog = 0*Segment.patchTog;
end

% Put the stations in a structure
[Station.lon, Station.lat]                       = deal(x(:), y(:));
[Station.x, Station.y, Station.z]                = sph2cart(DegToRad(Station.lon), DegToRad(Station.lat), 6371);
[Segment, Block, Station]                        = BlockLabel(Segment, Block, Station);


% Calculate all partials
Partials.elastic                                 = GetElasticPartials(Segment, Station);
Partials.slip                                    = GetSlipPartials(Segment, Block);
Partials.rotation                                = GetRotationPartials(Segment, Station, Command, Block);
if sum(Segment.patchTog) > 0 % if patches are involved at all
   [Partials.tri, tz, ts]                        = GetTriCombinedPartials(Patches, Station, [1 0]);
   ts = zeros(3*size(Patches.s, 1), 1);
   ts(1:3:end) = Patches.s(:, 1);
   ts(2:3:end) = Patches.s(:, 2);
   ts(3:3:end) = Patches.s(:, 3);
else
   Partials.tri                                  = zeros(3*numel(x), 1);
   ts                                            = 0;
end

% Construct solution vectors
[x, y, z] = EulerToOmega(Block.eulerLon(:), Block.eulerLat(:), Block.rotationRate*1e6);
omega = zeros(3*numel(x), 1);
omega(1:3:end) = x(:);
omega(2:3:end) = y(:);
omega(3:3:end) = z(:);

% Do the forward problems
vb = Partials.rotation*omega;
vd = Partials.elastic*Partials.slip*omega;
vt = Partials.tri*ts;
vs = zeros(size(vt));

if nargout == 1
   varargout{1} = vb - vd - vt;
elseif nargout == 4
   varargout{1} = vb;
   varargout{2} = vd;
   varargout{3} = vt;
   varargout{4} = vs;
elseif nargout == 5
   varargout{1} = vb;
   varargout{2} = vd;
   varargout{3} = vt;
   varargout{4} = vs;
   varargout{5} = vb - vd - vt;
end
