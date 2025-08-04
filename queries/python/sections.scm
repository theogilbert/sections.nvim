(
  (function_definition
    name: (identifier) @section.name
    parameters: (parameters
      [
        (identifier) @section.param
        (typed_parameter (identifier) @section.param)
        (default_parameter name: (identifier) @section.param)
        (typed_default_parameter name: (identifier) @section.param)
      ]
    )?
  ) @section
  (#set! type "function")
)


(
  (class_definition
    name: (identifier) @section.name
    superclasses: (argument_list (identifier) @section.param)*
  ) @section
  (#set! type "class")
)
