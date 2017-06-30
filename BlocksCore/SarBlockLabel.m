function sar = SarBlockLabel(sar, b)
% SarBlockLabel  Assigns block labels to SAR observation locations.

sar.blockLabel = zeros(size(sar.lon));
for i = setdiff(1:numel(b.interiorLon), b.exteriorBlockLabel)
   ip = inpolygonsphere(sar.lon, sar.lat, b.orderLon{i}, b.orderLat{i});
   sar.blockLabel(ip) = i;
end