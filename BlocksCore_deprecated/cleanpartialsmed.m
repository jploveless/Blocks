function g = cleanpartialsmed(g, p, threshv, threshd)

p = PatchCoordsx(p);

% Make a matrix whose rows contain the median of neighboring elements' values
szg = size(g);
gc = NaN(szg(1), 3);
dists = NaN(p.nEl, 1);

for i = 1:p.nEl
   dists = mag([p.xc - p.xc(i), p.yc - p.yc(i), p.zc - p.zc(i)], 2);
   selel = dists <= threshd | dists ~= 0;
   
   gc = [median(g(:, 3*selel-2), 2), median(g(:, 3*selel-1), 2), median(g(:, 3*selel-0), 2)];
   bad = abs(g(:, 3*i - [2 1 0]) - gc) >= threshv;
   g(bad) = gc(bad);
end
