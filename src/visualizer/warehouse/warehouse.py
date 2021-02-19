import pandas as pd
import re

EDGE_RE     = re.compile(r'edge\(\((?P<x1>[0-9]+),(?P<y1>[0-9]+)\),\((?P<x2>[0-9]+),(?P<y2>[0-9]+)\),(?P<dist>[0-9]+)\)')
NODE_CON_RE = re.compile(r'conflict\(v,\((?P<x1>[0-9]+),(?P<y1>[0-9]+)\),\((?P<x2>[0-9]+),(?P<y2>[0-9]+)\)\)')
EDGE_CON_RE = re.compile(r'conflict\(e,\(\((?P<x1>[0-9]+),(?P<y1>[0-9]+)\),\((?P<x2>[0-9]+),(?P<y2>[0-9]+)\)\),\(\((?P<x3>[0-9]+),(?P<y3>[0-9]+)\),\((?P<x4>[0-9]+),(?P<y4>[0-9]+)\)\)\)')
HOME_RE     = re.compile(r'home\((?P<r>[0-9]+),\((?P<x>[0-9]+),(?P<y>[0-9]+)\)\)')
START_RE    = re.compile(r'start\((?P<r>[0-9]+),\((?P<x>[0-9]+),(?P<y>[0-9]+)\)\)')
TASK_RE     = re.compile(r'task\((?P<t>.+),\((?P<x>[0-9]+),(?P<y>[0-9]+)\)\)')
DEPENDS_RE  = re.compile(r'depends\((?P<d>.+),(?P<t1>\(.+\)),(?P<t2>\(.+\))\)')

class Warehouse:
        def __init__(self, instance={}):
                self.edges = set()
                self.nodes = set()
                self.node_conflicts = pd.DataFrame(columns=['node1', 'node2'])
                self.edge_conflicts = pd.DataFrame(columns=['edge1', 'edge2'])
                self.home = {}
                self.robots = {}
                self.tasks = {}
                self.dependency_graph = pd.DataFrame(columns=['task1', 'task2', 'type'])
                if instance:
                        self.parse_instance(instance)

        def parse_instance(self, instance):
                for atom in instance:
                        m = EDGE_RE.match(atom)
                        if m:
                                self.edges.add(((int(m.group('x1')),int(m.group('y1'))),(int(m.group('x2')),int(m.group('y2'))),int(m.group('dist'))))
                                self.nodes.add((int(m.group('x1')),int(m.group('y1'))))
                                self.nodes.add((int(m.group('x2')),int(m.group('y2'))))
                        m = NODE_CON_RE.match(atom)
                        if m:
                                data = {'node1' : (int(m.group('x1')),(int(m.group('y1')))), 'node2' : (int(m.group('x2')),(int(m.group('y2'))))}
                                self.node_conflicts = self.node_conflicts.append(data, ignore_index=True)
                        m = EDGE_CON_RE.match(atom)
                        if m:
                                data = {'edge1' : ((int(m.group('x1')),(int(m.group('y1')))),(int(m.group('x2')),(int(m.group('y2'))))), 'edge2' : ((int(m.group('x3')),(int(m.group('y3')))),(int(m.group('x4')),(int(m.group('y4')))))}
                                self.edge_conflicts = self.edge_conflicts.append(data, ignore_index=True)
                        m = HOME_RE.match(atom)
                        if m:
                                self.home[int(m.group('r'))] = (int(m.group('x')),int(m.group('y')))
                        m = START_RE.match(atom)
                        if m:
                                self.robots[int(m.group('r'))] = (int(m.group('x')),int(m.group('y')))
                        m = TASK_RE.match(atom)
                        if m:
                                self.tasks[str(m.group('t'))] = (int(m.group('x')),int(m.group('y')))
                        m = DEPENDS_RE.match(atom)
                        if m:
                                data = {'task1' : str(m.group('t1')), 'task2' : str(m.group('t2')), 'type' : str(m.group('d'))}
                                self.dependency_graph = self.dependency_graph.append(data, ignore_index=True)