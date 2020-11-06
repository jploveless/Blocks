function h = allsegsmoothcline(direc, wid, col)
% ALLSEGSMOOTHCLINE  Plots all segments colored by a given value as 
% smoothly mitered polygons.
%    ALLSEGSMOOTHCLINE(DIREC, WID, COL) uses files in the result directory
%    DIREC to plot smoothly mitered colored lines of width WID (km) and 
%    color scaled by magnitude COL.  COL can either be a string containing
%    the name of a field of the loaded segment structure (e.g., 'ssRate', 'dsRate')
%    or a vector that exists in the workspace.
%

% Load the necessary files
b = ReadBlock([direc 'Mod.block']);
s  = ReadSegmentTri([direc 'Mod.segment']);
s  = OrderEndpoints(s);
[s.midLon, s.midLat] = deal(mean([s.lon1(:) s.lon2(:)], 2), mean([s.lat1(:) s.lat2(:)], 2));
[sta.lon, sta.lat] = deal(0);
[s, b, sta] = BlockLabel(s, b, sta);

nb = length(b.interiorLon);
si = cell(size(nb));



% Loop over each block
for i = 1:nb 
  % Find the segments comprising the block
  sib = union(find(s.eastLabel == i), find(s.westLabel == i));
  
  % Find the segment indices that correspond to the ordered block coordinates
  mo = 0.5*(b.orderLon{i}(1:end) + b.orderLon{i}([2:end, 1]));
  ma = 0.5*(b.orderLat{i}(1:end) + b.orderLat{i}([2:end, 1]));
  
  nbc = length(b.orderLon{i});
  [junk, si11] = ismember([s.lon1(sib), s.lat1(sib)], [b.orderLon{i} b.orderLat{i}], 'rows');
  [junk, si12] = ismember([s.lon1(sib), s.lat1(sib)], [b.orderLon{i}(2:nbc, 1) b.orderLat{i}(2:nbc, 1)], 'rows');
  [junk, si21] = ismember([s.lon2(sib), s.lat2(sib)], [b.orderLon{i} b.orderLat{i}], 'rows');
  [junk, si22] = ismember([s.lon2(sib), s.lat2(sib)], [b.orderLon{i}(2:nbc, 1) b.orderLat{i}(2:nbc, 1)], 'rows');

%  [junk, sio] = ismember([s.midLon(sib), s.midLat(sib)], [mo, ma], 'rows');
  si{i} = sib(sio);



end  
