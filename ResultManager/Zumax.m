function zumax(hx)
% ZUMAX - graphic - create a new figure with a copy of axis hx
%  if hx is not mentionned, and interactive input allows the user to select an axis


% interactivly select an axis among the figure subplots
if exist('hx')~=1 
    ginput(1); 
    hx = gca;
end

% get the original figure title
hof = get(hx,'parent');
titre = get(hof,'name');

% get the original axis title
ht = get(hx,'title');
titrax = get(ht,'string');
if isempty(titrax), titrax = 'zoom'; end;

% the the original figure colormap
m = colormap;

% create a new figure with title including original figure & axis titles
hf = figure('name',[titre,'[',titrax,']']);
colormap(m);


% duplicate the selected axis
hn = copyobj(hx,hf);
set(hn,'units','normalized','position',[0.1 0.1 0.8 0.8],'deletefcn','','buttondownfcn','');


% remove the original axis legend marker to prevent origninal legend from beeing deleted
set(0,'showhiddenhandles','on');
hl = findobj(hn,'Tag','LegendDeleteProxy');
if ~isempty(hl), set(hl,'deletefcn',''); end
set(0,'showhiddenhandles','off');
 
