function Gp = xyz2enumat(G, az)
% xyz2enumat   Rotates a matrix of x, y, z vectors to E, N, U
%   GP = xyz2enumat(G, AZ) rotates the x, y, z values of matrix G 
%   to E, N, U by rotating about AZ, returning the rotated values
%   to matrix GP.  AZ can be a scalar, a vector of values equal
%   to the number of columns of G, or a vector of values equal to
%   the number of columns of G divided by 2 or 3 (reflecting columns
%   containing displacements due to slip components).  G is assumed 
%   to be structured so that rows contain [X; Y; Z] values for each
%   point and GP is returned as [E; N; U].
%   

% Check inputs
sa             = numel(az);
sG             = size(G);

if sa == 1
   az          = repmat(az, sG(1)/3, sG(2));
elseif sa == sG(2)
   az          = repmat(az(:)', sG(1)/3, 1);
elseif sa == sG(2)/3
   az          = repmat(reshape(repmat(az(:)', 3, 1), sG(2), 1)', sG(1)/3, 1); 
elseif sa == sG(2)/2
   az          = repmat(reshape(repmat(az(:)', 2, 1), sG(2), 1)', sG(1)/3, 1);
end

% Copy matrix
Gp             = G;

% Do rotation
caz            = cosd(az);
saz            = sind(az);
xid            = 1:3:sG(1);
yid            = 2:3:sG(1);
Gp(1:3:end, :) = caz.*G(xid, :) + -saz.*G(yid, :);
Gp(2:3:end, :) = saz.*G(xid, :) + caz.*G(yid, :);