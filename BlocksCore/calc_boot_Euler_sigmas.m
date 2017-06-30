%function [Elon_sig, Elat_sig, rrate_sig, ...
%          lon_lat_corr, lon_rrate_corr, lat_rrate_corr] = calc_boot_Euler_sigmas(omega_x, omega_x_sig, omega_y, omega_y_sig, omega_z, omega_z_sig, J, W, d)
function [Elon_sig, Elat_sig, rrate_sig] = calc_boot_Euler_sigmas(omega_x, omega_x_sig, omega_y, omega_y_sig, omega_z, omega_z_sig, J, W, d)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                                       %%
%%  calc_boot_Euler_sigmas.m                                             %%
%%                                                                       %%
%%  This function will estimate 1-sigma uncertainties in the Euler pole  %%
%%  longitude and latitude as well as the block rotation rate.           %%
%%                                                                       %%
%%  Arguments:                                                           %%
%%    omega_x         : x component of estiamted rotation vector         %%
%%    omega_x_sig     : uncertainty in x component                       %%
%%    omega_y         : y component of estiamted rotation vector         %%
%%    omega_y_sig     : uncertainty in y component                       %%
%%    omega_z         : z component of estiamted rotation vector         %%
%%    omega_z_sig     : uncertainty in y component                       %%
%%    J               : Jacobian                                         %%
%%    W               : weighting matrix                                 %%
%%    d               : data_vector                                      %%
%%                                                                       %%
%%  Returned variables:                                                  %%
%%    Elon_sig   : estimate of Euler pole longitude uncertainty          %%
%%    Elat_sig   : estimate of Euler pole latitude uncertainty           %%
%%    rrate_sig  : estiamte of rotation rate uncertainty                 %%
%%    lon_lat_corr   : correlation between lon and lat                   %%
%%    lon_rrate_corr : correlation between lon and rrate                 %%
%%    lat_rrate_corr : correlation between lat and rrate                 %%
%%                                                                       %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Declare variables  %%
%%%%%%%%%%%%%%%%%%%%%%%%%
sig_mult                                                                                              = 1;
%%  n_blocks                                                                                              = size(J, 2) / 3;
n_combos                                                                                              = length(omega_x);
n_samples                                                                                             = 1000;
boot_Elon_sig                                                                                         = zeros(n_combos, 1);
boot_Elat_sig                                                                                         = zeros(n_combos, 1);
boot_rrate_sig                                                                                        = zeros(n_combos, 1);
sigma_vec                                                                                             = diag(W);


%%%%%%%%%%%%%%%%%%%%
%%  Scale sigmas  %%
%%%%%%%%%%%%%%%%%%%%
omega_x_sig                                                                                           = sig_mult * omega_x_sig;
omega_y_sig                                                                                           = sig_mult * omega_y_sig;
omega_z_sig                                                                                           = sig_mult * omega_z_sig;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Define inline function to generate the a vector of squared residuals  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  sum_weighted_resid                          = inline('sum((d - J * build_big_omega_from_omega(omega_x, omega_y, omega_z)).^2 ./ sigma_vec.^2)', 'J', 'omega_x', 'omega_y', 'omega_z', 'd', 'sigma_vec');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Build random vectors based on sigmas  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
omega_x_vec = repmat(omega_x, 1, n_samples) + repmat(omega_x_sig, 1, n_samples).*(rand(n_combos, n_samples) - 0.5);
omega_y_vec = repmat(omega_y, 1, n_samples) + repmat(omega_y_sig, 1, n_samples).*(rand(n_combos, n_samples) - 0.5);
omega_z_vec = repmat(omega_z, 1, n_samples) + repmat(omega_z_sig, 1, n_samples).*(rand(n_combos, n_samples) - 0.5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Convert these components of the rotation vector to an Euler pole location and rotation rate  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[rrate_vec, Elon_vec, Elat_vec] = omega_to_rate_and_Euler_DM(omega_x_vec, omega_y_vec, omega_z_vec);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Calculate the correlation coefficients in the propagated space  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lon_lat_corr_mat                                                                                    = corrcoef(Elon_vec', Elat_vec');
%lon_lat_corr(cnt)                                                                                   = lon_lat_corr_mat(1, 2);
%lon_rrate_corr_mat                                                                                  = corrcoef(Elon_vec', rrate_vec');
%lon_rrate_corr(cnt)                                                                                 = lon_rrate_corr_mat(1, 2);
%lat_rrate_corr_mat                                                                                  = corrcoef(Elat_vec', rrate_vec');
%lat_rrate_corr(cnt)                                                                                 = lat_rrate_corr_mat(1, 2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Calculate minimums, maximums and means and sigmas  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
min_Elon                                                                                           = min(Elon_vec, [], 2);
max_Elon                                                                                           = max(Elon_vec, [], 2);
mean_Elon                                                                                          = mean(Elon_vec, 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  The two estimates may cross the meridian and thus  %%
%%  give a huge difference.  We'll check to see that   %%
%%  the min and max aren't too far away                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Elon_sig = (max_Elon - min_Elon)./2;
hd = find(max_Elon - min_Elon > 180);
Elon_sig(hd) = ((360 - max_Elon(hd)) + min_Elon(hd))./2;

min_Elat                                                                                           = min(Elat_vec, [], 2);
max_Elat                                                                                           = max(Elat_vec, [], 2);
mean_Elat                                                                                          = mean(Elat_vec, 2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  The two estimates may cross the poles and thus    %%
%%  give a huge difference.  We'll check to see that  %%
%%  the min and max aren't too far away               %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Elat_sig = (max_Elat - min_Elat)./2;
hd = find(max_Elat - min_Elat > 90);
Elat_sig(hd) = ((90 - max_Elat(hd)) + (90 - abs(min_Elat(hd))))./2;

min_rrate                                                                                          = min(rrate_vec, [], 2);
max_rrate                                                                                          = max(rrate_vec, [], 2);
mean_rrate                                                                                         = mean(rrate_vec, 2);
rrate_sig		                                                                                    = (max_rrate - min_rrate)./2;


