# JSON parser for Lisp and SWI-Prolog
## GENERAL INFORMATION:
**Project Name**: jsonparse.pl

**Language**: SWI-Prolog

**Purpose**: Parser for JSON strings in a more accessible syntax for the Prolog language

**Developers**: Gabriele Moise'

## INTRODUCTION:
Developing web applications on the internet, but not limited to, requires exchanging data between heterogeneous applications, for example, between a web client written in Javascript and a server, and vice versa. A widely used standard for data exchange is the JavaScript Object Notation, or JSON. The purpose of this project is to develop a Prolog library capable of constructing data structures that represent JSON objects from their string representations.

The JSON syntax is defined on the website https://www.json.org. From the given grammar, a JSON object can be recursively broken down into the following parts, as does the parser:
   1. Object
   2. Array
   3. Value
   4. String
   5. Number

## MAIN FUNCTIONS:
1.  jsonparse/2 -> jsonparse(JSONString, Object). Takes a JSON string as input and parses it, returning it as the value of Object according to the following syntax:
    * `Object = jsonobj(Members)`
    * `Object = jsonarray(Elements)`
    
    and recursively:

    * `Members = []` or `Members = [Pair | MoreMembers]`
    * `Pair = (Attribute, Value)`
    * `Attribute = <SWI Prolog string>`
    * `Number = <Prolog number>`
    * `Value = <SWI Prolog string> | Number | Object`
    * `Elements = []` or `Elements = [Value | MoreElements]`

1. `jsonaccess/3 -> jsonaccess(Jsonobj, Fields, Result)`, which succeeds when Result is retrievable by following the chain of fields present in Fields (a list) starting from Jsonobj. A field represented by N (with N greater than or equal to 0) corresponds to an index of a JSON array.

1. `jsonread/2 -> jsonread(FileName, JSON)`. The predicate opens the file FileName and succeeds if it manages to construct a JSON object. If FileName does not exist, the predicate fails.

1. `jsondump -> jsondump(JSON, FileName)`. Writes the JSON object to the FileName in JSON syntax. If FileName does not exist, it is created, and if it exists, it is overwritten.
