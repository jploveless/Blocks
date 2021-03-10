function dirname = newdir(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                                 %%
%%  newdir.m                                                       %%
%%                                                                 %%
%%  This file returns the name of the directory most recently      %%
%%  created by some Blocks.                                        %%
%%                                                                 %%
%%  Providing an optional integer input argument N will return     %%
%%  the name of (newdir - N)                                       %%
%%                                                                 %%
%%                                                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 1
   N = varargin{:};
else
   N = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Get the directory listing that matches the filemask  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dir_list                             = dir;
n_files                              = length(dir_list);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Find the indices of the directories  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cnt = 1 : n_files
   is_dir_vec(cnt)                   = dir_list(cnt).isdir;
end
is_dir_idx                           = find(is_dir_vec == 1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Convert the directory names to values  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off
for cnt = 1 : length(is_dir_idx)
   temp_val                          = str2num(dir_list(is_dir_idx(cnt)).name);
   if length(temp_val) ~= 0
      dir_val(cnt)                   = temp_val(1);
   else
      dir_val(cnt)                   = 0;
   end

end
warning on


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Find the largest value of dir_val  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[max_dir_val, max_dir_idx]           = max(dir_val);
new_dir_idx                          = is_dir_idx(max_dir_idx);


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  define output name  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%
if new_dir_idx - N > 0
   dirname = [dir_list(new_dir_idx - N).name filesep];
else
   dirname = [dir_list(1).name filesep];
end