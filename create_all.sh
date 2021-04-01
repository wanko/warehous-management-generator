#!/bin/bash

configs=src/configs/
scenarios=src/scenarios/
heuristics=src/heurstics/
output=output

mkdir output

for config in $configs*.lp; do
    for scenario in $scenarios*.lp; do
        for heuristic in $heuristics*.lp; do
            config_name=$(basename -- "$config")
            scenario_name=$(basename -- "$scenario")
            heuristic_name=$(basename -- "$heuristic")
            config_name="${config_name%.*}"
            scenario_name="${scenario_name%.*}"
            heuristic_name="${heuristic_name%.*}"
            if [ -s $output/"$config_name"_"$scenario_name"_"$heuristic_name".lp ]; then
                echo "$config_name"_"$scenario_name"_"$heuristic_name" exists
            else
                echo Creating "$config_name"_"$scenario_name"_"$heuristic_name"
                clingo src/generator.lp src/arith.lp $config $scenario $heuristic --heuristic=Domain --out-atomf="%s." | tac | sed '7q;d' > $output/"$config_name"_"$scenario_name"_"$heuristic_name".lp    
                python src/visualizer/visualizer.py --file $output/"$config_name"_"$scenario_name"_"$heuristic_name".lp --output $output/"$config_name"_"$scenario_name"_"$heuristic_name" 
            fi
        done
    done
done

