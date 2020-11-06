function [pred, corrected] = remove_ramp(map_long, map_lat, data);

or=-map_lat.*3-mean(-map_lat(:).*3);
ab=-map_long-mean(-map_long(:));
g = find(isnan(data) == 0);
num = size(or,1)*size(or,2);
G = [or(:) ab(:) or(:).*ab(:) or(:).^2 ab(:).^2 ones(num,1)];
m = [or(g) ab(g) or(g).*ab(g) or(g).^2 ab(g).^2 ones(size(g))]\(data(g));

p = G*m;
pred = reshape(p,size(or,1),size(or,2));
corrected = data-pred;