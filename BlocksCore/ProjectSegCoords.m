function [f, s]               = ProjectSegCoords(f, s)
% ProjectSegCoords   Calculates Cartesian coordinates based on a local oblique Mercator projection. 
%   [F, S] = ProjectSegCoords(F, S) uses an oblique Mercator projection local to each 
%   fault segment defined in structure F to project both segment endpoint coordinates
%   and station coordinates defined in structure S.  The resulting Cartesian coordinates
%   are stored in fields in the updated structures:
%
%   S:
%      fpx
%      fpy
%      (nSta-by-nSeg arrays, with each column containing projected coordinates for a single segment)
%
%   F:
%      px1
%      py1
%      px2
%      py2
%      (nSeg-by-1 arrays giving projected endpoint coordinates for each segment)
%

%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Declare variables  %%
%%%%%%%%%%%%%%%%%%%%%%%%%
R                             = 6371;

if ~isstruct(f)
   f = struct('lon1', f(:, 1), 'lat1', f(:, 2), 'lon2', f(:, 3), 'lat2', f(:, 4));
end
if ~isstruct(s)
   s = struct('lon', s(:, 1), 'lat', s(:, 2));
end

% If no depth is defined for stations, assume they're at the surface
if ~isfield(s, 'z')
   s.z                        = 0*s.lon;
end
nsta                          = numel(s.lon);
nseg                          = numel(f.lon1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Calculate fault strikes  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f.strike                      = sphereazimuth(f.lon1, f.lat1, f.lon2, f.lat2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Do conversion to projected space  (Oblique Mercator)  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[mx, my]                      = faultobliquemerc([s.lon(:); f.lon1; f.lon2], [s.lat(:); f.lat1; f.lat2], f.lon1', f.lat1', f.lon2', f.lat2');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Separate station arrays and triangle element vectors  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s.fpx                         = mx(1:nsta, :);
s.fpy                         = my(1:nsta, :);
f.px1                         = diag(mx(nsta+0*nseg + (1:nseg), :));
f.py1                         = diag(my(nsta+0*nseg + (1:nseg), :));
f.px2                         = diag(mx(nsta+1*nseg + (1:nseg), :));
f.py2                         = diag(my(nsta+1*nseg + (1:nseg), :));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Scale to proper distances by multiplying by point's radius  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s.fpx                         = s.fpx.*repmat(R, nsta, nseg);
s.fpy                         = s.fpy.*repmat(R, nsta, nseg);
f.px1                         = f.px1.*R;
f.py1                         = f.py1.*R;
f.px2                         = f.px2.*R;
f.py2                         = f.py2.*R;




