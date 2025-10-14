BEGIN { OFS=""; print "{" }
{ print $0 }
END { print "}" }