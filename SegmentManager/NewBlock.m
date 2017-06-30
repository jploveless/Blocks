function [Block, newBlockName] = NewBlock(Block)
% Draw a new segment

    ud = get(gcf,'UserData');
    Seg = ud.Seg;
    title(Seg.axHandle, 'Click on the new block''s location', 'FontSize',12);

    % Select the first point
    set(gcf, 'WindowButtonDownFcn', @(h,e)setappdata(gcf,'doneClick',true));
    setappdata(gcf, 'doneClick', false);
    while ~getappdata(gcf, 'doneClick')
        [x, y] = GetCurrentAxesPosition;
        set(Seg.pszCoords, 'string', sprintf('(%7.3f)  %7.3f  ; %7.3f', npi2pi(x), x, y));
        drawnow; pause(0.02);
    end
    set(gcf, 'WindowButtonDownFcn', '');
    title(Seg.axHandle, '');

    [lonClose, latClose] = deal(x, y);

    % Add new block to Block structure
    newBlockName = char(inputdlg('New block name:'));
    Block.name = strvcat(Block.name, newBlockName);
    Block.eulerLon = [Block.eulerLon ; 0];
    Block.eulerLat = [Block.eulerLat ; 0];
    Block.eulerLonSig = [Block.eulerLonSig ; 0];
    Block.eulerLatSig = [Block.eulerLatSig ; 0];
    Block.interiorLon = [Block.interiorLon ; lonClose];
    Block.interiorLat = [Block.interiorLat ; latClose];
    Block.rotationRate = [Block.rotationRate ; 0];
    Block.rotationRateSig = [Block.rotationRateSig ; 0];
    Block.rotationInfo = [Block.rotationInfo ; 0];
    Block.aprioriTog = [Block.aprioriTog ; 0];
    Block.other1 = [Block.other1 ; 0];
    Block.other2 = [Block.other2 ; 0];
    Block.other3 = [Block.other3 ; 0];
    Block.other4 = [Block.other4 ; 0];
    Block.other5 = [Block.other5 ; 0];
    Block.other6 = [Block.other6 ; 0];

    % Update the blocks display - done by SegmentManagerFunctions('RedrawBlocks')
    %nBlock = numel(Block.interiorLon);
    %plot(Block.interiorLon(nBlock), Block.interiorLat(nBlock), 'go', 'Tag',strcat('Block.', num2str(nBlock)), 'LineWidth',1, 'MarkerFaceColor','g');
    drawnow;
