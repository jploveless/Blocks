function demo_ge_grid()
% % Demo ge_grid
% % Example usage of the ge_grid function.
% % 'help ge_grid' for more info.

x_max = -60;
x_min = -90;
y_max = 0;
y_min = -15;

output = ge_grid(x_min,x_max,y_min,y_max,...
                                'latRes',0.5,...
                                'lonRes',0.5,...
                                  'name','grid example');

            
kmlFileName = 'demo_ge_grid.kml';
ge_output(kmlFileName,output,'name',kmlFileName);