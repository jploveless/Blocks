function lockingDepths = PatchLDtoggle(lockingDepths, patchFiles, patchToggles, patchNames)
%
% PatchLDtoggle sets the locking depth to zero on segments that are associated
% with a patch. 
%
% Arguments:
%   lockingDepths = locking depth field of the segment array (i.e., Segment.lDep)
%   patchFiles    = array containing the numeric ID of the patch file corresponding to each segment (range 0:n)
%   patchToggles  = array containing 0 or 1 to specify whether a patch file should be ignored (0) or used (1)
%   patchNames    = string from command file containing 
%
% Outputs:
%   Segment       = updated locking depth array, containing zeros for the segments to be replaced by patches
%

% Check the number of files that are included
if size(patchNames, 1) == 1
   npf                = ~isempty(patchNames) + length(regexp(patchNames, '\s\S'));
else
   npf                = size(patchNames, 1);
end

% find the segments actively associated with a patch file
i                     = intersect(find(patchFiles), find(patchToggles == 1));
if max(patchFiles(i)) == npf
   % set those segments' LDs to 0
   lockingDepths(i)   = 0;
   % This function is called after LockingDepthManager, so no need to worry about LD toggles
   % affecting the zero LD assigned here.
else
   warning('Fewer patch filenames specified in Command file than referenced in Segment structure.')
   return
end
