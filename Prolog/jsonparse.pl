/*
* Mois� Gabriele 885986
* Vita  Andrea   887466
* This is a library for creating JSON files
* from an input file in PROLOG by
* parsing it in a different syntax.
*/

/*
* jsonparse/2 jsonparse(JSONString, Object), true if
* JSONString can be divided in a string,
* number, or in complex terms :Object = jsonobj(Members)
* or Object = jsonarray(Elements).
*/

jsonparse('{}', jsonobj([])) :- !.
jsonparse('[]', jsonarray([])) :- !.
jsonparse([], jsonarray([])) :- !.

% Converts JSONString from string to prolog Atom.
jsonparse(JSONString, Object) :-
    string(JSONString), !,
    catch(term_string(JSONTerm, JSONString), _, fail),
    term_to_atom(JSONTerm, JSONAtom),
    jsonparse(JSONAtom, Object).

% Converts the input JSON value (an atom) in a prolog array.
jsonparse(JSONArray, jsonarray(Elements)) :-
    atom(JSONArray),
    term_string(JSONAtom, JSONArray),
    jsonarray(JSONAtom, Elements), !.

jsonparse(JSONArray, jsonarray(Elements)) :-
    jsonarray(JSONArray, Elements),!.

% Converts the input atom in an object with the following structure:
% Members = [] or Members = [Pair | MoreMembers]
jsonparse(JSONAtom, jsonobj(Object)) :-
    atom(JSONAtom), !,
    term_string(ClnJSONString, JSONAtom),
    ClnJSONString =.. [{}, Members],
    jsonobj(Members, Object).

/* jsonarray/2 parses and convert the JSON list in a list of
 * elements with the following structure:
 * Elements = [] or Elements = [Value | MoreElements].
 */
jsonarray([],[]). %Returns an empty list if the JSON list is empty
jsonarray([Value | MoreElements], [ParsedValue | ParsedElements]) :-
    checkvalue(Value, ParsedValue),
    jsonarray(MoreElements, ParsedElements), !.

% jsonpair/2 checks for nested objects or arrays and parses them.
jsonpair(JSONString, Object) :-
    term_to_atom(JSONString, Atom),
    isobj(Atom),
    jsonparse(Atom, Object), !.

% Checks if all the elements inside a jsonarray(Value, MoreElements)
% are syntactically correct.
jsonpair([Value | MoreElements], Elements) :-
    checkvalue(Value, Elements),
    jsonarray(MoreElements, Elements),!.

% jsonobj/2 extracts all the members inside Object
jsonobj(Object, [ParsedPair]) :-
    parsepair(Object, ParsedPair),!.

jsonobj(Object, [ParsedPair| ParsedPairs]):-
    Object =.. [',', Pair | MorePairs],
    parsepair(Pair, ParsedPair),
    nth0(0, MorePairs, FirstPair),
    jsonobj(FirstPair, ParsedPairs), !.

% Calls jsonparse if a nested element is found.
jsonobj(Object, ParsedPair) :-
    jsonparse(Object, ParsedPair).

% parsepair/2 split a pair received from jsonobj/2
% in half as follows: (Value, Attribute).
parsepair(Pair, (Attribute, ParsedValue)) :-
    Pair =.. [':', Attribute, Value],
    string(Attribute),
    checkvalue(Value, ParsedValue).

% checkvalue/2 parses all the values received from parsepair/2 and
% jsopair/2.
checkvalue(Value, Value) :- string(Value), !.
checkvalue(Value, Value) :- number(Value), !.
checkvalue(Value, Value) :- atom(Value), !.
checkvalue(Value, ParsedValue) :- is_list(Value),
    jsonparse(Value,ParsedValue), !.
checkvalue(Value, ParsedValue) :-
    jsonpair(Value, ParsedValue), !.

% jsonobj/1 cheks if JSONString received as input should be
% treated as jsonobj([...]).
isobj(Atom) :-
    atom_chars(Atom, C),
    nth0(0, C, '{'),
    last(C, '}').

% jsonaccess/3 search for a specific element inside the parsed JSON
% atom through a set of fields, if anything has given inside
% the set, jsonacces will return the input atom.
jsonaccess(PartialResult, [], PartialResult) :- !.

% Search inside the input object jsonobj(ParsedOBject)
% the fields of the given set.
jsonaccess(jsonobj(ParsedObject), [Field | Fields], Result) :-
    jsonaccess(jsonobj(ParsedObject), Field, PartialResult),
    jsonaccess(PartialResult, Fields, Result),
    !.

% Search inside jsonobj(ParsedOBject) the set of given fields
jsonaccess(jsonarray(ParsedArray), [Field | Fields], Result) :-
    jsonaccess(jsonarray(ParsedArray), Field, PartialResult),
    jsonaccess(PartialResult, Fields, Result),
    !.

% If a string has passed as input, jsonaccess will search for the
% given string inside jsonobj(ParsedObject), fails otherwise.
jsonaccess(jsonobj(ParsedObject), String, Result) :-
    string(String),
    get_string(ParsedObject, String, Result),
    !.

% Search for the N-nth element inside ParsedArray.
jsonaccess(jsonarray(ParsedArray), N, Result) :-
    number(N),
    get_index(ParsedArray, N, Result), !.

jsonaccess(PartialResult, [], PartialResult) :- !.

jsonaccess(jsonobj(ParsedObject), [Field | Fields], Result) :-
    jsonaccess(jsonobj(ParsedObject), Field, PartialResult),
    jsonaccess(PartialResult, Fields, Result), !.

jsonaccess(jsonarray(ParsedArray), [Field | Fields], Result) :-
    jsonaccess(jsonarray(ParsedArray), Field, PartialResult),
    jsonaccess(PartialResult, Fields, Result), !.

% parse a number if it is found
jsonaccess(jsonarray(ParsedArray), N, Result) :-
    number(N),
    get_index(ParsedArray, N, Result), !.

% parse a string if it is found
jsonaccess(jsonobj(ParsedObject), String, Result) :-
    string(String),
    get_string(ParsedObject, String, Result), !.

% extract the string from Item, between objects; if no String
% is given, it will return Item.
get_string(_, [], _) :-
    fail, !.

get_string([(Item1, Item2) | _], String, Result) :-
    String = Item1,
    Result = Item2, !.

get_string([(_) | Items], String, Result) :-
    get_string(Items, String, Result), !.

% research for a specific array Item throughout a
% pointer to the array (N).
get_index([Item | _], 0, Item) :- !.

get_index([], _, _) :-
    fail, !.

get_index([_ | Items], N, Result) :-
    N > 0,
    P is N-1,
    get_index(Items, P, Result), !.



%%% FILE I/O.

% jsondump/2 writes JSON object on a file (FileName)
% and converts the object into the normal JSON syntax.

jsondump(JSON, FileName) :-
    absolute_file_name(FileName, AbsFileName),
    open(AbsFileName, write, Stream),
    jsonstring(JSON, JSONAtom),
    term_string(JSONAtom, JSONString),
    write(Stream, JSONString),
    close(Stream).

% Does the opposite of jsonparse: parses from
% the given Prolog syntax to JSON
jsonstring(jsonobj([]), {}) :- !.

jsonstring(jsonobj(Obj), Result) :-
    jsonstring(Obj, ObjReverse),
    Result =.. [{},  ObjReverse].

jsonstring([(Field, Attribute)], Result) :-
    jsonstring(Attribute, ObjReverse), !,
    Result =.. [':', Field, ObjReverse].

jsonstring([(Field, Attribute)], Result) :- !,
    Result =.. [':', Field, Attribute].

jsonstring([(Field, Attribute) | Objs], (Result, Results)) :-
    jsonstring(Attribute, ObjReverse), !,
    Result =.. [':', Field, ObjReverse],
    jsonstring(Objs, Results).

jsonstring([(Field, Attribute) | Objs], (Result, Results)) :- !,
    Result =.. [':', Field, Attribute],
    jsonstring(Objs, Results).

jsonstring([], []) :- !.

jsonstring(jsonarray(List), Result) :-
    jsonstring(List, Result).

jsonstring([Element], [Result]) :-
    jsonstring(Element, Result), !.

jsonstring([Element], [Element]) :- !.

jsonstring([Element | Elements], [ElementReverse | Results]) :-
    jsonstring(Element, ElementReverse), !,
    jsonstring(Elements, Results).

jsonstring([Element | Elements], [Element | Results]) :-
    jsonstring(Elements, Results).

% jsonread/2 read the entire .JSON file (FileName) and converts it
% into the Prolog notation using jsonparse/2.
jsonread(FileName, JSON) :-
    absolute_file_name(FileName, AbsFileName),
    catch(open(AbsFileName, read, Stream), _, false),
    read_string(Stream, _, JSONString),
    jsonparse(JSONString, JSON),
    close(Stream).













