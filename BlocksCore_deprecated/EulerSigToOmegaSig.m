function [sx, sy, sz,...
          xycorr, yzcorr, xzcorr] = EulerSigToOmegaSig(x, y, z, varargin)
% EULERSIGTOOMEGASIG  Converts Euler pole uncertainties to Cartesian equivalents
%    [SX, SY, SZ] = EULERSIGTOOMEGASIG(X, Y, Z, SLAT, SLON, SRATE) converts the 
%    Euler pole rotation uncertainties SLAT, SLON, SRATE (in radians) to the
%    Cartesian equivalents, SX, SY, and SZ.
%
%    [SX, SY, SZ] = EULERSIGTOOMEGASIG(X, Y, Z, EULERCOV) converts the covariance
%    matrix EULERCOV to Cartesian uncertainties.  EULERCOV should be either a 
%    vector or diagonal matrix of structure
%    [SLAT(1)^2; SLON(1)^2; SRATE(1)^2; ... ; SLAT(N)^2; SLON(N)^2; SRATE(N)^2]
%

no = numel(x); no3 = 3*no;
         
if length(varargin) == 3
   slat = varargin{1}; slon = varargin{2}; srat = varargin{3};
   eulercov = zeros(no3, 1);
   eulercov(1:3:end) = sqrt(slat); eulercov(2:3:end) = sqrt(slon); eulercov(3:3:end) = sqrt(srat);
   eulercov = diag(eulercov);
elseif length(varargin) == 1
   eulercov = varargin{1};
   if min(size(eulercov)) == 1
      eulercov = diag(eulercov);
   end
end
         
hxy = hypot(x, y);
hxyz = hypot(hxy, z);

% Calculate partial derivatives
dlat_dx = -z./hxy.^3./(1 + z.^2./(x.^2 + y.^2)).*x;
dlat_dy = -z./hxy.^3./(1 + z.^2./(x.^2 + y.^2)).*y;
dlat_dz = 1./hxy./(1 + z.^2./(x.^2 + y.^2));
dlon_dx = -y./x.^2./(1 + y.^2./x.^2);
dlon_dx = 1./x./(1 + y.^2./x.^2);
dlon_dz = 0;
drat_dx = x./hxyz;
drat_dy = y./hxyz;
drat_dz = z./hxyz;

% Assemble into block-diagonal matrix
A = zeros(no3);
one = 3*(1:no)-2;
two = 3*(1:no)-1;
thr = 3*(1:no)-0;
A(sub2ind([no3 no3], one, one)) = dlat_dx;
A(sub2ind([no3 no3], one, two)) = dlat_dy;
A(sub2ind([no3 no3], one, thr)) = dlat_dz;
A(sub2ind([no3 no3], two, one)) = dlon_dx;
A(sub2ind([no3 no3], two, two)) = dlon_dx;
A(sub2ind([no3 no3], two, thr)) = dlon_dz;
A(sub2ind([no3 no3], thr, one)) = drat_dx;
A(sub2ind([no3 no3], thr, two)) = drat_dy;
A(sub2ind([no3 no3], thr, thr)) = drat_dz;

% Do the covariance matrix transformation
iA = A\ones(no3);
omegacov = iA*eulercov*iA';

% Gather results
doc = diag(omegacov);
sx = sqrt(doc(1:3:end));
sy = sqrt(doc(2:3:end));
sz = sqrt(doc(3:3:end));
