function [nue, nun, nuu] = local_okada_calc(flong1, flat1, flong2, flat2, long, lat, fdip, fld, fss, fds, fts, nu, fbd)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                  %%
%%  local_okada_calc.m                              %%
%%                                                  %%
%%  This function calculates surface displacements  %%
%%  from an a buried Volterra (Okada, 1985)         %%
%%  dislocation.  The Okada calculation is          %%
%%  traditional but really nice part is that this   %%
%%  set of functions does a map projection local    %%
%%  to the trace of the fault.  This minimized      %%
%%  distortion due to larger scale projections.     %%
%%  Approximate enu components of displacements     %%
%%  are returned.  This allows for speedy           %%
%%  comparisons with measured displacements.        %%
%%                                                  %%
%%  The Okada takes one additional parameter then   %%
%%  does the common implementation.  Poisson's      %%
%%  ratio is passed and converted to what I've      %%
%%  taken to calling the Okada ratio.               %%
%%                                                  %%
%%  The map projection stuff requires the MATLAB    %%
%%  mapping toolbox                                 %%
%%                                                  %%
%%  Arguments:                                      %%
%%    flong1:  Longitude of fault endpoint one      %%
%%             [degrees]                            %%
%%    flat1:   Latitude of fault endpoint one       %%
%%             [degrees]                            %%
%%    flong2:  Longtiude of fault endpoint two      %%
%%             [degrees]                            %%
%%    flat2:   Latitude of fault endpoint two       %%
%%             [degrees]                            %%
%%    long:    station longitudes                   %%
%%             [degrees]                            %%
%%    lat:     station latitudes                    %%
%%             [degrees]                            %%
%%    fdip:    fault dip                            %%
%%             [degrees]                            %%
%%    fld:     fault locking depth [km]             %%
%%    fss:     strike slip component of slip        %%
%%    fds:     dip slip component of slip           %%
%%    fts:     tensile slip component of slip       %%
%%    nu:      Poisson's ratio                      %%
%%    fbd:     fault burial depth                   %%
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
flong1                        = deg_to_rad(flong1);
flat1                         = deg_to_rad(flat1);
flong2                        = deg_to_rad(flong2);
flat2                         = deg_to_rad(flat2);
long                          = deg_to_rad(long);
lat                           = deg_to_rad(lat);
fdip                          = deg_to_rad(fdip);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Do a local projection to flat space using an oblique Mercator projection  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[bx1, by1, bx2, by2, bx, by, baz]    = get_local_xy_coords_om_matlab(flong1, flat1, flong2, flat2, long, lat);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Get Okada style fault parameters  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[strike, L, W, ofx, ofy, ofxe, ofye, ...
               tfx, tfy, tfxe, tfye] = fault_params_to_okada_form(bx1, by1, bx2, by2, fdip, fld, fbd);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Do deformation calculation  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ux, uy, uz]                         = okada_plus_op_v(ofx, ofy, strike, fld, fdip, L, W, fss, fds, fts, bx, by, nu);

% [ux, uy, uz]                         = okada_disloc(ofx, ofy, strike, fld, fdip, L, W, fss, fds, fts, bx, by, nu);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Try a call to the function version of the angle correction routine  %%
%%  This is not neccesary with a Mercator projection as it is           %%
%%  conformal                                                           %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  [tux, tuy]                           =  unproject_vectors(flong1, flat1, flong2, flat2, long, lat, ux, uy);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Convert fault azimuth to a more useful rotation system  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
baz                                  = rad_to_deg(baz);
baz                                  = -baz + 90;
baz                                  = deg_to_rad(baz);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Rotate vectors to correct for fault strike  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nue											 = zeros(length(ux), 1);
nun											 = zeros(length(ux), 1);
for cnt = 1 : length(ux)
   [te, tn]                          = rotate_xy_vec(ux(cnt), uy(cnt), baz);
   nue(cnt) = te;
   nun(cnt) = tn;
end
nuu                                  = uz;
