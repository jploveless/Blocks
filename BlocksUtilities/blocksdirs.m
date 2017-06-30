function blocksdirs(bpath)
% BLOCKSDIRS  Creates an empty Blocks model directory structure
%    BLOCKSDIRS creates empty Blocks model directories in the 
%    current working directory. The directories:
%    - block
%    - command
%    - result
%    - segment
%    - station
%    are created, with blank template model.block, model.command
%    model.segment, and model.sta files placed in the appropriate
%    directory. These directories are not generated if they already
%    exist in the current working directory.
%
%    BLOCKSDIRS(path) creates the template directory structure in 
%    the specified path. 
%     

% Check for specification of input path
if nargin == 0
   bpath = pwd;
end

% Make sure target directory exists
if ~exist(bpath, 'dir')
   system(sprintf('mkdir %s', bpath));
end

% Determine $BlocksHome
a = which('blocksdirs.m');
p = [fileparts(a) filesep];

% Make block directory
if ~exist([bpath filesep 'block'], 'dir')
   system(sprintf('mkdir %s%sblock', bpath, filesep));
   system(sprintf('cp %smodel.block %s%sblock%s.', p, bpath, filesep, filesep));
end

% Make command directory
if ~exist([bpath filesep 'command'], 'dir')
   system(sprintf('mkdir %s%scommand', bpath, filesep));
   system(sprintf('cp %smodel.command %s%scommand%s.', p, bpath, filesep, filesep));
end

% Make result directory
if ~exist([bpath filesep 'result'], 'dir')
   system(sprintf('mkdir %s%sresult', bpath, filesep));
end

% Make segment directory
if ~exist([bpath filesep 'segment'], 'dir')
   system(sprintf('mkdir %s%ssegment', bpath, filesep));
   system(sprintf('cp %smodel.segment %s%ssegment%s.', p, bpath, filesep, filesep));
end

% Make station directory
if ~exist([bpath filesep 'station'], 'dir')
   system(sprintf('mkdir %s%sstation', bpath, filesep));
   system(sprintf('cp %smodel.sta %s%sstation%s.', p, bpath, filesep, filesep));
end
