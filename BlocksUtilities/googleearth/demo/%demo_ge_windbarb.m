function demo_ge_windbarb()
               
kmlFName = 'demo_ge_windbarb.kml';
daeDirStr = ['data',filesep,'barbdaes',filesep];
kmzTargetDir = pwd;

res = 0.6;


[X,Y] = meshgrid(-2:res:2);
Z = 150*(X.*exp(-X.^2 - Y.^2));
[U,V] = gradient(Z,res,res);
 
kmlStr = ge_windbarb(X,Y,1e2+Z,U,V,...
                      'arrowScale',2.5e4,...
                      'rLink',daeDirStr);
 
disp('done')                  
ge_kml(kmlFName,kmlStr)
                        
ge_kmz('demo_ge_windbarb.kmz',...
                  'kmzTargetDir',kmzTargetDir,...
                  'resourceURLs',{kmlFName,daeDirStr})
