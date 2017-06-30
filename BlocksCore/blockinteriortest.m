function [tf, idx] = blockinteriortest(seg, ip)

% Determine interior point Cartesian coordinates
[ipx, ipy, ipz] = sph2cart(deg_to_rad(b.interiorLon), deg_to_rad(b.interiorLat), 6371);

% Calculate cross product of vectors between the interior points and a vertex, and the vertex and its adjacent vertex

% Components of vectors between nodes and interior points
ipvecx = repmat(segx(cind(:)), 1, nblock) - repmat(ipx(:)', length(cind), 1);
ipvecy = repmat(segy(cind(:)), 1, nblock) - repmat(ipy(:)', length(cind), 1);
ipvecz = repmat(segz(cind(:)), 1, nblock) - repmat(ipz(:)', length(cind), 1);

% Components of vectors between node and adjacent node
advecx = segx(cind([2:end, 1])') - segx(cind(:));
advecy = segy(cind([2:end, 1])') - segy(cind(:));
advecz = segz(cind([2:end, 1])') - segz(cind(:));

% Cross product components
cpx = sign(ipvecy.*repmat(advecz, 1, nblock) - ipvecz.*repmat(advecy, 1, nblock));
cpy = sign(ipvecz.*repmat(advecx, 1, nblock) - ipvecx.*repmat(advecz, 1, nblock));
cpz = sign(ipvecx.*repmat(advecy, 1, nblock) - ipvecy.*repmat(advecx, 1, nblock));

% Point(s) interior to this block have all the same sign z-components



% For each block vertex, determine the azimuth to both neighboring vertices
adjaz = sphereazimuth(repmat(sego(cind(:)), 1, 2), repmat(sega(cind(:)), 1, 2), sego([cind([end, 1:end-1])', cind([2:end, 1])']), sega([cind([end, 1:end-1])', cind([2:end, 1])']));
%adjaz(adjaz < 0) = adjaz(adjaz < 0) + 360;

% Now determine the azimuth to all interior points
ipaz = sphereazimuth(repmat(sego(cind(:)), 1, nblock), repmat(sega(cind(:)), 1, nblock), repmat(b.interiorLon(:)', length(cind), 1), repmat(b.interiorLat(:)', length(cind), 1));
%ipaz(ipaz < 0) = ipaz(ipaz < 0) + 360;

% Check the sign of the differences in azimuth. 
% If an interior point lies within this block, then these differences should be entirely counterclockwise
d1 = ipaz - repmat(adjaz(:, 1), 1, nblock);
d2 = repmat(adjaz(:, 2), 1, nblock) - ipaz;
d1(d1 < -180) = d1(d1 < -180) + 360;
d2(d2 < -180) = d2(d2 < -180) + 360;
s1 = sign(d1);
s2 = sign(d2);
bin = (sum(s1 > 0) == length(cind)) & (sum(s2 > 0) == length(cind));

% For each interior point, determine the projection of the ordered
% segment coordinates onto a plane whose pole is the interior point.





% Check sum of angles between the interior point and pairs of adjacent
% block bounding vertices

dx1 = ip -  
dy1 = 
dz1 = 
dx2 = 
dy2 = 
dz2 = 

% Triangulate the block, then check to see if the line pierces any element

% Check to see on which side of the line segment the interior point lies

