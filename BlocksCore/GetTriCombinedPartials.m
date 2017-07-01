function [Gu, Ge, Patches, Station] = GetTriCombinedPartials(Patches, Station, op)
% Calculate elastic displacement and/or strain partial derivatives for triangular elements
% 
%   [Gu, Ge, tz] = GetTriCombinedPartials(Patches, Station, option)
%
%   Output arguments:
%   Gu : Displacement partials
%   Ge : Strain partials
%   tz : Zeroing array
%
%   Input arguments:
%   Patches : Patches structure
%   Station : Station structure
%   option : Flag vector indicating which partials should be calculated
%            The first element indicates whether displacement partials should be calculated,
%            and the second whether strain partials should be calculated, using the convention
%            0 = don't calculate, 1 = calculate.
%
%            option can also be an n-by-2 array, with each row corresponding to a row in the 
%            Station structure's fields.  This may cut down on calculation time, only calculating
%            the partials at the specified observation coordinates
%

% Initialize variables
nStations                                      = numel(Station.lon);
% Process options variable
op = logical(op);
if size(op, 1) == 1
   op                                          = repmat(op, nStations, 1);
end
nPatches                                       = numel(Patches.lon1);
Gu                                             = zeros(3*sum(op(:, 1)), 3*nPatches);
Ge                                             = zeros(6*sum(op(:, 2)), 3*nPatches);
Patches.tz                                     = zeros(nPatches, 1);
Patches.tz(abs(Patches.dip - 90) > 1)          = 2;
Patches.tz(Patches.tz == 0)                    = 3;
[v1u, v2u, v3u]                                = deal(cell(max(op(:, 1)), nPatches));
[v1e, v2e, v3e]                                = deal(cell(max(op(:, 2)), nPatches));
projstrikes                                    = zeros(sum(Patches.nEl), 1);

% Calculate the requested partials
if nPatches > 0
   parfor (iPatches = 1:nPatches)
      % Do local oblique Mercator projection
      [p, s]                                   = ProjectTriCoords([Patches.lon1(iPatches) Patches.lat1(iPatches) Patches.z1(iPatches) Patches.lon2(iPatches) Patches.lat2(iPatches) Patches.z2(iPatches) Patches.lon3(iPatches) Patches.lat3(iPatches) Patches.z3(iPatches)], Station);
      projstrikes(iPatches)                    = p.Strike;
      % If displacement partials are requested...
      if sum(op(:, 1)) > 0
         % Calculate elastic displacement for strike slip component
         [uxs, uys, uzs,...
          uxd, uyd, uzd,...
          uxt, uyt, uzt]                       = tri_dislz_partials([p.px1, p.px2, p.px3], [p.py1, p.py2, p.py3], abs([p.z1, p.z2, p.z3]), s.tpx(op(:, 1)), s.tpy(op(:, 1)), abs(s.dep(op(:, 1))), 0.25);
	      v1u{iPatches}                         = reshape(-[uxs uys -uzs]', 3*sum(op(:, 1)), 1);
	      v2u{iPatches}                         = reshape(-[uxd uyd -uzd]', 3*sum(op(:, 1)), 1);
	      v3u{iPatches}                         = reshape(-[uxt uyt -uzt]', 3*sum(op(:, 1)), 1);
	  end
      
      % If strain partials are requested...
      if sum(op(:, 2)) > 0
         [uxxs, uyys, uzzs, uxys, uxzs, uyzs,...
          uxxd, uyyd, uzzd, uxyd, uxzd, uyzd,...
          uxxt, uyyt, uzzt, uxyt, uxzt, uyzt]  = tri_strain_fast_partials([p.px1, p.px2, p.px3], [p.py1, p.py2, p.py3], abs([p.z1, p.z2, p.z3]), s.tpx(op(:, 2)), s.tpy(op(:, 2)), abs(s.dep(op(:, 2))), 0.25);
         v1e{iPatches}                         = reshape(-[uxxs uyys uzzs uxys -uxzs -uyzs]', 6*sum(op(:, 2)), 1);
         v2e{iPatches}                         = reshape(-[uxxd uyyd uzzd uxyd -uxzd -uyzd]', 6*sum(op(:, 2)), 1);
         v3e{iPatches}                         = reshape(-[uxxt uyyt uzzt uxyt -uxzt -uyzt]', 6*sum(op(:, 2)), 1);
	  end
%      parfor_progress;

   end
%   parfor_progress(0);

   % Place cells for each slip component into matrices
   if ~isempty(Gu)
      Gu(:, 1:3:end)                           = cell2mat(v1u);
      Gu(:, 2:3:end)                           = cell2mat(v2u);
      Gu(:, 3:3:end)                           = cell2mat(v3u);
      % Project using element strike to eliminate effects of local oblique projection
      Gu                                       = xyz2enumat(Gu, -projstrikes + 90);
   end 
   if ~isempty(Ge) 
      Ge(:, 1:3:end)                           = cell2mat(v1e);
      Ge(:, 2:3:end)                           = cell2mat(v2e);
      Ge(:, 3:3:end)                           = cell2mat(v3e);
      % Project using element strike to eliminate effects of local oblique projection
      Ge                                       = xyz2enumat_strain(Ge, -projstrikes + 90);
   end
   Patches.Strike                              = projstrikes;
end