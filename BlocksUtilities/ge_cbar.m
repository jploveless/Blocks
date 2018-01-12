function ge_cbar(cmap, cax, clabel, filename, varargin)

% Check file extension
[p, f, e] = fileparts(filename);
if isempty(e)
   filename = [filename '.png'];
   e = '.png';
end

% Parse optional arguments
if nargin > 3
   if rem(length(varargin), 2) == 1 % Odd number of arguments, so pos is first
      pos = varargin{1};
      varargin = varargin{2:end};
   end
end

if ~exist('pos', 'var')
   % Set default position on screen, mix of fraction and pixel dimensions
   % X, Y, W, H
   pos = [0.015 0.1 100 420]; 
end

% Make a figure with just a colorbar in it
figure('position', [0 0 pos(3:4)], 'color', 'k');
axis off
caxis(cax);
colormap(cmap);
cb = colorbar;

set(cb, 'ycolor', [1 1 1], 'linewidth', 2, 'fontsize', 12, 'fontweight', 'bold', 'axislocation', 'in')
set(cb, 'Position', [0.1 0.1095 0.3 0.8155], varargin{:})
ylabel(cb, clabel, 'color', [1 1 1], 'fontsize', 14)
export_fig(gcf, filename)
close
