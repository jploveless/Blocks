function cleanouttrisegs(seg, base)
% Remove the segment polygons corresponding to triangulated
% surfaces from a set of smooth c-line GMT files (made with
% allblockscline2gmt).

% Isolate the segments that need cleaning
seg = structsubset(seg, find(seg.patchFile));

% Identify blocks (files) we need to clean
blockidx = unique([seg.eastLabel; seg.westLabel]);
