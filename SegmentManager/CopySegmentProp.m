function Segment = CopySegmentProp(Segment, idx, newSegmentName, lon1, lat1, lon2, lat2)
%%  CopySegmentProp

Segment.name         = strvcat(Segment.name, newSegmentName);
Segment.lon1         = [Segment.lon1 ; lon1];
Segment.lat1         = [Segment.lat1 ; lat1];
Segment.lon2         = [Segment.lon2 ; lon2];
Segment.lat2         = [Segment.lat2 ; lat2];

sn = Segment;
f = fieldnames(Segment);
f = setdiff(f, {'name'; 'lon1'; 'lat1'; 'lon2'; 'lat2'});
for i = 1:length(f)
   d = getfield(Segment, f{i});
   d = [d; d(idx, :)];
   sn = setfield(sn, f{i}, d);
end

Segment = sn;