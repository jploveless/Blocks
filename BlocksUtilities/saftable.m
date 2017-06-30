function saftable(direc)
%

load([direc filesep 'faultids.mat']);
system(sprintf('touch %s%ssegtable.tex', direc, filesep))

% Segment names
names = {'car', 'wwg', 'moj', 'sbern', 'ind', 'sjels', 'imp'}
heads = {'Carrizo', 'White Wolf-Garlock', 'Mojave', 'San Bernadino', 'Indio', 'Imperial (San Jacinto-Elsinore)', 'Imperial'};

% Process segments
for i = 1:length(names)
   seg = eval(names{i});
   seg = OrderEndpoints(seg);
   sego = ordersegs(seg);
   seg = structsubset(seg, sego);
   seg2table(seg, [direc filesep 'segtable.tex'], heads{i});
end