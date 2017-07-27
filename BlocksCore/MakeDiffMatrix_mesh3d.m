function Diff = MakeDiffMatrix_mesh3d(Patches)
% MakeDiffMatrix_mesh3d  Creates a difference matrix for a mesh
%   Diff = MakeDiffMatrix_mesh3d(Patches) makes a three-dimensional
%   difference array for triangular meshes described by structure
%   Patches. 
%
%   Based on Eileen Evans' MakeDiffMatrix_mesh2d.
%

% Determine adjacency matrix
share = SideShare(Patches.v)'; 
keep = share > 0;
share = share(keep);

% Row indices. Same size as share, for linear indexing
rows = repmat(1:sum(Patches.nEl), 3, 1); 
rows = rows(keep);

% Convert row indices and share column indices to linear indices
szel = [3*sum(Patches.nEl), 3*sum(Patches.nEl)];
linind1 = sub2ind(szel, 3*rows-2, 3*share-2);
linind2 = sub2ind(szel, 3*rows-1, 3*share-1);
linind3 = sub2ind(szel, 3*rows-0, 3*share-0);

% Create square difference array
Diff = eye(3*sum(Patches.nEl)); % Positive one on the main diagonal
Diff(linind1) = -1; % Negative one in columns corresponding to adjacent elements
Diff(linind2) = -1;
Diff(linind3) = -1;