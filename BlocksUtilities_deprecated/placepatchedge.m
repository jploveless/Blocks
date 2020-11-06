function placepatchedge(psname, segname, pidx)
% PLACEPATCHEDGE  Places a specified patch surface trace into a segment file.
%   PLACEPATCHEDGE(PSNAME, SEGNAME, PIDX) uses the .segment file PSNAME, which
%   contains the coordinates of a patch's surface trace, to place these nodes 
%   into a master segment file, such that the segment file and the patch file
%   have identical surface traces.  PIDX is an integer specifying the patch 
%   identification number, based on the listing in the .command file.  The 
%   function works best when all segments replaced by patches have identical
%   properties, as the newly created segments simply copy those of a single
%   replaced segment.  The new segment file will have a "_adjust" appended
%   to its name; of course this can be manually changed if desired.
%

% Determine patch's top edge segment name and read in
pseg = ReadSegmentTri(psname);

% Read master segment file
seg = ReadSegmentTri(segname);

% Find the segments in need of replacement, identified by field patchName
replace = find(seg.patchFile == pidx);

% Delete those segments
keep = setdiff(1:numel(seg.lon1), replace);
segn = structsubset(seg, keep);
nsegn = numel(segn.lon1); % number of new segments

% Also need to find non-replaced segments that share an enpoint with with replaced
rc = [seg.lon1(replace) seg.lat1(replace); seg.lon2(replace) seg.lat2(replace)]; % replaced endpoints
ac = [segn.lon1 segn.lat1; segn.lon2 segn.lat2]; % all endpoints
aidx = ismember(ac, rc, 'rows');
aidx = find(aidx);
pc = [pseg.lon1 pseg.lat1; pseg.lon2 pseg.lat2]; % all patch endpoints
% For each adjacent segment (generally just a handful, unless there are a lot of triple junctions!)
for i = 1:length(aidx)
   if aidx(i) <= nsegn % If we're looking at endpoint 1
      k = dsearchn(pc, [segn.lon1(aidx(i)) segn.lat1(aidx(i))]); % Find the closest patch coordinate,
      segn.lon1(aidx(i)) = pc(k, 1); % and replace
      segn.lat1(aidx(i)) = pc(k, 2);
   else                % If we're looking at endpoint 2
      k = dsearchn(pc, [segn.lon2(aidx(i)-nsegn) segn.lat2(aidx(i)-nsegn)]);
      segn.lon2(aidx(i)-nsegn) = pc(k, 1);
      segn.lat2(aidx(i)-nsegn) = pc(k, 2);
   end
end

% Replicate relevant master segment properties
psegn = structsubset(seg, replace(1)*ones(length(pseg.lon1)));

% Replace the replicated coordinates with the actual patch edge coordinates
psegn.lon1 = pseg.lon1;
psegn.lon2 = pseg.lon2;
psegn.lat1 = pseg.lat1;
psegn.lat2 = pseg.lat2;

% Place the new segments into the master segment file
segf = structmath(segn, psegn, 'vertcat');

% Write the new segment file
nsegname = [segname(1:end-8) '_adjust.segment'];
WriteSegmentStruct(nsegname, segf);