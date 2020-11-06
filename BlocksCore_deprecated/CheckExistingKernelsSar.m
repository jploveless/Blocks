function Partials = CheckExistingKernels(c, s, p, st, sar);
%
% CheckExistingKernels checks to see if the specified existing elastic kernels
% can be used given the current segment, patch, and data geometries.
%
% Inputs:
%   c       = Command structure
%   s       = Segment structure
%   p       = Patches structure
%   st      = Station structure
%   sar     = SAR structure
%
% Returns:
%   ek      = elastic kernel for segments
%   tk      = elastic kernel for triangular patches
%   tz      = matrix denoting strike, dip, tensile partials for patches
%   ts      = matrix defining strikes of elements
%   If a kernel can be used, it is loaded and returned to newBlocks.  If not, the size
%   of the output kernel is zero and a new kernel will be calculated subsequently.
%

[Partials.elastic, Partials.selastic, Partials.tri, Partials.stri]  = deal(zeros(3*numel(st.lon), 0));
[segc, tric]      = deal(1);
[match, un1, un2] = deal([]);

if strcmp(c.reuseElastic, 'yes') == 1;
   % find the directory in which the existing kernel exists
   pa = fileparts(c.reuseElasticFile);
   
   % load the accompanying segment, station, and SAR files
   os = ReadSegmentTri(sprintf('%sMod.segment', pa));
   ost = ReadStation(sprintf('%sMod.sta.data', pa));
   osar = load(sprintf('%sSar.pred', pa));
   sareq = isequal(sortrows([sar.lon sar.lat]), sortrows(osar(:, 1:2)));
   
   % Compare coordinates for segments...
   if numel(ost.lon) >= numel(st.lon) % If the number of stations is the same or greater
      [match, un1, un2] = MatchSegments(os, s);
   end
   
   % ...and triangles
   if ~isempty(p.c) & exist(sprintf('%sMod.patch', pa), 'file') % If we have triangles now, and triangles exist in the old directory, 
      [oc, ov] = PatchData(sprintf('%sMod.patch', pa)); % Load the old patch data
      if numel(oc) == numel(p.c) & numel(ost.lon) == numel(st.lon) % If the numbers of triangles and stations are equal,
         dc = abs(oc - p.c); % Find the difference between coordinate locations
         tric = max(dc(:)) > 1e-4; % Logical statement about identical mesh; 0 means identical
      end
   else
      tric = 1;
   end   
   
   % load and modify the rectangle elastic partials, if necessary
   if ~isempty(match) % match has been calculated, which mean that at least the size of the partials is the same
      load(c.reuseElasticFile, 'elastic'); % Load the elastic partials for GPS stations
      load(c.reuseElasticFile, 'selastic'); % Load the elastic partials for SAR coordinates
      if any(~isempty([un1 un2])) % there are unique values, need to modify the elastic partials
         fprintf('\n  Modifying existing elastic kernel (GPS)...');
         Partials.elastic = NaN(3*numel(st.lon), 3*numel(s.lon1));
         fullIdx1 = ([3*match(:, 1)-2; 3*match(:, 1)-1; 3*match(:, 1)]);
         fullIdx2 = ([3*match(:, 2)-2; 3*match(:, 2)-1; 3*match(:, 2)]);

         Partials.elastic(:, fullIdx2) = elastic(:, fullIdx1); % place the columns of matched segment into the new kernel
         
         % if we need to add any new segments...
         if ~isempty(un2)
            % make a mini segment file containing only the new segments
            mods = structsubset(s, un2);
            % calculate the elastic partials for those segments
            ep = GetElasticPartials(mods, st);
            % place these partials into the larger partials array
            Partials.elastic(:, 3*un2(:)-2) = ep(:, 1:3:end);
            Partials.elastic(:, 3*un2(:)-1) = ep(:, 2:3:end);
            Partials.elastic(:, 3*un2(:)-0) = ep(:, 3:3:end);
            % Now operate on the SAR elastic kernel
            if sareq
               fprintf('\n  Modifying existing elastic kernel (SAR)...');
               Partials.selastic = NaN(numel(sar.lon), 3*numel(s.lon1));
               Partials.selastic(:, fullIdx2) = selastic(:, fullIdx1);
               eps = GetSarElasticPartials(mods, sar, sar.look_vec);
               Partials.selastic(:, 3*un2(:)-2) = eps(:, 1:3:end);
               Partials.selastic(:, 3*un2(:)-1) = eps(:, 2:3:end);
               Partials.selastic(:, 3*un2(:)-0) = eps(:, 3:3:end);
            end
         else
            Partials.elastic(:, Partials.elastic(ek(1, :))) = [];
            if sareq
               Partials.selastic(:, isnan(Partials.selastic(1, :))) = [];
            end
         end
      else
         fprintf('\n  Using existing elastic kernel (GPS)...');
         Partials.elastic = elastic;
         if sareq
            fprintf('\n  Using existing elastic kernel (SAR)...');
            Partials.selastic = selastic;
         end
      end
   end
   % load the triangular partials, if necessary
   if tric == 0
      fprintf('\n  Using existing triangular kernel (GPS)...');
      Partials.tri = getfield(load(c.reuseElasticFile, 'tri'), 'tri');
      if sareq
         fprintf('\n  Using existing triangular kernel (SAR)...');
         Partials.stri = getfield(load(c.reuseElasticFile, 'stri'), 'stri');
      end
      if ~isempty(p.uue)
         fprintf('\n     Extracting subset of existing triangular kernel...');
         uue3 = [3*p.uue(:)-2 3*p.uue(:)-1 3*p.uue(:)];
         Partials.tri(:, uue3(:)) = [];
         tz(p.uue) = [];
         ts(p.uue) = [];
      end
   end
end   

