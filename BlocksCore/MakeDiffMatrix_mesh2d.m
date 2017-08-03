%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%    Eileen Evans    9/11/2016 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% 
%   Describe purpose of script/function here. 
%                ( 9/11/2016 , 15:10:15 pm ) 
% 
%   INPUT 
%       1. Input one here 
%       2. Input two here 
% 
%   OUTPUT 
%       1. Output one here 
% 
%   Outline 
%       1.  
%       2.  
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function D = MakeDiffMatrix_mesh2d(Patches) 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Build adjacency Matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

share                       = SideShare(Patches.v); % For each element, give indices of N <= 3 elements that share sides
A                           = zeros(Patches.nEl,Patches.nEl);
for ii = 1:Patches.nEl;
    for jj = 1:3;
        thisone             = share(ii,jj);
        if thisone > 0
            A(ii,thisone)   = 1;
        end
    end
end

A = triu(A);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Make Single constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

D0 = zeros(0,Patches.nEl);

for patch = 1:Patches.nEl;
    s = sum(A(patch,:));
    D0_update = zeros(s,Patches.nEl);
    D0_update(1:s,patch) = 1;
    six = find(A(patch,:));
    for adj = 1:s;
        D0_update(adj,six(adj)) = -1;
    end
    D0 = [D0; D0_update];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%  Second component of slip
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

D = zeros(2*numel(D0(:,1)),2*numel(D0(1,:)));
for row = 1:numel(D0(:,1));
    for col = 1:numel(D0(1,:));
        
        if D0(row,col) == 1;
            D(row*2-1:row*2,col*2-1:col*2) = eye(2);
        elseif D0(row,col) == -1;
            D(row*2-1:row*2,col*2-1:col*2) = -eye(2);
        end
    end
end

end