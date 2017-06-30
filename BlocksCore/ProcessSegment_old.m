function Segment = ProcessSegment(Segment, Command)
% ProcessSegment   Carries out preliminary segment processing.

Segment.bDep                                     = zeros(size(Segment.bDep));
Segment                                          = OrderEndpoints(Segment); % Reorder segment endpoints in a consistent fashion, such that the western endpoint is the first

% Segment and station prep. 
[Segment.x1 Segment.y1 Segment.z1]               = sph2cart(DegToRad(Segment.lon1(:)), DegToRad(Segment.lat1(:)), 6371);
[Segment.x2 Segment.y2 Segment.z2]               = sph2cart(DegToRad(Segment.lon2(:)), DegToRad(Segment.lat2(:)), 6371);
[Segment.midLon Segment.midLat]                  = deal(0.5*(Segment.lon1 + Segment.lon2), 0.5*(Segment.lat1 + Segment.lat2));
[Segment.midX Segment.midY Segment.midZ]         = sph2cart(DegToRad(Segment.midLon), DegToRad(Segment.midLat), 6371);
Segment.lDep                                     = LockingDepthManager(Segment.lDep, Segment.lDepSig, Segment.lDepTog, Segment.name, Command.ldTog2, Command.ldTog3, Command.ldTog4, Command.ldTog5, Command.ldOvTog, Command.ldOvValue);
Segment.lDep                                     = PatchLDtoggle(Segment.lDep, Segment.patchFile, Segment.patchTog, Command.patchFileNames); % Set locking depth to zero on segments that are associated with patches
Segment                                          = SegCentroid(Segment);