function Index = staRowKeep(Data, Index)
% staRowKeep   Determines which station rows should be retained

if sum(abs(Data.upVel)) == 0
   Index.staRowkeep                              = setdiff(1:Index.szrot(1), [3:3:Index.szrot(1)]);
else
   Index.staRowkeep                              = 1:Index.szrot(1);
end