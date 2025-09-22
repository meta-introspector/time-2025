#!/usr/bin/env bash

gh api user/starred -paginate  > index/stars.json
#grep clone_url index/stars.txt |cut '-d"' -f4 |cut -d. -f1-2 > index/urls.txt
#for x in `cat urls.txt `; do grep -r $x ~/nix2/index/ || echo nope $x; done