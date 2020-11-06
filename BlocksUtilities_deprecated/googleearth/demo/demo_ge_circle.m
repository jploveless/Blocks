function demo_ge_circle


X = 4;
R = 5e5;

kmlStr = '';

for Y = 10:10:70
   
   latStr = ['Latitude = ',num2str(Y)];
   
   kmlStr = [kmlStr,ge_circle(X,Y,R,...
                         'divisions',5,...
                             'name',latStr,... 
                        'lineWidth',5.0,...
                        'lineColor','b8ff0b20',...
                        'polyColor','00000000')];
end


kmlFileName = 'demo_ge_circle.kml';

ge_output(kmlFileName,kmlStr,'name',kmlFileName)