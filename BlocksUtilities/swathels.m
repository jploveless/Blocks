function els = swathels(p, s, H, n);
%  SWATHELS finds the most influential swath of elements.
%    ELS = SWATHELS(P, S, H, N) finds the swath of elements across an 
%    entire mesh that contribute substantially to the signal at each 
%    station.  P defines the triangular element mesh (with fields lonc
%    and latc already determined as part of the structure), S defines the 
%    station structure, H is the matrix of partial derivatives, already
%    trimmed to eliminate vertical displacements and the third (zero) slip
%    component, and N is the number of truly most influential elements used
%    to bound the swath.  ELS is a trimmed matrix containing indices of the
%    most influential elements, with the column dimension equal to the number
%    of stations in the largest swath; all other rows are padded with trailing
%    zeros.
%

% Find most influential elements by examining partials magnitudes
estp = H(1:2:end, 1:2:end);
nstp = H(2:2:end, 1:2:end);
edtp = H(1:2:end, 2:2:end);
ndtp = H(2:2:end, 2:2:end);
stp  = sqrt(estp.^2 + nstp.^2 + edtp.^2 + ndtp.^2);
[rah, stp] = sort(stp, 2, 'descend'); % sort each row of the matrix
stp = stp(:, 1:n);                    % keep only the indices of the greatest contributors

% Allocate space for the swath elements
els = zeros(numel(s.lon), size(p.v, 1));

% Loop through all stations to find element swaths
for i = 1:numel(s.lon)
   % calculate azimuth from station to influential elements
   azes = azimuth(s.lat(i), s.lon(i), p.latc(stp(i, :)), p.lonc(stp(i, :)));
   % find mean azimuth
   maz = mean(azes);
   % find extreme differences from mean
   [mz, mxa] = max(azes - maz);
   [mz, mna] = min(azes - maz);
   % reckon points from extreme different elements; 5 degrees ought to do it
   [lat1, lon1] = reckon(p.latc(stp(i, mxa)), p.lonc(stp(i, mxa)), 5, maz); 
   [lat2, lon2] = reckon(p.latc(stp(i, mna)), p.lonc(stp(i, mna)), 5, maz); 
   % define the convex hull
   lonvec = [p.lonc(stp(i, :)); lon1; lon2];
   latvec = [p.latc(stp(i, :)); lat1; lat2];
   k = convhull(lonvec, latvec);
   % find all elements within the convex hull
   ip = find(inpolygon(p.lonc, p.latc, lonvec, latvec));
   els(i, 1:length(ip)) = ip;
end

% trim all excess trailing zeros
trim = find(sum(els) == 0, 1, 'first');
els = els(:, 1:els-1);
