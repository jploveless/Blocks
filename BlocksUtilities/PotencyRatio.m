function PotencyRatio(direc)
Station                                          = ReadStation([direc filesep 'Res.sta.data']); % Read station file
Segment                                          = ReadSegmentTri([direc filesep 'Mod.segment']); % Read segment file
Segment.bDep                                     = zeros(size(Segment.bDep));
Block                                            = ReadBlock([direc filesep 'Mod.block']);
Segment                                          = OrderEndpoints(Segment); % Reorder segment endpoints in a consistent fashion
[Segment.x1 Segment.y1 Segment.z1]               = sph2cart(DegToRad(Segment.lon1(:)), DegToRad(Segment.lat1(:)), 6371);
[Segment.x2 Segment.y2 Segment.z2]               = sph2cart(DegToRad(Segment.lon2(:)), DegToRad(Segment.lat2(:)), 6371);
[Segment.midLon Segment.midLat]                  = deal((Segment.lon1+Segment.lon2)/2, (Segment.lat1+Segment.lat2)/2);
[Segment.midX Segment.midY Segment.midZ]         = sph2cart(DegToRad(Segment.midLon), DegToRad(Segment.midLat), 6371);
Segment                                          = SegCentroid(Segment);
Station                                          = SelectStation(Station);
[Station.x Station.y Station.z]                  = sph2cart(DegToRad(Station.lon), DegToRad(Station.lat), 6371);

% Assign block labels and put sites on the correct blocks
[Segment, Block, Station]                        = BlockLabel(Segment, Block, Station);

% Plot segments
figure; hold on
line([Segment.lon1'; Segment.lon2'], [Segment.lat1'; Segment.lat2'], 'color', 0.5*[1 1 1]);

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
      segSlipRate = sqrt(Segment.ssRate(idx(j)).^2 + Segment.dsRate(idx(j)).^2 + Segment.tsRate(idx(j)).^2) / 1e3;
      segLength = distance(Segment.lat1(idx(j)), Segment.lon1(idx(j)), Segment.lat2(idx(j)), Segment.lon2(idx(j)), almanac('earth','ellipsoid','kilometers'));
      segArea = segLength * Segment.lDep(idx(j)) * 1e6;
      potencyFaults(j) = 3e10 * segArea * segSlipRate; 
   end
   sum(potencyFaults)
   
   % Calculate block area with areaint
   blockArea = areaint(Block.orderLat{i}, Block.orderLon{i}, almanac('earth','ellipsoid','kilometers'));
   blockVolume = blockArea * 17 * 1e9;
   strainMagnitude = sqrt(Block.other1(i)^2 + Block.other2(i)^2 + Block.other3(i)^2);
   potencyBlock = 3e10 * blockVolume * strainMagnitude;
   potencyRatio = potencyBlock/(sum(potencyFaults) + potencyBlock) * 100;
   
   % Plot the potency rate partioning in the middle of the block
%   midlon = mean(Segment.lon1(idx)); 
%   midlat = mean(Segment.lat1(idx));
%   text(midlon, midlat, sprintf('%4.1f', potencyRatio));
   text(Block.interiorLon(i), Block.interiorLat(i), sprintf('%4.1f', potencyRatio));
end


