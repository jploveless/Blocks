function h = meshview(c, v, varargin)
%
% MESHVIEW plots a triangulated mesh in a new figure.
%
%   MESHVIEW(C, V) plots the triangulated mesh using the vertex coordinates
%   contained in C and the element vertex indices contained in V.  C is an
%   n x 2 or n x 3 array of values containing the x, y or x, y, and z values
%   of each of the n vertices.  V is an m x 3 array, each line of which contains
%   the indices of the 3 vertices that make up each of the m triangular elements.
%   If C is n x 2, a 2-D representation of the mesh will be plotted and if C is 
%   n x 3, the full 3-D mesh will be plotted. 
%
%   MESHVIEW(C, V, COLOR) plots the mesh and colors the elements using the information
%   in array COLOR.  COLOR can either be a 1 x 3 vector specifying the RGB color values
%   used to plot all elements, or an m x 1 array providing values characterizing the
%   elements, i.e. slip magnitudes.  If COLOR is an m x 3 array, it is assumed that 
%   the values contained in the columns of COLOR represent some characteristic of the
%   element in the x, y, and z directions, e.g., slip magnitude in three directions.  In
%   this case, the total magnitude of slip is automatically calculated and used to color
%   the elements; to color the elements by a particular component, specify that component
%   as the m x 1 vector COLOR.
%
%   MESHVIEW(C, V, FIGURE) plots the mesh in the figure window specified with FIGURE.  The 
%   default behavior is to plot the mesh in a new figure window.
%
%   MESHVIEW(C, V, COLOR, FIGURE) uses both optional inputs.
%
%   H = MESHVIEW(...) returns the patch objects to the handle H.
%

% parse optional color input
if nargin == 3;
	if numel(varargin{1}) == 1 % figure flag is specified
		fign = varargin{1};
		color = repmat([1 1 1], size(v, 1), 1); % color the elements white if no color is given
	else
		color = varargin{1};
		if size(color, 2) == 3 % an array of x, y, z, values were given
			color = mag(color, 2);
		end
		fign = [];
	end		
elseif nargin == 4;
	color = varargin{1};
	if size(color, 2) == 3 % an array of x, y, z, values were given
		color = mag(color, 2);
	end
	fign = varargin{2};
else	
	color = repmat([1 1 1], size(v, 1), 1); % color the elements white if no color is given
	fign = [];
end

% make the plot
if numel(fign) == 0;
   figure
   ax = gca;
else
   if strcmp(class(fign), 'matlab.ui.Figure') % if it's actually a figure number
	   figure(fign);
	   ax = gca;
	   hold on
	elseif strcmp(class(fign), 'matlab.graphics.axis.Axes')
       ax = fign;
       hold on
	elseif strcmp(class(fign), 'double') 
	   if rem(fign, 1) == 0
	   	   figure(fign);
     	   ax = gca;
	       hold on 
       else % otherwise it's an axis handle
		   ax = fign;
		   hold on
	   end
	end
end
h = patch('Vertices', c, 'faces', v, 'facevertexcdata', color, 'facecolor', 'flat', 'edgecolor', 'black', 'parent', ax);
%caxis = [min(color), max(color)];
axis equal;
colormap(bluewhitered);