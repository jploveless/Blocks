function Index = triColKeep(Patches, Index)
% triColKeep   Determines which columns of the triangular slip matrices should be kept.
Index.triS                                    = (1:length(Patches.tz))';
Index.triD                                    = find(Patches.tz(:) == 2);
Index.triT                                    = find(Patches.tz(:) == 3);
Index.triColkeep                              = setdiff(1:3*sum(Patches.nEl), [3*Index.triD-0; 3*Index.triT-1]);