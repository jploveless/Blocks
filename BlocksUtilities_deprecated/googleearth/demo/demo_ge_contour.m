function demo_ge_contour()

[X,Y] = meshgrid(1:20,1:20);

cLimLow = -5;
cLimHigh = 5;
numLevels = 15;
lineValues = linspace(cLimLow,cLimHigh,numLevels+2);

Z = peaks(20);

kmlStr = ge_contour(X,flipud(Y),flipud(Z),...
               'colorMap','jet',...
             'lineValues',lineValues,...
                'cLimLow',cLimLow,...
               'cLimHigh',cLimHigh,...
              'lineWidth',3);
                    
ge_output('demo_ge_contour.kml',kmlStr);