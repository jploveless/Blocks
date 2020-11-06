function s = adjusthang(S, tol, outfile)
%

% Copy segment structure
s = S;
nseg = length(S.lon1);

% Check for hanging endpoints
lonVec = [S.lon1(:); S.lon2(:)];
latVec = [S.lat1(:); S.lat2(:)];
[uCoord1 uIdx1] = unique([lonVec latVec], 'rows', 'first');
[uCoord2 uIdx2] = unique([lonVec latVec], 'rows', 'last');
nOccur = uIdx2-uIdx1 + 1;
hang = nOccur == 1;
hangidx = find(hang);

% Construct hanging and full coordinate matrices
[lonhang, lonm] = meshgrid(uCoord1(hang, 1), lonVec);
[lathang, latm] = meshgrid(uCoord1(hang, 2), latVec);

% Calculate distance between hanging endpoints and all other endpoints
dis = distance(lathang(:), lonhang(:), latm(:), lonm(:), almanac('earth','ellipsoid','kilometers'));
dis = reshape(dis, size(lathang));
dis(dis == 0) = 1e23;
[~, minidx] = min(dis);

% Several checking operations on the hanging indices

% See if the closest point is another hanging point
si = sort([minidx(:), hangidx(:)], 2);
[ur, uidx] = unique(si, 'rows');
hangidx = hangidx(uidx);
minidx = minidx(uidx);

% Assign new endpoints to hanging points
% Operate with separate arrays for endpoints 1 and 2
s.lat1(hangidx(hangidx <= nseg)) = latVec(minidx(hangidx <= nseg));
s.lon1(hangidx(hangidx <= nseg)) = lonVec(minidx(hangidx <= nseg));
s.lat2(hangidx(hangidx > nseg)) = latVec(minidx(hangidx > nseg));
s.lon2(hangidx(hangidx > nseg)) = lonVec(minidx(hangidx > nseg));