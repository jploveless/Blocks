function demo_ge_cylinder()

x1 = -10;
y1 = -10;
x2 = -10.2;
y2 = -10.2;
x3 = -9.8;
y3 = -10;

kmlStr1 = ge_cylinder(x1,y1,5000,15000);

kmlStr2 = ge_cylinder(x2,y2,5000,20000,...
                           'divisions',3,...
                                'name','Cylinder number 2, less divisions.',...
                           'lineWidth',5.0,...
                           'lineColor','FFFF0000',...
                           'polyColor','FF00FF00');
                
kmlStr3 = ge_cylinder(x3,y3,5000,25000,...
                           'divisions',5,...
                          'visibility',0);

kmlFileName = 'demo_ge_cylinder.kml';

ge_output(kmlFileName,[kmlStr1,kmlStr2,kmlStr3]);