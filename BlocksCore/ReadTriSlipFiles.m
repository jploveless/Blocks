function triap = ReadTriSlipFiles(names, p)
% READTRISLIPFILES  Reads a priori slip files for triangles
%   triap = READTRISLIPFILES(names, p) reads a priori slip file(s) specified
%   by the full path names and applied to triangle patch structure p. names
%   can be a 1-by-n character array, assumed to have been specified in the 
%   .command file and referencing element indices by their position in the 
%   global listing of elements, or an m-by-p character array, assumed to have
%   be read in during ReadMshp and representing a priori slip on individual 
%   meshes listed in the .mshp file. In this case, the element indices specified
%   in the a priori slip files should be local to that mesh. 
%

% Blank array containing constraints
triap = zeros(sum(p.nEl), 3);

% Cumulative tally of number of elements
cnel = [0; cumsum(p.nEl(1:end-1))];

% Test to check the type of listing
numrows = size(names, 1);
if numrows > 1 % More than one file; source is ReadMshp
   % Loop through all file names
   for i = 1:numrows
      % If it's not blank, then a real name was specified
      if length(strtrim(names(i, :))) > 0
         slips = load(strtrim(names(i, :)));
         triap(cnel(i)+slips(:, 1), 1:size(slips, 2)) = [cnel(i)+slips(:, 1), slips(:, 2:end)];
      end
   end
else 
   % If only one file is specified, it was read from the .command file 
   if length(strtrim(names)) > 0
      triap = load(strtrim(names)); % No correction to indices needed; assumed to apply globally
   end
end

% Compact the output by returning only non-zero rows...
triap = triap(triap(:, 1) ~= 0, :);
% And by cutting off the third column, if coupling has been specified
%srows = sum(triap, 1) ~= 0;
%triap = triap(:, srows);
   