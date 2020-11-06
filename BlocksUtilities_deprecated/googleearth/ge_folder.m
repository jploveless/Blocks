function foutput = ge_folder(foldername,output,varargin)
% Reference page in help browser: 
% 
% <a href="matlab:web(fullfile(ge_root,'html','ge_folder.html'),'-helpbrowser')">link</a> to html documentation
% <a href="matlab:web(fullfile(ge_root,'html','license.html'),'-helpbrowser')">show license statement</a> 
%

AuthorizedOptions = authoptions( mfilename );

    snippet = ' ';
description = '';
 visibility = 1;

parsepairs %script that parses Parameter/value pairs.

if snippet==' '
	snippet_chars = '';
else
 	snippet_chars = [ '<Snippet>' snippet '</Snippet>',10 ];    
end
description_chars = [ '<description>',10,'<![CDATA[' description ']]>',10,'</description>',10 ];
visibility_chars = [ '<visibility>',10,int2str(visibility),10,'</visibility>',10];

header = [ '<Folder id="' foldername '">',...
		   '<name>',foldername,'</name>',...
		   visibility_chars,10,...
		   snippet_chars,10,...
		   description_chars,10 ];
footer = '</Folder>';

foutput = [header output footer];

