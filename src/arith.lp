#script (python)

from clingo.symbol import Number, Function
import math

def eucDist(coord1,coord2,size):
    x1 = coord1.arguments[0].number
    y1 = coord1.arguments[1].number
    x2 = coord2.arguments[0].number
    y2 = coord2.arguments[1].number
    
    yield Number(int(math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))*size.number))

# A Python3 program to find if 2 given line segments intersect or not 
  
class Point: 
    def __init__(self, x, y): 
        self.x = x 
        self.y = y 
  
# Given three colinear points p, q, r, the function checks if  
# point q lies on line segment 'pr'  
def onSegment(p, q, r): 
    if ( (q.x <= max(p.x, r.x)) and (q.x >= min(p.x, r.x)) and 
           (q.y <= max(p.y, r.y)) and (q.y >= min(p.y, r.y))): 
        return True
    return False
  
def orientation(p, q, r): 
    # to find the orientation of an ordered triplet (p,q,r) 
    # function returns the following values: 
    # 0 : Colinear points 
    # 1 : Clockwise points 
    # 2 : Counterclockwise 
      
    # See https://www.geeksforgeeks.org/orientation-3-ordered-points/amp/  
    # for details of below formula.  
      
    val = (float(q.y - p.y) * (r.x - q.x)) - (float(q.x - p.x) * (r.y - q.y)) 
    if (val > 0): 
          
        # Clockwise orientation 
        return 1
    elif (val < 0): 
          
        # Counterclockwise orientation 
        return 2
    else: 
          
        # Colinear orientation 
        return 0
  
# The main function that returns true if  
# the line segment 'p1q1' and 'p2q2' intersect. 
def doIntersect(p1,q1,p2,q2): 
      
    # Find the 4 orientations required for  
    # the general and special cases 
    o1 = orientation(p1, q1, p2) 
    o2 = orientation(p1, q1, q2) 
    o3 = orientation(p2, q2, p1) 
    o4 = orientation(p2, q2, q1) 
  
    # General case 
    if ((o1 != o2) and (o3 != o4)): 
        return True
  
    # Special Cases 
  
    # p1 , q1 and p2 are colinear and p2 lies on segment p1q1 
    if ((o1 == 0) and onSegment(p1, p2, q1)): 
        return True
  
    # p1 , q1 and q2 are colinear and q2 lies on segment p1q1 
    if ((o2 == 0) and onSegment(p1, q2, q1)): 
        return True
  
    # p2 , q2 and p1 are colinear and p1 lies on segment p2q2 
    if ((o3 == 0) and onSegment(p2, p1, q2)): 
        return True
  
    # p2 , q2 and q1 are colinear and q1 lies on segment p2q2 
    if ((o4 == 0) and onSegment(p2, q1, q2)): 
        return True
  
    # If none of the cases 
    return False

def crossing(v1,v2,v3,v4):
    p1 = Point(v1.arguments[0].number, v1.arguments[1].number) 
    q1 = Point(v2.arguments[0].number, v2.arguments[1].number) 
    p2 = Point(v3.arguments[0].number, v3.arguments[1].number) 
    q2 = Point(v4.arguments[0].number, v4.arguments[1].number) 

    if doIntersect(p1, q1, p2, q2): 
        yield Function('t',[])
    else:
        yield Function('f',[])

#end.


% calculate manhattan distance
manDist((X,Y),(X',Y'),D*S) :- X=1..MaxX, Y=1..MaxY, X'=1..MaxX, Y'=1..MaxY, D=|X-X'|+|Y-Y'|, dim(MaxX,MaxY), distance(S).

% calculate euclidean distance
eucDist((X,Y),(X',Y'),@eucDist((X,Y),(X',Y'),S)) :- X=1..MaxX, Y=1..MaxY, X'=1..MaxX, Y'=1..MaxY,
                                                    dim(MaxX,MaxY), distance(S).

% calculate max and min of coordinates

max(X,X',X) :- X=1..MaxX, X'=1..MaxX, X>=X', dim(MaxX,_).
max(Y,Y',Y) :- Y=1..MaxY, Y'=1..MaxY, Y>=Y', dim(_,MaxY).
min(X,X',X) :- X=1..MaxX, X'=1..MaxX, X<=X', dim(MaxX,_).
min(Y,Y',Y) :- Y=1..MaxY, Y'=1..MaxY, Y<=Y', dim(_,MaxY).
max(N',N,R) :- max(N,N',R).
min(N',N,R) :- min(N,N',R).