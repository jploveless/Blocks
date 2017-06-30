function Partials = CheckExistingKernels(Command, Segment, Patches, Data, Sar)
%
% CheckExistingKernels checks to see if the specified existing elastic kernels
% can be used given the current segment, patch, and data geometrieSegment.
%
% Inputs:
%   Command = Command structure
%   Segemnt = Segment structure
%   Patches = Patches structure
%   Data    = Combined data structure
%   Sar     = SAR structure (needed for elastic Partials modification)
%
% Returns:
%   ek      = elastic kernel for segments
%   tk      = elastic kernel for triangular patches
%   tz      = matrix denoting strike, dip, tensile partials for patches
%   ts      = matrix defining strikes of elements
%   If a kernel can be used, it is loaded and returned to newBlockSegment.  If not, the size
%   of the output kernel is zero and a new kernel will be calculated subsequently.
%

Partials.elastic      = zeros(0, 3*numel(Segment.lon1));
Partials.tri          = zeros(0, 3*sum(Patches.nEl));
Partials.selastic     = zeros(0, 3*numel(Segment.lon1));
Partials.stri         = zeros(0, 3*sum(Patches.nEl));
tric                  = true; % Flag to indicate whether we should calculate triangular partials
[match, un2]          = deal([]);

if strcmpi(Command.reuseElastic, 'yes')

   % Find the directory in which the existing kernel exists
   pa = fileparts(Command.reuseElasticFile);

   % Load the accompanying segment, station, and SAR files
   os = ReadSegmentTri(sprintf('%s%sMod.segment', pa, filesep));
   ost = sprintf('%s%sMod.sta.data', pa, filesep);
   if ~exist(ost, 'file')
      ost = sprintf('%s%sMod.sta', pa, filesep);
   end
   ost = ReadStation(ost);
   if ~isempty(Sar.x)
      osar = ReadSarPred(sprintf('%s%sSar.pred', pa, filesep));
   else
      osar = Sar;
   end

   % Compare station coordinates for segmentSegment...
   % *nio refers to the index of the new stations in the old
   [stniotf, stnio] = ismember([Data.lon(1:Data.nSta) Data.lat(1:Data.nSta)], [ost.lon ost.lat], 'rows');
   stnio3 = stack3([3*stnio(:)-2 3*stnio(:)-1 3*stnio(:)]);
   [sarniotf, sarnio] = ismember([Sar.lon, Sar.lat], [osar.lon, osar.lat], 'rows');

   % If there are no new stations, match the old segments to new
   if (sum(~stniotf) == 0) + (sum(~sarniotf) == 0) == 2 
      [match, un1, un2] = MatchSegments(os, Segment);
   end

   % Independent check for triangles because a mismatch in number of triangles usually means total remeshing
   if ~isempty(Patches.c) && exist(sprintf('%s%sMod.patch', pa, filesep), 'file') % If we have triangles now, and triangles exist in the old directory, 
      [op.c, op.v] = PatchData(sprintf('%s%sMod.patch', pa, filesep)); % Load the old patch data
      op.nc = size(op.c, 1); op.nEl = size(op.v, 1);
      op = PatchCoords(op);
      if (sum(~stniotf) == 0) + (sum(~sarniotf) == 0) == 2 % If the numbers of coordinates and stations are equal,
         [tniotf, tnio] = ismember([Patches.lonc, Patches.latc, Patches.zc], [op.lonc op.latc op.zc], 'rows'); % This requires centroid coordinates to be identical; gives the new elements' indices in old
         tric = logical(sum(tnio) == 0); % Set tri. calc to false so that we'll reuse triangles, but we'll check later to get any new triangles
      end
   else
      tric = true;
   end   
   
   % Load and modify the rectangle elastic partials, if necessary
   if ~isempty(match) % Match has been calculated, which means that at least the size of the partials is the same
      load(Command.reuseElasticFile, 'elastic'); % Load the elastic partials for GPS stations
      load(Command.reuseElasticFile, 'selastic'); % Load the elastic partials for SAR coordinates
      if length(un1) + length(un2) > 0 % there are unique values, need to modify the elastic partials
         Partials.elastic = NaN(3*Data.nSta, 3*numel(Segment.lon1));
         Partials.selastic = NaN(Data.nSar, 3*numel(Segment.lon1));
         fullIdx1 = ([3*match(:, 1)-2; 3*match(:, 1)-1; 3*match(:, 1)]);
         fullIdx2 = ([3*match(:, 2)-2; 3*match(:, 2)-1; 3*match(:, 2)]);
         if size(match, 1) < size(os.lon1, 1)
             fprintf('\n  Extract subset of existing elastic kernels...');
         else
             fprintf('\n  Using existing elastic kernels...');
         end
         Partials.elastic(:, fullIdx2) = elastic(stnio3, fullIdx1); % Place the columns of matched segment into the new kernel
         Partials.selastic(:, fullIdx2) = selastic(sarnio, fullIdx1);
         
         % if we need to add any new segmentSegment...
         if ~isempty(un2)
            fprintf('\n  Modifying existing elastic kernel (GPS)...');
            % make a mini segment file containing only the new segments
            mods = structsubset(Segment, un2);
            % calculate the elastic partials for those segments
            ep = GetElasticPartials(mods, Data);
            [ep, sep] = SarPartials(ep, Sar);
            % place these partials into the larger partials array
            Partials.elastic(:, 3*un2(:)-2) = ep(:, 1:3:end);
            Partials.elastic(:, 3*un2(:)-1) = ep(:, 2:3:end);
            Partials.elastic(:, 3*un2(:)-0) = ep(:, 3:3:end);
            % Now operate on the SAR elastic kernel
            fprintf('\n  Modifying existing elastic kernel (SAR)...');
            Partials.selastic(:, 3*un2(:)-2) = sep(:, 1:3:end);
            Partials.selastic(:, 3*un2(:)-1) = sep(:, 2:3:end);
            Partials.selastic(:, 3*un2(:)-0) = sep(:, 3:3:end);
         end
      else
         fprintf('\n  Using existing elastic kernel (GPS)...');
         Partials.elastic = elastic(stnio3, :);

         fprintf('\n  Using existing elastic kernel (SAR)...');
         Partials.selastic = selastic(sarnio, :);
      end
   end
   
   % load the triangular partials, if necessary
   if tric == 0
      tnio3 = stack3([3*tnio(:)-2 3*tnio(:)-1 3*tnio(:)]);
      load(Command.reuseElasticFile, 'tri');
      load(Command.reuseElasticFile, 'stri');
      if numel(tnio) < sum(op.nEl)
         fprintf('\n  Extracting subset of existing triangular kernels...');
         % Place existing partials
         Partials.tri = tri(stnio3, tnio3);
         Partials.stri = stri(sarnio, tnio3);
      elseif numel(tnio) == sum(op.nEl)
         fprintf('\n  Using existing triangular kernels...');
         % Place existing partials
         Partials.tri = tri(stnio3, tnio3);
         Partials.stri = stri(sarnio, tnio3);
      else
         fprintf('\n  Modifying existing triangular kernels...');
         % Place existing partials
         Partials.tri = NaN(3*Data.nSta, 3*sum(Patches.nEl));
         Partials.stri = NaN(Data.nSar, 3*sum(Patches.nEl));
         % Calculate new partials
         currels = find(tnio); % Indices of elements that are already calculated
         tnio = tnio(currels);
         tnio3 = stack3([3*tnio(:)-2 3*tnio(:)-1 3*tnio(:)]);
         calcels = setdiff(1:sum(Patches.nEl), currels); % Determine which elements need calculating
         calcels3 = stack3([3*calcels(:)-2 3*calcels(:)-1 3*calcels(:)]);
         currels3 = stack3([3*currels(:)-2 3*currels(:)-1 3*currels(:)]);
         calcels = patchsubset(Patches, calcels);
         et = GetTriCombinedPartials(calcels, Data, [1 0]);
         [et, set] = SarPartials(et, Sar);
         Partials.tri(:, currels3) = tri(stnio3, tnio3);
         Partials.tri(:, calcels3) = et;
         Partials.stri(:, currels3) = tri(sarnio, tnio3);
         Partials.stri(:, calcels3) = set;
      end
   end
end
fprintf('\n');