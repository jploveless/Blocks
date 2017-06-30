function [potencyAllFaults, potencyBlock, blockSeismic, potencyRatio, blockArea] = PotencyRatioFaultSeismic(direc, eqs)
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

% Open CMT file
fid = fopen(eqs, 'r');
c = textscan(fid, '%f%f%f%f%f%f%f%f%f%f%s');
eqlon = c{1}; eqlat = c{2}; eqmom = 1e-7*c{9}.*10.^c{10};
fclose(fid);

hh = load('/Users/jack/Documents/harvard_work/tibet/figures/seis/holt_hist_seis.txt');
eqlon = [eqlon; hh(:, 5)]; eqlat = [eqlat; hh(:, 4)]; eqmom = [eqmom; hh(:, 6).*10.^hh(:, 7)];

% Assign block labels and put sites on the correct blocks
[Segment, Block, Station]                        = BlockLabel(Segment, Block, Station);

% Plot segments
figure; hold on
line([Segment.lon1'; Segment.lon2'], [Segment.lat1'; Segment.lat2'], 'color', 0.5*[1 1 1]);

nblocks = length(Block.interiorLon);
inblocks = setdiff(1:nblocks, Block.exteriorBlockLabel);

wid = 50; % want to find earthquakes within 25 km of either side of the block

h = zeros(nblocks, 1);
segSeismic = zeros(length(Segment.lon1), 1);
potencyFaults = zeros(numel(Segment.lon1), 1);
for i = inblocks
   sib = union(find(Segment.eastLabel == i), find(Segment.westLabel == i));
   [ineqlon, seglon] = meshgrid(eqlon, Segment.midLon(sib));
   [ineqlat, seglat] = meshgrid(eqlat, Segment.midLat(sib));
   [eqidx, segidx] = meshgrid(1:length(eqlon), 1:length(Segment.midLon(sib)));
   deq = distance(ineqlat(:), ineqlon(:), seglat(:), seglon(:), almanac('earth','ellipsoid','kilometers'));
   closeidx = find(deq <= 25);
   closeeq = eqidx(closeidx);
   closeseg = segidx(closeidx);
   for j = 1:length(closeseg)
      segSeismic(sib(closeseg(j))) = segSeismic(sib(closeseg(j))) + eqmom(closeeq(j));
   end   

   % Calculate potency for each fault segment
   for j = 1:numel(sib)
      % slip rate in m/yr (not mm/yr)
      segSlipRate = sqrt(Segment.ssRate(sib(j)).^2 + Segment.dsRate(sib(j)).^2 + Segment.tsRate(sib(j)).^2) / 1e3;
      segLength = distance(Segment.lat1(sib(j)), Segment.lon1(sib(j)), Segment.lat2(sib(j)), Segment.lon2(sib(j)), almanac('earth','ellipsoid','kilometers'));
      segArea = segLength * Segment.lDep(sib(j))/abs(sind(Segment.dip(sib(j)))) * 1e6;
      potencyFaults(sib(j)) = 3e10 * segArea * segSlipRate; 
   end
end
keyboard

