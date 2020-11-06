function demo_ge_quiver3_2()

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

kmlStr3 = ge_axes('axesType','xzy',...
                     'xTick',X+[-1,0,1],...
                     'yTick',Y+[-1,0,1],...
                     'zTick',Z+linspace(-1,1,3)*7.5e4,...
               'xyLineColor','FF0000FF',...
               'xzLineColor','FF00FF00',...
               'yzLineColor','FFFF0000',...
                 'lineWidth',0.5,...
              'altitudeMode','relativeToGround',...
                'axesOrigin',[X,Y,Z]);

%Organize the results into a folder structure:
f01 = ge_folder('axes',kmlStr3);
f02 = ge_folder('vary heading',kmlStr1);
f03 = ge_folder('vary tilt',kmlStr2);

%Write the 3 foldered kmlStr's to a file:
ge_output('demo_ge_quiver3_2.kml',[f01,f02,f03]);

copyfile(fullfile(googleearthroot,'data','redcone.dae'),pwd)

