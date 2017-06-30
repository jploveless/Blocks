function u = triinv(s, p, beta, k, noise, varargin)
%
% TRIINV   Inverts surface displacements for slip on triangular mesh.
%    TRIINV(S, T, BETA, KERNEL) inverts the displacements/velocities contained 
%    in the .sta.data file S for slip on the triangular dislocation mesh defined
%    in the file T, which can be in .mat or .msh format, subject to the smoothing
%    constraint whose strength is defined as BETA.  The KERNEL argument allows for
%    specification of an existing matrix containing the triangular dislocation 
%    element partial derivatives, or the name of a file to which the partials 
%    will be saved.  The program will check for the existence of KERNEL, and 
%    load it if it exists.  If not, the elastic partials will be calculated and
%    saved to KERNEL.  No internal checks are made to assure that an existing 
%    KERNEL corresponds to the present station-source geometry, except that the 
%    inversion will fail if the loaded kernel does not have the same dimensions
%    as the present configuration of S and T.  
%
%    TRIINV(S, T, BETA, KERNEL, LOCK) also subjects the inversion to locking constraints
%    on the up and/or downdip extents of the triangular mesh.  LOCK is a vector
%    containing N or 2N elements, where N is the number of distinct patches in T.
%    For example, to lock the updip row of elements while placing no constraints
%    on the downdip extent, LOCK = [1 0].
%
%    TRIINV(STA, ...) loads the station structure STA rather than reading from a file.
%
%    TRIINV(..., PAT, ...) loads the triangular mesh as coordinate and vertex
%    arrays within the structure PAT (PAT.c, PAT.v, PAT.nEl, PAT.nc).
%
%    U = TRIINV(...) returns the estimated slip (rate) to vector U.
%
%    This function calls the following:
%
%    GetTriPartials, findplane, local_tri_calc, deg_to_rad, get_local_xy_coords_om_matlab_tri,
%    LineSphInt, mag, long_lat_to_xyz, rad_to_deg, xyz_to_long_lat, rotate_xy_vec, tri_disl,
%    MakeTriSmooth, PatchCoords, centroid3, ReadPatches, msh2coords, opentxt, swap, ReadStation, 
%    SideShare, TriDistCalc, ZeroTriEdges
%
%    all of which should be available in your $BLOCKSHOME/parallel or $BLOCKSHOME/BlocksUtilities
%    directories.
%

fprintf('  Loading input data...')
if ischar(s)
   % load the station file
   s                                = ReadStation(s);
end

% Check to see whether or not noise should be added
noise1 = sign(randn(numel(s.lon), 1)).*noise.*(mean(s.eastSig) + std(s.eastSig).*randn(numel(s.lon), 1));
noise2 = sign(randn(numel(s.lon), 1)).*noise.*(mean(s.northSig) + std(s.northSig).*randn(numel(s.lon), 1));

if ischar(p) % if the triangular mesh was specified as a file...
   % load the patch file...
   p                                = ReadPatches(p);
end
% ...and process its coordinates
p                                   = PatchCoords(p);

% Check the length of beta and repeat if necessary
if numel(beta) ~= numel(p.nEl)
   beta                             = repmat(beta, numel(p.nEl), 1);
end
fprintf('done.')

% Check for existing kernel
if exist(k, 'file')
   fprintf('\n  Loading existing elastic kernel...')
   load(k)
   % Make sure that the tri. partials are contained in array "g"
   if ~exist('g', 'var')
      g = tri;
      clear tri*
   end
   fprintf('done.')
else
   % Calculate the triangular partials
   fprintf('\n  Calculating elastic partials...')
   [g, ts, tz]                      = GetTriPartials(p, s);
   save(k, 'g', 'ts', 'tz');
   fprintf('done.')
end

% Trim vertical and tensile components
colkeep                             = sort([[1:3:3*sum(p.nEl)], [2:3:3*sum(p.nEl)]]');
rowkeep                             = sort([[1:3:3*numel(s.lon)], [2:3:3*numel(s.lon)]]');
g                                   = g(rowkeep, :);
g                                   = g(:, colkeep);

if nargin > 5
   Command.triEdge                  = varargin{:};
else
   Command.triEdge                  = 0;
end

if sum(Command.triEdge) ~= 0
   fprintf('\n  Applying edge constraints...')
   Ztri                             = ZeroTriEdges(p, Command);
   fprintf('done.')
else
   Ztri                             = zeros(0, size(g, 2));
end

if sum(beta)  
   fprintf('\n  Making the smoothing matrix...')
   share                            = SideShare(p.v);
   dists                            = TriDistCalc(share, p.xc, p.yc, p.zc); % distance is calculated in km
   w                                = MakeTriSmooth(share, dists);
   % weight the smoothing matrix by the constants beta
   be                               = zeros(3*length(p.v), 1);
   so                               = [0 cumsum(p.nEl)];
   for i = 1:numel(p.nEl)
      dist                          = dists(so(i)+1:so(i+1), :);
      distScale                     = mean(dist(find(dist)));
      be(3*(so(i)+1)-2:3*so(i+1))   = distScale^2*beta(i);
   end 
   w                                = repmat(be', size(w, 1), 1).*w;
   fprintf('done.')
else
   w                                = zeros(3*size(p.v, 1));
end
w                                   = w(colkeep, :);
w                                   = w(:, colkeep);

we                                  = zeros(3*numel(s.lon), 1);
we(1:3:end)                         = 1./s.eastSig.^2;
we(2:3:end)                         = 1./s.northSig.^2;
we(3:3:end)                         = 0;
we                                  = we(:);
we                                  = we(rowkeep);
we                                  = [we ; ones(size(w, 1), 1)]; % add the triangular smoothing vector
we                                  = [we ; ones(size(Ztri, 1), 1)]; % add the zero edge vector
We                                  = spdiags(we, 0, numel(we), numel(we)); % assemble into a matrix

% Assemble the Jacobian...
fprintf('\n  Assembling the Jacobian and data vector...')
G                                   = full([-g; w; Ztri]);
% ...and the data vector
d                                   = zeros(2*numel(s.lon) + 2*sum(p.nEl) + size(Ztri, 1), 1);
d(1:2:2*numel(s.lon))               = s.eastVel + noise1;
d(2:2:2*numel(s.lon))               = s.northVel + noise2;
fprintf('done.')

% Carry out the inversion
fprintf('\n  Doing the inversion...')
warning off all
u                                   = inv(G'*We*G)*G'*We*d;
fprintf('done.\n')
warning on all
