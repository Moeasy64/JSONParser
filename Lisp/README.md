
# GENERAL INFORMATION
- **Project Name:** jsonparse.lisp
- **Language:** Common Lisp
- **Purpose:** Parser for JSON strings into a more accessible syntax for the Common Lisp language
- **Developers:** Gabriele Moise'

## INTRODUCTION
Developing web applications on the Internet, but not only, requires exchanging data between heterogeneous applications, such as between a web client written in JavaScript and a server, and vice versa. A widely used standard for data exchange is the JavaScript Object Notation, or JSON. The purpose of this project is to create a Prolog library capable of building data structures that represent JSON objects from their string representation. The JSON syntax is defined on the website [JSON.org](https://www.json.org). From the given grammar, a JSON object can be recursively decomposed into the following parts, and the parser does the same:
1. Object = ’(’ jsonobj members ’)’
2. Object = ’(’ jsonarray elements ’)’
3. and recursively:
    * `members = pair*`
    * `pair = ’(’ attribute value ’)`
    * `attribute = <Common Lisp string>`
    * `number = <Common Lisp number>`
    * `value = string | number | Object`
    * `elements = value*`


## MAIN FUNCTIONS:

1. **jsonparse/1**
   - Function: `jsonparse JSONString`
   - Output: `sexp`
   - Description: Takes a JSON string as input and parses it returning it as a value of Object according to the syntax of JSON objects in Common Lisp, which is:
     - `Object = ’(’ jsonobj members ’)’`
     - `Object = ’(’ jsonarray elements ’)’`
     - and recursively:
       - `members = pair*`
       - `pair = ’(’ attribute value ’)’`
       - `attribute = <Common Lisp string>`
       - `number = <Common Lisp number>`
       - `value = string | number | Object`
       - `elements = value*`

2. **jsonaccess/2**
   - Function: `jsonaccess JSONParsed fields`
   - Output: `field_value`
   - Description: Accepts a JSON object represented in Common Lisp, as produced by the jsonparse function, and a series of "fields", retrieves the corresponding object.

3. **jsonread/1**
   - Function: `jsonread filename`
   - Output: `JSON`
   - Description: The jsonread function opens the file filename and returns a JSON object (or generates an error). If filename does not exist, the function generates an error.

4. **jsondump/2**
   - Function: `jsondump JSON filename`
   - Description: Writes the JSON object to the file filename in JSON syntax. If filename does not exist, it is created, and if it exists, it is overwritten.
