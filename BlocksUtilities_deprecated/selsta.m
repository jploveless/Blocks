function a = selsta;
%
% 	SELSTA allows for selection of stations.
%      SELSTA allows for interactive selection of stations in 
%      SEGMENTMANAGERGUI or RESULTMANAGERGUI.
%

ac = get(gca, 'children');

% Pick the topmost child that's actually visible
vis = get(ac, 'visible');
vis = find(cellfun('prodofsize', strfind(vis, 'on')));
vis = ac(vis(1));

% Do the selection
a = selectdata('selectionmode', 'lasso', 'ignore', setdiff(ac, vis));
