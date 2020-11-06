function [ek, tk, tz, ts] = CheckExistingKernelsNew(c, s, st, p);
%
% CheckExistingKernels checks to see if the specified existing elastic kernels
% can be used given the current segment and patch geometries.  This new version
% also allows alternate partials to be inserted into the matrix on a station-by-
% station basis.  The rationale for this is that we may want to use the standard
% homogeneous partials for far-field stations and partials calculated for a 
% heterogeneous medium within a specific region of interest.  This is controlled
% using the toggle option within the station structure.  A station toggle of 0 
% still toggles the station off, but now a toggle value greater than 1 will refer
% to the names of elastic kernel files specified in the command file.  These 
% kernel .mat files must contains the kernels (as variables "elastic" and "tri")
% as well as "station", "segment", and "patch" structures so that coordinates
% can be compared with the current model's geometric elements.
% 
%
% Inputs:
%   c       = Command structure
%   s       = Segment structure
%   st      = Station structure
%   p       = Patches structure
%
% Returns:
%   ek      = elastic kernel for segments
%   tk      = elastic kernel for triangular patches
%   tz      = matrix denoting strike, dip, tensile partials for patches
%   ts      = matrix defining strikes of elements
%   If a kernel can be used, it is loaded and returned to Blocks.  If not, the size
%   of the output kernel is zero and a new kernel will be calculated subsequently.
%

[ek, tk, tz, ts]  = deal(zeros(3*numel(st.lon), 0));
[segc, tric]      = deal(1);
[match, un1, un2] = deal([]);

if strcmp(c.reuseElastic, 'yes') == 1;
   % find the directory in which the existing kernel exists
   [pa, fi, ex] = fileparts(char(c.reuseElasticFile{1}(1), filesep));
   % load the accompanying segment and patch file
   os = ReadSegmentTri(sprintf('%s%sMod.segment', pa, filesep));
   ost = ReadStation(sprintf('%s%sMod.sta.data', pa, filesep));
   % compare coordinates for segments...
   % compare coordinates for segments...
   if numel(ost.lon) == numel(st.lon)
      [match, un1, un2] = MatchSegments(os, s);
   end
   if ~isempty(p.c) & exist(sprintf('%s%sMod.patch', pa, filesep), 'file') > 0
      [co, ve, sl] = PatchData(sprintf('%s%sMod.patch', pa, filesep));
      if numel(co) == numel(p.c) & numel(ost.lon) == numel(st.lon);
         % ... and triangles
         dc = abs(co - p.c);
         tric = max(dc(:)) > 1e-4;
      end
   else
      tric = 1;
   end  
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Alternate kernel checking %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   % if any stations have a toggle > 1, replace their partials with those from another kernels file (i.e., heterogeneous elasticity)
   aki = max(st.tog);
   if aki > 1
      ak = load(c.reuseElasticFile{1}(aki), 'station', 'segment', 'patch');
      % compare station coordinates
      [~, stmatch] = ismember([st.lon st.lat], [ak.station.lon ak.station.lat], 'rows');
      % compare segment parameters
      [amatch, aun1, aun2] = MatchSegments(ak.segment, s); 
      if numel(amatch) == numel(s.lon1) % all segments must match!
         % There are no criteria in place to re-calculate any part of the partials;
         % the rows must be used either as a whole, or in part if the partials were 
         % calculated for more stations/segments than are presently in use.
         akk = load(c.reuseElasticFile{1}(aki), 'elastic');
         
      
      
   end
   
   % load and modify the rectangle elastic partials, if necessary
   if ~isempty(match) % match has been calculated, which mean that at least the size of the partials is the same
      load(c.reuseElasticFile, 'elastic');
      if any(~isempty([un1 un2])) % there are unique values, need to modify the elastic partials
         fprintf('\n  Modifying existing elastic kernel...');
         ek = NaN(3*numel(st.lon), 3*numel(s.lon1));
         fullIdx1 = ([3*match(:, 1)-2; 3*match(:, 1)-1; 3*match(:, 1)]);
         fullIdx2 = ([3*match(:, 2)-2; 3*match(:, 2)-1; 3*match(:, 2)]);

         ek(:, fullIdx2) = elastic(:, fullIdx1); % place the columns of matched segment into the new kernel
         
         % if we need to add any new segments...
         if ~isempty(un2)
            % make a mini segment file containing only the new segments
            mods = struct('lon1', s.lon1(un2), 'lon2', s.lon2(un2), 'lat1', s.lat1(un2), 'lat2', s.lat2(un2), 'dip', s.dip(un2), 'lDep', s.lDep(un2), 'bDep', s.bDep(un2)); 
            % calculate the elastic partials for those segments
            ep = GetElasticPartials(mods, st);
            % place these partials into the larger partials array
            %nidx = sort([3*un2(:)-2; 3*un2(:)-1; 3*un2(:)]); 
            ek(:, 3*un2(:)-2) = ep(:, 1:3:end);
            ek(:, 3*un2(:)-1) = ep(:, 2:3:end);
            ek(:, 3*un2(:)-0) = ep(:, 3:3:end);
         else
            ek(:, isnan(ek(1, :))) = [];
         end
      else
         fprintf('\n  Using existing elastic kernel...');
         ek = elastic;
      end
   end
   % load the triangular partials, if necessary
   if tric == 0
      fprintf('\n  Using existing triangular kernel...');
      pt = load(c.reuseElasticFile, '-regexp', '^tri');
      tk = pt.tri;
      tz = pt.trizeros;
      ts = pt.tristrikes;
      clear pt
      if ~isempty(p.uue)
         fprintf('\n     Extracting subset of existing triangular kernel...');
         uue3 = [3*p.uue(:)-2 3*p.uue(:)-1 3*p.uue(:)];
         tk(:, uue3(:)) = [];
         tz(p.uue) = [];
         ts(p.uue) = [];
      end
   end
end   

