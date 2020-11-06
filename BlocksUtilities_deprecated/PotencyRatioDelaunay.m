function [potencyAllFaults, potencyBlock, potencyRatio, blockStrain, blockVolume, triVols] = PotencyRatioDelaunay(direc)
Station                                          = ReadStation([direc filesep 'Res.sta.data']); % Read station file
Segment                                          = ReadSegmentTri([direc filesep 'Mod.segment']); % Read segment file
Segment.bDep                                     = zeros(size(Segment.bDep));
Block                                            = ReadBlock([direc filesep 'Mod.block']);
Strain                                           = load([direc filesep 'Strain.delaunay'], '-mat'); % Read delaunay
Segment                                          = OrderEndpoints(Segment); % Reorder segment endpoints in a consistent fashion
[Segment.x1 Segment.y1 Segment.z1]               = sph2cart(DegToRad(Segment.lon1(:)), DegToRad(Segment.lat1(:)), 6371);
[Segment.x2 Segment.y2 Segment.z2]               = sph2cart(DegToRad(Segment.lon2(:)), DegToRad(Segment.lat2(:)), 6371);
[Segment.midLon Segment.midLat]                  = deal((Segment.lon1+Segment.lon2)/2, (Segment.lat1+Segment.lat2)/2);
[Segment.midX Segment.midY Segment.midZ]         = sph2cart(DegToRad(Segment.midLon), DegToRad(Segment.midLat), 6371);
Segment                                          = SegCentroid(Segment);
Station                                          = SelectStation(Station);
[Station.x Station.y Station.z]                  = sph2cart(DegToRad(Station.lon), DegToRad(Station.lat), 6371);

% Do quicker block labeling with existing information
%bc = ReadBlockCoords(direc);
%sl = ReadSegmentTri([direc filesep 'Label.segment']);
%Segment.westLabel = sl.ssRate; Segment.eastLabel = sl.ssRateSig;

Segment.lDep = median(Segment.lDep)*ones(size(Segment.lDep));

% Find dipping segments
[sboxx, sboxy, dipping] = segsurfproj(Segment);
dipping = find(dipping);

% Assign block labels and put sites on the correct blocks
[Segment, Block, Station]                        = BlockLabel(Segment, Block, Station);

% Loop over all blocks
nblocks = max([Segment.eastLabel(:) ; Segment.westLabel(:)]);
for i = 1:nblocks
   % find all fault segments for the current block and plot them.
   idx1 = find(Segment.eastLabel == i);
   idx2 = find(Segment.westLabel == i);
   idx  = [idx1(:) ; idx2(:)];
   
   % Calculate potency for each fault segment
   potencyFaults = zeros(numel(idx), 1);
   for j = 1:numel(idx)
      % slip rate in m/yr (not mm/yr)
      segSlipRate = sqrt(Segment.ssRate(idx(j)).^2 + Segment.dsRate(idx(j)).^2 + Segment.tsRate(idx(j)).^2) / 1e3 / 2;
      segLength = distance(Segment.lat1(idx(j)), Segment.lon1(idx(j)), Segment.lat2(idx(j)), Segment.lon2(idx(j)), almanac('earth','ellipsoid','kilometers'));
      segArea = segLength * Segment.lDep(idx(j))/abs(sind(Segment.dip(idx(j)))) * 1e6;
      potencyFaults(j) = 3e10 * segArea * segSlipRate; 
   end
   potencyAllFaults(i) = sum(potencyFaults);
   
   % Find all triangles associated with this block
   tri = find(Strain.triblock == i);
   trivols = Strain.triarea(tri) * median(Segment.lDep) * 1e9;
   blockArea(i) = areaint(Block.orderLat{i}, Block.orderLon{i}, almanac('earth','ellipsoid','kilometers'));
   blockVolume(i) = blockArea(i) * median(Segment.lDep) * 1e9;
   % Correct block volume for dipping segments
   dipidx = ismember(idx, dipping);
   dipidx = idx(find(dipidx));
   if ~isempty(dipidx)
      clear toparea
      for j = 1:length(dipidx)
         toparea(j) = areaint(sboxy(dipidx(j), :), sboxx(dipidx(j), :), almanac('earth','ellipsoid','kilometers'));
      end
      wedgevol = 0.5.*toparea(:).*Segment.lDep(dipidx);
      wedgevol = sum(wedgevol);
      blockVolume(i) = blockVolume(i) - wedgevol;
   end
 
   triVols(i) = sum(trivols);
   blockStrain(i) = sum(Strain.strainm(tri).*(trivols./triVols(i)));
   potencyBlock(i) = 3e10 * 2*blockStrain(i)*blockVolume(i);
   potencyRatio(i) = potencyBlock(i)/(potencyAllFaults(i) + potencyBlock(i)) * 100;
end
