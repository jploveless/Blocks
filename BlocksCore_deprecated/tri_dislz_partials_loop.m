function [uxs, uys, uzs,...
          uxd, uyd, uzd,...
          uxt, uyt, uzt, normVec]       = tri_dislz_partials(x, y, z, sx, sy, sz, pr);
%
% tri_disl.m
%
% Calculates displacements due to slip on a triangular dislocation in an
% elastic half space utilizing the Comninou and Dunders (1975) expressions
% for the displacements due to an angular dislocation in an elastic half
% space.
%
% Arguments
%  x  : x-coordinates of 3 triangle vertices.
%  y  : y-coordinates of 3 triangle vertices.
%  z  : z-coordinates of 3 triangle vertices.
%  sx : x-coordinates of observation points
%  sy : y-coordinates of observation points
%  sz : z-coordinates of observation points
%  ss : strike slip displacement
%  ds : dip slip displacement
%  ts : tensile slip displacement
%  pr : Poisson's ratio
%
% Returns
%  uij  : each uij represents the deformation in the i direction due to 
%         element slip in the j direction, where i is x, y, z and j is
%         s, d, t (corresponding to strike, dip, and tensile slip).  


% Calculate the slip vector in XYZ coordinates
normVec                      = cross([x(2);y(2);z(2)]-[x(1);y(1);z(1)], [x(3);y(3);z(3)]-[x(1);y(1);z(1)]);
normVec                      = normVec./norm(normVec);
% Enforce clockwise circulation
normVec                      = (sign(normVec(3)) + (normVec(3) == 0))*normVec; 
vord                         = [1 2+(normVec(3) < 0) 3-(normVec(3) < 0)];
x                            = x(vord);
y                            = y(vord);
z                            = z(vord);
strikeVec                    = [-sin(atan2(normVec(2),normVec(1))) cos(atan2(normVec(2),normVec(1))) 0]';
dipVec                       = cross(normVec, strikeVec);
slipComp                     = [1 1 1];
slipVec                      = [strikeVec(:) dipVec(:) normVec(:)] * slipComp(:);

% Solution vectors   
[uxs, uys, uzs...
 uxd, uyd, uzd...
 uxt, uyt, uzt]              = deal(zeros(size(sx)));

% Add a copy of the first vertex to the vertex list for indexing
x                            = [x x(1)];
y                            = [y y(1)];
z                            = [z z(1)];

for iTri = 1:3
   % Calculate strike and dip of current leg
   strike                   = 180/pi*(atan2(y(iTri+1)-y(iTri), x(iTri+1)-x(iTri)));
   segMapLength             = sqrt((x(iTri)-x(iTri+1))^2 + (y(iTri)-y(iTri+1))^2);
   [rx ry]                  = RotateXyVec(x(iTri+1)-x(iTri), y(iTri+1)-y(iTri), -strike);
   dip                      = 180/pi*(atan2(z(iTri+1)-z(iTri), rx));
   
   nd = sign(dip) + (dip == 0);
   beta = nd*pi/180*(90 - nd*dip);
   beta(nd*beta > pi/2) = pi/2 - nd*beta;

   ssVec                    = [cos(strike/180*pi); sin(strike/180*pi); 0];
   dsVec                    = [-sin(strike/180*pi); cos(strike/180*pi); 0];
   tsVec                    = cross(ssVec, dsVec);
   lss                      = dot(slipVec, ssVec);
   lds                      = dot(slipVec, dsVec);
   lts                      = dot(slipVec, tsVec);
   
   lsss = dot(strikeVec, ssVec);
   lssd = dot(strikeVec, dsVec);
   lsst = dot(strikeVec, tsVec);
   
   ldss = dot(dipVec, ssVec);
   ldsd = dot(dipVec, dsVec);
   ldst = dot(dipVec, tsVec);
   
   ltss = dot(normVec, ssVec);
   ltsd = dot(normVec, dsVec);
   ltst = dot(normVec, tsVec);
   
   ratios = repmat([lsss lssd lsst]./[lss lds lts], length(sx), 1); ratios(isnan(ratios)) = 1;
   ratiod = repmat([ldss ldsd ldst]./[lss lds lts], length(sx), 1); ratiod(isnan(ratiod)) = 1;
   ratiot = repmat([ltss ltsd ltst]./[lss lds lts], length(sx), 1); ratiot(isnan(ratiot)) = 1;

%   if (abs(beta) > 0.000001) && (abs(beta-pi) > 0.000001)
      % First angular dislocation
      [sx1 sy1]                 = RotateXyVec(sx-x(iTri), sy-y(iTri), -strike);
      [ux11, uy11, uz11...
       ux12, uy12, uz12...
       ux13, uy13, uz13]        = adv(sx1, sy1, sz-z(iTri), z(iTri), beta, pr, lss, lds, lts);
      
      % Project displacements so that individual slip component partials are returned
      uxvec = [ux11 ux12 ux13];
      uyvec = [uy11 uy12 uy13];
      uzvec = [uz11 uz12 uz13];
                
      ux1s = dot(uxvec, ratios, 2);
      uy1s = dot(uyvec, ratios, 2);
      uz1s = dot(uzvec, ratios, 2);
     
      ux1d = dot(uxvec, ratiod, 2);
      uy1d = dot(uyvec, ratiod, 2);
      uz1d = dot(uzvec, ratiod, 2);
      
      ux1t = dot(uxvec, ratiot, 2);
      uy1t = dot(uyvec, ratiot, 2);
      uz1t = dot(uzvec, ratiot, 2);
       
      % Second angular dislocation
      [sx2 sy2]                 = RotateXyVec(sx-x(iTri+1), sy-y(iTri+1), -strike); 
      [ux21, uy21, uz21...
       ux22, uy22, uz22...
       ux23, uy23, uz23]        = adv(sx2, sy2, sz-z(iTri+1), z(iTri+1), beta, pr, lss, lds, lts);

      % Project displacements so that individual slip component partials are returned
      uxvec = [ux21 ux22 ux23];
      uyvec = [uy21 uy22 uy23];
      uzvec = [uz21 uz22 uz23];

      ux2s = dot(uxvec, ratios, 2);
      uy2s = dot(uyvec, ratios, 2);
      uz2s = dot(uzvec, ratios, 2);

      ux2d = dot(uxvec, ratiod, 2);
      uy2d = dot(uyvec, ratiod, 2);
      uz2d = dot(uzvec, ratiod, 2);

      ux2t = dot(uxvec, ratiot, 2);
      uy2t = dot(uyvec, ratiot, 2);
      uz2t = dot(uzvec, ratiot, 2);

      % Rotate vectors to correct for strike
      [uxns uyns]               = RotateXyVec(ux1s-ux2s, uy1s-uy2s, strike);
      [uxnd uynd]               = RotateXyVec(ux1d-ux2d, uy1d-uy2d, strike);
      [uxnt uynt]               = RotateXyVec(ux1t-ux2t, uy1t-uy2t, strike);
      uzns                      = uz1s-uz2s;
      uznd                      = uz1d-uz2d;
      uznt                      = uz1t-uz2t;

     % Add the displacements from current leg
      uxns(isnan(uxns)) = 0; 
      uyns(isnan(uyns)) = 0;
      uzns(isnan(uzns)) = 0;
      
      uxnd(isnan(uxnd)) = 0;
      uynd(isnan(uynd)) = 0;
      uznd(isnan(uznd)) = 0;
      
      uxnt(isnan(uxnt)) = 0;
      uynt(isnan(uynt)) = 0;
      uznt(isnan(uznt)) = 0;

      uxs                       = uxs + uxns;
      uys                       = uys + uyns;
      uzs                       = uzs + uzns;
      
      uxd                       = uxd + uxnd;
      uyd                       = uyd + uynd;
      uzd                       = uzd + uznd;
      
      uxt                       = uxt + uxnt;
      uyt                       = uyt + uynt;
      uzt                       = uzt + uznt;
%   end
end

% Identify indices for stations under current triangle
inPolyIdx                       = intriangle(sx, sy, x, y, normVec);
t                               = LinePlaneIntersect(x, y, z, normVec, sx, sy, sz);
underIdx                        = t > 0 & t < 1 & inPolyIdx;

% Apply static offset to the points that lie underneath the current triangle
uxs                    = uxs - underIdx*strikeVec(1);
uys                    = uys - underIdx*strikeVec(2);
uzs                    = uzs - underIdx*strikeVec(3);

uxd                    = uxd - underIdx*dipVec(1);
uyd                    = uyd - underIdx*dipVec(2);
uzd                    = uzd - underIdx*dipVec(3);

uxt                    = uxt - underIdx*normVec(1);
uyt                    = uyt - underIdx*normVec(2);
uzt                    = uzt - underIdx*normVec(3);

save '~/Desktop/partials_output.mat'

function [in, on, t] = intriangle(x, y, xv, yv, normVec);
% intriangle  Tests for points inside a triangle.
%
% From http://paulbourke.net/geometry/insidepoly/ (Solution 3)

% Make sure the first node has been replicated 
xv = [xv(:); xv(1)]; xv = xv(1:4);
yv = [yv(:); yv(1)]; yv = yv(1:4);

t1 = (y(:) - yv(1)).*(xv(2) - xv(1)) - (x(:) - xv(1)).*(yv(2) - yv(1));
t2 = (y(:) - yv(2)).*(xv(3) - xv(2)) - (x(:) - xv(2)).*(yv(3) - yv(2));
t3 = (y(:) - yv(3)).*(xv(4) - xv(3)) - (x(:) - xv(3)).*(yv(4) - yv(3));

t = [t1 t2 t3];
on = ((sum(t == 0, 2) > 0) & (sum(t > 0, 2) == 2)); % Must lie on one edge and to the same side of the other edges
% Alternative determination for the case of vertical triangles: look for points very close to the edges
[di, seg, xi, yi] = pointlinedist([xv, yv], [x, y]);
tol = 1e-11*max([diff(xv); diff(yv)]); % Set tolerance
on = on | (max(di, [], 2) < tol & max(seg, [], 2)); % Test for close points
in = (on | (abs(sum(sign(t), 2)) == 3)); % All columns of t must have the same sign, indicating that the point lies tot eh same side of all edge

function [dist, seg, xi, yi] = pointlinedist(lin, pt)
% pointlinedist   Returns the shortest distance between a point a line.
%   pointlinedist(LIN, PT) returns the shortest distance between a point and
%   a line.  LIN is an 2-by-2n array containing the x, y coordinate pairs of the 
%   endpoints of n lines: 
%   [x11 y11 x21 y21 ... xn1 yn1
%    x12 y12 x22 y22 ... xn2 yn2]
%
%   (arranged to be plotted with line(LIN(:, 1:2:end), LIN(:, 2:2:end))
%   
%   or a set of connected n lines (with shared endpoints)
% 
%   [x1 y1
%    x2 y2
%    x3 y3
%    ...
%    xn yn]
%
%   and POINT is an m-by-2 array containing the x, y coordinates of points.  
%   Returned is an m-by-n array giving the shortest distance between the m 
%   points and the n lines.
%
%   DIST = pointlinedist(...) returns the distances to DIST.  
%
%   [DIST, SEG] = pointlinedist(...) returns a logical array SEG 
%   indicating whether or not the point intersects the specified
%   line segment.
%   
%   [DIST, XI, YI] = pointlinedist(...) also returns the coordinates
%   of the intersection points as an m-by-n arrays XI and YI.
%
%   From http://www.paulbourke.net/geometry/pointlineplane

% Replicate matrices to make dimensions agree
sl = size(lin, 1);
r = sort(repmat(1:sl, 1, 2)); r = r(2:end-1);
x1 = repmat(lin(r(1:2:end), 1)', size(pt, 1), 1);
y1 = repmat(lin(r(1:2:end), 2)', size(pt, 1), 1);
x2 = repmat(lin(r(2:2:end), 1)', size(pt, 1), 1);
y2 = repmat(lin(r(2:2:end), 2)', size(pt, 1), 1);
x3 = repmat(pt(:, 1), 1, size(x1, 2));
y3 = repmat(pt(:, 2), 1, size(x1, 2));

x2m1 = x2 - x1;
y2m1 = y2 - y1;
u = ((x3 - x1).*x2m1 + (y3 - y1).*y2m1)./(x2m1.^2 + y2m1.^2);
seg = (u >= 0 & u <= 1);

% Intersection coordinates
xi = x1 + u.*x2m1;
yi = y1 + u.*y2m1;

% Distances
dist = sqrt((x3 - xi).^2 + (y3 - yi).^2);


function t = LinePlaneIntersect(x, y, z, normVec, sx, sy, sz)
% Calculate the intersection of a line and a plane using a parametric
% representation of the plane.  This is hardcoded for a vertical line.
num                             = dot(repmat(normVec', size(sx)), repmat([x(1), y(1), z(1)], size(sx))-[sx, sy, sz], 2);
den                             = dot(repmat(normVec', size(sx)), [sx, sy, 0*sx]-[sx, sy, sz], 2);
den(den == 0)                   = eps;
t                               = num./den; % parametric curve parameter
% Special case for vertical elements; set t = 0.5 for points lying below the shallowest depth
t                               = (normVec(3) ~= 0)*t + (normVec(3) == 0)*0.5*(abs(sz) > abs(min(z)));    

function [a b] = swap(a, b)
% Swap two values
temp                            = a;
a                               = b;
b                               = temp;


function [xp yp] = RotateXyVec(x, y, alpha)
% Rotate a vector by an angle alpha
x                             = x(:);
y                             = y(:);
alpha                         = pi/180*alpha;
xp                            = cos(alpha).*x - sin(alpha).*y;
yp                            = sin(alpha).*x + cos(alpha).*y;


function [v1B1 v2B1 v3B1 v1B2 v2B2 v3B2 v1B3 v2B3 v3B3] = adv(y1, y2, y3, a, beta, nu, B1, B2, B3)
% These are the displacements in a uniform elastic half space due to slip
% on an angular dislocation (Comninou and Dunders, 1975).  Some of the
% equations for the B2 and B3 cases have been corrected following Thomas
% 1993.  The equations are coded in way such that they roughly correspond
% to each line in original text.  Exceptions have been made where it made 
% more sense because of grouping symbols.

sinbeta           = sin(beta);
cosbeta           = cos(beta);
cotbeta           = 1./tan(beta);
z1                = y1.*cosbeta - y3.*sinbeta;
z3                = y1.*sinbeta + y3.*cosbeta;
R2                = y1.*y1 + y2.*y2 + y3.*y3;
R                 = sqrt(R2);
y3bar             = y3 + 2.*a;
z1bar             = y1.*cosbeta + y3bar.*sinbeta;
z3bar             = -y1.*sinbeta + y3bar.*cosbeta;
R2bar             = y1.*y1 + y2.*y2 + y3bar.*y3bar;
Rbar              = sqrt(R2bar);
F                 = -atan2(y2, y1) + atan2(y2, z1) + atan2(y2.*R.*sinbeta, y1.*z1+(y2.*y2).*cosbeta);
Fbar              = -atan2(y2, y1) + atan2(y2, z1bar) + atan2(y2.*Rbar.*sinbeta, y1.*z1bar+(y2.*y2).*cosbeta);

% Case I: Burgers vector (B1,0,0)
v1InfB1           = 2.*(1-nu).*(F+Fbar) - y1.*y2.*(1./(R.*(R-y3)) + 1./(Rbar.*(Rbar+y3bar))) - ...
                    y2.*cosbeta.*((R.*sinbeta-y1)./(R.*(R-z3)) + (Rbar.*sinbeta-y1)./(Rbar.*(Rbar+z3bar)));
v2InfB1           = (1-2.*nu).*(log(R-y3)+log(Rbar+y3bar) - cosbeta.*(log(R-z3)+log(Rbar+z3bar))) - ...
                    y2.*y2.*(1./(R.*(R-y3))+1./(Rbar.*(Rbar+y3bar)) - cosbeta.*(1./(R.*(R-z3))+1./(Rbar.*(Rbar+z3bar))));
v3InfB1           = y2 .* (1./R - 1./Rbar - cosbeta.*((R.*cosbeta-y3)./(R.*(R-z3)) - (Rbar.*cosbeta+y3bar)./(Rbar.*(Rbar+z3bar))));
v1InfB1           = v1InfB1 ./ (8.*pi.*(1-nu));
v2InfB1           = v2InfB1 ./ (8.*pi.*(1-nu));
v3InfB1           = v3InfB1 ./ (8.*pi.*(1-nu));

v1CB1             = -2.*(1-nu).*(1-2.*nu).*Fbar.*(cotbeta.*cotbeta) + (1-2.*nu).*y2./(Rbar+y3bar) .* ((1-2.*nu-a./Rbar).*cotbeta - y1./(Rbar+y3bar).*(nu+a./Rbar)) + ...
                    (1-2.*nu).*y2.*cosbeta.*cotbeta./(Rbar+z3bar).*(cosbeta+a./Rbar) + a.*y2.*(y3bar-a).*cotbeta./(Rbar.*Rbar.*Rbar) + ...
                    y2.*(y3bar-a)./(Rbar.*(Rbar+y3bar)).*(-(1-2.*nu).*cotbeta + y1./(Rbar+y3bar) .* (2.*nu+a./Rbar) + a.*y1./(Rbar.*Rbar)) + ...
                    y2.*(y3bar-a)./(Rbar.*(Rbar+z3bar)).*(cosbeta./(Rbar+z3bar).*((Rbar.*cosbeta+y3bar) .* ((1-2.*nu).*cosbeta-a./Rbar).*cotbeta + 2.*(1-nu).*(Rbar.*sinbeta-y1).*cosbeta) - a.*y3bar.*cosbeta.*cotbeta./(Rbar.*Rbar));
v2CB1             = (1-2.*nu).*((2.*(1-nu).*(cotbeta.*cotbeta)-nu).*log(Rbar+y3bar) -(2.*(1-nu).*(cotbeta.*cotbeta)+1-2.*nu).*cosbeta.*log(Rbar+z3bar)) - ...
                    (1-2.*nu)./(Rbar+y3bar).*(y1.*cotbeta.*(1-2.*nu-a./Rbar) + nu.*y3bar - a + (y2.*y2)./(Rbar+y3bar).*(nu+a./Rbar)) - ...
                    (1-2.*nu).*z1bar.*cotbeta./(Rbar+z3bar).*(cosbeta+a./Rbar) - a.*y1.*(y3bar-a).*cotbeta./(Rbar.*Rbar.*Rbar) + ...
                    (y3bar-a)./(Rbar+y3bar).*(-2.*nu + 1./Rbar.*((1-2.*nu).*y1.*cotbeta-a) + (y2.*y2)./(Rbar.*(Rbar+y3bar)).*(2.*nu+a./Rbar)+a.*(y2.*y2)./(Rbar.*Rbar.*Rbar)) + ...
                    (y3bar-a)./(Rbar+z3bar).*((cosbeta.*cosbeta) - 1./Rbar.*((1-2.*nu).*z1bar.*cotbeta+a.*cosbeta) + a.*y3bar.*z1bar.*cotbeta./(Rbar.*Rbar.*Rbar) - 1./(Rbar.*(Rbar+z3bar)) .* ((y2.*y2).*(cosbeta.*cosbeta) - a.*z1bar.*cotbeta./Rbar.*(Rbar.*cosbeta+y3bar)));

v3CB1             = 2.*(1-nu).*(((1-2.*nu).*Fbar.*cotbeta) + (y2./(Rbar+y3bar).*(2.*nu+a./Rbar)) - (y2.*cosbeta./(Rbar+z3bar).*(cosbeta+a./Rbar))) + ...
                    y2.*(y3bar-a)./Rbar.*(2.*nu./(Rbar+y3bar)+a./(Rbar.*Rbar)) + ...
                    y2.*(y3bar-a).*cosbeta./(Rbar.*(Rbar+z3bar)).*(1-2.*nu-(Rbar.*cosbeta+y3bar)./(Rbar+z3bar).*(cosbeta + a./Rbar) - a.*y3bar./(Rbar.*Rbar));

v1CB1             = v1CB1 ./ (4.*pi.*(1-nu));
v2CB1             = v2CB1 ./ (4.*pi.*(1-nu));
v3CB1             = v3CB1 ./ (4.*pi.*(1-nu));

v1B1              = B1.*(v1InfB1 + v1CB1);
v2B1              = B1.*(v2InfB1 + v2CB1);
v3B1              = B1.*(v3InfB1 + v3CB1);


% Case II: Burgers vector (0,B2,0)
v1InfB2           = -(1-2.*nu).*(log(R-y3) + log(Rbar+y3bar)-cosbeta.*(log(R-z3)+log(Rbar+z3bar))) + ...
                    y1.*y1.*(1./(R.*(R-y3))+1./(Rbar.*(Rbar+y3bar))) + z1.*(R.*sinbeta-y1)./(R.*(R-z3)) + z1bar.*(Rbar.*sinbeta-y1)./(Rbar.*(Rbar+z3bar));
v2InfB2           = 2.*(1-nu).*(F+Fbar) + y1.*y2.*(1./(R.*(R-y3))+1./(Rbar.*(Rbar+y3bar))) - y2.*(z1./(R.*(R-z3))+z1bar./(Rbar.*(Rbar+z3bar)));
v3InfB2           = -(1-2.*nu).*sinbeta.*(log(R-z3)-log(Rbar+z3bar)) - y1.*(1./R-1./Rbar) + z1.*(R.*cosbeta-y3)./(R.*(R-z3)) - z1bar.*(Rbar.*cosbeta+y3bar)./(Rbar.*(Rbar+z3bar));
v1InfB2           = v1InfB2 ./ (8.*pi.*(1-nu));
v2InfB2           = v2InfB2 ./ (8.*pi.*(1-nu));
v3InfB2           = v3InfB2 ./ (8.*pi.*(1-nu));

v1CB2             = (1-2.*nu).*((2.*(1-nu).*(cotbeta.*cotbeta)+nu).*log(Rbar+y3bar) - (2.*(1-nu).*(cotbeta.*cotbeta)+1).*cosbeta.*log(Rbar+z3bar)) + ...
                    (1-2.*nu)./(Rbar+y3bar).* (-(1-2.*nu).*y1.*cotbeta+nu.*y3bar-a+a.*y1.*cotbeta./Rbar + (y1.*y1)./(Rbar+y3bar).*(nu+a./Rbar)) - ...
                    (1-2.*nu).*cotbeta./(Rbar+z3bar).*(z1bar.*cosbeta - a.*(Rbar.*sinbeta-y1)./(Rbar.*cosbeta)) - a.*y1.*(y3bar-a).*cotbeta./(Rbar.*Rbar.*Rbar) + ...
                    (y3bar-a)./(Rbar+y3bar).*(2.*nu + 1./Rbar.*((1-2.*nu).*y1.*cotbeta+a) - (y1.*y1)./(Rbar.*(Rbar+y3bar)).*(2.*nu+a./Rbar) - a.*(y1.*y1)./(Rbar.*Rbar.*Rbar)) + ...
                    (y3bar-a).*cotbeta./(Rbar+z3bar).*(-cosbeta.*sinbeta+a.*y1.*y3bar./(Rbar.*Rbar.*Rbar.*cosbeta) + (Rbar.*sinbeta-y1)./Rbar.*(2.*(1-nu).*cosbeta - (Rbar.*cosbeta+y3bar)./(Rbar+z3bar).*(1+a./(Rbar.*cosbeta))));
v2CB2             = 2.*(1-nu).*(1-2.*nu).*Fbar.*cotbeta.*cotbeta + (1-2.*nu).*y2./(Rbar+y3bar).*(-(1-2.*nu-a./Rbar).*cotbeta + y1./(Rbar+y3bar).*(nu+a./Rbar)) - ...
                    (1-2.*nu).*y2.*cotbeta./(Rbar+z3bar).*(1+a./(Rbar.*cosbeta)) - a.*y2.*(y3bar-a).*cotbeta./(Rbar.*Rbar.*Rbar) + ...
                    y2.*(y3bar-a)./(Rbar.*(Rbar+y3bar)).*((1-2.*nu).*cotbeta - 2.*nu.*y1./(Rbar+y3bar) - a.*y1./Rbar.*(1./Rbar+1./(Rbar+y3bar))) + ...
                    y2.*(y3bar-a).*cotbeta./(Rbar.*(Rbar+z3bar)).*(-2.*(1-nu).*cosbeta + (Rbar.*cosbeta+y3bar)./(Rbar+z3bar).*(1+a./(Rbar.*cosbeta)) + a.*y3bar./((Rbar.*Rbar).*cosbeta));
v3CB2             = -2.*(1-nu).*(1-2.*nu).*cotbeta .* (log(Rbar+y3bar)-cosbeta.*log(Rbar+z3bar)) - ...
                    2.*(1-nu).*y1./(Rbar+y3bar).*(2.*nu+a./Rbar) + 2.*(1-nu).*z1bar./(Rbar+z3bar).*(cosbeta+a./Rbar) + ...
                   (y3bar-a)./Rbar.*((1-2.*nu).*cotbeta-2.*nu.*y1./(Rbar+y3bar)-a.*y1./(Rbar.*Rbar)) - ...
                   (y3bar-a)./(Rbar+z3bar).*(cosbeta.*sinbeta + (Rbar.*cosbeta+y3bar).*cotbeta./Rbar.*(2.*(1-nu).*cosbeta - (Rbar.*cosbeta+y3bar)./(Rbar+z3bar)) + a./Rbar.*(sinbeta - y3bar.*z1bar./(Rbar.*Rbar) - z1bar.*(Rbar.*cosbeta+y3bar)./(Rbar.*(Rbar+z3bar))));
v1CB2             = v1CB2 ./ (4.*pi.*(1-nu));
v2CB2             = v2CB2 ./ (4.*pi.*(1-nu));
v3CB2             = v3CB2 ./ (4.*pi.*(1-nu));

v1B2              = B2.*(v1InfB2 + v1CB2);
v2B2              = B2.*(v2InfB2 + v2CB2);
v3B2              = B2.*(v3InfB2 + v3CB2);


% Case III: Burgers vector (0,0,B3)
v1InfB3           = y2.*sinbeta.*((R.*sinbeta-y1)./(R.*(R-z3))+(Rbar.*sinbeta-y1)./(Rbar.*(Rbar+z3bar)));
v2InfB3           = (1-2.*nu).*sinbeta.*(log(R-z3)+log(Rbar+z3bar)) - (y2.*y2).*sinbeta.*(1./(R.*(R-z3))+1./(Rbar.*(Rbar+z3bar)));
v3InfB3           = 2.*(1-nu).*(F-Fbar) + y2.*sinbeta.*((R.*cosbeta-y3)./(R.*(R-z3))-(Rbar.*cosbeta+y3bar)./(Rbar.*(Rbar+z3bar)));
v1InfB3           = v1InfB3 ./ (8.*pi.*(1-nu));
v2InfB3           = v2InfB3 ./ (8.*pi.*(1-nu));
v3InfB3           = v3InfB3 ./ (8.*pi.*(1-nu));

v1CB3             = (1-2.*nu).*(y2./(Rbar+y3bar).*(1+a./Rbar) - y2.*cosbeta./(Rbar+z3bar).*(cosbeta+a./Rbar)) - ...
                    y2.*(y3bar-a)./Rbar.*(a./(Rbar.*Rbar) + 1./(Rbar+y3bar)) + ...
                    y2.*(y3bar-a).*cosbeta./(Rbar.*(Rbar+z3bar)).*((Rbar.*cosbeta+y3bar)./(Rbar+z3bar).*(cosbeta+a./Rbar) + a.*y3bar./(Rbar.*Rbar));
v2CB3             = (1-2.*nu).*(-sinbeta.*log(Rbar+z3bar) - y1./(Rbar+y3bar).*(1+a./Rbar) + z1bar./(Rbar+z3bar).*(cosbeta+a./Rbar)) + ...
                    y1.*(y3bar-a)./Rbar.*(a./(Rbar.*Rbar) + 1./(Rbar+y3bar)) - ...
                    (y3bar-a)./(Rbar+z3bar).*(sinbeta.*(cosbeta-a./Rbar) + z1bar./Rbar.*(1+a.*y3bar./(Rbar.*Rbar)) - ...
                    1./(Rbar.*(Rbar+z3bar)).*((y2.*y2).*cosbeta.*sinbeta - a.*z1bar./Rbar.*(Rbar.*cosbeta+y3bar)));
v3CB3             = 2.*(1-nu).*Fbar + 2.*(1-nu).*(y2.*sinbeta./(Rbar+z3bar).*(cosbeta + a./Rbar)) + ...
                    y2.*(y3bar-a).*sinbeta./(Rbar.*(Rbar+z3bar)).*(1 + (Rbar.*cosbeta+y3bar)./(Rbar+z3bar).*(cosbeta+a./Rbar) + a.*y3bar./(Rbar.*Rbar));
v1CB3             = v1CB3 ./ (4.*pi.*(1-nu));
v2CB3             = v2CB3 ./ (4.*pi.*(1-nu));
v3CB3             = v3CB3 ./ (4.*pi.*(1-nu));

v1B3              = B3.*(v1InfB3 + v1CB3);
v2B3              = B3.*(v2InfB3 + v2CB3);
v3B3              = B3.*(v3InfB3 + v3CB3);

