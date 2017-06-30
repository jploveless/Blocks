function share = SideShare(v);
%
% SideShare determines the indices of the triangular elements sharing 
% one side with a particular element.  
%
% Inputs:
%   v          = n x 3 array containing the 3 vertex indices of the n elements,
%                assumes that values increase monotonically from 1:n
% Outputs:
%   share      = n x 3 array containing the indices of the elements sharing a
%                side with each of the n elements.  Zero values in the array
%                indicate elements with fewer than three neighbors (i.e., on
%                the edge of the geometry).
%

% make side arrays containing vertex indices of sides
[s1 s2 s3]                 = deal(sort(v(:, 1:2), 2), sort(v(:, 2:3), 2), sort([v(:, 3) v(:, 1)], 2));
sides                      = [s1; s2; s3];

% find the unique sides - each side can part of at most 2 elements
[usides, i1]               = unique(sides, 'rows', 'first');
[usides, i2]               = unique(sides, 'rows', 'last');
di                         = i2 - i1;
% shared sides are those whose first and last indices are not equal
shared                     = find(di);

% these are the indices of the shared sides
sside1                     = i1(shared);
sside2                     = i2(shared);
            
[el1, sh1]                 = ind2sub(size(v), sside1);
[el2, sh2]                 = ind2sub(size(v), sside2);
            
share                      = zeros(size(v, 1), 3);

for i = 1:size(el1, 1);
   share(el1(i), sh1(i))   = el2(i);
   share(el2(i), sh2(i))   = el1(i);
end