vertType(loading,1).
vertType(storage,1).
vertType(pallets,1).
distTypes(loading,storage,15).
distTypes(loading,pallets,15).
distTypes(pallets,storage,15).

location(loading,#inf,1,#sup,1).
location(storage,#inf,Y,#sup,Y) :- dim(X,Y).
location(pallets,#inf,1,#sup,1).

taskLocation(pickup,loading,N/2,#sup)  :- tasks(deliver,N).
taskLocation(putdown,storage,N/2,#sup) :- tasks(deliver,N).
taskLocation(pickup,pallets,N/2,#sup)  :- tasks(deliver,N).
taskLocation(putdown,loading,N/2,#sup) :- tasks(deliver,N).

:- task((ID,pickup),V), vert(loading,V),
   not 2 #sum { 1,ID,ID'  : depends(wait,(ID,pickup),(ID',putdown));
                1,ID'     : task((ID',putdown),V) } 2.