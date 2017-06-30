function h = smoothclineallblocks(seg, block, wid, col, triexclude)
% SMOOTHCLINEALLBLOCKS  Plots all blocks using smooth colored polygons.
%    H = SMOOTHCLINEALLBLOCKS(SEG, BLOCK, WID, COL) uses the information in 
%    structures SEG and BLOCK to plot smoothly connected polygons of width
%    WID (km) and color specified by COL.  For example, to plot all segments
%    in the newest run directory, with polygons 10 km wide and colored by
%    strike slip rate, call:
%
%    >> seg = ReadSegmentTri([newdir 'Mod.segment']);
%    >> block = ReadBlock([newdir 'Mod.block']);
%    >> h = smoothclineallblocks(seg, block, 10, seg.ssRate);
%

% Run block label with dummy stations
[sta.lon, sta.lat] = deal(0);
[seg.midLon, seg.midLat] = deal(mean([seg.lon1(:) seg.lon2(:)], 2), mean([seg.lat1(:) seg.lat2(:)], 2));
[seg, block, sta] = BlockLabel(seg, block, sta);

nblocks = length(block.interiorLon);
inblocks = setdiff(1:nblocks, block.exteriorBlockLabel);

for i = inblocks
   blockArea(i) = areaint(block.orderLat{i}, block.orderLon{i}, almanac('earth','ellipsoid','kilometers'));
end

[~, inblocks] = sort(blockArea);

figure
h = zeros(nblocks, 1);
for j = 1:length(inblocks)
   i = inblocks(j);
   sib = union(find(seg.eastLabel == i), find(seg.westLabel == i));
   bs = structsubset(seg, sib);
   bs = OrderEndpoints(bs);
   bc = col(sib);
   i
   idx = orderblocksegs(bs, [block.orderLon{i}(1) block.orderLat{i}(1)]);
   bs = structsubset(bs, idx);
   bc = bc(idx);
   [sx, sy] = swathblockseg(bs, [block.orderLon{i}, block.orderLat{i}], wid);
   
   % Define the individual polygons' indices
   nseg = length(bs.lon1);
   pidx = [1:nseg; 2:nseg+1; fliplr(nseg+2:2*nseg+1); fliplr(nseg+3:2*nseg+2)];
   
   % Remove segments representing triangulated regions, if requested
   if exist('triexclude', 'var')
      triidx = find(bs.patchFile > 0);
      pidx(:, triidx) = [];
      bc(triidx) = [];
   end 

   % Make the plot
   h(j) = patch('vertices', [sx(:) sy(:)], 'faces', pidx', 'facevertexcdata', bc);
end
shading flat;