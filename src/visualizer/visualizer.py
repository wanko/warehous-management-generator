import networkx as nx
import sys
import json
from warehouse.warehouse import Warehouse

# get and parse warehouse instance
data = json.load(sys.stdin)
warehouse = Warehouse(instance=data['Call'][0]['Witnesses'][0]['Value'])

G = nx.Graph()
for node in warehouse.nodes:
        G.add_node(node,pos=node)
for edge in warehouse.edges:
        G.add_edge(edge[0],edge[1])

pos=nx.get_node_attributes(G,'pos')
nx.draw(G,pos)

