%function idx = LocalOutliers(s, varargin)
%
% LOCALOUTLIERS identifies GPS stations whose velocity components are
% anomalous relative to those of their neighbors.
%
%   LOCALOUTLIERS(S) returns the indices of the GPS stations in structure
%   S whose velocity components are more than twice the mean sigma of the
%   10 closest stations.  That is, for each station, the mean velocity 
%   components and component sigmas are calculated for the 10 nearest 
%   neighbors, and those stations whose velocity components differ from 
%   the mean values by more than 5 times the mean component sigma are flagged.
%   5 times the mean sigmas seems from preliminary tests to flag the obvious
%   outliers; a smaller tolerance results in too many stations being flagged.
%
%   LOCALOUTLIERS(S, NUMSTA) specifies how many nearest neighbors are used
%   in the comparison.
%
%   LOCALOUTLIERS(S, TOL) specifies the velocity threshold that must be 
%   exceeded in order to flag a station.  TOL is a 2-element vector 
%   specifying the east and north tolerances.
%
%   LOCALOUTLIERS(S, TOG) will write a toggle file with the name TOG.
%
%   Any combination of the optional arguments can be entered in any order.
%   
%   IDX = LOCALOUTLIERS(...) returns the indices of the flagged outliers to 
%   the vector IDX.
%

% parse optional inputs
if nargin >= 2
   args      = varargin;
   argnum    = find(cellfun('isclass', args, 'double'));
   argstr    = find(cellfun('isclass', args, 'char'));
   argsiz    = cellfun('size', args, 2);
   argsiz    = argsiz(argnum);
   if sum(argsiz == 1)
      numsta = args{argnum(argsiz == 1)};
   else
      numsta    = 10;
   end  
   if sum(argsiz == 2) 
      tol    = args{argnum(argsiz == 2)};
      tole   = repmat(tol(1), numsta, numel(s.lon));
      toln   = repmat(tol(2), numsta, numel(s.lon));
   end % if not specified, TOL will be assigned in the loop
else
   numsta    = 10;
   argstr    = [];
end

% make coordinate matrices
[lon1, lon2] = meshgrid(s.lon, s.lon);
[lat1, lat2] = meshgrid(s.lat, s.lat);

% calculate distances, sort, and trim
d            = sqrt((lon1 - lon2).^2 + (lat1 - lat2).^2);
[d, idx]     = sort(d, 1);
idx          = idx(1:numsta + 1, :); % +1 to account for finding a distance = 0 with itself
d            = d(1:numsta + 1, :);
d(d > repmat(mean(d, 1), numsta + 1, 1)) = 0; % set large distances to zero

% find the real indices - discard indices corresponding to zero distance (self indices and large distances)
d            = reshape(d(find(idx - repmat(1:numel(s.lon), numsta+1, 1))), numsta, numel(s.lon));
idx          = reshape(idx(find(idx - repmat(1:numel(s.lon), numsta+1, 1))), numsta, numel(s.lon));

% calculate mean component velocities and, if required, sigmas
ve           = s.eastVel(idx);
vn           = s.northVel(idx);
me           = repmat(mean(ve, 1), numsta, 1);
mn           = repmat(mean(vn, 1), numsta, 1);
if ~exist('tole', 'var')
   tole      = repmat(5*mean(s.eastSig(idx), 1), numsta, 1);
   toln      = repmat(5*mean(s.northSig(idx), 1), numsta, 1);
end

% evaluate outliers
oute         = find(abs(ve - me) > tole);
outn         = find(abs(vn - mn) > toln);
out          = union(oute, outn);
%idx(find(~d))= 0;
%idx          = unique(idx(out));

%idx          = idx > 0;

% write a toggle file, if requested
if ~isempty(argstr)
   fid = fopen(args{argstr}, 'w');
   for i = 1:numel(idx)
      if exist('tol', 'var')
         fprintf(fid, '%s 0 Local outlier (%d nearest sta., [%d %d] E-N tol.)\n', s.name(idx(i), :), numsta, tol(1), tol(2));
      else
         fprintf(fid, '%s 0 Local outlier (%d nearest sta., 5-sigma tol.)\n', s.name(idx(i), :), numsta);
      end   
   end
   fclose(fid);
end

toln(1)
tole(1)
numsta