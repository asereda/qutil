.tst.desc["A Config Parser"]{
  before{
    `configFile mock {.tst.testFilePath `configs,x};
    };
  should["handle name substitution in values"]{
    cfg: .utl.parseConfig configFile `nameSubstitution;
    cfg["first";"bar"] mustmatch "banana/grape";
    cfg["first";"bat"] mustmatch "banana";
    cfg["first";"qux"] mustmatch "orange";
    cfg["first";"uxx"] mustmatch "banana/orange";
    cfg["first";"uzz"] mustmatch "banana/grape/orange/banana";
    };
  should["raise an error for circular dependency"]{
    mustthrow["Circular dependency for circular1"]{
      .utl.parseConfig configFile `circularDepedency;
      };
  };
  should["fill missing values from a DEFAULT section if available"]{
    cfg: .utl.parseConfig configFile `default;
    cfg["foo";"baz"] mustmatch string 4;
    };
  };

.tst.desc["A Raw Config Parser"]{
  before{
    `configFile mock {.tst.testFilePath `configs,x};
    };
  should["parse files from handles"]{
    mustnotthrow[();{.utl.parseRawConfig configFile `normal}];
    };
  should["parse lists of char lists"]{
    cfg: read0 configFile `normal;
    mustnotthrow[();{[x;y]; .utl.parseRawConfig x}[cfg]];
    };
  should["support multiple sections"]{
    cfg: .utl.parseRawConfig configFile `multipleSections;
    ("foo";"bar") mustin key cfg;
    cfg["foo";"bar"] musteq string 2;
    cfg["foo";"baz"] musteq string 3;
    cfg["bar";"qux"] musteq string 5;
    };
  should["raise an error if there is not at least one section"]{
    configFileName: 1 _ string configFile `noSections;
    mustthrow["There were no sections found in the file: '",configFileName,"'"]{
      .utl.parseRawConfig configFile `noSections
      };
    };
  should["recognize colon as a name-value pair separator"]{
    mustnotthrow[();{.utl.parseRawConfig configFile `colonSeparators}];
    cfg: .utl.parseRawConfig configFile `colonSeparators;
    cfg["foo";"bar"] musteq string 2;
    cfg["foo";"baz"] musteq string 3;
    };
  should["recognize equals as a name-value pair separator"]{
    mustnotthrow[();{.utl.parseRawConfig configFile `equalsSeparators}];
    cfg: .utl.parseRawConfig configFile `equalsSeparators;
    cfg["foo";"bar"] musteq string 2;
    cfg["foo";"baz"] musteq string 3;
    };
  should["raise an error if there is an empty key"]{
    configFileName: 1 _ string configFile `emptyKey;
    mustthrow["There was an empty key in the file: '",configFileName,"'"]{
      .utl.parseRawConfig configFile `emptyKey
      };
    };
  should["handle RFC 822 style LONG HEADER FIELD continuations"]{
    cfg: .utl.parseRawConfig configFile `longHeader;
    cfg["foo";"bar"] mustmatch "1 2 3\t4";
    };
  should["remove leading whitespace from values"]{
    cfg: .utl.parseRawConfig configFile `leadingWhitespace;
    cfg["foo";"bar"] mustmatch string 1;
    cfg["foo";"baz"] mustmatch string 2;
    };
  should["trim whitespace from keys"]{
    cfg: .utl.parseRawConfig configFile `tabsInKeys;
    key[cfg["first section"]] mustin\: ("foo";"blah";"baz";"hah");
    };
  should["ignore lines beginning with sharp"]{
    mustnotthrow[();{.utl.parseRawConfig configFile `sharpComment}];
    };
  should["ignore lines beginning with semi-colon"]{
    mustnotthrow[();{.utl.parseRawConfig configFile `semicolonComment}];
    };
  should["ignore lines containing only whitespace"]{
    mustnotthrow[();{.utl.parseRawConfig configFile `whitespace}];
    cfg: .utl.parseRawConfig configFile `whitespace;
    cfg["DEFAULT";"bar"] mustmatch "3 2\t5";
    };
  should["have the DEFAULT section in the raw configs if one was present"]{
    cfg: .utl.parseRawConfig configFile `normal; 
    "DEFAULT" mustin key cfg;
    };
  };
