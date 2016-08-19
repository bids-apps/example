#!/bin/bash
set -e
if [ "$#" -ge 4 ]; then
    bids-validator $2
		strace -r -s4096 -e trace=execve -fto $3/provenance.txt $1 ${@:2}
		#reprozip trace -d $3/provenance $1 ${@:2}
		#reprounzip graph -d $3/provenance --json $3/provenance/graph.json
		#reprounzip graph -d $3/provenance --dot $3/provenance/graph.dot
		#reprounzip graph -d $3/provenance --packages drop --otherfiles io --processes run --dot $3/provenance/graph_simplified.dot
		#dot -Tpng $3/provenance/graph_simplified.dot -o $3/provenance/graph_simplified.png
	else
		$1 ${@:2}
fi
