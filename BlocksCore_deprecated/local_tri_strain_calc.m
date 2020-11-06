function [nee, nnn, nuu, nen, neu, nnu, baz]  = local_tri_strain_calc(lon1, lat1, z1, lon2, lat2, z2, lon3, lat3, z3, slon, slat, sz, ess, eds, ets, nu);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                  %%
%%  local_tri_calc.m                                %%
%%                                                  %%
%%  This function calculates surface displacements  %%
%%  from triangular dislocation (Meade, 2007).      %%
%%  This set of functions does a map projection     %%
%%  local to the trace of the fault.  This          %%
%%  minimized distortion due to larger scale        %%
%%  projections.  Approximate enu components of     %%
%%  displacements are returned.  This allows for    %%
%%  speedy comparisons with measured displacements. %%
%%                                                  %%
%%                                                  %%
%%  The map projection stuff requires the MATLAB    %%
%%  mapping toolbox                                 %%
%%                                                  %%
%%  Arguments:                                      %%
%%    lon1:    Longitude of element vertex one      %%
%%             [degrees]                            %%
%%    lat1:    Latitude of element vertex one       %%
%%             [degrees]                            %%
%%    z1:      Depth of element vertex one          %%
%%             [km]                                 %%
%%    lon2:    Longitude of element vertex two      %%
%%             [degrees]                            %%
%%    lat2:    Latitude of element vertex two       %%
%%             [degrees]                            %%
%%    z2:      Depth of element vertex two          %%
%%             [km]                                 %%
%%    lon3:    Longitude of element vertex three    %%
%%             [degrees]                            %%
%%    lat3:    Latitude of element vertex three     %%
%%             [degrees]                            %%
%%    z3:      Depth of element vertex three        %%
%%             [km]                                 %%
%%    slon:    station longitudes                   %%
%%             [degrees]                            %%
%%    slat:    station latitudes                    %%
%%             [degrees]                            %%
%%    ess:     strike slip component of slip        %%
%%    eds:     dip slip component of slip           %%
%%    ets:     tensile slip component of slip       %%
%%    nu:      Poisson's ratio                      %%
%%                                                  %%
%%  Returned variables:                             %%
%%    nue:  east displacement                       %%
%%    nun:  north displacement                      %%
%%    nuu:  up displacement                         %%
%%                                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Convert everything into radians  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lon1                                       = deg_to_rad(lon1);
lat1                                       = deg_to_rad(lat1);
lon2                                       = deg_to_rad(lon2);
lat2                                       = deg_to_rad(lat2);
lon3                                       = deg_to_rad(lon3);
lat3                                       = deg_to_rad(lat3);
slon                                       = deg_to_rad(slon);
slat                                       = deg_to_rad(slat);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Do a local projection to flat space using an oblique Mercator projection  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[bx1, by1, bz1,...
 bx2, by2, bz2,...
 bx3, by3, bz3,...
 bx, by, baz]                              = get_local_xy_coords_om_matlab_tri(lon1, lat1, z1, lon2, lat2, z2, lon3, lat3, z3, slon, slat);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Do deformation calculation  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[xx, yy, zz, xy, xz, yz]                    = tri_strain_fast([bx1 bx2 bx3], [by1 by2 by3], -[bz1 bz2 bz3], bx, by, sz, ess, eds, ets, nu);
%[nee, nnn, nzz, nen, neu, nnu]              = tri_strain([bx1 bx2 bx3], [by1 by2 by3], -[bz1 bz2 bz3], bx, by, sz, ess, eds, ets, nu);
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Convert fault azimuth to a more useful rotation system  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%baz                                        = rad_to_deg(baz);
%baz                                        = -baz + 90;
%baz                                        = deg_to_rad(baz);
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Rotate vectors to correct for fault strike  %%
%%%  i.e., rotate out of oblique Mercator        %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[nuee, nunn, nuen, nueu, nunu]            = deal(zeros(size(uxx)));
%for cnt = 1 : length(uxx)
%   [tee, tne]                             = rotate_xy_vec(uxx(cnt), uxy(cnt), baz);
%   [ten, tnn]                             = rotate_xy_vec(uxy(cnt), uyy(cnt), baz);
%   [teu, tnu]                             = rotate_xy_vec(uxz(cnt), uyz(cnt), baz);
%   nuee(cnt)                              = tee;
%   nunn(cnt)                              = tnn;
%   nuen(cnt)                              = ten;
%   nueu(cnt)                              = teu;
%   nunu(cnt)                              = tnu;
%end
%nuuu                                      = uzz;

[nee, nnn, nuu, nen, neu, nnu]       = deal(zeros(size(xx)));
baz = baz + pi/2;
rot = [cos(baz) sin(baz) 0; -sin(baz) cos(baz) 0; 0 0 1];
for i = 1:length(xx)
   smat = [xx(i) xy(i) xz(i); xy(i) yy(i) yz(i); xz(i) yz(i) zz(i)];
   rmat = rot*smat*rot';
   nee(i) = rmat(1); nnn(i) = rmat(5); nuu(i) = rmat(9);
   nen(i) = rmat(2);
   neu(i) = rmat(3);
   nnu(i) = rmat(6);
end
