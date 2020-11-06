function [psnt, varargout] = TriPartialsStrength(c, v, s, p, comp, varargin)
%
% TRIPARTIALSSTRENGTH evaluates the strength of the partials of any subset
% of triangular elements at all stations.
%
%    TRIPARTIALSSTRENGTH(C, V, S, P, COMP) calculates the strength of the triangular
%    partials P (defined for the mesh characterized by C and V) at all stations
%    in the structure S and plots a scatter plot showing this strength.  The 
%    strength of the partials is defined as the summed total from a group of
%    interactively selected stations divided by the overall total of the partials.
%    COMP specifies the components of the velocity field and slip directions that
%    should be calculated and is given as a 2 element vector:
%
%    COMP = [i j], where i is the component of the station velocity and j is the
%    component of slip on the elements.  i and j can be 1...4:
%
%    N  |  i   |  j 
%    -----------------
%    1  | eVel | sSlip
%	  2  | nVel | dSlip
%	  3  | uVel | tSlip
%	  4  | mag  | mag
%
%    TRIPARTIALSSTRENGTH(C, V, S, P, SEL) provides the subset of stations whose
%    strength is to be evaluated in SEL.  
% 
%    PS = TRIPARTIALSSTRENGTH(...) outputs the percent strength to PS.
%
%    [PST, PSO] = TRIPARTIALSSTRENTH(...) outputs the percent strength relative
%    to the total partials' power as well as the non-selected partials' power
%    (PST and PSO, respectively)
%

% determine the selected elements, either given or interactive
if nargin == 6
	selel = varargin{:}; % given as optional argument
else
	selel = SelEls(c, v); % need to specify as selected elements
end

% calculate the partials strength
use = find(s.tog);
nSta = numel(use); vSta = 1:nSta;
nTri = size(v, 1);   vTri = 1:nTri;

% first parse the components
velc = 3 - comp(1); tric = 3 - comp(2);

% find necessary row indices of partials
if velc >= 0
	velInd = 3*vSta - velc;
else
	velInd = 1:3*nSta;
end

% find necessary column indices of partials
if tric >= 0
	triInd = 3*vTri - tric;
	triSel = 3*selel - tric;
else
	triInd = 1:3*nTri;
	triSel = [3*selel - 2; 3*selel - 1; 3*selel];
end

triOth = setdiff(triInd, triSel);

% sum the partials
pss = sum(abs(p(velInd, triSel)), 2); % selected
pst = sum(abs(p(velInd, triInd)), 2); % total
pso = sum(abs(p(velInd, triOth)), 2); % other

% normalize selected partials
psnt = pss./pst; % by total
psno = pss./pso; % by others

if numel(psnt) > nSta % magnitude is selected, need to do one more summation
	[psnt, psno] = deal(reshape(psnt, 3, nSta), reshape(psno, 3, nSta));
	[psnt, psno] = deal(sum(psnt, 1), sum(psno, 1));
	[psnt, psno] = deal(psnt(:), psno(:));
end

% make a scatter plot showing the influence of the selected partials
figure; hold on
load WorldHiVectors
lon_bounds = [median(s.lon(use)) - std(s.lon(use)), median(s.lon(use)) + std(s.lon(use))];
lat_bounds = [median(s.lat(use)) - std(s.lat(use)), median(s.lat(use)) + std(s.lat(use))];
plot(lon, lat, 'color', 0.5*[1 1 1]);
scatter(s.lon(use), s.lat(use), [], psnt(:), 'filled');
axis equal
axis([lon_bounds lat_bounds]);
title('Partials strength: Selected relative to total');

if nargout == 2;
	figure; hold on
	plot(lon, lat, 'color', 0.5*[1 1 1]);
	scatter(s.lon(use), s.lat(use), [], psno(:), 'filled');
	axis equal
	axis([lon_bounds lat_bounds]);
	title('Partials strength: Selected relative to non-selected');
	varargout = {psno};
end