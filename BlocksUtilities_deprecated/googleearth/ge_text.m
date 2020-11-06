function kmlStr = ge_text(X,Y,Z,S,varargin)


AuthorizedOptions = authoptions(mfilename);


iconScale = 0;
iconURL = 'none';


kmlStr = ge_point(X,Y,Z,varargin{:},...
    'iconScale',iconScale,'iconURL',iconURL,'name',S);