function [G, Patches] = GetTriSlipPartials(Patches, Block, Segment)
% Calculate slip partial derivatives for triangular elements
nPatches                                           = sum(Patches.nEl);
nBlocks                                            = numel(Block.eulerLon);
G                                                  = zeros(3*nPatches, 3*nBlocks);
[Patches.patchNum, ...       
 Patches.eastLabel, ...       
 Patches.westLabel]                                = deal(zeros(nPatches, 1));
[Patches.xxc, Patches.yyc, Patches.zzc]            = sph2cart(deg2rad(Patches.lonc), deg2rad(Patches.latc), 6371 - abs(Patches.zc));
 
% Determine which blocks lie on either side of each patch

% Find segments that are replaced by patches 
psi                                                = intersect(find(Segment.patchFile), find(Segment.patchTog));
% Calculate segment strikes, for comparison to element strikes
Segment.strike                                     = sphereazimuth(Segment.lon1, Segment.lat1, Segment.lon2, Segment.lat2);
Seg                                                = structsubset(Segment, psi);
rhrstrike                                          = Seg.strike + 180*(Seg.dip > 90);

% Switch the zeroing array
tz                                                 = Patches.tz;
tz(Patches.tz == 2)                                = 3;
tz(Patches.tz == 3)                                = 2;

% Strike correction: Elements that dip > 90 
nscorr                                             = false(nPatches, 1);
ewcorr                                             = nscorr;
nscorr(Patches.strike > 0 & Patches.strike < 180)  = true;
ewcorr(Patches.strike < 270 & Patches.strike > 90) = true;

for iPatch = 1:nPatches
   % Find which mesh this TDE belongs to
   Patches.patchNum(iPatch)                        = find(1+[0; cumsum(Patches.nEl)] <= iPatch, 1, 'last');
   % Find all segments corresponding to that mesh  
   nseg                                            = find(Seg.patchFile == Patches.patchNum(iPatch));
   useLons                                         = Seg.midLon(nseg);
   useLats                                         = Seg.midLat(nseg);
   % Find the segment that is closest to this element
   nsegInd                                         = dsearchn([useLons(:) useLats(:)], [Patches.lonc(iPatch) Patches.latc(iPatch)]);
   % Assign segment and its block labels to a new field of the structure
   Patches.nearSeg(iPatch)                         = nseg(nsegInd);
   Patches.eastLabel(iPatch)                       = Seg.eastLabel(Patches.nearSeg(iPatch));
   Patches.westLabel(iPatch)                       = Seg.westLabel(Patches.nearSeg(iPatch));
    
   % Projection from Cartesian to spherical coordinates at element centroids
   rowIdx                                          = (iPatch-1)*3+1;
   colIdxE                                         = (Patches.eastLabel(iPatch)-1)*3+1;
   colIdxW                                         = (Patches.westLabel(iPatch)-1)*3+1;
   R                                               = GetCrossPartials([Patches.xxc(iPatch) Patches.yyc(iPatch) Patches.zzc(iPatch)]);
   [vn_wx, ve_wx, vu_wx]                           = CartVecToSphVec(R(1,1), R(2,1), R(3,1), Patches.lonc(iPatch), Patches.latc(iPatch));
   [vn_wy, ve_wy, vu_wy]                           = CartVecToSphVec(R(1,2), R(2,2), R(3,2), Patches.lonc(iPatch), Patches.latc(iPatch));
   [vn_wz, ve_wz, vu_wz]                           = CartVecToSphVec(R(1,3), R(2,3), R(3,3), Patches.lonc(iPatch), Patches.latc(iPatch));
  
   % Use strike and dip to resolve slip onto plane
   R                                               = [ve_wx vn_wx vu_wx; ve_wy vn_wy vu_wy; ve_wz vn_wz vu_wz]';
   strike                                          = Patches.strike(iPatch);
   rot                                             = [sind(strike), cosd(strike), 0; cosd(strike), -sind(strike), 0; 0, 0, 1];
   R                                               = rot*R;
   R(1, :)                                         = R(1, :); % Consistent with negative dextral slip
   R(2, :)                                         = -R(2, :)./abs(cosd(Patches.dip(iPatch))); % Correct horizontal motion by dip
   R(3, :)                                         = R(2, :); % Tensile slip 
   R(tz(iPatch), :)                                = [0 0 0]; % Set one perpendicular component to zero

   % Compare element azimuth to segment azimuth. If they are on different sides of E-W, we need to flip labels
   % If the following is a true, the segment has a southerly strike, and if false, it has a northerly strike
   Patches.nssegtest(iPatch)                       = rhrstrike(Patches.nearSeg(iPatch)) < 180 & rhrstrike(Patches.nearSeg(iPatch)) > 0;
   Patches.ewsegtest(iPatch)                       = rhrstrike(Patches.nearSeg(iPatch)) < 270 & rhrstrike(Patches.nearSeg(iPatch)) > 90;
   Rcorr                                           = 1;
   Rcorr(Patches.ewsegtest(iPatch))                = -1;

   % Place into appropriate columns
   G(rowIdx:rowIdx+2,colIdxE:colIdxE+2)            = Rcorr*R;
   G(rowIdx:rowIdx+2,colIdxW:colIdxW+2)            = Rcorr*-R;
end