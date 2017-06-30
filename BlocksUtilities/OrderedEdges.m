function elo = OrderedEdges(c, v);
% OrderedEdges returns the edges 
el = boundedges(c, v);
elo = [el(1, :)];
for i = 2:length(el);
	[next, col] = find(el == elo(i-1, 2)); % find all of the boundary lines containing the second entry of the current ordered boundary line
	n = find(sum(el(next, :), 2) ~= sum(elo(i-1, :), 2)); % choose that which is not the current boundary line
	next = next(n); col = col(n); 
	elo = [elo; [el(next, col) el(next, setdiff([1 2], col))]]; % order the endpoints of the next boundary line
end
elo = elo';