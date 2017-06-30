function WriteInputCopies(c, direc)
% WRITEINPUTCOPIES  Copies Blocks input files to results directory
%   WriteInputCopies(c, direc) writes the input files as specified in
%   command structure c to the folder direc.
%

% Make the directory
system(sprintf('mkdir %s', direc)); 

% Copy the segment, block, and station file
system(sprintf('cp ''%s'' %s%s.', c.segFileName, direc, filesep));
system(sprintf('cp ''%s'' %s%s.', c.blockFileName, direc, filesep));
system(sprintf('cp ''%s'' %s%s.', c.staFileName, direc, filesep));

% Parse number of patch files
spaces = strfind(strtrim(c.patchFileNames), ' ');
npatch = numel(spaces) + 1;
ends = [spaces - 1, length(strtrim(c.patchFileNames))];
begs = [1 ends(1:end-1)+2];
% Write patch files
if ends ~= 0
   for i = 1:length(begs)
      system(sprintf('cp ''%s'' %s%s.', c.patchFileNames(begs(i):ends(i)), direc, filesep));
   end
end
