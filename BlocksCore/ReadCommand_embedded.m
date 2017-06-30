function [Command] = ReadCommand_embedded(baseFileName)
% ReadCommand.m
%
% Read in commands from *.command file

% Set up input file stream
infile                  = fopen(baseFileName, 'r');

% Set default values
Command.reuseElastic                                  = 'no';
Command.reuseElasticFile                              = '';
Command.saveKernels                                   = 'no'; 
Command.poissonsRatio                                 = 0.25;
Command.unitSigmas                                    = 'no';
Command.ldTog2                                        = 0;
Command.ldTog3                                        = 0;
Command.ldTog4                                        = 0;
Command.ldTog5                                        = 0;
Command.ldOvTog                                       = 'no';
Command.ldOvValue                                     = 0;
Command.aprioriBlockName                              = '';
Command.patchFileNames                                = '';
Command.triSmooth                                     = 0.5;
Command.nIter                                         = 1;
Command.triRake                                       = [];
Command.triKinCons                                    = 0; 
Command.smoothEdge                                    = 0; 
Command.triEdge                                       = [0 0 0]; 
Command.strainMethod                                  = 0; 
Command.epatch                                        = '';     
Command.epatchbc                                      = '';   
Command.epatchtrim                                    = 0;
Command.ebcWeight                                     = 1;  

% Read in commands one line at a time
while 1

   line                                               = fgetl(infile);
   if ~isstr(line), break, end
   colon_index                                        = find(line == ':');
   command                                            = lower(line(1:colon_index - 1));
   value                                              = line(colon_index + 2 : end);

   % Parse the string and pull out the values
   switch command

      case('segment file name')
         Command.segFileName                          = value;

      case('station file name')
         Command.staFileName                          = value;

      case('block file name')
         Command.blockFileName                        = value;

      case('reuse old elastic kernel')
         Command.reuseElastic                         = value;

      case('old elastic kernel file')
         Command.reuseElasticFile                     = value;
         % Make a cell array containing all files specified
%         Command.reuseElasticFile                     = textscan(Command.reuseElasticFile, '%s');
      
      case('save current elastic kernels')
         Command.saveKernels                          = value;
    
      case('fault resolution')
         Command.faultRes                             = str2double(value);

      case('poissons ratio')
         Command.poissonsRatio                        = str2double(value);
      
      case('set all uncertainties to 1')
         Command.unitSigmas                           = value;
         
      case('station data weight')
         Command.stationDataWgt                       = str2double(value);

      case('station data weight minimum')
         Command.stationDataWgtMin                    = str2double(value);

      case('station data weight maximum')
         Command.stationDataWgtMax                    = str2double(value);

      case('station data weight steps')
         Command.stationDataWgtSteps                  = str2double(value);

      case('slip constraint weight')
         Command.slipConWgt                           = str2double(value);

      case('slip constraint weight minimum')
         Command.slipConWgtMin                        = str2double(value);

      case('slip constraint weight maximum')
         Command.slipConWgtMax                        = str2double(value);

      case('slip constraint weight steps')
         Command.slipConWgtSteps                      = str2double(value);
    
      case('block constraint weight')
         Command.blockConWgt                          = str2double(value);

      case('block constraint weight minimum')
         Command.blockConWgtMin                       = str2double(value);

      case('block constraint weight maximum')
         Command.blockConWgtMax                       = str2double(value);

      case('block constraint weight steps')
         Command.blockConWgtSteps                     = str2double(value);

      case('locking depth toggle 2')
         Command.ldTog2                               = str2double(value);
    
      case('locking depth toggle 3')
         Command.ldTog3                               = str2double(value);
    
      case('locking depth toggle 4')
         Command.ldTog4                               = str2double(value);
    
      case('locking depth toggle 5')
         Command.ldTog5                               = str2double(value);
    
      case('locking depth override toggle')
         Command.ldOvTog                              = lower(value);
      
      case('locking depth override value')
         Command.ldOvValue                            = str2double(value); 
    
      case('apriori block motions relative to')
         Command.aprioriBlockName                     = lower(value);
         
      case('triangulated patch files')
         Command.patchFileNames                       = value;

      case('patch slip distribution files')
         Command.slipFileNames                        = lower(value);
      
      case('mesh smoothing values')
         Command.triSmooth                            = str2num(value);
      
      case('surface azimuth of triangular slips')
         Command.triRake                              = str2num(value);
         
      case('enforce patch kinematic consistency')
         Command.triKinCons                           = str2num(value); 
      
      case('constrain edge element slip to equal that of adjacent segment')
         Command.smoothEdge                           = str2num(value); 
      
      case('set [updip downdip lateral] limits to zero slip')
         Command.triEdge                              = str2num(value); 

      case('strain calculation method')
         Command.strainMethod                         = str2num(value); 
         
      case('number of monte carlo iterations')
         Command.nIter                                = str2double(value); 

      case('embedded fault patch files')
         Command.epatch                               = value; 

      case('embedded fault boundary condition files')
         Command.epatchbc                             = value; 

      case('reduce dimensions of embedded fault slip (1) and stress components (2)')
         Command.epatchtrim                           = str2double(value); 
         
      case('embedded stress weight constraint')
         Command.ebcWeight                            = str2double(value); 
         



   end   
end
fclose(infile);