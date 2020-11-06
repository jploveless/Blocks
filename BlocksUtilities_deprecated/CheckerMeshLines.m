function [xl, yl] = CheckerMeshLines(p, xc, yc, varargin)
%
% CHECKERMESHLINES returns coordinates defining a checkerboard
% mesh test.
%   CHECKERMESHLINES(P, XC, YC) determines the coordinates
%   of lines that, when overlain on a triangular mesh P (as returned
%   from READPATCHES, i.e., including the number of coordinates and 
%   elements in each mesh entity), define the outlines of the 
%   checkerboard cells described by XC, YC (as returned from CHECKERTEST).
%
%   CHECKERMESHLINES(P, XC, YC, FILE) writes the coordinates of lines to 
%   FILE, which is formatted for plotting using GMT's PSXY -M program.
%
%   [XL, YL] = CHECKERMESHLINES(...) returns the coordinates of all lines
%   to XL, YL, which can be plotted using LINE(XL, YL).
%

% Determine the nodes that line the edges of the mesh
cnel = cumsum([0 p.nEl]);
ec = NaN(cnel(end), 2);
start = 1;
for i = 1:numel(p.nEl)
   edge = OrderedEdges(p.c, p.v(cnel(i)+1:cnel(i+1), :));
   ec(start:start+numel(edge)-1, :) = [p.c(edge(:), 1) p.c(edge(:), 2)];
   start = start + numel(edge);
end
ec(find(~isnan(ec(:, 1)), 1, 'last')+1:end, :) = [];
% Determine the intersections between the mesh edges and the checkerboard lines
[xiv, yiv] = deal(NaN(4*numel(xc), 1));
start = 1;
for j = 1:numel(xc)
   [xi, yi] = pbisect(ec(1:2:end, :), ec(2:2:end, :), repmat([xc(j) min(yc)], length(ec)/2, 1), repmat([xc(j) max(yc)], length(ec)/2, 1));
   idx = find(~isnan(xi));
   xiv(start:start+numel(idx)-1) = xi(idx);
   yiv(start:start+numel(idx)-1) = yi(idx);
   start = start + numel(idx);
end
[xih, yih] = deal(NaN(4*numel(yc), 1));   
start = 1;
for j = 1:numel(yc)
   [xi, yi] = pbisect(ec(1:2:end, :), ec(2:2:end, :), repmat([min(xc) yc(j)], length(ec)/2, 1), repmat([max(xc) yc(j)], length(ec)/2, 1));
   idx = find(~isnan(xi));
   xih(start:start+numel(idx)-1) = xi(idx);
   yih(start:start+numel(idx)-1) = yi(idx);
   start = start + numel(idx);
end

% Arrange output
xl = [xiv(1:2:end)' xih(1:2:end)'; xiv(2:2:end)' xih(2:2:end)'];
yl = [yiv(1:2:end)' yih(1:2:end)'; yiv(2:2:end)' yih(2:2:end)'];

% Write to GMT format, if requested
if nargin == 4
   out = [xl(:)'; yl(:)'];
   out = out(:, ~isnan(out(1, :)));
   fid = fopen(varargin{:}, 'w');
   fprintf(fid, '%g %g\n%g %g\n>\n', out);
   fclose(fid);
end 