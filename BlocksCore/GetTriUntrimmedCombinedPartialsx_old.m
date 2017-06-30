function [Gu, Ge, tz] = GetTriUntrimmedCombinedPartialsx(Patches, Station, op)
% Calculate elastic displacement and/or strain partial derivatives for triangular elements
% 
%   [Gu, Ge, tz, strike, dip] = GetTriCombinedPartials(Patches, Station, option)
%
%   Output arguments:
%   Gu : Displacement partials
%   Ge : Strain partials
%   tz : Zeroing array
%   strike : element strikes
%   dip : element dips
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

% Process options variable
op = logical(op);
if size(op, 1) == 1
   op = repmat(op, nStations, 1);
end

% Initialize variables
nStations                                      = numel(Station.x);
nPatches                                       = numel(Patches.x1);
Gu                                             = zeros(3*sum(op(:, 1)), 3*nPatches);
Ge                                             = zeros(6*sum(op(:, 2)), 3*nPatches);
tz                                             = zeros(nPatches, 1);
tz(abs(Patches.dip - 90) > 1)                  = 2;
tz(tz == 0)                                    = 3;
[v1u v2u v3u]                                  = deal(cell(max(op(:, 1)), nPatches));
[v1e v2e v3e]                                  = deal(cell(max(op(:, 2)), nPatches));

% Calculate the requested partials
if nPatches > 0
   parfor_progress(nPatches);
   parfor (iPatches = 1:nPatches)
      if sum(op(:, 1)) > 0
         % Calculate elastic displacement for strike slip component
         [ux, uy, uz]                          = tri_dislz([Patches.x1(iPatches), Patches.x2(iPatches), Patches.x3(iPatches)], [Patches.y1(iPatches), Patches.y2(iPatches), Patches.y3(iPatches)], abs([Patches.z1(iPatches), Patches.z2(iPatches), Patches.z3(iPatches)]), Station.x(op(:, 1)), Station.y(op(:, 1)), abs(Station.z(op(:, 1))), -1, 0, 0, 0.25);
	      v1u{iPatches}                         = reshape([ux uy uz]', 3*sum(op(:, 1)), 1);
	      [ux, uy, uz]                          = tri_dislz([Patches.x1(iPatches), Patches.x2(iPatches), Patches.x3(iPatches)], [Patches.y1(iPatches), Patches.y2(iPatches), Patches.y3(iPatches)], abs([Patches.z1(iPatches), Patches.z2(iPatches), Patches.z3(iPatches)]), Station.x(op(:, 1)), Station.y(op(:, 1)), abs(Station.z(op(:, 1))), 0, -1, 0, 0.25);
	      v2u{iPatches}                         = reshape([ux uy uz]', 3*sum(op(:, 1)), 1);
	      [ux, uy, uz]                          = tri_dislz([Patches.x1(iPatches), Patches.x2(iPatches), Patches.x3(iPatches)], [Patches.y1(iPatches), Patches.y2(iPatches), Patches.y3(iPatches)], abs([Patches.z1(iPatches), Patches.z2(iPatches), Patches.z3(iPatches)]), Station.x(op(:, 1)), Station.y(op(:, 1)), abs(Station.z(op(:, 1))), 0, 0, -1, 0.25);
	      v3u{iPatches}                         = reshape([ux uy uz]', 3*sum(op(:, 1)), 1);
	   end
   
      if sum(op(:, 2)) > 0
         [uxx, uyy, uzz,...
          uxy, uxz, uyz, nv]                   = tri_strain_fast([Patches.x1(iPatches) Patches.x2(iPatches) Patches.x3(iPatches)], [Patches.y1(iPatches) Patches.y2(iPatches) Patches.y3(iPatches)], abs([Patches.z1(iPatches) Patches.z2(iPatches) Patches.z3(iPatches)]), Station.x(op(:, 2)), Station.y(op(:, 2)), abs(Station.z(op(:, 2))), -1, 0, 0, 0.25);
         v1e{iPatches}                         = reshape([uxx uyy uzz uxy uxz uyz]', 6*sum(op(:, 2)), 1);
         [uxx, uyy, uzz,...
          uxy, uxz, uyz]                       = tri_strain_fast([Patches.x1(iPatches) Patches.x2(iPatches) Patches.x3(iPatches)], [Patches.y1(iPatches) Patches.y2(iPatches) Patches.y3(iPatches)], abs([Patches.z1(iPatches) Patches.z2(iPatches) Patches.z3(iPatches)]), Station.x(op(:, 2)), Station.y(op(:, 2)), abs(Station.z(op(:, 2))), 0, -1, 0, 0.25);
         v2e{iPatches}                         = reshape([uxx uyy uzz uxy uxz uyz]', 6*sum(op(:, 2)), 1);
         [uxx, uyy, uzz,...
          uxy, uxz, uyz]                       = tri_strain_fast([Patches.x1(iPatches) Patches.x2(iPatches) Patches.x3(iPatches)], [Patches.y1(iPatches) Patches.y2(iPatches) Patches.y3(iPatches)], abs([Patches.z1(iPatches) Patches.z2(iPatches) Patches.z3(iPatches)]), Station.x(op(:, 2)), Station.y(op(:, 2)), abs(Station.z(op(:, 2))), 0, 0, -1, 0.25);
         v3e{iPatches}                         = reshape([uxx uyy uzz uxy uxz uyz]', 6*sum(op(:, 2)), 1);
      end
      parfor_progress;
   end
   parfor_progress(0);
   % Place cells for each slip component into matrices
   keyboard
   Gu(:, 1:3:end) = cell2mat(v1u);
   Gu(:, 2:3:end) = cell2mat(v2u);
   Gu(:, 3:3:end) = cell2mat(v3u);
   Ge(:, 1:3:end) = cell2mat(v1e);
   Ge(:, 2:3:end) = cell2mat(v2e);
   Ge(:, 3:3:end) = cell2mat(v3e);
end