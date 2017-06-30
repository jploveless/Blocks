function varargout = findplane(v1,v2,v3);

% Function findplane uses the Cartesian coordinates of three points to find
% the equation of the plane on which they lie.
%
% The plane is described as:
% Ax + By + Cz + D = 0
%
% v1, v2, v3 are n x 3 vectors containing the x, y, z coordinates
% of n sets of 3 points that define n planes.
%
% Output A, B, C, and D are coefficients of the plane equation
% Output s and d are the strike and dip, respectively, of the plane
% SYNTAX: 
% [A,B,C,D]					 	= findplane(v1,v2,v3), 
% [A,B,C,D,strike,dip] 		= findplane(v1,v2,v3) 
% or:
% [strike,dip] 				= findplane(v1,v2,v3)
%
% The vector (A,B,C) describes the normal (pole) to the plane
% 
% From Paul Bourke website, coded by J. Loveless, 18 Feb. 2005

A = v1(:,2).*(v2(:,3)-v3(:,3)) + v2(:,2).*(v3(:,3)-v1(:,3)) + v3(:,2).*(v1(:,3)-v2(:,3));
B = v1(:,3).*(v2(:,1)-v3(:,1)) + v2(:,3).*(v3(:,1)-v1(:,1)) + v3(:,3).*(v1(:,1)-v2(:,1));
C = v1(:,1).*(v2(:,2)-v3(:,2)) + v2(:,1).*(v3(:,2)-v1(:,2)) + v3(:,1).*(v1(:,2)-v2(:,2));
D = -(v1(:,1).*(v2(:,2).*v3(:,3)-v3(:,2).*v2(:,3)) + v2(:,1).*(v3(:,2).*v1(:,3)-v1(:,2).*v3(:,3)) + v3(:,1).*(v1(:,2).*v2(:,3)-v2(:,2).*v1(:,3)));

% determine strike and dip
[s, d, r] = cart2sph(A, B, C);

strike = -s*180/pi; % negative because cart2sph outputs pole trend as positive CCW from azimuth 90
dip = 90-abs(d*180/pi); % trend of pole is output by cart2sph
if d
   dip = sign(d)*dip;
end

if nargout == 4;
	 varargout(1:4) = {A, B, C, D};
elseif nargout == 6;
    varargout(1:6) = {A, B, C, D, strike, dip};
elseif nargout == 2;
    varargout(1:2) = {strike, dip};
else 
    error('ErrorTests:inperr','\n Invalid number of outputs.\n Enter either:\n    [A,B,C,D,strike,dip] = findplane(v1,v2,v3)\n or\n    [strike,dip] findplane(v1,v2,v3)')
end