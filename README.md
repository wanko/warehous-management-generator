# Warehouse Management Generator
ASP-based instance generator for the Warehouse Management Problem

### Requirements
  - Generator
    - clingo >=5:
        - Most convenient way to install is conda via
        `conda install clingo -c potassco/label/dev`
        - Please consult the following resource for further information [clingo](https://github.com/potassco/clingo)
  - Visualizer
    - Python >=3 with modules: 
        - networkx
        - matplotlib
        - pandas
        - json

### Usage

#### Generator

    clingo src/generator.lp src/arith.lp src/configs/<config> src/scenarios/<scenario> scr/heuristic/<heuristic> --heuristic=Domain --out-atomf="%s." | tac | sed '7q;d' > <instance>

The call creates an instance with warehouse configuration `<config>`, scenario <scenario> and heuristic `<heuristic>` under filename `<instance>`. Fact format corresponds to paper.

##### Example

    clingo src/generator.lp src/arith.lp src/configs/20x4_15_1_0_25_2_6_3.lp src/scenarios/replenish.lp src/heurstics/many_edges.lp --heuristic=Domain --out-atomf="%s." | tac | sed '7q;d' > instance.lp

##### Warehouse configuration
Fact format:
  - dim(X,Y): Warehouse grid dimensions are X times Y
  - distance(D): Points in the grid are D apart
  - range(R): Edges between points are allowed to be D*R long
  - fill(Min,Max): At least Min, at most Max percent of points are used as vertices
  - robots(N): Number of robots is N
  - robotsSize(S): Robots are S big
  - homeArea(X,Y,X',Y'): Robots home coordinates (HX,HY) fulfill X<=HX<=X', Y<=HY<=Y'
  - robotSpeed(S): Robots drive S fast
  - task(T,N): N tasks of type T are required
  - distTasks(D): Locations of tasks have to be at least D apart 

#### Visualizer

Per default, the visualizer expects a json output of clingo over stdin and assumes the last answer set is a Warehouse Management Problem instance

    clingo src/generator.lp src/arith.lp <generator parameter> --outf=2 | python src/visualizer/visualizer.py

Alternatively, an Warehouse Management Problem instance file can be given as input

    python src/visualizer/visualizer.py --file <instance> [--output <output>]

For both modes, if `--output` is not specified, interactive plots are output to the display, otherwise two pictures <output>_warehouse.png and `<output>`_dependencygraph.png are created.

##### Examples

    clingo src/generator.lp src/arith.lp src/configs/20x4_15_1_0_25_2_6_3.lp src/scenarios/replenish.lp src/heurstics/many_edges.lp --heuristic=Domain --outf=2 | python src/visualizer/visualizer.py

    clingo src/generator.lp src/arith.lp src/configs/20x4_15_1_0_25_2_6_3.lp src/scenarios/replenish.lp src/heurstics/many_edges.lp --heuristic=Domain --out-atomf="%s." | tac | sed '7q;d' > instance.lp 
    python src/visualizer/visualizer.py --file instance.lp --output ./instance
