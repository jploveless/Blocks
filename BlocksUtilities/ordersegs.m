function [idx, c] = ordersegs(s)
% ORDERSEGS  Places a subset of connected segments in order.
%   IDX = ORDERSEGS(S) uses the segment structure S, usually a 
%   subset of a total segment structure (as produced by STRUCTSUBSET)
%   and returns an array of indices into S giving the segments in 
%   west to east order, or in the case of "C" shaped faults, north
%   to south order.
%
%   [IDX, C] = ORDERSEGS(S) also outputs a nSeg-by-2 array C containing
%   unique ordered coordinates.

nseg = length(s.lon1);

% Make sure endpoints are ordered
s = OrderEndpointsSphere(s);
% Find common endpoints; conn gives each west endpoint's east counterpart
[junk, conn] = ismember([s.lon1(:) s.lat1(:)], [s.lon2(:) s.lat2(:)], 'rows');
west = find(conn == 0); % the segment whose west endpoint doesn't have an east match is the westernmost point
ww = west;
if length(west) > 1
   for i = 1:length(west)
      wc = ismember([s.lon1(:) s.lat1(:)], [s.lon1(west(i)), s.lat1(west(i))], 'rows');
      wc = find(wc); 
      wc = wc(find(wc - west(i)));
      if length(wc) > 0
         conn(west(i)) = wc;
         ww(i) = 0;
      end
   end
end
west = west(find(ww));
if length(west) > 1
   [junk, w] = min(s.lon1(west));
   west = west(w);
end
idx = west;
match = west;
se = 2;

if isempty(west)
   [junk, west] = max([s.lat1(:); s.lat2(:)]);
   [west, junk] = ind2sub([nseg, 2], west);
   idx = west;
   match = west;
   se = 1; % looking for a western endpoint now
end

allc                       = [[s.lon1(:) s.lat1(:)]; [s.lon2(:) s.lat2(:)]];
[cou, i1]					 	= unique(allc, 'rows', 'first');
[cou, i2]						= unique(allc, 'rows', 'last');

% Find unique points and indices to them
[unp, unidx, ui] = unique(allc, 'rows', 'first');
us = ui(1:nseg); ue = ui(nseg+1:end);

while length(idx) < nseg
   % establish starting coordinates
	cs = match; % current segment start
	cp = [us(cs) ue(cs)]; % current point: start point of the current segment
	cp = cp(se); % pick whether we're looking for a match of the start or endpoint
	
   matchss = (us == cp); % starts matching current
	matchss(cs) = 0;
	matchss = find(matchss);
	matches = (ue == cp); % ends matching current
	matches(cs) = 0;
	matches = find(matches);
  
   if isempty(matchss) % no starts were matched
      match = matches;
      idx = [idx; match];
      se = 1; % want to look for a starting point next time
   else
      match = matchss;
      idx = [idx; match];
      se = 2; % want to look for an ending point next time
   end
end

if nargout == 2
   c = zeros(2*nseg, 2);
   c(1:2:end, :) = [s.lon1(idx) s.lat1(idx)];
   c(2:2:end, :) = [s.lon2(idx) s.lat2(idx)];
   [~, i, j] = unique(c, 'rows', 'first');
   c = c(sort(i), :);
   if junk == 1
      ca = c;
      ca(1, :) = c(2, :);
      ca(2, :) = c(1, :);
      c = ca;
   end
end
   