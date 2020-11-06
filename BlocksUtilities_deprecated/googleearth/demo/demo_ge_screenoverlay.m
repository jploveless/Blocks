function demo_ge_screenoverlay()

folderName = fullfile(pwd,'png');

promptStr = ['Do you want to create a directory ',char(39),'png',char(39),...
    ' in the current directory? Y/N [Y]: '];
reply = input(promptStr, 's');
if isempty(reply)
    reply = 'Y';
end

if strcmpi(reply,'Y')
    mkdir(folderName)
else
    disp('User abort.')
    return
end

nFrames = 20;
sizeLeft = 0;
sizeBottom = 0;
sizeWidth = 0.35;
sizeHeight = 0.3;

tIndex = datenum(now);

kmlStr = '';


figure('InvertHardCopy','off','color',0.8*[1,1,1])
hAx = subplot(1,1,1);
set(hAx,'lineWidth',2,'fontsize',16)
box on
for iFrame = 2:nFrames

    x = -pi:.1:pi;
    y = sin(x-(iFrame/nFrames));

    plot(x,y,'linewidth',2)
    set(gca,'XLim',[-4,4],'YLim',[-1,1])
    %hold on;
    stampFileName = [folderName,filesep,'sine_t=',num2str(iFrame,'%02d'),'.png'];
    
    write_image(stampFileName,[],0.9);

    tStart = datestr(tIndex+iFrame-1,'yyyy-mm-ddTHH:MM:SSZ');
    tStop  = datestr(tIndex+iFrame,'yyyy-mm-ddTHH:MM:SSZ');

    kmlStr = [kmlStr,ge_plot(x,y,'timeSpanStart',tStart,...
                                 'timeSpanStop',tStop)];


    kmlStr = [kmlStr,ge_screenoverlay(stampFileName,...
                                  'sizeLeft',sizeLeft,...
                                  'sizeLeftUnits','fraction',...
                                  'sizeBottom',sizeBottom,...
                                  'sizeBottomUnits','fraction',...
                                  'sizeWidth',sizeWidth,...
                                  'sizeWidthUnits','fraction',...
                                  'sizeHeight',sizeHeight,...
                                  'sizeHeightUnits','fraction',...
                                  'timeSpanStart',tStart,...
                                  'timeSpanStop',tStop)];

end

kmlStr = ge_folder('graph tests', kmlStr);
ge_output('demo_ge_screenoverlay.kml',kmlStr);


function write_image(filename,transpColor,alphaValue)
F = getframe(gcf);

% [X,Map] = frame2im(F);
if isempty(transpColor)
    IO = zeros(size(F.cdata(:,:,1)));
else
    IO = F.cdata(:,:,1)==transpColor(1)&...
         F.cdata(:,:,2)==transpColor(2)&...
         F.cdata(:,:,1)==transpColor(3);
end

xAlpha = double(~IO*alphaValue);
imwrite(F.cdata,filename,'png','Alpha',xAlpha);
