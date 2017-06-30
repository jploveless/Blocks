function [strike, L, W, ofx, ofy, ofxe, ofye, tfx, tfy, tfxe, tfye] = fault_params_to_okada_form(sx1, sy1, sx2, sy2, dip, D, bd)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                 %%
%%  fault_params_to_okada_form.m                   %%
%%                                                 %%
%%  MATLAB script                                  %%
%%                                                 %%
%%  This function takes fault trace, dip, and      %%
%%  locking depth information and calculates the   %%
%%  anchor coordinates, length, width and strike   %%
%%  of the fault plane as per Okada (1985).        %%
%%                                                 %%
%%  It may be beneficial in the future to compute  %%
%%  the midpoint base anchor as well for using     %%
%%  Okada (1992) Stanford binary.                  %%
%%                                                 %%
%%  We should also allow for buried faults in the  %%
%%  future.  This can be achieved by passing a     %%
%%  locking depth and a burial depth.  The only    %%
%%  output changed would be the width of the       %%
%%  fault plane.                                   %%
%%                                                 %%
%%  We may need to be more formal about say        %%
%%  endpoint1 < endpoint2 ... maybe                %%
%%                                                 %%
%%  Arguments:                                     %%
%%    sx1:  x coord of fault trace endpoint1       %%
%%    sy1:  y coord of fault trace endpoint1       %%
%%    sx2:  x coord of fault trace endpoint2       %%
%%    sy2:  y coord of fault trace endpoint2       %%
%%    dip:  dip of fault plane [radians]           %%
%%    D  :  fault locking depth                    %%
%%    bd :  burial depth (top "locking depth")     %%
%%                                                 %%
%%  Returned variables:                            %%
%%    strike:  stike of fault plane                %%
%%    L     :  fault length                        %%
%%    W     :  fault width                         %%
%%    ofx   :  x coord of fault anchor             %%
%%    ofy   :  y coord of fault anchor             %%
%%    ofxe  :  x coord of other buried corner      %%
%%    ofye  :  y coord of other buried corner      %%
%%    tfx   :  x coord of fault anchor             %%
%%             (top relative)                      %%
%%    tfy   :  y coord of fault anchor             %%
%%             (top relative)                      %%
%%    tfxe  :  x coord of other buried corner      %%
%%             (top relative)                      %%
%%    tfye  :  y coord of other buried corner      %%
%%             (top relative)                      %%
%%                                                 %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Calculate need parameters for Okada input  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
strike                        = atan2(sy1 - sy2, sx1 - sx2) + pi;
L                             = sqrt((sx2 - sx1).^2+(sy2 - sy1).^2);
W                             = (D - bd)./sin(dip);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  For older versions without a burial depth option  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  W                             = D / sin(dip);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Calculate fault segment anchor and other buried point  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ofx                           = sx1 + D./ tan(dip).* sin(strike);
ofy                           = sy1 - D./ tan(dip).* cos(strike);
ofxe                          = sx2 + D./ tan(dip).* sin(strike);
ofye                          = sy2 - D./ tan(dip).* cos(strike);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Calculate fault segment anchor and other buried point (top relative)  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tfx                           = sx1 + bd./ tan(dip).* sin(strike);
tfy                           = sy1 - bd./ tan(dip).* cos(strike);
tfxe                          = sx2 + bd./ tan(dip).* sin(strike);
tfye                          = sy2 - bd./ tan(dip).* cos(strike);
