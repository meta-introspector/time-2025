reduce .[] as $item ({}; . + { ($item | split(" ") | .[1]): ($item | split(" ") | .[0] | tonumber) })
