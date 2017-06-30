function save_current_figure(varargin)
%%  save_current_figure.m
%%
%%  This will save the current figure as
%%     .jpg
%%     .png
%%     .eps
%%     .tiff
%%
%%  Arguments (optional) :
%%    base_file_name
%%    resolution
%%    tag_stat
%%
%%  Returned variables : none

%%  Declare variables
resolution                                   = 300;
tag_stat                                     = 'no';

%%  Parse the command line
if (nargin == 0)
   base_file_name                            = input('Base name for figure --> ', 's');
elseif (nargin == 1)
   base_file_name                            = varargin{1};
elseif (nargin == 2)
   base_file_name                            = varargin{1};
   resolution                                = varargin{2};
elseif (nargin == 3)
   base_file_name                            = varargin{1};
   resolution                                = varargin{2};
   tag_stat                                  = varargin{3};
else
   disp(sprintf('Too many input arguments'));
   return;
end

%%  Add a location and time stamp tag to the figure if necessary
if (strcmp(tag_stat, 'tag'))
   myfootnote('path', '', 'date');
end

%%  Write the .jpg
print('-djpeg100', sprintf('-r%d', resolution), sprintf('%s.jpg', base_file_name));

%%  Write the .png
print('-dpng', sprintf('-r%d', resolution), sprintf('%s.png', base_file_name));

%%  Write the .tiff
print('-dtiff', sprintf('-r%d', resolution), sprintf('%s.tiff', base_file_name));

%%  Write the .eps
print('-depsc2', sprintf('%s.eps', base_file_name));

%%  Announce current path
disp(sprintf(' '));
disp(sprintf('All files written to %s at %d%% resolution', pwd, resolution));

%%  Announce the size and location of the files
jpg_file_info                                       = dir(sprintf('%s.jpg', base_file_name));
disp(sprintf('%s.jpg    is %10.3f kB', base_file_name, jpg_file_info.bytes / 1e3));
png_file_info                                       = dir(sprintf('%s.png', base_file_name));
disp(sprintf('%s.png    is %10.3f kB', base_file_name, png_file_info.bytes / 1e3));
tiff_file_info                                      = dir(sprintf('%s.tiff', base_file_name));
disp(sprintf('%s.tiff   is %10.3f kB', base_file_name, tiff_file_info.bytes / 1e3));
eps_file_info                                       = dir(sprintf('%s.eps', base_file_name));
disp(sprintf('%s.eps    is %10.3f kB', base_file_name, eps_file_info.bytes / 1e3));
disp(sprintf(' '));