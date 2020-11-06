function gn = cleanpartials(g, p, thresh)



% Find shared sides
share = SideShare(p.v);
sharev = share > 0;
share(share == 0) = 1;

% Make a matrix whose rows containt the averages of neighboring elements' values
szg = size(g);
gc = NaN(szg);
gc1 = gc; gc2 = gc; gc3 = gc;

for i = 1:size(share, 1)
   sv = repmat(sharev(i, :), szg(1), 1);
   gc(:, 3*i-2) = median(g(:, 3*share(i, sharev(i, :))-2), 2);
   gc(:, 3*i-1) = median(g(:, 3*share(i, sharev(i, :))-1), 2);
   gc(:, 3*i-0) = median(g(:, 3*share(i, sharev(i, :))-0), 2);
   gc1(:, 3*i-2) = g(:, 3*share(i, 1)-2);
   gc1(:, 3*i-1) = g(:, 3*share(i, 1)-1);
   gc1(:, 3*i-0) = g(:, 3*share(i, 1)-0);
   gc2(:, 3*i-2) = g(:, 3*share(i, 2)-2);
   gc2(:, 3*i-1) = g(:, 3*share(i, 2)-1);
   gc2(:, 3*i-0) = g(:, 3*share(i, 2)-0);
   gc3(:, 3*i-2) = g(:, 3*share(i, 3)-2);
   gc3(:, 3*i-1) = g(:, 3*share(i, 3)-1);
   gc3(:, 3*i-0) = g(:, 3*share(i, 3)-0);
end

% Replace outliers
t1 = abs(g./gc1) >= thresh;
t2 = abs(g./gc2) >= thresh;
t3 = abs(g./gc3) >= thresh;
ts = t1 + t2 + t3;
% Make sure that bad elements don't share a side with other bad elements
[r, c] = find(ts >= 2);
correl = unique(ceil(c/3));
for i = 1:length(correl)
   loc = ismember(sharev(correl(i), :).*share(correl(i), :), correl);
   sv = repmat(sharev(correl(i), ~loc), szg(1), 1);
   gc(:, 3*correl(i)-2) = median(g(:, 3*share(correl(i), ~loc)-2), 2);
   gc(:, 3*correl(i)-1) = median(g(:, 3*share(correl(i), ~loc)-1), 2);
   gc(:, 3*correl(i)-0) = median(g(:, 3*share(correl(i), ~loc)-0), 2);
end
gn = g;
gn(ts >= 2) = gc(ts >= 2);
keyboard