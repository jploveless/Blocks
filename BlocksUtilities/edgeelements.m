function [els, nodes] = edgeelements(c, v, strthresh)
% EDGEELEMENTS  Finds elements lining the edge of a mesh.
%   [elements, nodes] = EDGEELEMENTS(c, v, thresh) finds the 
%   indices of elements lining the edges of the mesh defined by 
%   coordinate array c and vertex ordering array v, returning the 
%   indices to top, bot, s1, and s2. This algorithm does not rely on 
%   finding the tops and bottoms based on nodes lying at a particular 
%   depth, instead relying on finding abrupt changes in the trends of 
%   the mesh edges, set by optional third argument thresh (the default
%   is 55 degrees). This makes it more suitable for meshes that have 
%   irregular depth top traces (such as subduction trenches) and/or are
%   not generated based on a set of depth contours.
%
% 

% Define default strike change threshold
if ~exist('strthresh', 'var')
   strthresh = 55;
end

% Allocate space for edge matrices
[els.top, els.bot, els.s1, els.s2] = deal([]);
[nodes.top, nodes.bot, nodes.s1, nodes.s2] = deal([]);

% Get ordered edge coordinates
elo = OrderedEdges(c, v);
% Use ordered coordinates to calculate angles between adjacent edges
elo = [elo(1, :) elo(1, 1)];
[x, y, z] = sph2cart(deg_to_rad(c(elo, 1)), deg_to_rad(c(elo, 2)), 6371+(c(elo, 3)));
edgevecs = [x(2:end)-x(1:end-1), y(2:end)-y(1:end-1), z(2:end)-z(1:end-1)];

% Calculate difference in angles of adjacent edges
dstr = acosd(dot(edgevecs(1:end, :), edgevecs([end, 1:end-1], :), 2)./(mag(edgevecs(1:end, :), 2).*mag(edgevecs([end, 1:end-1], :), 2)));

% Find sharp angles; these are mesh corners. These are indices into elo.
corn = find(abs(dstr) > strthresh & abs(dstr) < (360-strthresh));
corn = [corn; corn(1)]-1;


% Need to do this after distinguishing lateral edges from top and bottom
% Check adjacent edges: should exceed threshold for true corners 

% Use corner indices to separate edges. Make inherent assumption that the top and bottom are longer than the sides
dcorn = diff(corn);
% Address negative index differences by adding size of elo
% Adjusted corners, just for differencing
corna = corn;
% Find the negative difference and add size of elo to all subsequent corner indices
corna(find(dcorn < 0, 1)+1:end) = corna(find(dcorn < 0, 1)+1:end) + size(elo, 2);
dcorn = diff(corna);
edgeend = cumsum(dcorn); edgeend(end) = edgeend(end) - 1;
edgebeg = [1; edgeend(1:end-1)];
[~, sidx] = sort(dcorn); % Get the indices of the longer edges

% Loop through and find the elements along each edge
for j = 1:length(dcorn)
   % Indices of all coordinates along this edge
   eidx = 1+(corn(j):corn(j+1));
   if isempty(eidx) % This happens when the second index is less than the first index
      eidx = 1+[(corn(j)):(length(elo)-2), 0:corn(j+1)];
   end
   % Find elements that contain at least 2 of these coordinates
   eedge = sum(ismember(v, elo(eidx)), 2) >= 2;

% Check edge indices, and check whether any entries of corn lie between 2 others
% But then need to rerun with a revised corn

   % Assign to distinct edges
   if ismember(j, sidx(1:2)) % Working on a side 
      if isempty(els.s1)
         els.s1 = eedge;
         nodes.s1 = elo(eidx);
      else
         els.s2 = eedge;
         nodes.s2 = elo(eidx);
      end
   else
      % Working on a top or bottom, so let's test the depth of the corner
      if c(elo(corn(j)+1), 3) < mean(c(elo, 3)) % If it's deeper than the mean edge depth,
         els.bot = logical(sum([els.bot, eedge], 2)); % it's the bottom edge
         nodes.bot = [nodes.bot, elo(eidx)];
      else % Else it's the top edge
         els.top = logical(sum([els.top, eedge], 2));
         nodes.top = [nodes.top, elo(eidx)];
      end
   end
end

