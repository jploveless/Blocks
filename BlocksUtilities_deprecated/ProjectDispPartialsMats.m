function Gp = ProjectDispPartialsMats(G, strike, dip, rake);
% PROJECTDISPPARTIALS  Projects displacement partial components onto a fault.
%
%   PROJECTDISPPARTIALS(G, S, D) projects the matrix of displacement partials G onto
%   the fault surfaces defined by strike, S, and dip, D, arrays.  G is a 3.*n-by-3.*n
%   array relating the x, y, z displacement components to the 3 slip components of n 
%   faults, and S and D are n-by-1 arrays defining each fault's geometry.
%
%   GP = PROJECTDISPPARTIALS(G, S, D) returns the projected matrix to GP, which is a 
%   3.*n-by-3.*n array with rows describing displacement in the strike direction, in the dip
%   direction, and in the fault-normal direction.
%
%   The sign conventions are the same as for tribemx:
%                   +      |     - 
%    -------------------------------
%    1.  Strike: Sinistral | Dextral
%    2.     Dip: Reverse   | Normal
%    3. Tensile: Opening   | Closing
%

% Handle dips > 90
dip(dip > 90) = dip(dip > 90) - 90;

% Check rake
if ~exist('rake', 'var')
   rake = zeros(size(dip));
end

% Trig. function arrays
sins  = repmat(sind(strike), 1, size(G, 2));
coss  = repmat(cosd(strike), 1, size(G, 2));
sined = repmat(sind(dip), 1, size(G, 2));
cosed = repmat(cosd(dip), 1, size(G, 2));
cosr  = repmat(cosd(rake), 1, size(G, 2));
sinr  = repmat(sind(rake), 1, size(G, 2));

% Extract matrix components
ux = G(1:3:end, :);
uy = G(2:3:end, :);
uz = G(3:3:end, :);

% Do the rotation, R*D*S*u (used symbolic toolbox)
ud = -ux.*(sinr.*sins - cosr.*coss.*cosed) - uy.*(coss.*sinr + cosr.*cosed.*sins) - cosr.*sined.*uz;
us = ux.*(cosr.*sins + coss.*cosed.*sinr) + uy.*(cosr.*coss - cosed.*sinr.*sins) - sinr.*sined.*uz;
un = cosed.*uz + coss.*sined.*ux - sined.*sins.*uy;

% Write the projected partials
Gp = zeros(size(G));
Gp(1:3:end, :) = us;
Gp(2:3:end, :) = -ud;
Gp(3:3:end, :) = un;

