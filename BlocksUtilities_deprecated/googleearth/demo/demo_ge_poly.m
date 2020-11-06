function demo_ge_poly()%% Demo ge_poly 

load(fullfile(googleearthroot,'data','conus.mat'));

world_coasts = ge_poly(uslon,uslat,...
                       'polyColor','9933ffff',...
                        'altitude',150000,...
                    'altitudeMode','relativeToGround',...
                         'extrude',1,...
                      'tessellate',true);
                  
kmlFileName = 'demo_ge_poly.kml';
ge_output(kmlFileName,world_coasts);




