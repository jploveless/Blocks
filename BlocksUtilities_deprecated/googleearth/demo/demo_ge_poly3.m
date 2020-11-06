function demo_ge_poly3()

x = linspace(0,20,100); %longitude
e1 = 1e6;   %elevation 1
e2 = 5e6;   %elevation 2
lat = 5;    %latitude

%Polygon coordinates:
X = [x,fliplr(x)];
Y = [ones(size(x))*lat,ones(size(x))*lat];
Z = [ones(size(x))*e1,ones(size(x))*e2];

%Initialize kml string:
kmlStr='';

for j=-180:20:180
    %Shift polygon by j degrees longitude:
    sX = X + j;
    
    kmlStr = [kmlStr,ge_poly3(sX,Y,Z,...
                      'altitudeMode','relativeToGround',...
                       'msgToScreen',true)];
end

ge_output('demo_ge_poly3.kml',kmlStr);