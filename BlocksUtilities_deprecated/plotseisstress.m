function plotseisstress(seg, idx, seis, idx2)
% SEG = segment file
% IDX = full index list
% SEIS = full path to seismicity catalog (.mat) from Lin et al. --- needs to include fields "qlon" and "qlat"
% IDX2 = optional, specifies the indices along which the plot will actually be made

% Check to see if second index vector exists
if ~exist('idx2', 'var')
   idx2 = idx;
end

% Run the self stress calculation
[S, SS, OS] = selfstress(seg, idx);

% Some segment subsets
sseg = structsubset(seg, idx2);
sego = ordersegs(sseg);
sseg = structsubset(sseg, sego);

% Seismicity processing
a1 = who;
load(seis);
a2 = who;
da = setdiff(a2, a1);
[lon, lat] = deal(getfield(eval(da{2}), 'qlon'), getfield(eval(da{2}), 'qlat'));
[sx, sy, sseg] = swathseg(sseg, 10);
in = inpolygon(wrapTo360(lon), lat, sx, sy);
lon = lon(in); lat = lat(in);
n = alongseghist(sseg, 10, wrapTo360(lon), lat);

% Segment lengths and distances
leng = distance(sseg.lat1, sseg.lon1, sseg.lat2, sseg.lon2, almanac('earth', 'wgs84'));
middist = cumsum(leng) - leng./2;

% Plotting
figure
ax = plotyy(middist, log10(abs(OS.sh(sego))), middist, log10(n));
hold(ax(1), 'on')
plot(ax(1), middist, log10(abs(S.sh(sego))), 'r')
plot(ax(1), middist, log10(abs(SS.sh(sego))), 'm')
legend('Non-self', 'Total', 'Self')
xlabel('Distance (km)')
ylabel(ax(1), 'log_{10}\tau')
ylabel(ax(2), 'log_{10}N_{eq}')