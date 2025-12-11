%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    2/12/2014 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   Make constraint matrix D (Evans et al., 2015; equation 4). 
%                ( 2/12/2014 , 21:35:41 pm ) 
% 
%   INPUT 
%       1. Block    - Block structure from Blocks. Field other3 is used here 
%                       to identify blocks that should be left out of the 
%                       constraint matrix (e.g. Pacific relative to North
%                       American Plates)
%       2. Segment  - Segment structure from Blocks
%
% 
%   OUTPUT 
%       1. DD - Constraint matrix  
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function [DD] =MakeDiffMatrixGen(Block,Segment) 
% keyboard
%%% Build adjacency Matrix
AdjMat = zeros(numel(Block.interiorLon));
for bb = 1:numel(Block.interiorLon);
    eastix = (Segment.westLabel==bb);
    East = unique(Segment.eastLabel(eastix));
    westix = (Segment.eastLabel==bb);
    West = unique(Segment.westLabel(westix));
    AdjMat(bb,[East; West]) = 1;
end
% A = sparse(AdjMat);

% keyboard

%%% Remove adjacency between excluded blocks
% keyboard
exclud = Block.other3 == 1;
AdjMat(exclud,exclud) = 0;

% [mlon ix] = min(Block.interiorLon);
% rest = ix;
% [mlon ix] = max(Block.interiorLon);
% stableNA = ix;
% ix = find(Block.interiorLon==240.132);
% Pacific = ix;
% 
% AdjMat(rest,stableNA) = 0;
% AdjMat(stableNA,rest) = 0;
% AdjMat(rest,Pacific) = 0;
% AdjMat(Pacific,rest) = 0;
% AdjMat(rest,Pacific) = 0;
% AdjMat(Pacific,stableNA) = 0;
% AdjMat(stableNA,Pacific) = 0;
% 
% AdjMat(rest,:) = 0;
% AdjMat(:,rest) = 0;
% keyboard

AdjMat = triu(AdjMat);
% keyboard

%%% first make single constraints
nblocks = numel(AdjMat(1,:));
D = zeros(0,nblocks);

for block = 1:nblocks;  
    s = sum(AdjMat(block,:)); % find the number of blocks surrounding the block we are interested in
    D_update = zeros(s,nblocks); % add the appropriate number of new rows
    D_update(1:s,block) = 1;
    six = find(AdjMat(block,:));
    for adj = 1:s;
        D_update(adj,six(adj)) = -1;
       
    end
%     keyboard
    D = [D; D_update];
end
% figure; imagesc(D); colormap(bluewhitered);

DD = zeros(3*numel(D(:,1)),3*numel(D(1,:)));
for row = 1:numel(D(:,1));
    for col = 1:numel(D(1,:));
        
        if D(row,col) == 1;
            DD(row*3-2:row*3,col*3-2:col*3) = eye(3);
        elseif D(row,col) == -1;
            DD(row*3-2:row*3,col*3-2:col*3) = -eye(3);
        end
    end
end
% figure; imagesc(DD); colormap(bluewhitered);
