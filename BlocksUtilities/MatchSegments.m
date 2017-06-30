function [match, unique1, unique2] = MatchSegments(s1, s2);
%
%  MATCHSEGMENTS returns the indices of segments that are identical in two
%  different segment files.
%
%    [MATCH, UNIQUE1, UNIQUE2] = MATCHSEGMENTS(S1, S2) examines Segment 
%    structures S1 and S2 to look for identical segments.  It returns the 
%    indices of matched and unmatched segments in the arrays MATCH, 
%    UNIQUE1, and UNIQUE2.  The structure of the output arrays is as follows:
%
%    MATCH is an n-by-2 array containing the indices of segments contained in
%    both S1 and S2.  The first column contains the indices of S1 segments
%    contained in S2 and the second column contains the indices of those
%    segments in S2.  
% 
%    UNIQUE1 and UNIQUE2 are m-by-1 and p-by-1 vectors containing the indices
%    of the segments unique to S1 and S2, respectively.  
%
%    The sizes of the output arrays are such that n + m = numel(S1.lon1) and
%    n + p = numel(S2.lon).
%    

% Declare number of segments in each file
n1 = numel(s1.lon1);
n2 = numel(s2.lon1);

% find matched characteristics
[match, m1, m2]         = intersect([s1.lon1(:), s1.lon2(:), s1.lat1(:), s1.lat2(:), s1.lDep(:), s1.bDep(:), s1.dip(:)], ...
                                    [s2.lon1(:), s2.lon2(:), s2.lat1(:), s2.lat2(:), s2.lDep(:), s2.bDep(:), s2.dip(:)], 'rows');
match = [m1 m2];         
unique1 = setdiff(1:n1, m1);
unique2 = setdiff(1:n2, m2);
