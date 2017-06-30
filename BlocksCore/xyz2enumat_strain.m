function Gp = xyz2enumat_strain(G, az)
% xyz2enumat_strain   Rotates a strain matrix of x, y, z vectors to E, N, U
%   GP = xyz2enumat_strain(G, AZ) rotates the x, y, z values of matrix G 
%   to E, N, U by rotating about AZ, returning the rotated values
%   to matrix GP.  AZ can be a scalar, a vector of values equal
%   to the number of columns of G, or a vector of values equal to
%   the number of columns of G divided by 2 or 3 (reflecting columns
%   containing displacements due to slip components).  G is assumed 
%   to be structured so that rows contain [EXX; EYY; EZZ; EXY; EXZ; EYZ] 
%   values for each point and GP is returned as [EEE; ENN; EUU; EEN; EEU; ENZ].
%   

% Check inputs
sa             = numel(az);
sG             = size(G);

if sa == 1
   az          = repmat(az, sG(1)/6, sG(2));
elseif sa == sG(2)
   az          = repmat(az(:)', sG(1)/6, 1);
elseif sa == sG(2)/3
   az          = repmat(reshape(repmat(az(:)', 3, 1), sG(2), 1)', sG(1)/6, 1); 
elseif sa == sG(2)/2
   az          = repmat(reshape(repmat(az(:)', 2, 1), sG(2), 1)', sG(1)/6, 1);
end

% Copy matrix
Gp             = G;

% Extract tensor components
uxx            = G(1:6:end, :);
uyy            = G(2:6:end, :);
uzz            = G(3:6:end, :);
uxy            = G(4:6:end, :);
uxz            = G(5:6:end, :);
uyz            = G(6:6:end, :);

% Do rotation
caz            = cosd(az);
saz            = sind(az);
Gp(1:6:end, :) = caz.*(uxx.*caz - uxy.*saz) - saz.*(uxy.*caz - uyy.*saz);
Gp(4:6:end, :) = caz.*(uxy.*caz - uyy.*saz) + saz.*(uxx.*caz - uxy.*saz);
Gp(5:6:end, :) = uxz.*caz - uyz.*saz;
Gp(2:6:end, :) = caz.*(uyy.*caz + uxy.*saz) + saz.*(uxy.*caz + uxx.*saz);
Gp(6:6:end, :) = uyz.*caz + uxz.*saz;

 