function [vx, vy, vz] = sph_vec_to_cart_vec(vn, ve, vu, long, lat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                    %%
%%  sph_vec_to_cart_vec.m                             %%
%%                                                    %%
%%  This script transforms vectors from Cartesian to  %%
%%  spherical components.                             %%
%%  Both longitude and latitude are expected to be    %%
%%  given in radians.                                 %%
%%                                                    %%
%%  Arguments:                                        %%
%%    vn:    vector of north components of velocity   %%
%%    ve:    vector of east components of velocity    %%
%%    vu:    vector of up components of velocity      %%
%%    long:  vector of station longitudes             %%
%%    lat:   vector of station latitudes              %%
%%                                                    %%
%%  Returned variables:                               %%
%%    vx:    vector of x components of velocity       %%
%%    vy:    vector of y components of velocity       %%
%%    vz:    vector of z components of velocity       %%
%%                                                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Loop over each vector  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('sph->Cart_vector_transform')
for v_cnt = 1 : length(vn)
   G            = zeros(3);
   G            = [ -sin(lat(v_cnt))*cos(long(v_cnt)) , ...
                    -sin(lat(v_cnt))*sin(long(v_cnt)) , ...
                     cos(lat(v_cnt)) ; ...
                    -sin(long(v_cnt)) , ...
                     cos(long(v_cnt)) , ...
                     0 ; ...
                    -cos(lat(v_cnt))*cos(long(v_cnt)) , ...
	            -cos(lat(v_cnt))*sin(long(v_cnt)) , ...
		    -sin(lat(v_cnt)) ];
   v_c          = inv(G)*[vn(v_cnt) ; ve(v_cnt) ; vu(v_cnt)];
   vx(v_cnt)    = v_c(1);
   vy(v_cnt)    = v_c(2);
   vz(v_cnt)    = v_c(3);
end
