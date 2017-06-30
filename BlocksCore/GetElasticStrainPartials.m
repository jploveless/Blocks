function G = GetElasticStrainPartials(Segment, Station)
% Calculate elastic partial derivatives
nStations                                   = numel(Station.lon);
nSegments                                   = numel(Segment.lon1);
G                                           = zeros(6*nStations, 3*nSegments);
[v1 v2 v3]                                  = deal(cell(1, nSegments));
projstrikes                                 = sphereazimuth(Segment.lon1, Segment.lat1, Segment.lon2, Segment.lat2);
parfor (iSegment = 1:nSegments)
   [nee, nnn, nuu, nen, neu, nnu]           = local_okada_strain_calc(Segment.lon1(iSegment), Segment.lat1(iSegment), Segment.lon2(iSegment), Segment.lat2(iSegment), Station.lon, Station.lat, (Station.z), Segment.dip(iSegment), Segment.lDep(iSegment), 1, 0, 0, 0.25, Segment.bDep(iSegment));
   v1{iSegment}                             = reshape([nee, nnn, nuu, nen, neu, nnu]', 6*nStations, 1);
    
   if(Segment.dip(iSegment) ~= 90)
      [nee, nnn, nuu, nen, neu, nnu]        = local_okada_strain_calc(Segment.lon1(iSegment), Segment.lat1(iSegment), Segment.lon2(iSegment), Segment.lat2(iSegment), Station.lon, Station.lat, (Station.z), Segment.dip(iSegment), Segment.lDep(iSegment), 0, 1, 0, 0.25, Segment.bDep(iSegment));
      v2{iSegment}                          = reshape([nee, nnn, nuu, nen, neu, nnu]', 6*nStations, 1);
      v3{iSegment}                          = zeros(6*nStations, 1);
   else
      [nee, nnn, nuu, nen, neu, nnu]        = local_okada_strain_calc(Segment.lon1(iSegment), Segment.lat1(iSegment), Segment.lon2(iSegment), Segment.lat2(iSegment), Station.lon, Station.lat, (Station.z), Segment.dip(iSegment), Segment.lDep(iSegment), 0, 0, 1, 0.25, Segment.bDep(iSegment));
      v2{iSegment}                          = zeros(6*nStations, 1);
      v3{iSegment}                          = reshape([nee, nnn, nuu, nen, neu, nnu]', 6*nStations, 1);
   end
end
G(:, 1:3:end)                               = cell2mat(v1);
G(:, 2:3:end)                               = cell2mat(v2);
G(:, 3:3:end)                               = cell2mat(v3);
G                                           = xyz2enumat_strain(G, projstrikes + 90);
