#!/usr/bin/python
"""
$Id: cwm.py,v 1.198 2012/01/30 09:30:20 timbl Exp $

Closed World Machine

(also, in Wales, a valley  - topologiclly a partially closed world perhaps?)

This is an application which knows a certian amount of stuff and can manipulate
it. It uses llyn, a (forward chaining) query engine, not an (backward chaining)
inference engine: that is, it will apply all rules it can but won't figure out
which ones to apply to prove something. 


License
-------
Cwm: http://www.w3.org/2000/10/swap/doc/cwm.html

Copyright (c) 2000-2004 World Wide Web Consortium, (Massachusetts 
Institute of Technology, European Research Consortium for Informatics 
and Mathematics, Keio University). All Rights Reserved. This work is 
distributed under the W3C Software License [1] in the hope that it 
will be useful, but WITHOUT ANY WARRANTY; without even the implied 
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

[1] http://www.w3.org/Consortium/Legal/2002/copyright-software-20021231

"""

#the following lines should be removed. They will NOT work with any distribution
#-----------------
from os import chdir, getcwd
from sys import path
qqq = getcwd()
chdir(path[0])
chdir('..')
path.append(getcwd())
chdir(qqq)
#import swap
#print dir(swap)
#-----------------
#end lines should be removed


import string, sys

# From  http://www.w3.org/2000/10/swap/
from swap import  diag
from swap.why import  explainFormula, newTopLevelFormula
from swap.diag import verbosity, setVerbosity, progress, tracking, setTracking
from swap.uripath import join, splitFrag
from swap.webAccess import urlopenForRDF, load, sandBoxed 

from swap import  notation3            # N3 parsers and generators
from swap import  toXML                 #  RDF generator

from swap.why import BecauseOfCommandLine
from swap.query import think, applyRules, applyQueries, applySparqlQueries, testIncludes
from swap.update import patch

from swap import  uripath
from swap import  llyn
from swap import  RDFSink

cvsRevision = "$Revision: 1.198 $"
    
            

#################################################  Command line

    
def doCommand():
        """Command line RDF/N3 tool
        
 <command> <options> <steps> [--with <more args> ]

options:
 
--pipe        Don't store, just pipe out *

steps, in order left to right:

--rdf         Input & Output ** in RDF/XML insead of n3 from now on
--n3          Input & Output in N3 from now on. (Default)
--rdf=flags   Input & Output ** in RDF and set given RDF flags
--n3=flags    Input & Output in N3 and set N3 flags
--ntriples    Input & Output in NTriples (equiv --n3=usbpartane -bySubject -quiet)
--language=x  Input & Output in "x" (rdf, n3, etc)  --rdf same as: --language=rdf
--languageOptions=y     --n3=sp same as:  --language=n3 --languageOptions=sp
--ugly        Store input and regurgitate, data only, fastest *
--bySubject   Store input and regurgitate in subject order *
--no          No output *
              (default is to store and pretty print with anonymous nodes) *
--base=<uri>  Set the base URI. Input or output is done as though theis were the document URI.
--closure=flags  Control automatic lookup of identifiers (see below)
<uri>         Load document. URI may be relative to current directory.

--apply=foo   Read rules from foo, apply to store, adding conclusions to store
--patch=foo   Read patches from foo, applying insertions and deletions to store
--filter=foo  Read rules from foo, apply to store, REPLACING store with conclusions
--query=foo   Read a N3QL query from foo, apply it to the store, and replace the store with its conclusions
--sparql=foo   Read a SPARQL query from foo, apply it to the store, and replace the store with its conclusions
--rules       Apply rules in store to store, adding conclusions to store
--think       as -rules but continue until no more rule matches (or forever!)
--engine=otter use otter (in your $PATH) instead of llyn for linking, etc
--why         Replace the store with an explanation of its contents
--why=u       proof tries to be shorter
--mode=flags  Set modus operandi for inference (see below)
--reify       Replace the statements in the store with statements describing them.
--dereify     Undo the effects of --reify
--flatten     Reify only nested subexpressions (not top level) so that no {} remain.
--unflatten   Undo the effects of --flatten
--think=foo   as -apply=foo but continue until no more rule matches (or forever!)
--purge       Remove from store any triple involving anything in class log:Chaff
--data              Remove all except plain RDF triples (formulae, forAll, etc)
--strings     Dump :s to stdout ordered by :k whereever { :k log:outputString :s }
--crypto      Enable processing of crypto builtin functions. Requires python crypto.
--help        print this message
--revision    print CVS revision numbers of major modules
--chatty=50   Verbose debugging output of questionable use, range 0-99
--sparqlServer instead of outputting, start a SPARQL server on port 8000 of the store
--sparqlResults        After sparql query, print in sparqlResults format instead of rdf

finally:

--with        Pass any further arguments to the N3 store as os:argv values
 

            * mutually exclusive
            ** doesn't work for complex cases :-/
Examples:
  cwm --rdf foo.rdf --n3 --pipe     Convert from rdf/xml to rdf/n3
  cwm foo.n3 bar.n3 --think         Combine data and find all deductions
  cwm foo.n3 --flat --n3=spart

Mode flags affect inference extedning to the web:
 r   Needed to enable any remote stuff.
 a   When reading schema, also load rules pointed to by schema (requires r, s)
 E   Errors loading schemas of definitive documents are ignored
 m   Schemas and definitive documents laoded are merged into the meta knowledge
     (otherwise they are consulted independently)
 s   Read the schema for any predicate in a query.
 u   Generate unique ids using a run-specific

Closure flags are set to cause the working formula to be automatically exapnded to
the closure under the operation of looking up:

 s   the subject of a statement added
 p   the predicate of a statement added
 o   the object of a statement added
 t   the object of an rdf:type statement added
 i   any owl:imports documents
 r   any doc:rules documents
 E   errors are ignored --- This is independant of --mode=E

 n   Normalize IRIs to URIs
 e   Smush together any nodes which are = (owl:sameAs)

See http://www.w3.org/2000/10/swap/doc/cwm  for more documentation.

Setting the environment variable CWM_RDFLIB to 1 maked Cwm use rdflib to parse
rdf/xml files. Note that this requires rdflib.
"""
        
        import time
        import sys
        from swap import  myStore

        # These would just be attributes if this were an object
        global _store
        global workingContext
        option_need_rdf_sometime = 0  # If we don't need it, don't import it
                               # (to save errors where parsers don't exist)
        
        option_pipe = 0     # Don't store, just pipe though
        option_inputs = []
        option_reify = 0    # Flag: reify on output  (process?)
        option_flat = 0    # Flag: reify on output  (process?)
        option_crypto = 0  # Flag: make cryptographic algorithms available
        setTracking(0)
        option_outURI = None
        option_outputStyle = "-best"
        _gotInput = 0     #  Do we not need to take input from stdin?
        option_meta = 0
        option_normalize_iri = 0
        
        option_flags = { "rdf":"l", "n3":"", "think":"", "sparql":""}
            # RDF/XML serializer can't do list ("collection") syntax.
            
        option_quiet = 0
        option_with = None  # Command line arguments made available to N3 processing
        option_engine = "llyn"
        option_why = ""
        
        _step = 0           # Step number used for metadata
        _genid = 0

        hostname = "localhost" # @@@@@@@@@@@ Get real one
        
        # The base URI for this process - the Web equiv of cwd
        _baseURI = uripath.base()
        
        option_format = "n3"      # set the default format
        option_first_format = None
        
        _outURI = _baseURI
        option_baseURI = _baseURI     # To start with - then tracks running base
        
        #  First pass on command line        - - - - - - - P A S S  1
        
        for argnum in range(1,len(sys.argv)):  # options after script name
            arg = sys.argv[argnum]
            if arg.startswith("--"): arg = arg[1:]   # Chop posix-style -- to -
#            _equals = string.find(arg, "=")
            _lhs = ""
            _rhs = ""
            try:
                [_lhs,_rhs]=arg.split('=',1)
                try:
                    _uri = join(option_baseURI, _rhs)
                except ValueError:
                    _uri = _rhs
            except ValueError: pass
            if arg == "-ugly": option_outputStyle = arg
            elif _lhs == "-base": option_baseURI = _uri
            elif arg == "-rdf":
                option_format = "rdf"
                if option_first_format == None:
                    option_first_format = option_format 
                option_need_rdf_sometime = 1
            elif _lhs == "-rdf":
                option_format = "rdf"
                if option_first_format == None:
                    option_first_format = option_format 
                option_flags["rdf"] = _rhs
                option_need_rdf_sometime = 1
            elif arg == "-n3":
                option_format = "n3"
                if option_first_format == None:
                    option_first_format = option_format 
            elif _lhs == "-n3":
                option_format = "n3"
                if option_first_format == None:
                    option_first_format = optio
