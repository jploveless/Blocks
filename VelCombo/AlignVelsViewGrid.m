function AlignVelsViewGrid(names, nOverlap, meanRes, varargin)
%
% ALIGNVELSVIEWGRID produces a grid showing relationships between aligned 
% velocity fields.  The upper triangular part of the grid shows the number
% of common stations in all field combinations, while the lower triangular 
% part shows the mean residual magnitude of the aligned fields.  Grid cells
% corresponding to fields that were not aligned due to an insufficient number
% of collocated stations are shaded with diagonal lines (but the statistics
% are still written to that cell).  
% 
%    ALIGNVELSVIEWGRID(NAMES, NOVERLAP, MEANRES) uses the arrays 
%    NAMES, NOVERLAP, and MEANRES that are saved to a .MAT file by 
%    ALIGNALLFIELDS.m to create the view grid.  This assumes that 
%    the minimum number of stations required to carry out the 
%    rotation was 10 (the default of ALIGNALLFIELDS.m).
%
%    ALIGNVELSVIEWGRID(NAMES, NOVERLAP, MEANRES, THRESH) allows for
%    an optional specification of THRESH, the minimum number of stations
%    needed for an alignment.


% check input arguments
if nargin == 4
   thresh = varargin{1};
else
   thresh = 10;
end

nFields = numel(names); % number of fields
[x, y] = meshgrid([1:nFields+1]); % make an x, y array of grid coordinates
cmat = triu(ones(nFields+1), 1) + tril(0.5*ones(nFields+1), -1); % make the color table for the grid
ub = find(nOverlap < thresh); % find the entries of the non-aligned fields

% start the figure
figure('position', [100 100 800 800])
%pco = pcolor(x, y, cmat);
pco = pcolor(x, y, ones(nFields+1));
colormap(gray); caxis([0 1])
set(pco, 'linewidth', 1);
set(pco, 'facecolor', 'none')

ax = gca;
fs = 12;
% set the axis tick names to be the field names
set(ax, 'ytick', 0.5+1:nFields+1, 'yticklabel', names, 'xtick', 0.5+1:nFields+1, 'xticklabel', [], 'fontname', 'times', 'fontsize', fs);
set(ax, 'ydir', 'reverse', 'fontsize', fs)
% rotated x axis labels
text(0.5+1:nFields+1, repmat(max(y(:))+0.1, 1, nFields), names, 'HorizontalAlignment', 'right', 'rotation', 90, 'fontname', 'times', 'fontsize', fs);
set(gcf, 'defaulttextverticalalignment', 'middle', 'defaulttexthorizontalalignment', 'center')

% color the non-rotated fields' grid cells with diagonal lines
[x, y] = deal(x(1:end-1, 1:end-1), y(1:end-1, 1:end-1));
for i = 1:length(ub)
   [xdi, ydi] = dlines(x(ub(i)) + [0 1], y(ub(i)) + [0 1], 5, -1);
   line(xdi, ydi, 'color', 0.5*[1 1 1]);
end

% Place grid lines on top of diagonal lines
ac = get(gca, 'children');
set(gca, 'children', flipud(ac));

% write the statistics to each box
[x0, y0] = meshgrid(1.5:1:0.5+nFields);
lx = x0(find(tril(x0, -1)));
ly = y0(find(tril(y0, -1)));
lt = num2str(meanRes(find(tril(x0, -1))), '%.2f');
f = ones(nFields); tlf = find(tril(f, -1)); dash = (ismember(tlf, ub));
lt(dash, :) = repmat(' -- ', length(find(dash)), 1); 
tlt = text(lx, ly, lt, 'color', 'r', 'backgroundcolor', [1 1 1], 'fontname', 'times', 'fontsize', 2*fs);
ux = x0(find(triu(x0, 1)));
uy = y0(find(triu(y0, 1)));
ut = cellstr(num2str(nOverlap(find(triu(x0, 1))), '%.0f'));
ut = strtrim(ut);
tut = text(ux, uy, ut, 'color', 'b', 'backgroundcolor', [1 1 1], 'fontname', 'times', 'fontsize', 2*fs);

ap = get(ax, 'position');
set(ax, 'position', ap + [.05 .06 0 0], 'ticklength', [0 0], 'layer', 'top');