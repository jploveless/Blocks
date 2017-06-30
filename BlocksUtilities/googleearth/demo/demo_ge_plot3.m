function demo_ge_plot3()

t = 0:pi/50:10*pi;
alt = 1e6;

X = sin(t);
Y = cos(t);
Z = t*alt;

output = ge_plot3(X,Y,Z,...
                    'lineWidth',1.2,...
                    'lineColor','ff32a4ff',...
                         'name','out01');


kmlFileName = 'demo_ge_plot3.kml';
ge_output(kmlFileName,output);