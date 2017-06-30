function allblockscline2gmt(h, outbase, cpt)

h = h(find(h));
for i = 1:length(h)
   outname = [outbase num2str(i)];
   smoothblockcline2gmt(h(i), outname, cpt);
end