function G = GetSarElasticPartials(Segment, Station, look_vec)
% Calculate elastic partial derivatives
nStations                                   = numel(Station.lon);
nSegments                                   = numel(Segment.lon1);
G                                           = zeros(nStations, 3*nSegments);
[v1 v2 v3]                                  = deal(cell(1, nSegments));
parfor (iSegment = 1:nSegments)
    [ve vn vu]                              = local_okada_calc(Segment.lon1(iSegment), Segment.lat1(iSegment), Segment.lon2(iSegment), Segment.lat2(iSegment), Station.lon, Station.lat, Segment.dip(iSegment), Segment.lDep(iSegment), 1, 0, 0, 0.25, Segment.bDep(iSegment));
    
    ulos                                    = dot(repmat(look_vec(:), 1, nStations), [ve'; vn'; vu']);
    v1{iSegment}                            = reshape(ulos', nStations, 1);
    
    if(Segment.dip(iSegment) > 90)
      [ve vn vu]                            = local_okada_calc(Segment.lon1(iSegment), Segment.lat1(iSegment), Segment.lon2(iSegment), Segment.lat2(iSegment), Station.lon, Station.lat, Segment.dip(iSegment), Segment.lDep(iSegment), 0, -1, 0, 0.25, Segment.bDep(iSegment));
    elseif (Segment.dip(iSegment) < 90)
      [ve vn vu]                            = local_okada_calc(Segment.lon1(iSegment), Segment.lat1(iSegment), Segment.lon2(iSegment), Segment.lat2(iSegment), Station.lon, Station.lat, Segment.dip(iSegment), Segment.lDep(iSegment), 0, 1, 0, 0.25, Segment.bDep(iSegment));
    else
      ve                                    = zeros(nStations, 1);
      vn                                    = zeros(nStations, 1);
      vu                                    = zeros(nStations, 1);
    end
    ulos                                    = dot(repmat(look_vec(:), 1, nStations), [ve'; vn'; vu']);
    v2{iSegment}                            = reshape(ulos', nStations, 1);
    
    if(Segment.dip(iSegment) == 90)
      [ve vn vu]                            = local_okada_calc(Segment.lon1(iSegment), Segment.lat1(iSegment), Segment.lon2(iSegment), Segment.lat2(iSegment), Station.lon, Station.lat, Segment.dip(iSegment), Segment.lDep(iSegment), 0, 0, 1, 0.25, Segment.bDep(iSegment));
    else
      ve                                    = zeros(nStations, 1);
      vn                                    = zeros(nStations, 1);
      vu                                    = zeros(nStations, 1);
    end
    ulos                                    = dot(repmat(look_vec(:), 1, nStations), [ve'; vn'; vu']);
    v3{iSegment}                            = reshape(ulos', nStations, 1);
end

G(:, 1:3:end) = cell2mat(v1);
G(:, 2:3:end) = cell2mat(v2);
G(:, 3:3:end) = cell2mat(v3);
