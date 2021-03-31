dim(40,4).
distance(15).
range(1).
fill(25,75).

robots(4).
robotSize(14).
homeArea(X/2,1,#sup,1):-dim(X,Y).
robotSpeed(1).

tasks(deliver,8).
tasks(wait,N/2) :- tasks(deliver,N).
distTasks(15).