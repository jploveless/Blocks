function [omegax_sig, omegay_sig, omegaz_sig] = omega_cov_to_epoles_cov(omegax, omegay, omegaz, big_Cov_epoles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                             %%
%%  epoles_cov_to_omega_cov.m                                  %%
%%                                                             %%
%%  This function takes the model parameter covariance matrix  %%
%%  in terms of the rotation vector omega and linearly         %%
%%  propagates them to Euler pole location and rotation rate   %%
%%  space.                                                     %%
%%                                                             %%
%%  Arugments:                                                 %%
%%     omegax    : x component of the rotation vector          %%
%%     omegay    : y component of the rotation vector          %%
%%     oemgaz    : z component of the rotation vector          %%
%%     big_Cov_epoles : Covariance matrix for Euler poles and  %%
%%                      rotation rates                         %%
%%                                                             %%
%%  Returned variables:                                        %%
%%     Euler_lon_sig : propagated uncertainty for Euler lon    %%
%%     Euler_lat_sig : propagated uncertainty for Euler lat    %%
%%     rotation_rate_sig : propagated uncertainty for          %%
%%                         rotation rate                       %%
%%                                                             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Loop over each set of estimates  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cnt = 1 : length(omegax)


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%  Get local indices to grab the parts of the big matrix and vectors that we need  %%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   crnt_idx                                           = (cnt - 1) * 3 + 1;


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%  Assign local variables for each set of estimates  %%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   x                                                  = omegax(cnt);
   y                                                  = omegay(cnt);
   z                                                  = omegaz(cnt);
   Cov_epoles                                         = big_Cov_epoles( crnt_idx : crnt_idx + 2 , crnt_idx : crnt_idx + 2);
   Euler_lon_sig                                      = sqrt(Cov_epoles(1, 1));
   Euler_lat_sig                                      = sqrt(Cov_epoles(2, 2));
   rotation_rate_sig                                  = sqrt(Cov_epoles(3, 3));


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%  There may be cases where x, y and z are all zero.  This leads to /0 errors.  To avoid this  %%
   %%  we check for these cases and Let A = b * I where b is a small constant (10^-4) and I is     %%
   %%  the identity matrix                                                                         %%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   if (x == 0) & (y == 0)
      A                                               = 10^-4 .* eye(3);
   else
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%  Calculate the partial derivatives  %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      dlat_dx                                         = -z / (x^2 + y^2)^(3/2) / (1 + z^2 / (x^2 + y^2)) * x;
      dlat_dy                                         = -z / (x^2 + y^2)^(3/2) / (1 + z^2 / (x^2 + y^2)) * y;
      dlat_dz                                         = 1 / (x^2 + y^2)^(1/2) / (1 + z^2 / (x^2 + y^2));
      dlon_dx                                         = -y / x^2 / (1 + (y / x)^2);
      dlon_dy                                         = 1 / x / (1 + (y / x)^2);
      dlon_dz                                         = 0;
      dmag_dx                                         = x / sqrt(x^2 + y^2 + z^2);
      dmag_dy                                         = y / sqrt(x^2 + y^2 + z^2);
      dmag_dz                                         = z / sqrt(x^2 + y^2 + z^2);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%  Organize them into a matrix  %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      A                                               = [ dlat_dx, dlat_dy, dlat_dz ; ...
                                                          dlon_dx, dlon_dy, dlon_dz ; ...
                                                          dmag_dx, dmag_dy, dmag_dz ];
   end

   delta_vec_epoles                                   = [ Euler_lat_sig ; Euler_lon_sig ; rotation_rate_sig ];


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%  Propagate the uncertainties and the new covariance matrix  %%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   delta_vec_omega                                    = inv(A) * delta_vec_epoles;
   Cov_omega                                          = inv(A) * Cov_epoles * inv(A)';


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%  Organized data for the return  %%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   diag_vec                                           = diag(Cov_omega);
   omegax_sig(cnt)                                    = sqrt(diag_vec(1));
   omegay_sig(cnt)                                    = sqrt(diag_vec(2));
   omegaz_sig(cnt)                                    = sqrt(diag_vec(3));


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%  Organize data for the return (This doesn't seem to work so well)  %%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%  omegax_sig(cnt)                                    = delta_vec_omega(1);
   %%  omegay_sig(cnt)                                    = delta_vec_omega(2);
   %%  omegaz_sig(cnt)                                    = delta_vec_omega(3);

end
