function [Partials, Data, Sigma, Index] = emptyTriArrays(Partials, Data, Sigma, Index)
% emptyTriPartials   Makes a series of empty matrices for cases when no triangles are used.

Partials.tri         = zeros(Index.szrot(1), 0);
Partials.stri        = zeros(Data.nSar, 0);
Partials.trislip     = zeros(0, Index.szrot(2));
Partials.triSlipCon  = [];
Partials.triBlockCon = zeros(0, Index.szrot(2));
Partials.smooth      = [];
Data.smooth          = [];
Sigma.smooth         = [];
Data.triSlipCon      = [];  
Sigma.triSlipCon     = [];
Index.triConkeep     = [];
Index.triColkeep     = [];
Index.triSmoothkeep  = [];