function seg = autoextend(S, hdt, hat)

% Copy segment structure
s = S;
nseg = length(S.lon1);

% Primitive block label: group segments based on consecutive names
groups = zeros(nseg, 2);
pidx = regexp(S.name(1, :), 'part\d+', 'start');
basen = S.name(1, 1:pidx-1);
groups(1) = 1;
j = 1;
for i = 2:nseg
   pidx = regexp(S.name(i, :), 'part\d+', 'start');
   if strcmp(basen, S.name(i, 1:pidx-1));
      groups(j, 2) = i;
   else
      basen = S.name(i, 1:pidx-1);
      groups(j, 2) = i-1;
      j = j+1;
      groups(j, 1) = i;
   end
end
groups(groups(:, 1) == 0, :) = [];
groups(end) = nseg;
%
%% Run an intersection check, getting rid of very short overlaps
%for i = 1:nseg
%   [ilat, ilon, inseg1, inseg2] = gcisect(s.lat1(i), s.lon1(i), s.lat2(i), s.lon2(i),...
%                                          s.lat1, s.lon1, s.lat2, s.lon2);
%   iidx = 1:nseg;
%   inseg1(i) = 0; inseg2(i) = 0;
%   ilat = ilat(inseg1 & inseg2);
%   ilon = ilon(inseg1 & inseg2);
%   iidx = iidx(inseg1 & inseg2);
%   % Get rid of the intersection point that is the hanging point's segment's other endpoint
%   depa1 = abs(ilat - s.lat1(i));
%   depo1 = abs(ilon - s.lon1(i));
%   depa2 = abs(ilat - s.lat2(i));
%   depo2 = abs(ilon - s.lon2(i));
%   oep = min(depa1 + depo1) > 1e-6 | min(depa2 + depo2) > 1e-6;
%   ilat = ilat(oep);
%   ilon = ilon(oep);
%   iidx = iidx(oep);
%   % Get rid of any intersection points within segments part of the continuous trace
%   gidx = find(groups(:, 1) <= i, 1, 'last');
%   tr = iidx >= groups(gidx, 1) & iidx <= groups(gidx, 2);
%   ilat = ilat(~tr);
%   ilon = ilon(~tr);
%   iidx = iidx(~tr);
%   if length(iidx) > 1
%      keyboard
%   end
%   % Lengths of the overlaps
%   od1 = distance(ilat, ilon, s.lat1(i), s.lon1(i));
%   od2 = distance(ilat, ilon, s.lat2(i), s.lon2(i));
%   odr = od1./od2; % ratio of overlap lengths
%   % If distance from intersection to endpoint 1 is twice (or more) the length of the
%   % distance to endpoint 2, reassign endpoint 2 to be the intersection
%   if odr >= 10
%      S.lat2(i) = ilat; 
%      S.lon2(i) = ilon;
%   % If distance from intersection to endpoint 2 is twice (or more) the length of the
%   % distance to endpoint 1, reassign endpoint 1 to be the intersection
%   elseif odr <= 0.1
%      S.lat1(i) = ilat; 
%      S.lon1(i) = ilon;
%   end
%end   
%keyboard

% Check for hanging endpoints
lonVec = [S.lon1(:); S.lon2(:)];
latVec = [S.lat1(:); S.lat2(:)];
[uCoord1 uIdx1] = unique([lonVec latVec], 'rows', 'first');
[uCoord2 uIdx2] = unique([lonVec latVec], 'rows', 'last');
nOccur = uIdx2-uIdx1 + 1;
hang = nOccur == 1;
hangidx = uIdx1(hang);
sidx = hangidx;
ep1 = sidx <= nseg; % hanging point is endpoint 1
ep2 = sidx > nseg; % hanging point is endpoint 2
sidx(ep2) = sidx(ep2) - nseg; % segment index of hanging points
% Pre-split single segments with both hanging endpoints



hanglon = S.lon1(sidx); hanglon(ep2) = S.lon2(sidx(ep2));
hanglat = S.lat1(sidx); hanglat(ep2) = S.lat2(sidx(ep2));
[hangdist, hangaz] = distance((ep2.*S.lat1(sidx) + ep1.*S.lat2(sidx)),...
                              (ep2.*S.lon1(sidx) + ep1.*S.lon2(sidx)),...
                              (ep1.*S.lat1(sidx) + ep2.*S.lat2(sidx)),...
                              (ep1.*S.lon1(sidx) + ep2.*S.lon2(sidx)));

% Make blank segment fields
newseg.lon1 = zeros(length(sidx), 1);
newseg.lat1 = newseg.lon1; 
newseg.lon2 = newseg.lon1;
newseg.lat2 = newseg.lon1;
newseg.dip = newseg.lon1;
newseg.lDep = newseg.lon1;
newseg.name = repmat(' ', length(sidx), 200);
validhang = ones(length(sidx), 1);

% Threshold score
tscore = 10./hdt - hat;

% Empty matrix for deleting split segments
ds = [];

% Extend hanging endpoints
for i = 1:316%length(hangidx)
%   if validhang(i) == 1 % check to see if this point has been handled yet (by a previous extension)
      % Check to see if any other hanging points are closer, within threshold degrees of strike
      [sdis, saz] = distance(hanglat(i), hanglon(i), hanglat, hanglon);
      sdis(i) = 9999; saz(i) = 9999; % Replace self zeros with crazy values
      hscore = 10./sdis - abs(saz - hangaz(i));
      [hmax, hidx] = max(hscore);
      
      % Find intersection coordinates with all other segments
      sd = setdiff(1:nseg, sidx(i));
      % Change intersections back to capital S
      [ilat, ilon, inseg1, inseg2] = gcisect(S.lat1(sidx(i)), S.lon1(sidx(i)), S.lat2(sidx(i)), S.lon2(sidx(i)),...
                                             S.lat1(sd), S.lon1(sd), S.lat2(sd), S.lon2(sd));
      iidx = sd;
      % Check to see if this hanging point is worth extending, or if the segment intersects
      % another segment very nearby (short, intersecting hanger)
      in = find(inseg1 & inseg2);
      % Distance to other endpoint
      od1 = distance(ilat(in), ilon(in), (ep2(i)*S.lat1(sidx(i)) + ep1(i)*S.lat2(sidx(i))), (ep2(i)*S.lon1(sidx(i)) + ep1(i)*S.lon2(sidx(i))));
      % Distance to hanging endpoint
      od2 = distance(ilat(in), ilon(in), (ep1(i)*S.lat1(sidx(i)) + ep2(i)*S.lat2(sidx(i))), (ep1(i)*S.lon1(sidx(i)) + ep2(i)*S.lon2(sidx(i))));
      odr = od1./od2; % ratio of overlap lengths
      % If distance from an intersection to the other endpoint is more than twice the 
      % distance to the hanging endpoint, reassign hanging endpoint to be that intersection
      [mxodr, odridx] = max(odr);
      if mxodr >= 2
         in = in(odridx);
         if ep1(i)
            s.lat1(sidx(i)) = ilat(in);
            s.lon1(sidx(i)) = ilon(in);
         else   
            s.lat2(sidx(i)) = ilat(in); 
            s.lon2(sidx(i)) = ilon(in);
         end
         if ~ismember([s.lon2(iidx(in)), s.lat2(iidx(in))], [hanglon hanglat], 'rows')
            s = CopySegmentProp(s, iidx(in), strcat(s.name(iidx(in), :), 'b'), ilon(in), ilat(in), s.lon2(iidx(in)), s.lat2(iidx(in)));
            ds = [ds; iidx(in)];
         end
         if ~ismember([s.lon1(iidx(in)), s.lat1(iidx(in))], [hanglon hanglat], 'rows')
            s = CopySegmentProp(s, iidx(in), strcat(s.name(iidx(in), :), 'a'), s.lon1(iidx(in)), s.lat1(iidx(in)), ilon(in), ilat(in));
            ds = [ds; iidx(in)];
         end
%         keyboard
         inseg1 = logical(ones(length(sd), 1));
      end
      
      % Get rid of the intersection points that are within the hanging point's segment and are not within another segment
      ilat = ilat(~inseg1 & inseg2);
      ilon = wrapTo360(ilon(~inseg1 & inseg2));
      iidx = iidx(~inseg1 & inseg2);
      % Get rid of the intersection point that is the hanging point's segment's other endpoint
      depa = abs(ilat - (ep2(i)*S.lat1(sidx(i)) + ep1(i)*S.lat2(sidx(i))));
      depo = abs(ilon - (ep2(i)*S.lon1(sidx(i)) + ep1(i)*S.lon2(sidx(i))));
      oep = (depa + depo) > 1e-6;
      ilat = ilat(oep);
      ilon = ilon(oep);
      iidx = iidx(oep);
      % Get rid of any intersection points within segments part of the continuous trace
      gidx = find(groups(:, 1) <= sidx(i), 1, 'last');
      ftr = sd >= groups(gidx, 1) & sd <= groups(gidx, 2);
      tr = iidx >= groups(gidx, 1) & iidx <= groups(gidx, 2);
      ilat = ilat(~tr);
      ilon = ilon(~tr);
      iidx = iidx(~tr);
      % Get rid of any intersection points not in the segment projection toward the hanging point
      iaz = azimuth(hanglat(i), hanglon(i), ilat, ilon);
      ca = abs(hangaz(i) - iaz) < 1;
      ilat = ilat(ca);
      ilon = ilon(ca);
      iidx = iidx(ca);
      
      if ~isempty(iidx)
         % Find distance between the hanging endpoint and the segment intersections
         dis = distance(hanglat(i), hanglon(i), ilat, ilon);
         iscore = 10./dis;
         % Minimum distance gives closest intersection and new endpoint
         [mmax, midx] = max(iscore);
      else
         mmax = -9999;
      end
      
      if mmax > hmax
         newseg.lon1(i) = hanglon(i);
         newseg.lon2(i) = ilon(midx);
         newseg.lat1(i) = hanglat(i);
         newseg.lat2(i) = ilat(midx);
         newseg.dip(i) = S.dip(sidx(i));
         newseg.lDep(i) = S.lDep(sidx(i));
         sname = [strtrim(S.name(sidx(i), :)) '_extend'];
         newseg.name(i, 1:length(sname)) = sname;
         % Split the segment hosting the intersection
         s = CopySegmentProp(s, iidx(midx), strcat(s.name(iidx(midx), :), 'b'), ilon(midx), ilat(midx), S.lon2(iidx(midx)), S.lat2(iidx(midx)));
         s = CopySegmentProp(s, iidx(midx), strcat(s.name(iidx(midx), :), 'a'), S.lon1(iidx(midx)), S.lat1(iidx(midx)), ilon(midx), ilat(midx));
         ds = [ds; iidx(midx)];
      else
         if hmax > tscore
            % Choose the nearest other hanging point (no split required)
            newseg.lon1(i) = hanglon(i);
            newseg.lon2(i) = hanglon(hidx);
            newseg.lat1(i) = hanglat(i);
            newseg.lat2(i) = hanglat(hidx);
            newseg.dip(i) = S.dip(sidx(i));
            newseg.lDep(i) = S.lDep(sidx(i));
            sname = [strtrim(S.name(sidx(i), :)) '_extend'];
            newseg.name(i, 1:length(sname)) = sname;
            validhang(hidx) = 0;
         end
      end
%         clf; line([s.lon1'; s.lon2'], [s.lat1'; s.lat2'], 'color', 'r'); pause(0.2); drawnow
%         i

%   end
end
newseg.name = newseg.name(:, 1:size(S.name, 2));
dse = find(sum(abs([newseg.lon1 newseg.lat1 newseg.lon2 newseg.lat2]), 2) ~= 0);
newseg = structsubset(newseg, dse);
keyboard
S = DeleteSegment(S, [ds; dse]);
nsegn = length(S.lon1);
seg = structmath(S, newseg, 'vertcat');
nsegnn = length(seg.lon1);
segleng = distance(seg.lat1, seg.lon1, seg.lat2, seg.lon2);
ds = [];

% Now traverse introduced segments to find intersections and correct them
for i = nsegn+1:nsegnn 
   oh = setdiff(nsegn+1:nsegnn, i);
   [ilat, ilon, inseg1, inseg2] = gcisect(seg.lat1(i), seg.lon1(i), seg.lat2(i), seg.lon2(i),...
                                          seg.lat1(oh), seg.lon1(oh), seg.lat2(oh), seg.lon2(oh));
   ilon = wrapTo360(ilon);
   reali = inseg1 & inseg2 & sum(abs([ilat ilon] - [seg.lat1(oh) seg.lon1(oh)]), 2) > 1e-4 & sum(abs([ilat ilon] - [seg.lat2(oh) seg.lon2(oh)]), 2) > 1e-4;
   if ~isempty(find(reali))
      ci = [i; oh(reali)']; % combined indices
      [~, dom] = min(segleng(ci)); % Dominant segment is the shortest one
      % Set all other lon2, lat2 coordinates to be the intersections
      adj = setdiff(ci, ci(dom));
      seg.lon2(adj) = ilon(find(reali));
      seg.lat2(adj) = ilat(find(reali));
      % Split the dominant segment
      seg = CopySegmentProp(seg, ci(dom), strcat(seg.name(ci(dom), :), 'b'), ilon(find(reali)), ilat(find(reali)), seg.lon2(ci(dom)), seg.lat2(ci(dom)));
      seg = CopySegmentProp(seg, ci(dom), strcat(seg.name(ci(dom), :), 'a'), seg.lon1(ci(dom)), seg.lat1(ci(dom)), ilon(find(reali)), ilat(find(reali)));
   end
end

