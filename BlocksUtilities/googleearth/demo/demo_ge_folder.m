function demo_ge_folder()

N = 250;

X_NE = -180+rand(N,1)*180;
Y_NE = rand(N,1)*90;

X_NW = rand(N,1)*180;
Y_NW = rand(N,1)*90;

X_SE = -180+rand(N,1)*180;
Y_SE = -90+rand(N,1)*90;

X_SW = rand(N,1)*180;
Y_SW = -90+rand(N,1)*90;

kmlStr_NE='';
kmlStr_NW='';
kmlStr_SE='';
kmlStr_SW='';

for k=1:N
    S = ge_cylinder(X_NE(k),Y_NE(k),5e4,5e5,...
                                'polyColor','FF0000FF',...
                                'lineColor','FF0000FF',...
                                'divisions',3);
    kmlStr_NE = [kmlStr_NE,S];
end

for k=1:N
    S = ge_cylinder(X_NW(k),Y_NW(k),5e4,5e5,...
                                'polyColor','FF00FF00',...
                                'lineColor','FF00FF00',...
                                'divisions',3);
    kmlStr_NW = [kmlStr_NW,S];
end

for k=1:N
    S = ge_cylinder(X_SE(k),Y_SE(k),5e4,5e5,...
                                'polyColor','FFFF0000',...
                                'lineColor','FFFF0000',...
                                'divisions',3);
    kmlStr_SE = [kmlStr_SE,S];
end

for k=1:N
    S = ge_cylinder(X_SW(k),Y_SW(k),5e4,5e5,...
                                'polyColor','FFFF00FF',...
                                'lineColor','FFFF00FF',...
                                'divisions',3);
    kmlStr_SW = [kmlStr_SW,S];
end

NorthStr = [ge_folder('Eastern hemisphere',kmlStr_NE),ge_folder('Western hemisphere',kmlStr_NW)];
SouthStr = [ge_folder('Eastern hemisphere',kmlStr_SE),ge_folder('Western hemisphere',kmlStr_SW)];

kmlStr_all = [ge_folder('Northern hemisphere',NorthStr),ge_folder('Southern hemisphere',SouthStr)];


kmlFileName = 'demo_ge_folder.kml';

ge_output(kmlFileName,kmlStr_all)

