%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Warehouse Architecture %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Guess edges, make sure fill is correct and every vertex is reachable
{ edge(V,V') : V<V', eucDist(V,V',D), distance(R), range(T), D<=T*R }.
edge(V,V') :- edge(V',V).
vert(V;V') :- edge(V,V').
:- fill(Min,Max), dim(MaxX,MaxY), not (MaxX*MaxY*Min)/100 { vert((X,Y)) : X=1..MaxX, Y=1..MaxY  } (MaxX*MaxY*Max)/100.
1{ svert(V) : vert(V) }1.
reach(V') :- svert(V), edge(V,V').
reach(V') :- reach(V), edge(V,V').
:- vert(V), not reach(V).

%degree(V,D) :- vert(V), D=#sum{ 1,V,V' : edge(V,V') }. % too inefficient
%:- degree(MinD,Min,Max), dim(MaxX,MaxY), not (MaxX*MaxY*Min)/100 #sum{ 1,V : degree(V,D), D>=MinD } (MaxX*MaxY*Max)/100.

% Check that edges are not crossing
:- edge((X1,Y1),(X2,Y2)), (X1,Y1)<(X2,Y2),
   1{ edge((X3,Y3),(X4,Y4)) : (X1,Y1)!=(X3,Y3), (X1,Y1)!=(X4,Y4), (X2,Y2)!=(X3,Y3), (X2,Y2)!=(X4,Y4),
                              t=@crossing((X1,Y1),(X2,Y2),(X3,Y3),(X4,Y4))}.

% Calculate travel time
edge(V,V',D*S) :- edge(V,V'), robotSpeed(S), eucDist(V,V',D).

% Guess special vertices
N { vert(T,(X,Y)) : X=1..MaxX, Y=1..MaxY } N :- dim(MaxX,MaxY), vertType(T,N).
:- vert(T,V), not vert(V).

% Make sure special types are certain distance apart and in desired area
:- #sum{ 1,V,V' : vert(T,V), vert(T',V'), eucDist(V,V',D'), D'<D } >= 1, distTypes(T,T',D).
:- location(T,XMN,YMN,XMX,YMX), vert(T,(X,Y)), 
   1 #sum { 1 : XMN>X; 1 : XMX<X; 1 : YMN>Y; 1 : YMX<Y }.

% avoid conflicting vertex definitions (can be defined anywhere else as a catchall predicate)
:- conflict(V), vert(V).

% Calculate vertex conflicts
conflict(v,V,V') :- vert(V), vert(V'), eucDist(V,V',D), robotSize(S), D<=S. 
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
:- homeArea(XMN,YMN,XMX,YMX),  home(R,(X,Y)), 
   1 #sum { 1 : XMN>X; 1 : XMX<X; 1 : YMN>Y; 1 : YMX<Y }.
conflict(V) :- home(_,V), 1 { vert(_,V) }.
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
N { depends(wait,T,T') : task(T,_), task(T',_), not depends(deliver,T,T') } N :- tasks(wait,N), N>0.
dependsTrans(T,T')  :- depends(D,T,T').
dependsTrans(T,T'') :- dependsTrans(T,T'), dependsTrans(T',T'').
:- dependsTrans(T,T).
:- depends(deliver,T,T'), task(T,V), task(T',V'),
   distTasks(M), eucDist(V,V',D), D<M.

% check that tasks are at desired special vertices
:- taskLocation(TT,VT,MN,MX), not MN #sum { 1,V,ID : task((ID,TT),V), vert(VT,V) } MX.

#show depends/3.
#show task/2.