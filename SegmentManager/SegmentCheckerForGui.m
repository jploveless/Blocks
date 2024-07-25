function SegmentCheckerForGui(S)

    disp('Checking for vertical/horizontal segments...');
    [S.lon1, S.lat1, S.lon2, S.lat2] = order_lon_lat_pairs(S.lon1, S.lat1, S.lon2, S.lat2);
    %h = flipud(h); %#ok<NASGU>  unused

    % delete previous legend objects
    %delete(
    leg = zeros(6, 1);
    leglab = {'Vertical segment', 'Horizontal segment', 'Same coords. (reg.)', 'Same coords. (rev.)', 'Intersection', 'Hanging point'};

    % Check the lengths and azimuths of segments
    rvec = zeros(numel(S.lat1), 1);
    avec = rvec;
    for i = 1:numel(S.lon1)
        rng = gcdist(S.lat1(i), S.lon1(i), S.lat2(i), S.lon2(i));
        az = sphereazimuth(S.lon1(i), S.lat1(i), S.lon2(i), S.lat2(i));
        avec(i) = az;
        rvec(i) = 1e-3*rng;

        if (avec(i) == 180)
            sprintf('%d is horizontal, ', i, avec(i));
        end
        if (rvec(i) == 0)
            sprintf('%d has %f length, ', i, rvec(i));
        end
    end
    %keyboard

    % Show vertical segments
    tolerance = 0.1; %degs
    hvec1 = abs(avec)<tolerance | abs(avec-360)<tolerance | abs(avec-180)<tolerance; %(avec == 0) | (avec == 180);
    %set(h(hvec), 'color','r', 'linewidth',6);
    plot([S.lon1(hvec1);S.lon2(hvec1)], [S.lat1(hvec1);S.lat2(hvec1)], 'color','r', 'linewidth',2, 'tag','CheckedSegment');
    if any(hvec1)
        leg(1) = line(0, 0, 'color','r', 'visible','off');
        drawnow;
    end

    % Show horizontal segments
    hvec2 = abs(avec-90)<tolerance | abs(avec-270)<tolerance; %(avec == 90) | (avec == 270);
    %set(h(hvec2), 'color','r', 'linewidth',6);
    plot([S.lon1(hvec2);S.lon2(hvec2)], [S.lat1(hvec2);S.lat2(hvec2)], 'color','b', 'linewidth',2, 'tag','CheckedSegment');

    %hv = findobj(gca, 'color','r', 'marker','none');
    %if ~isempty(hv)
    if any(hvec2); % (hvec1|hvec2)
        leg(2) = line(0, 0, 'color','b', 'visible','off');
        drawnow;
    end

    % Check for duplicates with same ordering
    disp('Checking for duplicate segments (same ordering)...');
    anyFound = false;
    for i = 1:numel(S.lon1)-1
        j = i+1:numel(S.lon1);
        lonMatch1 = repmat(S.lon1(i), numel(j), 1) - S.lon1(j)';
        lonMatch2 = repmat(S.lon2(i), numel(j), 1) - S.lon2(j)';
        latMatch1 = repmat(S.lat1(i), numel(j), 1) - S.lat1(j)';
        latMatch2 = repmat(S.lat2(i), numel(j), 1) - S.lat2(j)';

        lom = j((lonMatch1==0)&(lonMatch2==0)); %=j(intersect(find(lonMatch1 == 0), find(lonMatch2 == 0)));
        lam = j((latMatch1==0)&(latMatch2==0)); %=j(intersect(find(latMatch1 == 0), find(latMatch2 == 0)));

        %dup = intersect(lom, lam);
        if ~isempty(lom)
            %disp('same coords - longitude - same ordering')
            %set(h(i),   'marker', '>', 'color', [0.5 0 0.5]);
            %set(h(lom), 'marker', '>', 'color', [0.5 0 0.5]);
            plot([S.lon1([i,lom]);S.lon2([i,lom])], [S.lat1([i,lom]);S.lat2([i,lom])], 'marker','>', 'color',[0.5 0 0.5], 'linewidth',2, 'tag','CheckedSegment');
            anyFound = true;
        end

        if ~isempty(lam)
            %disp('same coords - latitude - same ordering')
            %set(h(i),   'marker', '^', 'color', [0.5 0 0.5]);
            %set(h(lam), 'marker', '^', 'color', [0.5 0 0.5]);
            plot([S.lon1([i,lam]);S.lon2([i,lam])], [S.lat1([i,lam]);S.lat2([i,lam])], 'marker','>', 'color',[0.5 0 0.5], 'linewidth',2, 'tag','CheckedSegment');
            anyFound = true;
        end
    end

    %sor = setdiff(findobj('color', [0.5 0 0.5]), leg);
    %if ~isempty(sor)
    if anyFound
        leg(3) = line(0, 0, 'color',[0.5 0 0.5], 'visible','off');
        drawnow;
    end

    % Check for duplicates with opposite ordering
    disp('Checking for duplicate segments (reverse ordering)...');
    anyFound = false;
    for i = 1:numel(S.lon1)-1
        j = i+1:numel(S.lon1);
        lonMatch1 = repmat(S.lon1(i), numel(j), 1) - S.lon2(j)';
        lonMatch2 = repmat(S.lon2(i), numel(j), 1) - S.lon1(j)';
        latMatch1 = repmat(S.lat1(i), numel(j), 1) - S.lat2(j)';
        latMatch2 = repmat(S.lat2(i), numel(j), 1) - S.lat1(j)';

        %lom = j(intersect(find(lonMatch1 == 0), find(lonMatch2 == 0)));
        lom = j((lonMatch1==0) & (lonMatch2==0));
        if ~isempty(lom)
            %disp('same coords - longitude - opposite ordering')
            %set(h(i),   'marker', '<', 'color', 'c');
            %set(h(lom), 'marker', '<', 'color', 'c');
            plot([S.lon1([i,lom]);S.lon2([i,lom])], [S.lat1([i,lom]);S.lat2([i,lom])], 'marker','v', 'color','c', 'linewidth',2, 'tag','CheckedSegment');
            anyFound = true;
        end

        %lam = j(intersect(find(latMatch1 == 0), find(latMatch2 == 0)));
        lam = j((latMatch1 == 0) & (latMatch2 == 0));
        if ~isempty(lam)
            %disp('same coords - latitude - opposite ordering')
            %set(h(i),   'marker', 'v', 'color', 'c');
            %set(h(lam), 'marker', 'v', 'color', 'c');
            plot([S.lon1([i,lam]);S.lon2([i,lam])], [S.lat1([i,lam]);S.lat2([i,lam])], 'marker','v', 'color','c', 'linewidth',2, 'tag','CheckedSegment');
            anyFound = true;
        end
    end

    %ror = setdiff(findobj('color', 'c'), leg);
    %if ~isempty(ror)
    if anyFound
        leg(4) = line(0, 0, 'color','c', 'visible','off');
        drawnow;
    end

    %% Check for overlaps that are not intersections
    disp('Checking for overlapped segments...');
    anyFound = false;
    for i = 1:numel(S.lon1)-1
        j = i+1:numel(S.lon1);
        p1 = repmat([S.lon1(i) S.lat1(i)], numel(j), 1);
        p2 = repmat([S.lon2(i) S.lat2(i)], numel(j), 1);
        p3 = [S.lon1(j)' S.lat1(j)'];
        p4 = [S.lon2(j)' S.lat2(j)'];
        [xi,yi] = pbisect(p1, p2, p3, p4);

        ci = [xi, yi]; % intesection coordinate array
        realc = find(sum(isnan(ci), 2) == 0);
        [isect, reali] = setdiff(ci(realc, :), [p1(1, :); p2(1, :)], 'rows'); %#ok<ASGLU>
        if ~isempty(reali) % if there's a real intersection...
            j = j(realc(reali)); % identify its index
            %set(h(i), 'marker', 'x', 'color', 'm');
            %set(h(j), 'marker', 'x', 'color', 'm');
            plot([S.lon1([i(:);j(:)]);S.lon2([i(:);j(:)])], [S.lat1([i(:);j(:)]);S.lat2([i(:);j(:)])], 'marker','x', 'color','m', 'linewidth',2, 'tag','CheckedSegment');
            anyFound = true;
        end
    end

    %ise = setdiff(findobj('color', 'm'), leg);
    %if ~isempty(ise)
    if anyFound
        leg(5) = line(0, 0, 'color','m', 'visible','off');
        drawnow;
    end

    % Find unique points
    disp('Checking for hanging points...');
    lonVec = [S.lon1'; S.lon2'];
    latVec = [S.lat1'; S.lat2'];
    [uCoord1, uIdx1] = unique([lonVec latVec], 'rows', 'first');
    [uCoord2, uIdx2] = unique([lonVec latVec], 'rows', 'last'); %#ok<ASGLU>
    nOccur = uIdx2-uIdx1 + 1;
    hang = plot(uCoord1(nOccur==1,1), uCoord1(nOccur==1,2), 'or', 'tag','hang', 'markersize',10);
    if ~isempty(hang)
        leg(6) = line(0, 0, 'marker','o', 'markersize',10, 'color','r', 'linestyle','none', 'visible','off');
        drawnow;
    end

    % Display legend
    legIdx = leg~=0;
    if any(legIdx)
        legs = legend(leg(legIdx), leglab(legIdx), 'location','southeast');
        setappdata(gcf, 'checklegend', legs);
        drawnow;
        delete(leg(legIdx));
    else
        msgbox('All segments are okay.')
    end

function [xi,yi] = pbisect(p1,p2,p3,p4)
% [XI,YI] = PBISECT(P1,P2,P3,P4) gives (XI,YI) coordinates of the intersection
% between line segments described by the (X,Y) pairs contained in P1, P2, P3,
% and P4.  P1-P4 should be of the form [x y], of size n-by-2.  The function 
% returns NaN values for xi and yi if the two segments do not intersect.  The
% outputs XI and YI are each n-by-1.
%
% The solution is as described by Paul Bourke.

ua = ((p4(:, 1)-p3(:, 1)).*(p1(:, 2)-p3(:, 2)) - (p4(:, 2)-p3(:, 2)).*(p1(:, 1)-p3(:, 1)))./ ...
     ((p4(:, 2)-p3(:, 2)).*(p2(:, 1)-p1(:, 1)) - (p4(:, 1)-p3(:, 1)).*(p2(:, 2)-p1(:, 2)));
ub = ((p2(:, 1)-p1(:, 1)).*(p1(:, 2)-p3(:, 2)) - (p2(:, 2)-p1(:, 2)).*(p1(:, 1)-p3(:, 1)))./ ...
     ((p4(:, 2)-p3(:, 2)).*(p2(:, 1)-p1(:, 1)) - (p4(:, 1)-p3(:, 1)).*(p2(:, 2)-p1(:, 2)));

xi = nan(size(p1, 1), 1); % assign NaNs by default
yi = xi;
is = (ub >= 0 & ub <= 1 & ua >=0 & ua <= 1); % check for intersections
if any(is) % if there are any intersections, calculate them here.
    xi(is) = p3(is, 1) + ub(is).*(p4(is, 1)-p3(is, 1));
    yi(is) = p3(is, 2) + ub(is).*(p4(is, 2)-p3(is, 2));
end

% check to see whether or not the calculated intersection is actually an endpoint 
% (but potentially different by machine precision)
d1 = (sum(p1 - p3, 2) == 0);
d2 = (sum(p1 - p4, 2) == 0);
endpoints = d1 | d2;
if any(endpoints)
    xi(endpoints) = p1(endpoints, 1);
    yi(endpoints) = p1(endpoints, 2);
end
d1 = (sum(p2 - p3, 2) == 0); 
d2 = (sum(p2 - p4, 2) == 0);
endpoints = d1 | d2;
if any(endpoints)
    xi(endpoints) = p2(endpoints, 1);
    yi(endpoints) = p2(endpoints, 2);
end
