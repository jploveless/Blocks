function g = trimPartials(g, dips)
% trimPartials   Removes Green's function components based on dip.
%   G = trimPartials(G, DIPS) adjusts the Green's functions of the 
%   m-by-3*n matrix G based on the n-by-1 vector DIPS, which gives
%   the element dips in degrees.  For vertical elements, dip slip 
%   components are removed, and for dipping elements, tensile slip
%   components are removed.  The trimmed matrix is returned as G.
%

% Identify dipping and vertical elements
tz                                  = 3*ones(size(dips)); % By default, all are vertical (will zero out second component of slip)
tz(abs(90-dips) > 1)                = 2; % Dipping elements are changed

triD                                = find(tz(:) == 2); % Find those with dip-slip
triT                                = find(tz(:) == 3); % Find those with tensile slip
colkeep                             = setdiff(1:size(g, 2), [3*triD-0; 3*triT-1]);
g                                   = g(:, colkeep); % eliminate the partials that equal zero
