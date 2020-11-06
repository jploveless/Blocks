function demo_ge_text()


kmlStr='';
for k=1:10
    kmlStr = [kmlStr,ge_text(2,k,400000,num2str(k),...
        'altitudeMode','relativeToGround','description',...
        'Use HTML to add description here. <BR><HR><BR>')];
end


ge_output('demo_ge_text.kml',kmlStr)