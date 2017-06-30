function Command = ParseOptCommands(Command, varargin)
% ParseOptCommands   Updates command structure with function arguments.
%
%    C = ParseOptCommands(C, Name, Value) updates the command structure C with 
%    fields as defined as input arguments to Blocks, replacing the corresponding
%    field read from the .command file. 
%
%    Valid field names are:
%          segFileName          
%          staFileName          
%          sarFileName          
%          blockFileName        
%          reuseElastic         
%          reuseElasticFile     
%          saveKernels          
%          faultRes             
%          poissonsRatio        
%          unitSigmas           
%          stationDataWgt       
%          stationDataWgtMin    
%          stationDataWgtMax    
%          stationDataWgtSteps  
%          sarWgt               
%          sarRamp              
%          slipConWgt           
%          slipConWgtMin        
%          slipConWgtMax        
%          slipConWgtSteps      
%          blockConWgt          
%          blockConWgtMin       
%          blockConWgtMax       
%          blockConWgtSteps     
%          ldTog2               
%          ldTog3               
%          ldTog4               
%          ldTog5               
%          ldOvTog              
%          ldOvValue            
%          aprioriBlockName     
%          mshpFileName         
%          patchFileNames       
%          triSlipConstraintType
%          slipFileNames        
%          triSmooth            
%          triSmooth            
%          pmagTriSmooth        
%          smoothType           
%          triEdge              
%          triEdge              
%          triDepthTol          
%          triConWgt            
%          strainMethod         
%          nIter                
%          inversionType        
%          inversionParam01              
%          inversionParam02              
%          inversionParam03              
%          inversionParam04              
%          inversionParam05              
%          dumpall       
%         



% Parse arguments

% Check that an even number of arguments were specified
if rem(nargin-1, 2) == 1
   error('Optional input arguments must follow the form "Name", "Value"')
end

% Parse the fields and values
fn = {varargin{1:2:end}};
va = {varargin{2:2:end}};

Fn = fieldnames(Command);
Command.changed = ''; % Keep a record of the changed fields
% Insert the fields into the command structure
for i = 1:numel(fn)
   if ~ismember(fn{i}, Fn)
      warning('Unrecognized field name specified in optional Blocks input arguments.')
   end
   Command = setfield(Command, fn{i}, va{i});
   Command.changed = strcat(Command.changed, fn{i});
end
                
