; Gabriele Moisè 885986
; Andrea   Vita  887466

; parse a string from JSON syntax to the parsed version required
(defun jsonparse (jsonString)
  (cond ((stringp jsonString) 
         (list-or-object (clean-list (string-to-list jsonString))))
        (T (error "syntax error"))))

; converts a string to a list
(defun string-to-list (string)
  (concatenate 'list string))

; converts a list to a string
(defun list-to-string (char-list)
  (if (null char-list) ""
      (concatenate 'string (string (car char-list)) 
      (list-to-string (cdr char-list)))))    

; recognize if a list of chars is wether a list or an object  
(defun list-or-object (JSONCharList)
  (cond ((and (eq (car JSONCharList) #\{)
              (eq (car (last JSONCharList)) #\}))
         (jsonobj JSONCharList))
        ((and (eq (car JSONCharList) #\[)
              (eq (car (last JSONCharList)) #\]))
         (jsonarray JSONCharList))
        (T (error "syntax error"))))

; clean the list of chars
(defun clean-list (JSONCharList)
  (remove #\Tab 
  (remove #\NewLine 
  (remove-spaces JSONCharList 0 nil))))

; removes only the spaces that aren't between brackets, and so inside a string
(defun remove-spaces (JSONCharList BoolQuotes NoSpaceList)
  (cond ((and (null JSONCharList) (null NoSpaceList)) nil)
        ((null JSONCharList) NoSpaceList)
        ((and (eq (car JSONCharList) #\") (eq BoolQuotes 0)) 
         (remove-spaces (cdr JSONCharList) 
                       1 
                       (append NoSpaceList (list (car JSONCharList)))))
        ((and (eq (car JSONCharList) #\") (eq BoolQuotes 1)) 
         (remove-spaces (cdr JSONCharList) 
                       0 
                       (append NoSpaceList (list (car JSONCharList)))))
        ((and (eq (car JSONCharList) #\Space) (zerop BoolQuotes))
         (remove-spaces (cdr JSONCharList) 
                       BoolQuotes 
                       NoSpaceList))
        (T (remove-spaces (cdr JSONCharList) 
                         BoolQuotes 
                         (append NoSpaceList (list (car JSONCharList)))))))

; split the pairs field-attribute
(defun split (CharList NParens BoolQuotes PairsList)
  (cond ((and (null CharList) (null PairsList)) nil)
        ((null CharList) (list (split-pair PairsList 0 0 nil)))
        ((or (eq (car CharList) #\{) 
             (eq (car CharList) #\[) 
             (and (eq (car CharList) #\") 
                  (eq BoolQuotes 0)))
         (split (cdr CharList)
                (+ NParens 1)
                1
                (append PairsList (list (car CharList)))))
        ((or (eq (car CharList) #\}) 
             (eq (car CharList) #\]) 
             (and (eq (car CharList) #\") 
                  (eq BoolQuotes 1)))
         (split (cdr CharList)
                (- NParens 1)
                0
                (append PairsList (list (car CharList)))))
        ((and (eq (car CharList) #\,) 
              (zerop NParens) 
              (zerop BoolQuotes))
         (append (list (split-pair PairsList 0 0 nil))  
                 (split-pair (split (cdr CharList) 
                                        NParens
                                        BoolQuotes
                                        nil) 0 0 nil)))
        (T (split (cdr CharList) 
                  NParens 
                  BoolQuotes 
                  (append PairsList (list (car CharList)))))))

; creates all the lists containing the pairs field-attribute
(defun split-pair (PairsList NParens BoolQuotes Result)
  (cond ((and (null PairsList) (null Result)) nil)
        ((null PairsList) Result)
        ((or (eq (car PairsList) #\{) 
             (eq (car PairsList) #\[) 
             (and (eq (car PairsList) #\") 
                  (eq BoolQuotes 0)))
         (split-pair (cdr PairsList)
                   (+ NParens 1)
                   1
                   (append Result (list (car PairsList)))))
        ((or (eq (car PairsList) #\}) 
             (eq (car PairsList) #\]) 
             (and (eq (car PairsList) #\") 
                  (eq BoolQuotes 1)))
         (split-pair (cdr PairsList)
                   (- NParens 1)
                   0
                   (append Result (list (car PairsList)))))
        ((and (eq (car PairsList) #\:) 
              (zerop NParens) 
              (zerop BoolQuotes))
         (append (list (jsonstring Result)) 
                 (list (jsonvalue (split-pair (cdr PairsList) 0 0 nil)))))
        (T (split-pair (cdr PairsList)
                     NParens 
                     BoolQuotes 
                     (append Result (list (car PairsList)))))))

; parse the list of chars into a booleanm a number, 
; a string, an array or an object
(defun jsonvalue (List)
  (cond ((null List) (error "syntax error"))
        ((eq (car List) #\") (jsonstring List)) ; string
        ((or (eq (car List) #\t) (eq (car List) #\f) (eq (car List) #\n)) 
         (jsonboolean List)) ; boolean
        ((and (and (not (eq (car List) #\.))
                   (not (eq (car (last List)) #\.)))
              (is-number List 0))
         (jsonnumber List)) ; number
        ((or (eq (car List) #\{) (eq (car List) #\[))
         (list-or-object List)) ; object or array
        (T  (error "syntax error"))))

; parse a list of chars into a string
(defun jsonstring (List)
  (cond ((and (eq (car List) #\") (eq (car (last List)) #\"))
         (list-to-string (remove #\" List)))
        (T (error "syntax error"))))

; parse a list of chars into a number
(defun jsonnumber (List)
 (cond ((null (find #\. List)) (parse-integer (list-to-string List)))
       (T (parse-float (list-to-string List)))))

; parse a list of chars into a boolean
(defun jsonboolean (List)
  (cond ((equal (list-to-string List) "true") 'true)
        ((equal (list-to-string List) "false") 'false)
        ((equal (list-to-string List) "null") 'null)
        (T (error "syntax error"))))

; established if a list of chars is a number or not 
(defun is-number (List BPoint)
  (cond ((null List) T)
        ((and (not (eq (car List) #\0))
              (not (eq (car List) #\1))
              (not (eq (car List) #\2))
              (not (eq (car List) #\3))
              (not (eq (car List) #\4))
              (not (eq (car List) #\5))
              (not (eq (car List) #\6))
              (not (eq (car List) #\7))
              (not (eq (car List) #\8))
              (not (eq (car List) #\9))
              (not (eq (car List) #\.)))
              nil)
        ((and (eq (car List) #\.) (not (zerop BPoint))) nil)
        ((and (eq (car List) #\.) (zerop BPoint)) 
         (is-number (cdr List) 1))
        (T (is-number (cdr List) BPoint))))

; parse a list of chars into an object
(defun jsonobj (JSONCharList)
  (append (list 'jsonobj)
          (split-pair (split (remove-parens JSONCharList) 0 0 nil)
                      0
                      0
                      nil)))

; parse a list of chars into a list
(defun jsonarray (JSONCharList)
  (append (list 'jsonarray)
          (check-value (split (remove-parens JSONCharList) 0 0 nil) nil)))

; parse the values of a list
(defun check-value (List ValuedList)
  (cond ((null List) ValuedList)
        (T (check-value (cdr List)
                           (append ValuedList 
                                   (list (jsonvalue (car List))))))))

; remove the border parenthesis
(defun remove-parens (List)
  (string-to-list (subseq (list-to-string List)
                          1
                          (- (length (list-to-string List)) 1))))

; access to all the fields inside a parsed value from jsonparse
(defun jsonaccess (JSONThing Will &rest Smith)
  (cond ((stringp Will) (jsonaccess-object JSONThing Will Smith))
        ((numberp Will) (jsonaccess-array JSONThing Will Smith))
        (T (error "syntax error"))))

; access to the field attribute
(defun jsonaccess-object (JSONObj Field &optional PositionList)
  (cond ((null JSONObj) nil)
        ((equal (car JSONObj) 'jsonobj) 
         (jsonaccess-object (cdr JSONObj) Field PositionList))
        ((and (equal (car (car JSONObj)) Field)
              (not (null (car PositionList))))
         (jsonaccess-array (car (cdr (car JSONObj)))
                           (car PositionList)
                           (cdr PositionList)))
        ((equal (car (car JSONObj)) Field) (car (cdr (car JSONObj))))
        (T (jsonaccess-object (cdr JSONObj) Field PositionList))))

; access to the element of an array attribute
(defun jsonaccess-array (JSONArray Position &optional PositionList)
  (cond ((null JSONArray) nil)
        ((stringp Position) (jsonaccess-object JSONArray Position PositionList))
        ((or (<= (+ Position 1) 0) (>= (+ Position 1) (length JSONArray)))
         (error "array index out of bound"))
        ((null (car PositionList)) (nth (+ Position 1) JSONArray))
        ((listp (nth (+ Position 1) JSONArray))
         (jsonaccess-array (nth (+ Position 1) JSONArray)
                           (car PositionList)
                           (cdr PositionList)))
        (T (error "syntax error"))))
        
; converts from the parsed element from jsonparse to the normal JSON syntax
(defun jsonreverse (JSONparsed)
  (list-to-string (jsonvalue-reverse JSONparsed)))

; adds brackets and recognize if an element is an object, 
; a list or a value such as boolean, number, string or null
(defun jsonvalue-reverse (JSONparsed)
  (cond ((null JSONparsed) nil)
        ((stringp JSONparsed) (append (list #\") 
                                      (string-to-list JSONparsed) 
                                      (list #\")))
        ((equal JSONparsed 'null) (string-to-list "null"))
        ((equal JSONparsed 'true) (string-to-list "true"))
        ((equal JSONparsed 'false) (string-to-list "false"))
        ((numberp JSONparsed) (string-to-list (write-to-string JSONparsed)))
        ((equal (car JSONparsed) 'jsonarray) 
          (append (list #\[)
                  (clean-array (mapcar 'jsonvalue-reverse (cdr JSONparsed)) nil)
                  (list #\])))
        ((equal (car JSONparsed) 'jsonobj) 
          (append (list #\{)
                  (clean-obj (mapcar 'jsonvalue-reverse (cdr JSONparsed)) nil)
                  (list #\})))
        (T (mapcar 'jsonvalue-reverse JSONparsed))))

; adds #\: #\ #\Space, inside the object
(defun clean-obj (List FixedList)
  (cond ((null List) FixedList)
        ((null FixedList) (clean-obj (cdr List) (fix-pairs (car List))))
        (T (clean-obj (cdr List) (append FixedList (list #\,) 
          (list #\Space) (fix-pairs (car List)))))))

; adds #\: between field and attribute
(defun fix-pairs (List)
  (append (first List) 
          (list #\Space) 
          (list #\:) 
          (list #\Space) 
          (second List)))

; adds #\, #\Space between elements
(defun clean-array (List FixedList)
  (cond ((null List) FixedList)
        ((null FixedList) (clean-array (cdr List) (first List)))
        (T (clean-array (cdr List) (append FixedList (list #\,) 
                                                   (list #\Space) 
                                                   (first List))))))

; element becomes the head element of the list l
(defun insert-element (element l)
  (if (null l)
      (list element)
    (cons (first l) (insert-element element (rest l)))))

; read a JSON file and parse it through the jsonparse func
(defun jsonread (filename)  
  (with-open-file (in filename
                      :direction :input
                      :if-does-not-exist :error)
    (jsonparse (list-to-string (input-load in)))))

(defun input-load (in)
  (if (listen in) (append (list (read-char in)) (input-load in))))

; write on a JSON file a parsed object
(defun jsondump (JSONparse filename)
  (with-open-file (out filename
                      :direction :output
                      :if-exists :supersede
                      :if-does-not-exist :create)
    (format out (jsonreverse JSONparse)) filename))