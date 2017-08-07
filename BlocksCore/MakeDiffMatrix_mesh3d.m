function Diff = MakeDiffMatrix_mesh3d(Patches)
% MakeDiffMatrix_mesh3d  Creates a difference matrix for a mesh
%   Diff = MakeDiffMatrix_mesh3d(Patches) makes a three-dimensional
%   difference array for triangular meshes described by structure
%   Patches. 
%
%   Based on Eileen Evans' MakeDiffMatrix_mesh2d.
%

snel = sum(Patches.nEl);

% Determine adjacency matrix
share = SideShare(Patches.v)'; 
share(share == 0) = -1e20;
share = sort(share);
share(share < repmat(1:snel, 3, 1)) = 0;
Share = zeros(9, snel);
Share(1:3:end, :) = 3*share-2;
Share(2:3:end, :) = 3*share-1;
Share(3:3:end, :) = 3*share;
keep = Share > 0;
share = Share(keep);

% Row indices. Same size as share, for linear indexing
rows = 1:9*snel;
cols = repmat(reshape(1:3*snel, 3, snel), 3, 1);
cols = cols(keep);
rows = rows(keep)';

% Convert row indices and share column indices to linear indices
szel = [9*snel, 3*snel]; % 9 rows for each element = 3 neighbors*3 slip components
adjaind = sub2ind(szel, rows, share);
selfind = sub2ind(szel, rows, cols);

% Create square difference array
Diff = zeros(szel);
Diff(selfind) = 1; % Positive one in columns corresponding to particular elements
Diff(adjaind) = -1; % Negative one in columns corresponding to adjacent elements
Diff = Diff(keep, :);
