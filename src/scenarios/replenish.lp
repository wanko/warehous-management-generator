vertType(loading,N/2) :- tasks(deliver,N).
vertType(storage,Y) :- dim(X,Y).
vertType(pallets,2).
distTypes(loading,storage,15).
distTypes(loading,pallets,15).
distTypes(pallets,storage,15).

location(loading,#inf,1,X/2,1)  :- dim(X,Y).
location(storage,#inf,Y,#sup,Y) :- dim(X,Y).
location(pallets,#inf,1,#sup,1).

taskLocation(pickup,loading,N/2,#sup)  :- tasks(deliver,N).
taskLocation(putdown,storage,N/2,#sup) :- tasks(deliver,N).
taskLocation(pickup,pallets,N/2,#sup)  :- tasks(deliver,N).
taskLocation(putdown,loading,N/2,#sup) :- tasks(deliver,N).

replenish(V,ID) :- task((ID,pickup),V), vert(loading,V),
                   depends(wait,(ID,pickup),(ID',putdown)),
                   depends(deliver,(ID''',pickup),(ID',putdown)),
                   task((ID',putdown),V), task((ID''',pickup),V'), vert(pallets,V').

:- not replenish(V,ID), task((ID,pickup),V), vert(loading,V).
:- vert(loading,V), not task((_,pickup),V).