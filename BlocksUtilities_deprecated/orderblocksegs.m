function idx = orderblocksegs(s, bc1)
% ORDERBLOCKSEGS  Places a block's segments in order.
%   IDX = ORDERBLOCKSEGS(S) uses the segment structure S, which is a 
%   subset of a total segment structure describing a block (as produced
%   by STRUCTSUBSET) and returns an array of indices into S giving the 
%   segments in sequential order.  The beginning segment is arbitrarily
%   assigned to be the first segment in the unordered input list.
%
%   IDX = ORDERSEGS(S, BC1) will start the ordering at the segment whose
%   westernmost endpoint coordinates are [BC1(1) BC1(2)].
%

nseg = length(s.lon1);

% Make sure endpoints are ordered
s = OrderEndpointsSphere(s);

% Find the first endpoint, arbitrary or specified
if ~exist('bc1', 'var')
   west = 1;
else
   [junk, west1] = ismember(bc1, [s.lon1(:) s.lat1(:)], 'rows');
   [junk, west2] = ismember(bc1, [s.lon2(:) s.lat2(:)], 'rows');
   west = [west1 west2];
   west = west(find(west, 1));
end

allc                       = [[s.lon1(:) s.lat1(:)]; [s.lon2(:) s.lat2(:)]];
[cou, i1]					 	= unique(allc, 'rows', 'first');
[cou, i2]						= unique(allc, 'rows', 'last');

% Find unique points and indices to them
[unp, unidx, ui] = unique(allc, 'rows', 'first');
us = ui(1:nseg); ue = ui(nseg+1:end);


idx = west;
match = west;
se = 2;
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

