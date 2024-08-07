function [Patches, Command, Index] = ProcessPatches(Patches, Command, Segment)
% ProcessPatches   Carries out preliminary patches processing


if ~isempty(Command.patchFileNames)
   Patches                                       = ReadPatches(Command.patchFileNames); % Read triangulated patch files
   Patches.c(Patches.c(:, 1) < 0, 1)             = Patches.c(Patches.c(:, 1) < 0, 1) + 360; % Wrap to 360 longitudes
   Patches                                       = PatchEndAdjust(Patches, Segment); % Adjust patch end coordinates to agree with segment end points
   [Patches, Command]                            = TogglePatches(Patches, Segment, Command); % Adjust structure so that only the toggled-on patch data are retained
   Patches                                       = PatchCoords(Patches); % Create patch coordinate arrays
   if numel(Command.triSmooth) == 1
      Command.triSmooth                          = repmat(Command.triSmooth, 1, numel(Patches.nEl));
   elseif numel(Command.triSmooth) ~= numel(Patches.nEl)
      error('BLOCKS:SmoothNEqPatches', 'Smoothing magnitude must be a constant or array equal in size to the number of patches.');
   end
   % Beginning and ending element indices of each patch
   Index.pends                                   = cumsum(Patches.nEl(:));   
   Index.pbegs                                   = [1; Index.pends(1:end-1)+1];
   Index.pends2                                  = cumsum(2*Patches.nEl(:));
   Index.pbegs2                                  = [1; Index.pends(1:end-1)+1];
end