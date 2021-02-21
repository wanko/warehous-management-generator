% calculate manhattan distance
manDist((X,Y),(X',Y'),D*S) :- X=1..MaxX, Y=1..MaxY, X'=1..MaxX, Y'=1..MaxY, D=|X-X'|+|Y-Y'|, dim(MaxX,MaxY), distance(S).

% calculate max and min of coordinates

max(X,X',X) :- X=1..MaxX, X'=1..MaxX, X>=X', dim(MaxX,_).
max(Y,Y',Y) :- Y=1..MaxY, Y'=1..MaxY, Y>=Y', dim(_,MaxY).
min(X,X',X) :- X=1..MaxX, X'=1..MaxX, X<=X', dim(MaxX,_).
min(Y,Y',Y) :- Y=1..MaxY, Y'=1..MaxY, Y<=Y', dim(_,MaxY).
max(N',N,R) :- max(N,N',R).
min(N',N,R) :- min(N,N',R).