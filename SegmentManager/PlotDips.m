function [x_vec, y_vec] = PlotDips(fault_lon1, fault_lat1, fault_lon2, fault_lat2, fault_dip, fault_ldep, fault_bdep)

% Reorder endpoints, assuring that western point comes first
lon1 = fault_lon1;
lon2 = fault_lon2;
lat1 = fault_lat1;
lat2 = fault_lat2;
east_first = lon1 > lon2;
fault_lon1(east_first) = lon2(east_first);
fault_lat1(east_first) = lat2(east_first);
fault_lon2(east_first) = lon1(east_first);
fault_lat2(east_first) = lat1(east_first);

x_vec = zeros(numel(fault_lon1), 4);
y_vec = x_vec;

% Calculate buried coordinates
for i = 1:numel(fault_lon1)
   [strike, L, W, ofx, ofy, ofxe, ofye, ...
    tfx, tfy, tfxe, tfye] = fault_params_to_okada_form(fault_lon1(i), fault_lat1(i), ...
                                                       fault_lon2(i), fault_lat2(i), ...
                                                       deg_to_rad(fault_dip(i)), ...
                                                       fault_ldep(i)/110, fault_bdep(i)/110);
   ffstrike                      = strike;
   ffL                           = L;
   ffW                           = W;
   fflon1                        = ofx;
   fflat1                        = ofy;
   fflon2                        = ofxe;
   fflat2                        = ofye;
   tflon1                        = tfx;
   tflat1                        = tfy;
   tflon2                        = tfxe;
   tflat2                        = tfye;

   x_vec(i, :) = [fault_lon1(i), fflon1, fflon2, fault_lon2(i)];
   y_vec(i, :) = [fault_lat1(i), fflat1, fflat2, fault_lat2(i)];
   if (fault_dip(i) ~= 90)
      poly_hndl = patch(x_vec, y_vec, 1.00 * [1 0 0 ], 'Clipping', ...
                        'on', 'EdgeColor', 'k', 'tag', 'Dips', 'LineStyle', '-');
   end
end
