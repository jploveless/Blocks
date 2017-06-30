function [new_vec] = swap_index(old_vec, new_idx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                    %%
%%  swap_index.m                      %%
%%                                    %%
%%  This function reorders vectors.   %%
%%  Both vectors must be the same     %%
%%  length.                           %%
%%                                    %%
%%  Arugments:                        %%
%%    old_vec : unordered vector      %%
%%    new_idx : index mapping vector  %%
%%                                    %%
%%  Returned variables:               %%
%%    new_vec : reordered vector      %%
%%                                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Make sure both vectors are the same length  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (length(old_vec) ~= length(new_idx))
   disp(sprintf('Old vector and new index mapping vector are not the same length!'))
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Declare blanck vector of the right length and shape  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
new_vec                  = zeros(size(old_vec));


%%%%%%%%%%%%%%%%%%%
%%  Do the swap  %%
%%%%%%%%%%%%%%%%%%%
for cnt = 1 : length(old_vec)
   new_vec(new_idx(cnt)) = old_vec(cnt);
end
