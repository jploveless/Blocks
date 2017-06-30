clear
close all
clc

%Define the location of the Collada model origin:
X = 0;    %latitude  [degrees]
Y = 0;    %longitude [degrees]
Z = 1e5;  %elevation [m]

%Define the URL of the Collada model:
arrowStr = 'redcone.dae';

%Initialize kml strings as null character arrays:
kmlStr1 = '';
kmlStr2 = '';

%Use Google's date format:
S = 'yyyy-mm-ddTHH:MM:SSZ';

for m=[1,2]
  for a=0:359

  tStart = datestr(now+a+(m-1)*365,S);
  tEnd = datestr(now+a+1+(m-1)*365,S);

     if m==1
       %vary heading
       U = sin(deg2rad(a));
       V = cos(deg2rad(a));
       W = 0;
       kmlStr1 = [kmlStr1,ge_quiver3(X,Y,Z,U,V,W,...
                  'modelLinkStr',arrowStr,...
                    'arrowScale',1e6,...
                  'altitudeMode','relativeToGround',...
                 'timeSpanStart',tStart,...
                  'timeSpanStop',tEnd,...
                   'msgToScreen',true)];
     elseif m==2
       %vary tilt
       U = 0;
       V = cos(deg2rad(a));
       W = sin(deg2rad(a));
       kmlStr2 = [kmlStr2,ge_quiver3(X,Y,Z,U,V,W,...
                  'modelLinkStr',arrowStr,...
                    'arrowScale',1e6,...
                  'altitudeMode','relativeToGround',...
                 'timeSpanStart',tStart,...
                  'timeSpanStop',tEnd,...
                   'msgToScreen',true)];
    end
  end
end

%Add xyz-axes to the kml file to facilitate
%better interpretation:

kmlStr3 = ge_axes('axesType','xyz',...
                     'xTick',X+[0:0.25:1],...
                     'yTick',Y+[0:0.25:1],...
                     'zTick',Z+[0:2e4:1e5],...
               'xyLineColor','400000FF',...
               'xzLineColor','4000FF00',...
               'yzLineColor','40FF0000',...
                 'lineWidth',2,...
              'altitudeMode','relativeToGround');

%Organize the results into a folder structure:
f01 = ge_folder('axes',kmlStr3);
f02 = ge_folder('vary heading',kmlStr1);
f03 = ge_folder('vary tilt',kmlStr2);

%Write the 3 foldered kmlStr's to a file:
ge_output('example_quiver3.kml',[f01,f02,f03]);