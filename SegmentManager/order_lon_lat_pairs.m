function [nlon1, nlat1, nlon2, nlat2] = order_lon_lat_pairs(lon1, lat1, lon2, lat2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                            %%
%%  order_lon_lat_pairs.m                     %%
%%                                            %%
%%  This function orders longitude, latitude  %%
%%  pairs according to the blocks_sp1         %%
%%  convention.                               %%
%%                                            %%
%%  Arguments:                                %%
%%    lon1: longitude of fault endpoint A     %%
%%    lat1: latitude of fault endpoint A      %%
%%    lon2: longitude of fault endpoint B     %%
%%    lat2: latitude of fault endpoint B      %%
%%                                            %%
%%  Returned variables:                       %%
%%    nlon1: ordered longitude enpoint A'     %%
%%    nlat1: ordered latitude endpoint A'     %%
%%    nlon2: ordered longitude endpoint B'    %%
%%    nlat2: ordered latitude endpoint B'     %%  
%%                                            %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for cnt = 1 : length(lon1)

   if (lon1(cnt) == lon2(cnt))
      if (lat1(cnt) < lat2(cnt))
         nlon1(cnt) = lon1(cnt);
         nlat1(cnt) = lat1(cnt);
         nlon2(cnt) = lon2(cnt);
         nlat2(cnt) = lat2(cnt);
      else
         nlon1(cnt) = lon2(cnt);
         nlat1(cnt) = lat2(cnt);
         nlon2(cnt) = lon1(cnt);
         nlat2(cnt) = lat1(cnt);
      end
   elseif (lon1(cnt) < lon2(cnt))
      nlon1(cnt) = lon1(cnt);
      nlat1(cnt) = lat1(cnt);
      nlon2(cnt) = lon2(cnt);
      nlat2(cnt) = lat2(cnt);
   else
      nlon1(cnt) = lon2(cnt);
      nlat1(cnt) = lat2(cnt);
      nlon2(cnt) = lon1(cnt);
      nlat2(cnt) = lat1(cnt);
   end
end
