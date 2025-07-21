((function_declaration
   name: (identifier) @section.name
   ) @section
 (#set! type "function")
 )

((assignment_statement
   ( variable_list
     name: (identifier) @section.name
     )
   (
    (expression_list
      value: (function_definition)
      )
    )
   ) @section
   (#set! type "function")
 )

