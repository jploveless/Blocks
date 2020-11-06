function [s, b, st] = BlockLabel(s, b, st)
%

nseg = numel(s.lon1);

% make sure western vertex is the start point
[segx, i] = sort([s.lon1(:) s.lon2(:)], 2);
segy = [s.lat1(:) s.lat2(:)];
i = (i-1)*nseg + repmat((1:nseg)', 1, 2);
segy = segy(i);

% make sure there are no hanging segments
allc 								= [segx(:) segy(:)];
allc                       = [[s.lon1(:) s.lat1(:)]; [s.lon2(:) s.lat2(:)]];
[cou, i1]					 	= unique(allc, 'rows', 'first');
[cou, i2]						= unique(allc, 'rows', 'last');
if isempty(~find(i2-i1, 1))
	fprintf(1, '*** All blocks are not closed! ***\n');
else
	fprintf(1, 'No hanging segments found');
end

% Carry out a few operations on all segments

% Find unique points and indices to them
[unp, unidx, ui] = unique(allc, 'rows', 'first');
us = ui(1:nseg); ue = ui(nseg+1:end);

% Calculate the azimuth of each fault segment
% Using atan instead of azimuth because azimuth breaks down for very long segments
az1 = rad2deg(atan2(segx(:, 1) - segx(:, 2), segy(:, 1) - segy(:, 2)));
az2 = rad2deg(atan2(segx(:, 2) - segx(:, 1), segy(:, 2) - segy(:, 1)));
az = [az2 az1];
az(az < 0) = az(az < 0) + 360;

% Declare array to store polygon segment indices
poly_ver                   = zeros(1, nseg);
trav_ord                   = poly_ver;
seg_poly_ver               = zeros(nseg);
seg_trav_ord					= seg_poly_ver;


for i = 1:nseg
	% establish starting coordinates
	cs = i; % current segment start
	cp = us(i); % current point: start point of the current segment
	se = 1; % flag indicating that it's looking towards ending point
   starti = cs; % index of the starting point
   seg_cnt = 1;
	
	clear poly_vec trav_ord
	
   while 1
		matchss = (us == cp); % starts matching current
		matchss(cs) = 0;
		matchss = find(matchss);
		matches = (ue == cp); % ends matching current
		matches(cs) = 0;
		matches = find(matches);

      match = [matchss; matches];
      
      % If it's a multiple intersection, find which path to take
      if numel(match) > 1
      	daz = az(cs, se) - [az(matchss, 2); az(matches, 1)];
         daz(find(abs(daz) > 180)) = daz(find(abs(daz) > 180)) - sign(daz(find(abs(daz) > 180)))*360;
         [maz, mi] = max(daz);
      else
         mi = 1;
      end
      match = match(mi);
      
      % Determine the new starting point
      cs = match; % current index
      if mi <= numel(matchss) % if the index is a start-current match
      	cp = ue(cs); % the new point is the match's ending point
      	se = 2; % looking towards the start point
      else
      	cp = us(cs); % otherwise it's the match's starting point
      	se = 1; % looking towards the end point
      end

      % Prevent endless loops
      if seg_cnt > nseg
      	disp(sprintf('Cannot close block starting with segment: %s', s.name(starti, :)))
   break;
      end
      
      % Break upon returning to the starting segment
      if match == starti && seg_cnt > 1
         seg_cnt              = 1;
         poly_vec             = [poly_vec, starti];
         trav_ord             = [trav_ord, se];
   break;
      else
         poly_vec(seg_cnt)    = cs;
         trav_ord(seg_cnt)    = se;
         seg_cnt              = seg_cnt + 1;
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%  Put poly_vec into seg_poly_ver                     %%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   seg_poly_ver(i, 1:length(poly_vec)) = poly_vec;
   seg_trav_ord(i, 1:length(trav_ord)) = trav_ord;
end	

% Determine the unique block polygons
[so, blockrows] = unique(sort(seg_poly_ver, 2), 'rows');
seg_poly_ver = seg_poly_ver(blockrows, :);
seg_trav_ord = seg_trav_ord(blockrows, :);
z = find(so == 0);
so(z) = NaN;
so = sort(so, 2);
[so, blockrows] = sortrows(so);
seg_poly_ver = seg_poly_ver(blockrows, :);
seg_trav_ord = seg_trav_ord(blockrows, :);

% Determine number of blocks
nblock = size(seg_poly_ver, 1);

% Calculate block area and label each block
%bcx = zeros(nblock, nseg); % make an array for holding the circulation coordinates
%bcy = bcx;
barea = zeros(nblock, 1);
alabel = zeros(nblock, 1);
ext = 0;

el = zeros(nseg, 1);
wl = el;
stl = zeros(numel(st.lon), 1);
dLon = 1e-6;


for i = 1:nblock
	% Take block coordinates from the traversal order matrix
	sib = seg_poly_ver(i, (seg_poly_ver(i, :) ~= 0)); % segments in block
	ooc = seg_trav_ord(i, (seg_trav_ord(i, :) ~= 0)); % order in which the segments are traversed
	cind = (ooc-1)*nseg + sib; % convert index pairs to linear index
%  bcx(i, 1:numel(cind)) = segx(cind);
%	bcy(i, 1:numel(cind)) = segy(cind);
   bcx = segx(cind)';
   bcy = segy(cind)';
   barea(i) = polyarea(bcx, bcy);
	% Test which block interior points lie within the current circulation
	bin = inpolygon(b.interiorLon, b.interiorLat, bcx, bcy);
   % Now test the segments for labeling east and west sides
   testlon = s.midLon(sib) + dLon; % perturbed midpoint longitude
   cin = inpolygon(testlon, s.midLat(sib), bcx, bcy); % test to see which perturbed coordinates lie within the current block
   % Now test the station coordinates for block identification
   stin = inpolygon(st.lon, st.lat, bcx, bcy);   
	if numel(find(bin)) > 1 % exterior block or error
      if barea(i) == max(barea) && ext == 0 % if the area is the largest and exterior hasn't yet been assigned
	      alabel(find(~bin)) = i; % ...assign this block as the exterior
   	   ext = i; % and specifically declare the exterior label
   	elseif ext > 0
   		disp('Interior points do not uniquely define blocks!')
         break;
      end
   else % if there is only one interior point within the segment polygon (i.e., all other blocks)...
      alabel(find(bin)) = i; % assign that block associate label to the current block
      el(sib(cin > 0)) = i; % segments within the polygon are assigned this block as their east label
      wl(sib(cin == 0)) = i; % those that don't are assigned this block as their west label
      stl(stin > 0) = i; % associate stations with the block
   end

   % Add ordered polygons to the blocks structure
   b.orderLon{i} = bcx;
   b.orderLat{i} = bcy;
   
end

if ext == 0 % Special case for a single block
   ext = 2;
   alabel = [1 2];
end

% treat exterior block segment labels - set exterior block for yet undefined segment labels
el(el == 0) = ext;
wl(wl == 0) = ext;
% treat exterior block stations
stl(stl == 0) = ext;

% Final outputs
s.eastLabel = el;
s.westLabel = wl;

[st.blockLabel, st.blockLabelUnused] = deal(stl);
% Reorder block properties
b = BlockReorder(alabel, b);
b.associateLabel = alabel;
b.exteriorBlockLabel = ext;

