function out = modelcrawl(direcs, oldmat, faultnames)
% modelcrawl  Crawls Blocks directories to organize fault results
%   modelcrawl(direcs, name) reads fault slip rate information from
%   the list of directories contained in direcs and arranges it into
%   a set of matrices, with runs as the rows and fault segments as the
%   columns. Specify name as a string as the name of a new .mat file 
%   to be created from this run, or referencing an existing .mat file
%   saved from a previous run of modelcrawl. Or, specify name as a 
%   structure in the workspace containing matrix fields created
%   by a previous run. 
% 

% Parse whether we're appending or not
if isstruct(oldmat) % If a structure is passed, 
   out = oldmat; % We'll build onto it
elseif ischar(oldmat) % If a string is passed,
   if exist(oldmat, 'file') == 2 % and it's a .mat file,
      out = load(oldmat) % Read it as a structure.
   else % If not, 
      out = struct([]); % Create a blank structure
      

