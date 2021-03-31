import networkx as nx
import sys
import json
import matplotlib.pyplot as plt
import pandas as pd
import argparse
from warehouse.warehouse import Warehouse

parser = argparse.ArgumentParser(description='Visualize a Warehouse Problem Instance.')
parser.add_argument("-f", "--file", type=str,
                    default=None,
                    help="Read instance file (Default: json format from clingo via stdin)")
parser.add_argument("-o", "--output", type=str,
                    default="screen",
                    help="Output either to screen or files (Default: screen). Specify absolute or relative filename without extension.")
args = parser.parse_args()

# get and parse warehouse instance
if args.file:
        with open(args.file) as f:
                instance = []
                for line in f:
                        line.replace(".","")
                        instance.extend(line.split(" "))
        warehouse = Warehouse(instance=instance)
else:
        data = json.load(sys.stdin)
        warehouse = Warehouse(instance=data['Call'][0]['Witnesses'][len(data['Call'][0]['Witnesses'])-1]['Value'])

# create graphs
# warehouse
G = nx.Graph()
H = nx.Graph()
R = nx.Graph()
T = nx.Graph()
for node in warehouse.nodes:
        G.add_node(node,pos=node)
for edge in warehouse.edges:
        G.add_edge(edge[0],edge[1])
for robot in warehouse.home:
        H.add_node(warehouse.home[robot],pos=warehouse.home[robot])
for robot in warehouse.robots:
        R.add_node(warehouse.robots[robot],pos=warehouse.robots[robot])
for task in warehouse.tasks:
        T.add_node(warehouse.tasks[task],pos=warehouse.tasks[task])
# task dependency
D = nx.DiGraph()
for task1 in warehouse.tasks:
        for row in warehouse.dependency_graph[warehouse.dependency_graph['task1'] == task1].itertuples():
                D.add_node(task1)
                D.add_node(row.task2)
                D.add_edge(task1,row.task2,type=row.type)

# draw warehouse
pos=nx.get_node_attributes(G,'pos')
whf = plt.figure("Warehouse")
nx.draw(G,pos)
nx.draw_networkx_edge_labels(G,pos,edge_labels={(edge[0],edge[1]) : edge[2] for edge in warehouse.edges})
pos=nx.get_node_attributes(H,'pos')
nx.draw_networkx_nodes(H,pos,node_shape='^',node_color='green')
nx.draw_networkx_labels(H,pos,labels={warehouse.home[robot] : "home "+str(robot) for robot in warehouse.home})
pos=nx.get_node_attributes(T,'pos')
nx.draw_networkx_nodes(T,pos,node_shape='v',node_color='red')
nx.draw_networkx_labels(T,{node : (pos[node][0],pos[node][1]+0.2) for node in pos},labels={warehouse.tasks[task] : "task "+str(task) for task in warehouse.tasks})
pos=nx.get_node_attributes(R,'pos')
nx.draw_networkx_nodes(R,pos,node_shape='o',node_color='grey')
nx.draw_networkx_labels(R,{node : (pos[node][0],pos[node][1]-0.2) for node in pos},labels={warehouse.robots[robot] : "robot "+str(robot) for robot in warehouse.robots})

# draw dependency graph
dgf = plt.figure("Dependency Graph")
pos = nx.circular_layout(D)
nx.draw(D,pos)
nx.draw_networkx_edges(D,pos, arrows=True)
nx.draw_networkx_edge_labels(D,pos,edge_labels=nx.get_edge_attributes(D,'type'))
nx.draw_networkx_labels(D,pos,labels={task: task+'\n'+str(warehouse.tasks[task]) for task in warehouse.tasks})

if args.output == "screen":
        plt.show()
else:
        whf.savefig(args.output+"_warehouse.png")
        dgf.savefig(args.output+"_dependencygraph.png")

