function varargout = SmoothEdges(share, p, s, dslip, c)
%
% SmoothEdges creates the smoothing matrix allowing the mesh edges
% that are adjacent to rectangular patches to be smoothed, as well 
% as the elements wholly within the mesh.
%
%  Inputs:
%
%     share    = array of indices of adjacent elements
%     p        = patch structure
%     s        = segment structure
%     dslip    = matrix of slip partial derivatives
%     c        = command structure
%
%  Outputs:
%     Either:
%     Wn       = new smoothing matrix
%     [w, ws]  = new components of smoothing matrix (triangular and segment, such that Wn = [ws w])
%

elOrd                                        = [0; cumsum(p.nEl)];
coOrd                                        = [0; cumsum(p.nc)];

updips                                       = [];
downdips                                     = [];

if isfield(s, 'centLon') == 0
   s                                         = SegCentroid(s);
end
scoords                                      = [s.lon1(:) s.lat1(:); s.lon2(:) s.lat2(:)]; 

adjIndex                                     = [];
edge                                         = [];
edists                                       = [];
nEdgeEl                                      = [];

ws                                           = zeros(3*elOrd(end), size(dslip, 2));
dists                                        = TriDistCalc(share, p.xc, p.yc, p.zc); % calculate distance between element centroids and neighbors

% make the regular smoothing matrix
w                                            = MakeTriSmooth(share, dists);
% weight the smoothing matrix by the constants beta
beta                                         = zeros(3*length(p.v), 1);
cnel                                         = [0; cumsum(p.nEl)];
for i = 1:numel(p.nEl)
   dist                                      = dists(cnel(i)+1:cnel(i+1), :);
   distScale                                 = mean(dist(find(dist)));
   beta(3*(cnel(i)+1)-2:3*cnel(i+1))         = distScale^2*c.triSmooth(i);
end

if c.smoothEdge == 1
   for i = 1:numel(p.nEl);
      elRange                                   = elOrd(i)+1:elOrd(i+1);
      coRange                                   = coOrd(i)+1:coOrd(i+1);
      patchSegs                                 = intersect(find(s.patchFile == i), find(s.patchTog > 0)); % determine which segments belong to the patch
      if ~isempty(patchSegs)
         % Create coordinate arrays of the segment end points for this patch
         patchSegsLons                             = [s.lon1(patchSegs(:)); s.lon2(patchSegs(:))];
         patchSegsLats                             = [s.lat1(patchSegs(:)); s.lat2(patchSegs(:))];
         patchSegsCoords                           = [patchSegsLons(:) patchSegsLats(:)];
         [uc, ucInd1]                              = unique(patchSegsCoords, 'rows', 'first');
         [uc, ucInd2]                              = unique(patchSegsCoords, 'rows', 'last');
         endInd                                    = round(ucInd1(find(ucInd2-ucInd1 == 0))/2);
         endCoords                                 = patchSegsCoords(ucInd1(find(ucInd2-ucInd1 == 0)), :);
         % find the segments adjacent to these end point segments, i.e., those that share the endpoints
         comPts                                    = find(ismember(scoords, endCoords, 'rows'));
         comPts(comPts > length(s.lon1))           = comPts(comPts > length(s.lon1)) - length(s.lon1);
         adjInd                                    = setdiff(comPts, patchSegs);
         % Determine which triangular elements are closest to the adjacent segment, picking only elements that line the perimeter
         [perim, col]                              = find(share(elRange, :) == 0);
         perim                                     = elOrd(i) + unique(perim);
         % find updip edge
         zeroZ                                     = coOrd(i) + find(p.c(coRange, 3) == max(p.c(coRange, 3)));
         % find those elements having two zero-depth coordinates
         updip                                     = elOrd(i) + find(sum(ismember(p.v(elRange, :), zeroZ), 2) == 2);
         % find the deepest coordinates
         maxZ                                      = coOrd(i) + find(p.c(coRange, 3) == min(p.c(coRange, 3)));
         % find those elements having two max. depth coordinates
         downdip                                   = elOrd(i) + find(sum(ismember(p.v(elRange, :), maxZ), 2) == 2);
         % Lateral edges are those perimeter elements that do not belong to either the updip or downdip elements
         edges                                     = setdiff(perim, [updip(:); downdip(:)]);
         edge                                      = [edge; edges];
         % Need to decide which segment a given edge element lies closest to
         [sedists, nEdgeInd]                       = min([sqrt((s.centx(adjInd(1)) - p.xc(edges)).^2 + (s.centy(adjInd(1)) - p.yc(edges)).^2 + (s.centz(adjInd(1)) - p.zc(edges)).^2) ...
                                                          sqrt((s.centx(adjInd(2)) - p.xc(edges)).^2 + (s.centy(adjInd(2)) - p.yc(edges)).^2 + (s.centz(adjInd(2)) - p.zc(edges)).^2)], [], 2);
         edists                                    = [edists; sedists];
         nEdgeEl                                   = [nEdgeEl; adjInd(nEdgeInd)];
      end
   end
   
   % Make a smoothing matrix that incorporates the adjacent segments
   for i = 1:length(edge);
      zcol                                      = find(dists(edge(i), :) == 0, 1);
      dists(edge(i), zcol)                      = edists(i);  % place the element-segment distance values into appropriate rows
   end
   
   % make the segment "smoothing" matrix - not really smoothing, but equating of element and segment velocities
   for i = 1:length(edge);
      ws(3*edge(i)-2:3*edge(i), :)              = dslip(3*nEdgeEl(i)-2:3*nEdgeEl(i), :);
      % add -1 values to the edge elements
      dent                                      = 3*edge(i) - [2 1 0];
      w(dent(1), dent(1))                       = w(dent(1), dent(1))-1;
      w(dent(2), dent(2))                       = w(dent(2), dent(2))-1;
      w(dent(3), dent(3))                       = w(dent(3), dent(3))-1;
      beta(dent(1))                             = edists(i).^2*beta(dent(1));
      beta(dent(2))                             = edists(i).^2*beta(dent(2));
      beta(dent(3))                             = edists(i).^2*beta(dent(3));
   end
end

% assemble final smoothing matrix, if requested
if nargout == 1
   Wn                                        = [ws w];
   varargout                                 = Wn;
elseif nargout == 2
   varargout{1}                              = w;
   varargout{2}                              = ws;
elseif nargout == 3
   varargout{1}                              = w;
   varargout{2}                              = ws;
   varargout{3}                              = beta;
end