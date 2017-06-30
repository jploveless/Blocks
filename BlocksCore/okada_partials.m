function [uxstot, uystot, uzstot...
          uxdtot, uydtot, uzdtot...
          uxttot, uyttot, uzttot]   = okada_partials(xf, yf, strike, d, delta, L, W, U1, U2, U3, xs, ys, Pr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                                        %%
%%  okada_plus_op_v.m          
%%                                                                        %%
%%  ** Change here (the "_v") is that stations are referenced as 
%%     a vector, rather than looping over each station.                   %%
%%                                                                        %%
%%                                                                        %%
%%  Calculate surface displacements due to slip on a dislocation          %%
%%  in an elastic halfspace (after Okada, BSSA 1985).  All angle          %%
%%  arguments (stike and dip) are assumed to be given in radians.         %%
%%                                                                        %%
%%  This version of Okada's code has been somewhat optimized.  By         %%
%%  reducing repetitive calculations 25% fewer flops are needed.  The     %%
%%  scaling seems rather linear and amounts to about a 15% increase in    %%
%%  speed.                                                                %%
%%                                                                        %%
%%  Note:  *** special version for use with blocks_sp1.m  ***             %%
%%         Fault and station coordinates are assumed to be pre-rotated    %%
%%       through the use of 'get_local_coords_om.m'                       %%
%%         In the end it may be more efficient to have separate funtions  %%
%%       for calculating each of the three dislocation components.  This  %%
%%       makes sense in terms of the partial derivative method we use     %%
%%       calculating model velocities, as well as for the estimation      %%
%%       part.                                                            %%
%%                                                                        %%
%%  Arguments:                                                            %%
%%    xf     : x component of fault corner in Okada ref frame             %%
%%    xf     : y component of fault corner in Okada ref frame             %%
%%    strike : is the azimuth of the fault (should always be zero for     %%
%%             blocks_sp1 case)                                           %%
%%    d      : is the depth (-z) of the origin of the fault               %%
%%    dip    : is the inclination of the fault (measured clockwise        %%
%%             from horizontal left, facing along the strike)             %%
%%    L      : is the along strike length of the fault plane              %%
%%    W      : is the down dip length of fault plane                      %%
%%    U1     : is the magnitude of the strike slip dislocation            %%
%%    U2     : is the magnitude of the dip slip dislocation               %%
%%    U3     : is the magnitude of the tensile dislocation                %%
%%    xs     : x component of station position                            %%
%%    ys     : y component of station position                            %%
%%    Pr     : is Poisson's ratio                                         %%
%%                                                                        %%
%%  Returned variables:                                                   %%
%%    uxtot  : total x displacement                                       %%
%%    uytot  : total y displacement                                       %%
%%    uztot  : total z displacement                                       %%
%%                                                                        %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Declare constants and variables  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tol                = 1.0e-4;
alpha              = -2 * Pr + 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Get station locations relative to fault anchor  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xt                 = xs - xf;
yt                 = ys - yf;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Rotate station locations to remove strike  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
alpha_rot          = -strike;
[xr, yr]           = rotate_xy_vec(xt, yt, alpha_rot);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Calculate some values that are frequently needed  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sind               = sin(delta);
cosd               = cos(delta);
twopi              = 2.*pi;

uxtot			       = zeros(length(xr), 1);
uytot              = zeros(length(xr), 1);
uztot              = zeros(length(xr), 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Find displacements at each station  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  x               = xr;
  y               = yr;
  p               = y.*cosd + d.*sind;
  q               = repmat(y.*sind - d.*cosd, 1, 4);
  zi              = [x x x-L x-L];
  eta             = [p p-W p p-W];
  ybar            = eta.*cosd + q.*sind;
  dbar            = eta.*sind - q.*cosd;
  R               = sqrt(zi.^2 + eta.^2 + q.^2);
  X               = sqrt(zi.^2 + q.^2);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%  Calculate some more commonly used values  %%
  %%  These are introduced to reduce repetive   %%
  %%  calculations.  (see okada.m for Okada's   %%
  %%  form of the equations)                    %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  Reta            = R+eta;
  Rzi             = R+zi;
  Rdbar           = R+dbar;
  qdivR           = q./R;
  phi             = atan(zi.*eta./q./R);


  if (abs(cosd) >= tol)
    I5            =  alpha * 2 ./ cosd * atan((eta.*(X + q.*cosd) ...
                     + (X.*(R + X)*sind))./(zi.*(R+X).*cosd));
    I4            =  alpha./cosd * (log(Rdbar) - sind.*log(Reta));
    I3            =  alpha .* (1./cosd.*ybar./Rdbar - log(Reta) )  ...
                     + sind./cosd.*I4;
    I2            =  alpha .* (-log(Reta)) - I3;
    I1            =  alpha .* (-1./cosd.*zi./Rdbar) - sind./cosd.*I5;
  else
    I5            = -alpha.*(zi.*sind)./Rdbar;
    I4            = -alpha.*q./Rdbar;
    I3            =  alpha./2 .*(eta./Rdbar + ybar.*q./Rdbar.^2 - log(Reta));
    I2            =  alpha .* (-log(Reta)) - I3;
    I1            = -alpha/2 .* (zi.*q)./Rdbar.^2;
  end

  uxs             = -U1./twopi .* (zi.*qdivR./(Reta) + phi + I1.*sind);
  uxd             = -U2./twopi .* (qdivR - I3.*sind.*cosd);
  uxt             =  U3./twopi .* (q.*qdivR./(Reta) - I3.*sind.^2);

  uys             = -U1./twopi .* (ybar.*qdivR./(Reta) + q.*cosd./(Reta) + I2.*sind);
  uyd             = -U2./twopi .* (ybar.*qdivR./(Rzi)  + cosd.*phi - I1.*sind.*cosd);
  uyt             =  U3./twopi .* (-dbar.*qdivR./(Rzi) - sind.*(zi.*qdivR./(Reta) - phi) - I1.*sind.^2);

  uzs             = -U1./twopi .* (dbar.*qdivR./(Reta) + q.*sind./(Reta) + I4.*sind);
  uzd             = -U2./twopi .* (dbar.*qdivR./(Rzi) + sind.*phi - I5.*sind.*cosd);
  uzt             =  U3./twopi .* (ybar.*qdivR./(Rzi) + cosd.*(zi.*qdivR./(Reta) - phi) - I5.*sind.^2);

  uxstot          = uxs(:, 1) - uxs(:, 2) - uxs(:, 3) + uxs(:, 4);
  uxdtot          = uxd(:, 1) - uxd(:, 2) - uxd(:, 3) + uxd(:, 4);
  uxttot          = uxt(:, 1) - uxt(:, 2) - uxt(:, 3) + uxt(:, 4);
  uystot          = uys(:, 1) - uys(:, 2) - uys(:, 3) + uys(:, 4);
  uydtot          = uyd(:, 1) - uyd(:, 2) - uyd(:, 3) + uyd(:, 4);
  uyttot          = uyt(:, 1) - uyt(:, 2) - uyt(:, 3) + uyt(:, 4);
  uzstot          = uzs(:, 1) - uzs(:, 2) - uzs(:, 3) + uzs(:, 4);
  uzdtot          = uzd(:, 1) - uzd(:, 2) - uzd(:, 3) + uzd(:, 4);
  uzttot          = uzt(:, 1) - uzt(:, 2) - uzt(:, 3) + uzt(:, 4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Rotate the station displacements back to include the effect of the strike  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[uxstot, uystot]  = rotate_xy_vec(uxstot, uystot, -alpha_rot);
[uxdtot, uydtot]  = rotate_xy_vec(uxdtot, uydtot, -alpha_rot);
[uxttot, uyttot]  = rotate_xy_vec(uxttot, uyttot, -alpha_rot);