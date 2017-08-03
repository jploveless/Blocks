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
share = repmat(share, 9, 1);
keep = share > 0;
share = share(keep);

% Row indices. Same size as share, for linear indexing
rows = repmat(1:sum(Patches.nEl), 9, 1); 
rows = rows(keep);

% Convert row indices and share column indices to linear indices
szel = [9*sum(Patches.nEl), 3*sum(Patches.nEl)];
% Strike slip share
linind1 = sub2ind(szel, 9*rows-8, 3*share-2);
linind2 = sub2ind(szel, 9*rows-7, 3*share-2);
linind3 = sub2ind(szel, 9*rows-6, 3*share-2);
% Dip slip share
linind4 = sub2ind(szel, 9*rows-5, 3*share-1);
linind5 = sub2ind(szel, 9*rows-4, 3*share-1);
linind6 = sub2ind(szel, 9*rows-3, 3*share-1);
% Tensile slip share
linind7 = sub2ind(szel, 9*rows-2, 3*share-0);
linind8 = sub2ind(szel, 9*rows-1, 3*share-0);
linind9 = sub2ind(szel, 9*rows-0, 3*share-0);

% Create square difference array
Diff = zeros(szel);
Diff(1:3:end, :) = eye(3*sum(Patches.nEl)); % Positive one on the main diagonal
Diff(2:3:end, :) = eye(3*sum(Patches.nEl)); % Positive one on the main diagonal
Diff(3:3:end, :) = eye(3*sum(Patches.nEl)); % Positive one on the main diagonal
Diff(linind1) = -1; % Negative one in columns corresponding to adjacent elements
Diff(linind2) = -1;
Diff(linind3) = -1;
Diff(linind4) = -1;
Diff(linind5) = -1;
Diff(linind6) = -1;
Diff(linind7) = -1;
Diff(linind8) = -1;
Diff(linind9) = -1;
