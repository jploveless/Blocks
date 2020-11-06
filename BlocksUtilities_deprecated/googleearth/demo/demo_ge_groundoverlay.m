function demo_ge_groundoverlay()

N = 66;
E = 38;
S = 2;
W = -23;

url = ['data',filesep,'map.bmp'];

kmlStr = ge_groundoverlay(N,E,S,W,...
                         'imgURL',url,...
                 'viewBoundScale',1e3,...
                      'polyAlpha','7C');

             
source = fullfile(googleearthroot,'data','map.bmp');
destination = fullfile(pwd,'data','map.bmp');
     

mkdir('data')
copyfile(source,destination);
ge_output('demo_ge_groundoverlay.kml',kmlStr)
           
