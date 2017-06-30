function [fx1, fy1, fx2, fy2, sx, sy, faz] = get_local_xy_coords_om_matlab(flong1, ...
                                                                           flat1, ...
                                                                           flong2, ...
                                                                           flat2, ...
                                                                           long, ...
                                                                           lat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                 %%
%%  get_local_xy_coords_om_matlab.m                %%
%%                                                 %%
%%  Oblique Mercator projection                    %%
%%  Zero ellipticity model at this point           %%
%%                                                 %%
%%  Projection is with axis of cyclinder normal    %%
%%  to the fault strike.                           %%
%%                                                 %%
%%  This versian requires the MATLAB mapping       %%
%%  toolbox.                                       %%
%%                                                 %%
%%  All arguments should be dimensioned as         %%
%%  radians.                                       %%
%%                                                 %%
%%  Returned variables are dimensioned as          %%
%%  radians.                                       %%
%%                                                 %%
%%  Arguments:                                     %%
%%    flong1:    longitude of one fault endpoint   %%
%%    flat1:     latitude of one fault endpoint    %%
%%    flong2:    longitude of one fault endpoint   %%
%%    flat2:     latitude of one fault endpoint    %%
%%    long:      vector of station longitudes      %%
%%    lat:       vector or station latitudes       %%
%%                                                 %%
%%  Returned variables:                            %%
%%    fx1:       projected x coordinate of one     %%
%%               fault endpoint                    %%
%%    fy1:       projected y coordinate of one     %%
%%               fault endpoint                    %%
%%    fx2:       projected x coordinate of one     %%
%%               fault endpoint                    %%
%%    fy2:       projected y coordinate of one     %%
%%               fault endpoint                    %%
%%    sx:        vector of projected x coordinate  %%
%%               of station locations              %%
%%    sy:        vector of projected y coordinate  %%
%%               of station locations              %%
%%    faz:       Azimuth of fault segment          %%
%%                                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Declare variables  %%
%%%%%%%%%%%%%%%%%%%%%%%%%
R                             = 6371;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Incorporate fault endpoint information into  %%
%%  longitude and latitude vectors               %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%long                          = [long ,flong1 ,flong2];
%lat                           = [lat ,flat1 ,flat2];
long                          = [long(:)' ,flong1 ,flong2];
lat                           = [lat(:)' ,flat1 ,flat2];

%%  M_MAP version

[pole_lon, pole_lat]          = get_pole_from_gcps(flong1, flat1, flong2, flat2);
[oo_lon, oo_lat, oo_direc]    = neworigin(rad_to_deg(pole_lon), rad_to_deg(pole_lat));
m_proj('Oblique Mercator', 'lon', [oo_lon, rad_to_deg(flong2)], 'lat', [oo_lat, rad_to_deg(flat2)], 'direction', 'horizontal');
[mx, my]                      = m_ll2xy(rad_to_deg(long), rad_to_deg(lat), 'clip', 'off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Scale to proper distances  %%
%%  This looks correct         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mx                            = mx .* R;
my                            = my .* R;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Calculate fault azimuth  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
faz                           = azimuth(flat1, flong1, flat2, flong2);
faz                           = deg_to_rad(faz);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Seperate fault endpoint information from station locations  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fx1                           = mx(length(mx) - 1);
fy1                           = my(length(my) - 1);
fx2                           = mx(length(mx));
fy2                           = my(length(my));
sx                            = mx(1 : length(mx) - 2);
sy                            = my(1 : length(my) - 2);
