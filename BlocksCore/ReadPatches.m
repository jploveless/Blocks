function Patches                 = ReadPatches(filenames);
% ReadPatches reads triangulated patch files into a common structure.
%    Patches = ReadPatches(FILENAMES) reads in triangulated patch files
%    specified by the space-delimited string of FILENAMES and returns 
%    their geometry to the structure Patches.
%
%    FILENAMES is a space-separated string containing filenames, with 
%    full paths if not in the current directory, of element files to 
%    be read. Acceptable file formats are .msh (from Gmsh), .mat (from
%    Matlab), and .ts (from GOCAD). Files can be of mixed type, as long
%    as the extension is specified. 
% 
%    The returned structure Patches contains fields:
%          c    : all vertex coordinates (n x 3)
%          v    : element vertex indices (m x 3)
%          nEl  : number of elements in each patch file
%          nc   : number of coordinates in each patch file
%
%    The meshes can be visualized using meshview(Patches.c, Patches.v). 
%
%    See also: msh2coords, readts, meshview, PatchCoords, PatchCoordsx

Patches.c                        = [];
Patches.v                        = [];
Patches.nEl                      = [];
Patches.nc                       = [];

if numel(filenames) > 0
   if size(filenames, 1) == 1
      spaces                     = [0 findstr(filenames, ' ') length(filenames)+1];
      % Check which spaces are really separating files
      notword                    = regexp(filenames(spaces(1:end-1)+1), '\W');
      spaces                     = spaces([notword, length(spaces)]);
      nfiles                     = length(spaces) - 1;
   else
      nfiles                     = size(filenames, 1);
   end
   
   for i = 1:nfiles
      if exist('spaces', 'var')
         filename                = filenames(spaces(i)+1:spaces(i+1)-1);
      else
         filename                = strtrim(filenames(i, :));
      end
      
      if filename(end-3:end)     == '.msh'
         [c, v]                  = msh2coords(filename);
      elseif filename(end-3:end) == '.mat'
         load(filename, 'c', 'v')
      elseif filename(end-2:end) == '.ts'
         [c, v]                  = readts(filename);
      end
 
      % Ensure consistent node circulation direction     
      crossd                     = cross([c(v(:, 2), :) - c(v(:, 1), :)], [c(v(:, 3), :) - c(v(:, 1), :)]);
      negp                       = find(crossd(:, 3) < 0);
      [v(negp, 2), v(negp, 3)]   = swap(v(negp, 2), v(negp, 3));
      
      % Augment structure fields
      Patches.v                  = [Patches.v; v + sum(size(Patches.c, 1))];
      % Make an equal number of decimal places
      c                          = [str2num(num2str(c(:, 1), '%3.3f')), str2num(num2str(c(:, 2), '%3.3f')), str2num(num2str(c(:, 3), '%3.3f'))]; % Consistent with precision of station, segment files. We need a consistent precision when checking for existing kernels
      Patches.c                  = [Patches.c; c];
      Patches.nEl                = [Patches.nEl; size(v, 1)];
      Patches.nc                 = [Patches.nc; size(c, 1)];
   end
end