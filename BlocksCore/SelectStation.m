function Station  = SelectStation(Station)
% This function returns all station variables that have station_tog >= 1.
%
% Arguments:  all station variables
%
% Returned variables: all station variables

keep_idx                           = find(Station.tog>=1);
Station.lon                        = Station.lon(keep_idx);
Station.lat                        = Station.lat(keep_idx);
Station.dep                        = Station.dep(keep_idx);

Station.eastVel                    = Station.eastVel(keep_idx);
Station.northVel                   = Station.northVel(keep_idx);
Station.upVel                      = Station.upVel(keep_idx);

Station.eastSig                    = Station.eastSig(keep_idx);
Station.northSig                   = Station.northSig(keep_idx);
Station.upSig                      = Station.upSig(keep_idx);

Station.eastAdj                    = Station.eastAdj(keep_idx);
Station.northAdj                   = Station.northAdj(keep_idx);
Station.upAdj                      = Station.upAdj(keep_idx);

Station.corr                       = Station.corr(keep_idx);
Station.other1                     = Station.other1(keep_idx);
Station.tog                        = Station.tog(keep_idx);
% Station.blockLabel                 = Station.blockLabel(keep_idx);
Station.name                       = Station.name(keep_idx, :);