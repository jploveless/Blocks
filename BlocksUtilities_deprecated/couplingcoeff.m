function chi = couplingcoeff(p, slip, seg)
%
%  COUPLINGCOEFF calculates the coupling coefficient on triangular
%  mesh elements.
%  
%      CHI = COUPLINGCOEFF(P, SLIP, SEG) uses the geometry of the mesh 
%      contained in the structure P, the slip distribution in SLIP,
%      and the modeled fault slip rates SEG to calculate the coupling
%      coefficient on the mesh.  P, SLIP, and SEG can either be the 
%      loaded structures (read using READPATCHES, PATCHDATA, and 
%      READSEGMENT, respectively), or they may be the actual data structures
%      or arrays.  The coupling coefficient is returned to CHI.
%      
%      For all triangular elements, the function finds the closest segement
%      that has been replaced by that element's mesh, projects the segement
%      slip rate onto the dipping element, and determines the coupling
%      coefficient.
%     

% Process input data

% Check patches
if ischar(p)
   p = ReadPatches(p);
   p = PatchCoords(p);
elseif ~isfield(p, 'xc')
   p = PatchCoords(p);
end

% Check slip
if ischar(slip)
   [c, v, slip] = PatchData(slip);
end

% Check segments
if ischar(seg)
   seg = ReadSegmentTri(seg);
end
[seg.midLon seg.midLat] = deal((seg.lon1+seg.lon2)/2, (seg.lat1+seg.lat2)/2);

% Calculate element dips
[strike, dip] = findplane([p.x1 p.y1 p.z1], [p.x2 p.y2 p.z2], [p.x3 p.y3 p.z3]);

% Calculate coupling coefficients
chi = zeros(size(p.v, 1), 1);
cnel = cumsum([0 p.nEl]);

% For each patch,
for i = 1:numel(p.nEl)
   % Find all segments associated with this patch
   segs = find(seg.patchTog.*seg.patchFile == i);
   % Find the segment closest to each element
   k = dsearchn([seg.midLon(segs(:)) seg.midLat(segs(:))], [p.lonc(cnel(i)+1:cnel(i+1)) p.latc(cnel(i)+1:cnel(i+1))]);
   segs = segs(k);
   % Project the slip rate onto the element
   srate = mag([seg.ssRate(segs) seg.dsRate(segs) seg.tsRate(segs)], 2)./cosd(dip(cnel(i)+1:cnel(i+1)));
   % Calculate chi
   chi(cnel(i)+1:cnel(i+1)) = sign(slip(cnel(i)+1:cnel(i+1), 2)).*mag(slip(cnel(i)+1:cnel(i+1), 1:2), 2)./srate;
end