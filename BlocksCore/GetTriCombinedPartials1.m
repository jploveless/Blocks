function [Gu, Ge, tz] = GetTriCombinedPartials(Patches, Station, op)
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
tz                                             = zeros(nPatches, 1);
tz(abs(Patches.dip - 90) > 1)                  = 2;
tz(tz == 0)                                    = 3;
[v1u v2u v3u]                                  = deal(cell(max(op(:, 1)), nPatches));
[v1e v2e v3e]                                  = deal(cell(max(op(:, 2)), nPatches));

% Do local oblique Mercator projection
[Patches, Station]                             = ProjectTriCoords(Patches, Station);

% Calculate the requested partials
if nPatches > 0
   parfor_progress(nPatches);
   parfor (i = 1:nPatches)
      % If displacement partials are requested...
      if sum(op(:, 1)) > 0
         % Calculate elastic displacement for all slip components
         [uxs uys uzs...
          uxd uyd uzd...
          uxt uyt uzt]                         = tri_dislz_partials([Patches.px1(i), Patches.px2(i), Patches.px3(i)], [Patches.py1(i), Patches.py2(i), Patches.py3(i)], abs([Patches.z1(i), Patches.z2(i), Patches.z3(i)]), Station.tpx(op(:, 1), i), Station.tpy(op(:, 1), i), abs(Station.z(op(:, 1))), 0.25);
	      v1u{i}                                = reshape(-[uxs uys -uzs]', 3*sum(op(:, 1)), 1);
	      v2u{i}                                = reshape(-[uxd uyd -uzd]', 3*sum(op(:, 1)), 1);
	      v3u{i}                                = reshape(-[uxt uyt -uzt]', 3*sum(op(:, 1)), 1);
	   end
      
      % If strain partials are requested...
      if sum(op(:, 2)) > 0
         % Calculate elastic strains for all slip components
         [uxxs uyys uzzs uxys uxzs uyzs...
          uxxd uyyd uzzd uxyd uxzd uyzd...
          uxxt uyyt uzzt uxyt uxzt uyzt]       = tri_strain_fast_partials([Patches.px1(i), Patches.px2(i), Patches.px3(i)], [Patches.py1(i), Patches.py2(i), Patches.py3(i)], abs([Patches.z1(i), Patches.z2(i), Patches.z3(i)]), Station.tpx(op(:, 1), i), Station.tpy(op(:, 1), i), abs(Station.z(op(:, 1))), 0.25);
         v1e{i}                                = reshape(-[uxxs uyys uzzs uxys uxzs uyzs]', 6*sum(op(:, 2)), 1);
         v2e{i}                                = reshape(-[uxxd uyyd uzzd uxyd uxzd uyzd]', 6*sum(op(:, 2)), 1);
         v3e{i}                                = reshape(-[uxxt uyyt uzzt uxyt uxzt uyzt]', 6*sum(op(:, 2)), 1);
	   end
      parfor_progress;
   end
   parfor_progress(0);
   % Place cells for each slip component into matrices
   if ~isempty(Gu)
      Gu(:, 1:3:end)                           = cell2mat(v1u);
      Gu(:, 2:3:end)                           = cell2mat(v2u);
      Gu(:, 3:3:end)                           = cell2mat(v3u);
      % Project using element strike to eliminate effects of local oblique projection
      Gu                                       = xyz2enumat(Gu, -Patches.Strike + 90);
   end 
   if ~isempty(Ge) 
      Ge(:, 1:3:end)                           = cell2mat(v1e);
      Ge(:, 2:3:end)                           = cell2mat(v2e);
      Ge(:, 3:3:end)                           = cell2mat(v3e);
      % Project using element strike to eliminate effects of local oblique projection
      Ge                                       = xyz2enumat_strain(Ge, -Patches.Strike + 90);
   end
end