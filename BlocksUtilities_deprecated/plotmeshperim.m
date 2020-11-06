function plotmeshperim(p, fn, varargin)
% PLOTMESHPERIM  Plots mesh perimeters.
%   PLOTMESHPERIM(P, FIG) plots the perimeters of the triangular mesh(es)
%   of structure P in figure number FIG. By default, the shading is turned
%   flat in the figure; call "shading faceted" to outline all elements if 
%   desired.
%
%   PLOTMESHPERIM(P, FIG, 'param', 'value', ...) accepts optional arguments
%   to specify the line style of the mesh perimeters. The default is to plot
%   perimeters as black lines of width 1. 
%

% Check optional formatting arguments
if nargin > 2
   fs = varargin;
else
   fs = {'color', 'k', 'linewidth', 1};
end

% Set up figure
figure(fn) % Switch to specified figure
shading flat % This removes the edges from around the triangles, if they're already plotted
hold on

% Get the indices of where the individual meshes start and end
ends = cumsum(p.nEl);
begs = [1; ends(1:end-1)+1];

% Loop through faults and plot perimeters
for i = 1:length(p.nEl)
   edges = OrderedEdges(p.c, p.v(begs(i):ends(i), :)); % Determine coordinates that lie along the edges of the faults
   plot3(p.c(edges(1, [1:end, 1]), 1), p.c(edges(1, [1:end, 1]), 2), p.c(edges(1, [1:end, 1]), 3), fs{:}); % Plot those edges on the figure
end