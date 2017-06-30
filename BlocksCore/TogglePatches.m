function [np, nc] = TogglePatches(p, s, c)
% TOGGLEPATCHES   Adjusts the patch structure to accommodate segment toggling.
%    [NP, NC, UP, UUE] = TOGGLEPATCHES(P, S) adjusts the patch structure P and 
%    command structure C based on the segment patch toggles in segment structure
%    S and returns new, adjusted structures NP and NC.  Added to NP are fields up,
%    a vector containing the indices of used patches, and uue, the indices of the
%    unused elements.  The function uses S.patchFile and S.patchTog to determine
%    which elements of the patch structure should be retained.
%

% Replicate the structures
np = p;
nc = c;

% Cumulative number of elements
cel = [0; cumsum(p.nEl(:))]';

% Empty arrays for retained patches and discarded elements
np.up = 1:length(p.nEl); np.uue = []; 
j = 0;
for i = 1:numel(p.nEl)
   j = j+1;
   ps = intersect(find(s.patchFile == i), find(s.patchTog > 0)); % determine which segments belong to the patch
   if isempty(ps) % if no segments corresponding to this patch are turned on, 
      np.v(cel(j)+1:cel(j+1), :) = []; % delete the corresponding elements
      np.nEl(j) = []; % and the length of the element number array
      nc.triSmooth(j) = []; % and the smoothing array
      nc.triEdge(3*j-2:3*j) = []; % and the boundary condition array
      np.up(j) = [];
      np.uue = [np.uue, cel(j)+1:cel(j+1)];
      cel = [0 cel(j+2:end)-cel(j+1)];
      j = j-1; 
   end
end

