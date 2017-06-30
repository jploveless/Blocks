function [F, C, R, J, P, S, s, B, M, r, T, E, A, t, m, I, K, D, c, X, G, L] = BlocksGmt(varargin)
%
% BlocksGmt acts like a Zumax function, but instead of simply showing a "figure 
% capture" of the contents of a Segment Manager or Result Manager window, it
% generates a GMT Postscript file containing the all objects visible in the 
% current window.  A skeleton script, blocksgmt.bash, is simply passed a series
% of input arguments, which activate various GMT programs to plot the visible
% objects.
%
% Order of arguments passed to GMT
% 1.  F = Folder of results (%s)
% 2.  C = directory of compare results (%s or -)
% 3.  R = range (%s, -RminLon/maxLon/minLat/maxLat)
% 4.  J = width of output Postscript (%d, width in cm)
% 5.  P = portrait flag, auto-set by current aspect ratio (%d, 0-1)
% 6.  S = Stations (%d, 0-3)
% 7.  s = station names (%d, 0-3)
% 8.  B = oBserved velocities (%d, 0-3)
% 9.  M = Modeled velocities (%d, 0-3)
% 10. r = residual velocities (%d, 0-3)
% 11. T = roTational velocities (%d, 0-3)
% 12. E = Elastic velocities (%d, 0-3)
% 13. A = strAin velocities (%d, 0-3)
% 14. t = triangle velocities (%d, 0-3)
% 15. m = residual magnitudes (%d, 0-2)
% 16. I = residual Improvement (%d, 0-1)
% 17. K = striKe slip numerical rates (%d, 0-3)
% 18. D = Dip slip numerical rates (%d, 0-3)
% 19. c = colored rates (%d, 0-4) 
% 20. X = principal strain aXes (%d, 0-3)
% 21. G = trianGle slip rates (%d, 0-4)
% 22. L = Legend placement (%d, 0-5)
%
% Numerical flags follow the following syntax:
% [0-1]:
%   0 = do not plot
%   1 = plot
% [0-2]:
%   0 = do not plot
%   1 = plot for result directory only
%   2 = plot for compare directory only
% [0-3]:
%   0 = do not plot
%   1 = plot for result directory only
%   2 = plot for compare directory only
%   3 = plot for both result and compare directories
% [0-4]:
%   0 = do not plot
%   1 = plot strike slip values for result directory
%   2 = plot dip slip values for result directory
%   3 = plot strike slip values for compare directory
%   4 = plot dip slip values for compare directory
% [0-5]:
%   0 = no legend
%   1 = NW corner
%   2 = NE corner
%   3 = SE corner
%   4 = SW corner

% GUI to set some layout parameters
[L] = BlocksGmtGui;

% Get directory name(s)
F = get(findobj(gcf, 'Tag', 'Rst.loadEdit'), 'string');
C = get(findobj(gcf, 'Tag', 'Rst.cloadEdit'), 'string');
if ~strmatch(C, '-')
	C = '-';
end

% Get current range
range = getappdata(gcf, 'Range');
R = sprintf('-R%d/%d/%d/%d', range.lon(1), range.lon(2), range.lat(1), range.lat(2));

% Set width of plot
J = 1;
% Determine aspect
P = 0;

% Write the segment coordinates needed for this particular range
segment = getappdata(gcf, 'Segment');
in1 = inpolygon(segment.lon1, segment.lat1, [range.lon1, range.lon2, range.lon2, range.lon1], [range.lat1, range.lat1, range.lat2, range.lat2]);
in2 = inpolygon(segment.lon2, segment.lat2, [range.lon1, range.lon2, range.lon2, range.lon1], [range.lat1, range.lat1, range.lat2, range.lat2]);
in = union(find(in1), find(in2));
fid = fopen([F '/Seg.coords'], 'w');
for i = 1:length(in)
	fprintf(fid, '%d %d\n%d %d\n>\n', segment.lon1(in(i)), segment.lat1(in(i)), segment.lon2(in(i)), segment.lat2(in(i)));
end

% Get station controls
%  stations
S = [get(findobj(gcf, 'tag', 'Rst.StatCheck'), 'value') get(findobj(gcf, 'tag', 'Rst.cStatCheck'), 'value')];
S = sum(find(S));
%  station names
s = [get(findobj(gcf, 'tag', 'Rst.StanCheck'), 'value') get(findobj(gcf, 'tag', 'Rst.cStanCheck'), 'value')];
s = sum(find(s));
%  observed velocities
B = [get(findobj(gcf, 'tag', 'Rst.ObsvCheck'), 'value') get(findobj(gcf, 'tag', 'Rst.cObsvCheck'), 'value')];
B = sum(find(B));
%  modeled velocities
M = [get(findobj(gcf, 'tag', 'Rst.ModvCheck'), 'value') get(findobj(gcf, 'tag', 'Rst.cModvCheck'), 'value')];
M = sum(find(M));
%  residual velocities
r = [get(findobj(gcf, 'tag', 'Rst.ResvCheck'), 'value') get(findobj(gcf, 'tag', 'Rst.cResvCheck'), 'value')];
r = sum(find(r));
%  rotational velocities
T = [get(findobj(gcf, 'tag', 'Rst.RotvCheck'), 'value') get(findobj(gcf, 'tag', 'Rst.cRotvCheck'), 'value')];
T = sum(find(T));
%  elastic velocities
E = [get(findobj(gcf, 'tag', 'Rst.DefvCheck'), 'value') get(findobj(gcf, 'tag', 'Rst.cDefvCheck'), 'value')];
E = sum(find(E));
%  strain velocities
A = [get(findobj(gcf, 'tag', 'Rst.StrvCheck'), 'value') get(findobj(gcf, 'tag', 'Rst.cStrvCheck'), 'value')];
A = sum(find(A));
%  triangle velocities
t = [get(findobj(gcf, 'tag', 'Rst.TrivCheck'), 'value') get(findobj(gcf, 'tag', 'Rst.cTrivCheck'), 'value')];
t = sum(find(t));
%  residual magnitudes
m = [get(findobj(gcf, 'tag', 'Rst.ResmCheck'), 'value') get(findobj(gcf, 'tag', 'Rst.cResmCheck'), 'value')];
m = sum(find(m));

% Other parameters

%  residual improvement
I = 0;
if ~strmatch(C, '-')
	I = get(findobj(gcf, 'Tag', 'Rst.ResidImpCheck'), 'value');
end

%  slip rates
%    numerical
%      strike slip
K = [get(findobj(gcf, 'tag', 'Rst.SlipNumCheck'), 'value')*get(findobj(gcf, 'tag', 'Rst.srateNumRadio'), 'value'),...
     get(findobj(gcf, 'tag', 'Rst.cSlipNumCheck'), 'value')*get(findobj(gcf, 'tag', 'Rst.csrateNumRadio'), 'value')];
K = sum(find(K));
%      dip slip
D = [get(findobj(gcf, 'tag', 'Rst.SlipNumCheck'), 'value')*get(findobj(gcf, 'tag', 'Rst.drateNumRadio'), 'value'),...
     get(findobj(gcf, 'tag', 'Rst.cSlipNumCheck'), 'value')*get(findobj(gcf, 'tag', 'Rst.cdrateNumRadio'), 'value')];
D = sum(find(D));
%    colored
c = [get(findobj(gcf, 'tag', 'Rst.SlipColCheck'), 'value')*[get(findobj(gcf, 'tag', 'Rst.srateColRadio'), 'value') get(findobj(gcf, 'tag', 'Rst.drateColRadio'), 'value')],...
     get(findobj(gcf, 'tag', 'Rst.cSlipColCheck'), 'value')*[get(findobj(gcf, 'tag', 'Rst.csrateColRadio'), 'value') get(findobj(gcf, 'tag', 'Rst.cdrateColRadio'), 'value')]];
c = find(c);
if isempty(c)
	c = 0;
elseif c == 1
	% Make the bash file for plotting variable width strike slip lines
	a = findobj(gcf, '-regexp', 'tag', '^SlipCols');
	unc = a(1:length(a)/2);
	sli = a(length(a)/2+1:end);
	unc = unc(in);
	sli = sli(in);
	fid = fopen([F 'SegSlip.bash'], 'w');
	for i = 1:length(in)
		fprintf(fid, 'psxy -R -Jm -O -K -W%d/%d/%d/%d <<END >> $1.ps\n%d %d\n%d %d\nEND\n', get(sli(i), 'linewidth'), 255*get(sli(i), 'color'), segment.lon1(in(i)), segment.lat1(in(i)), segment.lon2(in(i)), segment.lat2(in(i)));
	end
	fclose(fid)
elseif c == 2
	% Make the bash file for plotting variable width dip slip lines
	a = findobj(gcf, '-regexp', 'tag', '^SlipCold');
	unc = a(1:length(a)/2);
	sli = a(length(a)/2+1:end);
	unc = unc(in);
	sli = sli(in);
	fid = fopen([F 'SegSlip.bash'], 'w');
	for i = 1:length(in)
		fprintf(fid, 'psxy -R -Jm -O -K -W%d/%d/%d/%d <<END >> $1.ps\n%d %d\n%d %d\nEND\n', get(sli(i), 'linewidth'), 255*get(sli(i), 'color'), segment.lon1(in(i)), segment.lat1(in(i)), segment.lon2(in(i)), segment.lat2(in(i)));
	end
	fclose(fid)
elseif c == 3
	% Make the bash file for plotting variable width strike slip lines
	a = findobj(gcf, '-regexp', 'tag', '^cSlipCols');
	unc = a(1:length(a)/2);
	sli = a(length(a)/2+1:end);
	unc = unc(in);
	sli = sli(in);
	fid = fopen([F 'SegSlip.bash'], 'w');
	for i = 1:length(in)
		fprintf(fid, 'psxy -R -Jm -O -K -W%d/%d/%d/%d <<END >> $1.ps\n%d %d\n%d %d\nEND\n', get(sli(i), 'linewidth'), 255*get(sli(i), 'color'), segment.lon1(in(i)), segment.lat1(in(i)), segment.lon2(in(i)), segment.lat2(in(i)));
	end
	fclose(fid)
elseif c == 4
	% Make the bash file for plotting variable width dip slip lines
	a = findobj(gcf, '-regexp', 'tag', '^cSlipCold');
	unc = a(1:length(a)/2);
	sli = a(length(a)/2+1:end);
	unc = unc(in);
	sli = sli(in);
	fid = fopen([F 'SegSlip.bash'], 'w');
	for i = 1:length(in)
		fprintf(fid, 'psxy -R -Jm -O -K -W%d/%d/%d/%d <<END >> $1.ps\n%d %d\n%d %d\nEND\n', get(sli(i), 'linewidth'), 255*get(sli(i), 'color'), segment.lon1(in(i)), segment.lat1(in(i)), segment.lon2(in(i)), segment.lat2(in(i)));
	end
	fclose(fid)
end

%   strain axes
X = [get(findobj(gcf, 'tag', 'Rst.StrainCheck'), 'value') get(findobj(gcf, 'tag', 'Rst.cStrainCheck'), 'value')];
X = sum(find(X));

%   triangle slip rates
G = [get(findobj(gcf, 'tag', 'Rst.TriCheck'), 'value')*[get(findobj(gcf, 'tag', 'Rst.TriSRadio'), 'value') get(findobj(gcf, 'tag', 'Rst.TriDRadio'), 'value')],...
     get(findobj(gcf, 'tag', 'Rst.cTriCheck'), 'value')*[get(findobj(gcf, 'tag', 'Rst.cTriDRadio'), 'value') get(findobj(gcf, 'tag', 'Rst.cTriDRadio'), 'value')]];
G = find(G);
if isempty(G)
	G = 0;
end

% Write the segment coordinates needed for this particular range
segment = getappdata(gcf, 'Segment');
in1 = inpolygon(segment.lon1, segment.lat1, [range.lon1, range.lon2, range.lon2, range.lon1], [range.lat1, range.lat1, range.lat2, range.lat2]);
in2 = inpolygon(segment.lon2, segment.lat2, [range.lon1, range.lon2, range.lon2, range.lon1], [range.lat1, range.lat1, range.lat2, range.lat2]);
in = union(find(in1), find(in2));
fid = fopen([F '/Seg.coords'], 'w');
for i = 1:length(in)
	fprintf(fid, '%d %d\n%d %d\n>\n', segment.lon1(in(i)), segment.lat1(in(i)), segment.lon2(in(i)), segment.lat2(in(i)));
end

%   do the same for the compare directory, if necessary
if ~strmatch(C, '-')
	segment = getappdata(gcf, 'Segment');
	in1 = inpolygon(segment.lon1, segment.lat1, [range.lon1, range.lon2, range.lon2, range.lon1], [range.lat1, range.lat1, range.lat2, range.lat2]);
	in2 = inpolygon(segment.lon2, segment.lat2, [range.lon1, range.lon2, range.lon2, range.lon1], [range.lat1, range.lat1, range.lat2, range.lat2]);
	in = union(find(in1), find(in2));
	fid = fopen([C '/Seg.coords'], 'w');
	for i = 1:length(in)
		fprintf(fid, '%d %d\n%d %d\n>\n', segment.lon1(in(i)), segment.lat1(in(i)), segment.lon2(in(i)), segment.lat2(in(i)));
	end
end