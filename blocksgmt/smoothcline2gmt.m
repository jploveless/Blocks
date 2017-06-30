function smoothcline2gmt(h, outname, cpt, neg)
% CLINE2GMT  Converts segments plotted using CLINE to GMT format.
%   CLINE2GMT(H, OUTNAME), where H is the handle produced by MYCLINE,
%   converts the segment data into a format useable in GMT and writes
%   them to OUTNAME.xy.  The output produced can be plotted using a 
%   straight up PSXY command, as the pen attributes are fully 
%   specified.
%
%   CLINE2GMT(H, OUTNAME, CPT) also writes a GMT colormap file, with
%   limits as specified in the Matlab figure, based on the colormap
%   given by CPT.  CPT can be any valid GMT colormap file.  Note that
%   adding a ' -I' after the .cpt name allows an inverse colormap to
%   be produced.  In this case, only the color table lookup is given 
%   in each segment's header line, requiring the use of the "-C" option
%   with PSXY.
%

% Get color info
C = get(h, 'cdata'); % Segment colors
ax = get(h, 'parent'); % Axis handle
cols = floor(255*colormap(ax)); % Colormap, converted to 0-256
m = size(cols, 1); % length of current colormap
clims = get(ax, 'clim'); % Current color limits
index = fix((C-clims(1))/diff(clims)*(m-1))+1; % Get indices of each segment value
index(index < 1) = 1; index(index > m) = m;

% Get coordinate info
x = get(h, 'xdata');
y = get(h, 'ydata');

% Make specific coordinate array
nc = size(x, 1);
coords = zeros(2*nc, size(x, 2));
coords(1:2:end, :) = x;
coords(2:2:end, :) = y;

fid = fopen([outname '.xy'], 'w');
% Write out
if ~exist('cpt', 'var') % option 1: full pen specification
   out = [cols(index, 1)'; cols(index, 2)'; cols(index, 3)'; coords];
   fprintf(fid, ['> -G%d/%d/%d\n' repmat('%d %d\n', 1, nc)], out);
else
   out = [C'; coords];
   if exist('neg', 'var')
      if neg == 1
         use = find(C >= 0);
      elseif neg == -1
         use = find(C < 0);
      end
      out = out(:, use);
   end
   fprintf(fid, ['> -Z%d\n' repmat('%d %d\n', 1, nc)], out);
   cptfile = [outname '.cpt'];
   cptcom = sprintf('makecpt -C%s -T%d/%d/1 > %s', cpt, clims(1), clims(2), cptfile);
   system(cptcom);
end
fclose(fid);

