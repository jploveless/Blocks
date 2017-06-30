function showsnapsegments(s, S, p);

fn = figure;
meshview(p.c, p.v, fn);
aa = axis; 
hold on;
line([s.lon1'; s.lon2'], [s.lat1'; s.lat2'], 'color', 0.75*[1 1 1]);
%line([S.lon1'; S.lon2'], [S.lat1'; S.lat2'], 'color', 'r');
[~, newseg] = setdiff([S.lon1, S.lon2, S.lat1, S.lat2], [s.lon1 s.lon2 s.lat1 s.lat2], 'rows');
line([S.lon1(newseg)'; S.lon2(newseg)'], [S.lat1(newseg)'; S.lat2(newseg)'], 'color', 'r', 'linewidth', 3)
axis equal; axis(aa);

[y, fs] = wavread('decepticon.wav'); sound(y, fs);