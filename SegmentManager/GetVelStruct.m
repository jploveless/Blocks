function [Station] = GetVelStruct(varargin)
%%  GetVelStruct.m
%%
%%  This function reads in and returns the station information in fileName.
%%
%%  Arguments:
%%    fileName     :  file name (required)
%%    showText     :  1 to print info (optional) default is 0 (no print)
%%
%%  Returned variables:
%%    Station       :  a struct with everything 

%%  Process varargin
if (nargin == 0)
   fprintf(1, 'No arguments found!  Exiting.  Please supply a file name.');
   return;
end

fileName                                                             = deblank(varargin{1});
showText                                                             = 0;
if (nargin > 1)
   showText                                                          = varargin{2};
end


%%  Figure out if we are looking for a .vel or .sta.data file
if ( strcmp(fileName(end-3 : end), '.vel') )
   Station                                                           = ReadVelStruct(fileName, showText);
elseif ( strcmp(fileName(end - 8 : end), '.sta.data') )
   Station                                                           = ReadStadataStruct(fileName, showText);   
else
   fprintf(1, 'Unrecognized file format!');
   return;
end
