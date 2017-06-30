function [xp, yp] = rotate_xy_vec(x, y, alpha)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                     %%
%%  rotate_xy_vec.m                    %%
%%                                     %%
%%  Rotate vectors in Cartesian space  %%
%%  vp = R * v, where alpha is         %%
%%  assumed to be in radians.          %%
%%                                     %%
%%  Arguments:                         %%
%%    x:     x component               %%
%%    y:     y component               %%
%%    alpha: rotation angle (radians)  %%
%%                                     %%
%%  Returned variables:                %%
%%    xp:    rotated x component       %%
%%    yp:    rotated y component       %%
%%                                     %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Declare variables  %%
%%%%%%%%%%%%%%%%%%%%%%%%%
n                        = length(x);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Build rotation matrix  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
R                        = [cos(alpha), -sin(alpha) ; ...
                            sin(alpha),  cos(alpha)];


%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Do multiplication  %%
%%%%%%%%%%%%%%%%%%%%%%%%%
A                        = R * [x(:)' ; y(:)'];
xp                       = A(1, :)';
yp                       = A(2, :)';
