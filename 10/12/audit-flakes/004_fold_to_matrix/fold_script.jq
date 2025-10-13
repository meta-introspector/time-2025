group_by(.owner + "/" + .repo) | map({
  owner: (.[0].owner // "N/A"),
  repo: (.[0].repo // "N/A"),
  narHashes: (map(.narHash) | group_by(.) | map({value: .[0], count: length})),
  revs: (map(.rev) | group_by(.) | map({value: .[0], count: length})),
  types: (map(.type) | group_by(.) | map({value: .[0], count: length}))
})