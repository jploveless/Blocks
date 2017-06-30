function [potencyAllFaults, potencyBlock, blockSeismic, potencyRatio, blockArea] = PotencyRatioDelaunaySeismic(direc, eqs)
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
eqlon = c{1}; eqlat = c{2}; eqmom = c{9}.*10.^c{10};
fclose(fid);


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
   potencyAllFaults(i) = sum(potencyFaults);
   
   % Find all triangles associated with this block
   tri = find(Strain.triblock == i);
   trivols = Strain.triarea(tri) * 15 * 1e9;
   triVols(i) = sum(trivols);
   blockArea(i) = areaint(Block.orderLat{i}, Block.orderLon{i}, almanac('earth','ellipsoid','kilometers'));
   blockVolume(i) = blockArea(i) * 15 * 1e9;
   %blockStrain = sum(Strain.strainm(tri).*(trivols./sum(trivols)));
   blockStrain(i) = sum(Strain.strainm(tri).*(trivols./blockVolume(i)));
   blockStrain2(i) = sum(Strain.strainm(tri).*(trivols./triVols(i)));
   potencyBlock(i) = 3e10 * 2*blockStrain(i)*blockVolume(i);
   
   
   % Find all earthquakes associated with this block
   ineq = inpolygon(eqlon, eqlat, Block.orderLon{i}, Block.orderLat{i});
   % Now find all earthquakes that are greater than 25 km from the block boundaries
   [ineqlon, seglon] = meshgrid(eqlon(ineq), Block.orderLon{i});
   [ineqlat, seglat] = meshgrid(eqlat(ineq), Block.orderLat{i});
   [eqidx, segidx] = meshgrid(1:sum(ineq), 1:length(Block.orderLon{i}));
   deq = distance(ineqlat(:), ineqlon(:), seglat(:), seglon(:), almanac('earth','ellipsoid','kilometers'));
   closeeq = unique(eqidx(find(deq < 25)));
   ineq = find(ineq);
   closeeq = ineq(closeeq);
   inteq = setdiff(ineq, closeeq); % find interior earthquakes
   intmom = sort(eqmom(inteq));
   blockSeismic(i) = 1e-7*sum(intmom(:))/33; % Multiply by 1e-7 to give N-m, Divide by 33 for number of years to give moment rate
   
   potencyTris = 3e10 * trivols.* Strain.strainm(tri);
   potencyTriSum = sum(potencyTris);
   potencyTriMean = mean(potencyTris);
   potencyRatioSum = potencyTriSum/(sum(potencyFaults) + potencyTriSum) * 100;
   potencyRatioMean = potencyTriMean/(sum(potencyFaults) + potencyTriMean) * 100;

   potencyRatio(i) = blockSeismic(i)/(potencyBlock(i)) * 100;
   % Plot the potency rate partioning in the middle of the block
%   midlon = mean(Segment.lon1(idx)); 
%   midlat = mean(Segment.lat1(idx));
%   text(midlon, midlat, sprintf('%4.1f\n%4.1f', potencyRatioSum, potencyRatioMean));
   text(Block.interiorLon(i), Block.interiorLat(i), sprintf('%4.1f\n%4.1f', potencyRatioSum, potencyRatioMean));
%   text(Block.interiorLon(i), Block.interiorLat(i), sprintf('%4.1f', potencyRatio(i)));
end
keyboard

