function [vn ve vu] = CartVecToSphVec(vx, vy, vz, lon, lat)
% This function transforms vectors from Cartesian to spherical components.
%
% Arguments:
%   vx:    vector of x components of velocity
%   vy:    vector of y components of velocity
%   vz:    vector of z components of velocity
%   lon:   vector of station longitudes
%   lat:   vector of station latitudes
%
% Returned variables:
%   vn:    vector of north components of velocity
%   ve:    vector of east components of velocity
%   vu:    vector of up components of velocity

[lat lon]       = deal(DegToRad(lat), DegToRad(lon));
[vn ve vu]      = deal(zeros(size(vx)), zeros(size(vx)), zeros(size(vx)));

for v_cnt = 1 : numel(vx)
%    G            = zeros(3);
   G            = [ -sin(lat(v_cnt))*cos(lon(v_cnt)) , -sin(lat(v_cnt))*sin(lon(v_cnt)) , cos(lat(v_cnt)) ; ...
                    -sin(lon(v_cnt)) , cos(lon(v_cnt)) , 0 ; ...
                    -cos(lat(v_cnt))*cos(lon(v_cnt)) , -cos(lat(v_cnt))*sin(lon(v_cnt)) , -sin(lat(v_cnt)) ];
   v_s          = G*[vx(v_cnt) ; vy(v_cnt) ; vz(v_cnt)];
   vn(v_cnt)    = v_s(1);
   ve(v_cnt)    = v_s(2);
   vu(v_cnt)    = v_s(3);
%    G            = [ sin(lat(v_cnt))*cos(lon(v_cnt)) , sin(lat(v_cnt))*sin(lon(v_cnt)) , cos(lat(v_cnt)) ; ...
%                     cos(lat(v_cnt))*cos(lon(v_cnt)) , cos(lat(v_cnt))*sin(lon(v_cnt)) , -sin(lat(v_cnt)) ; ...
%                     -sin(lon(v_cnt)) , cos(lon(v_cnt)) , 0 ];
%    v_s          = G*[vx(v_cnt) ; vy(v_cnt) ; vz(v_cnt)];
%    vu(v_cnt)    = v_s(1);
%    vn(v_cnt)    = v_s(2);
%    ve(v_cnt)    = v_s(3);
end
