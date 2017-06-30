function [clus, Clus] = meshclusters(p, sel)
% meshclusters   Finds isolated clusters of selected elements.
%   meshclusters(P, SEL) finds clusters of elements within the 
%   patch structure P that are selected, as identified in vector
%   SEL, which contains indices of selected elements or is a 
%   logical array giving selected elements. The clusters' element
%   indices are returned to a cell. 
%
%   If all elements are selected in SEL, then the returned indices
%   are those of all elements. 
%

% Master control statement to detect whether or not any elements are even selected
if sum(sel) > 0

% Blank cluster index array
idx = zeros(0, 2); lidx = [];

% Find the bounding edges of the selected elements
el = boundedges(p.c, p.v(sel, :));

% Each cluster should be identified by circulating around edge nodes.
% A cluster is closed when the starting node is reached.
% If, along the way, a node is encountered more than once, it marks a "neck"

% Check to see if there are any "necked" clusters (meeting at a single vertex)
uel = unique(el(:));
nn = hist(el(:), uel)';
necks = [uel(find(nn > 2)), nn(find(nn > 2))];
necksegs = el(sum(ismember(el, necks(:, 1)), 2) > 0, :);
El = el;
elvec = 1:size(El, 1);

% Initial loop control: while any edges remain
while size(El, 1) > 2 % This 2 should never be encountered; it keeps the loop going even for single-element clusters
   % Make sure the first segment doesn't have a neck as its end point
   El = [setdiff(El, necksegs, 'rows'); necksegs];
   clusstart = El(1, :); % El gets updated with each advancement through the cluster; we take the first node
   elo = El(1, :); % This cluster's edges start with the first row of remaining edges
   k = 2; % Cluster row counter
   while elo(end, 2) ~= clusstart(1) % Keep advancing until we get back to the starting point 
     	[next, col] = find(El == elo(k-1, 2)); % find all of the boundary lines containing the second entry of the current ordered boundary line
		n = find(sum(El(next, :), 2) ~= sum(elo(k-1, :), 2)); % choose that which is not the current boundary line
 		next = next(n(1)); col = col(n(1));
   	if col == 1
	   	elo(k, :) = El(next, :);
	   else
		   elo(k, :) = El(next, [2 1]);
	   end 
  		k = k+1; % Increment cluster row counter
      El = setdiff(El, elo, 'rows'); % Update edges remaining
   end
   idx = [idx; elo]; % Update master cluster edge list
	lidx = [lidx; size(elo, 1)]; % Update number of edges in each cluster
   necksegs = setdiff(necksegs, idx, 'rows'); % Updated neck edges remaining
end

% Now loop through all cluster edges and find elements lying within
last = cumsum(lidx);
first = [1; last(1:end-1)+1];
if islogical(sel)
   sel = find(sel);
end
j = 1;
for i = 1:length(lidx)
   clu = intersect(sel, find(inpolygon(p.lonc, p.latc, p.c(idx(first(i):last(i), :), 1), p.c(idx(first(i):last(i), :), 2))));
   if ~isempty(clu)
      clus{j} = clu;
      First(j) = first(i);
      Last(j) = last(i); 
      j = j+1;
   end
end

% Make a cluster matrix
Clus = zeros(length(clus), sum(p.nEl));
for i = 1:length(clus)
   Clus(i, clus{i}) = 1;
end


% Update the cluster element counter to account for necks that weren't caught
% Combine necked clusters into one
if length(clus) > 1

	[~, necki] = ismember(idx, necks(:, 1));
	for i = 1:size(necks, 1) % For each neck point,
	    clear neckclus
		% Find which clusters the neck point belongs to
		neckr = find(necki(:, 1) == i); % Row index
		for j = 1:2 % Necks by default cannot be common among more than 2 clusters
		    neckfind = find(sum([neckr(j) >= First(:), neckr(j) <= Last(:)], 2) == 2);
		    if ~isempty(neckfind) % When a neck actually forms a hole, it's not separating two clusters
    			neckclus(j) = neckfind;
    		end
		end
		% Update the later cluster, since it will be checked by subsequent neck points
		if exist('neckclus', 'var')
    	   if length(neckclus) > 1
		      if diff(neckclus) ~= 0 && max(neckclus) <= numel(clus) % Second clause is so that empty clusters aren't used
			     Clus(neckclus(2), :) = Clus(neckclus(2), :) + Clus(neckclus(1), :);
		         Clus(neckclus(1), :) = Clus(neckclus(2), :); % Make a copy; we'll get rid of it later if need be
    	      end
    	   end   
		end
	end
	[~, keepclus] = unique(Clus, 'rows');
	if sum(keepclus) >= 1
		Clus = Clus(keepclus, :); % Take a subset of clusters
		for i = 1:size(Clus, 1)
		   cluscell{i} = find(Clus(i, :));
		end
	end
clus = cluscell;
end

else
% Blank arrays if no elements are even selected
clus = {};
Clus = zeros(0, sum(p.nEl));

end