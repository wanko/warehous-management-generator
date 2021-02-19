%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Warehouse Architecture %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Guess edges, make sure fill is correct and every vertex is reachable
manDist((X,Y),(X',Y'),D*S) :- X=1..MaxX, Y=1..MaxY, X'=1..MaxX, Y'=1..MaxY, D=|X-X'|+|Y-Y'|, dim(MaxX,MaxY), distance(S).
{ edge(V,V') : V<V', manDist(V,V',D), distance(R), range(T), D<=T*R }.
edge(V,V') :- edge(V',V).
:- not (MaxX*MaxY*Min)/100 { vert((X,Y)) : X=1..MaxX, Y=1..MaxY  } (MaxX*MaxY*Max)/100, fill(Min,Max), dim(MaxX,MaxY).
vert(V;V') :- edge(V,V').
1{ svert(V) : vert(V) }1.
reach(V') :- svert(V), edge(V,V').
reach(V') :- reach(V), edge(V,V').
:- vert(V), not reach(V).

% Check that edges are not crossing
:- edge((X1,Y1),(X2,Y2)), (X1,Y1)<(X2,Y2),
   1{ edge((X3,Y3),(X4,Y4)) : (X1,Y1)!=(X3,Y3), (X2,Y2)!=(X4,Y4), (X1,Y1)!=(X4,Y4), (X2,Y2)!=(X3,Y3), (X3,Y3)<(X4,Y4),
                              O1 = (Y2-Y1)*(X3-X2)-(X2-X1)*(Y3-Y2), O2 = (Y2-Y1)*(X4-X2)-(X2-X1)*(Y4-Y2), O1 != O2}.

% Calculate travel time
edge(V,V',D*S) :- edge(V,V'), robotSpeed(S), manDist(V,V',D).

% Guess storage
N { storeVert((X,Y)) : X=1..MaxX, Y=1..MaxY } N :- dim(MaxX,MaxY), storage(N).
:- storeVert(V), not vert(V).

% Guess loading
N { loadVert((X,Y)) : X=1..MaxX, Y=1..MaxY } N :- dim(MaxX,MaxY), storage(N).
:- loadVert(V), not vert(V).

% Make sure loading and storage vertices have the correct distance
:- #sum{ 1,V,V' : storeVert(V), loadVert(V'), manDist(V,V',D'), D'<D } >= 1, distLoadStore(D).

% Specify and forbid conflicting occupation
conflict(V) :- loadVert(V), storeVert(V).
:- conflict(V), vert(V).

% Calculate vertex conflicts
conflict(v,V,V') :- vert(V), vert(V'), manDist(V,V',D), robotSize(S), D<=S. 
% Calculate edge conflicts
conflict(e,(V1,V2),(V3,V4)) :- edge(V1,V2), edge(V3,V4), conflict(v,V1,V3), conflict(v,V2,V4). 

#show edge/3.
#show conflict/3.

%%%%%%%%%%%%
%% Robots %%
%%%%%%%%%%%%

robot(R) :- robots(N), R=1..N.
1 { home(R,(X,Y)) : X=1..MaxX, Y=1..MaxY } 1 :- robot(R), dim(MaxX,MaxY).
:- home(R,V), not vert(V).
conflict(V) :- home(_,V), 1 { loadVert(V); storeVert(V) }.
conflict(V) :- 2 { home(R,V) }, vert(V).
start(R,V) :- home(R,V), not replan.
1 { start(R,(X,Y)) : X=1..MaxX, Y=1..MaxY } 1 :- robot(R), dim(MaxX,MaxY).
conflict(V) :- 2 { start(R,V) }, vert(V).

#show robot/1.
#show home/2.
#show start/2.


%%%%%%%%%%%
%% Tasks %%
%%%%%%%%%%%

depends(deliver,(ID,pickup),(ID,putdown)) :- tasks(deliver,N), ID=1..N.
1 { task((ID,pickup),V)  : vert(V) } 1 :- tasks(deliver,N), ID=1..N.
1 { task((ID,putdown),V) : vert(V) } 1 :- tasks(deliver,N), ID=1..N.
N { depends(wait,T,T') : task(T,_), task(T',_), not depends(deliver,T,T') } N :- tasks(wait,N).
depends(T,T')  :- depends(D,T,T').
depends(T,T'') :- depends(T,T'), depends(T',T'').
:- depends(T,T).

#show depends/3.
#show task/2.