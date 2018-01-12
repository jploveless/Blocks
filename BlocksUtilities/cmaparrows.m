function cmaparrows(template, cmap, outdir)
% cmaparrows  Makes a set of .dae files from an arrow template
%   cmaparrows(template, cmap, outdir) uses the arrow template
%   in the .dae file template and writes a set of arrows, each 
%   with a fill color representing a line of the colormap 
%   cmap to directory outdir. 
%

% Get template filename
[p, f, e] = fileparts(template);

% Create output directory if it doesn't exist
if ~exist(outdir, 'dir')
   mkdir(outdir);
end

% Read template
a = opentxt(template);

% Loop through colormap
for i = 1:size(cmap, 1)
   % Replace line 129 color specification
   a(129, 36:64) = sprintf('%0.7f %0.7f %0.7f', cmap(i, :));
   % Write new .dae file
   fid = fopen(sprintf('%s%s%s%g.dae', outdir, filesep, f, i), 'w');
   for j = 1:size(a, 1)
      fprintf(fid, '%s\n', strip(a(j, :), 'right'));
   end
   fclose(fid);
end

   