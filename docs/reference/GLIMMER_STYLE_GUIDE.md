## Glimmer Style Guide

- Widgets are declared with underscored lowercase versions of their SWT names minus the SWT package name.
- Widget declarations may optionally have arguments and be followed by a block (to contain properties and content)
- Widget blocks are always declared with curly braces
- Widget arguments are always wrapped inside parentheses
- Widget properties are declared with underscored lowercase versions of the SWT properties
- Widget property declarations always have arguments and never take a block
- Widget property arguments are never wrapped inside parentheses
- Widget listeners are always declared starting with `on_` prefix and affixing listener event method name afterwards in underscored lowercase form. Their multi-line blocks rely on the `do; end` style.
- Widget listeners are always followed by a block using curly braces (Only when declared in DSL. When invoked on widget object directly outside of GUI declarations, standard Ruby conventions apply)
- Data-binding is done via `bind` keyword, which always takes arguments wrapped in parentheses
- Custom widget `body`, `before_body`, and `after_body` blocks open their blocks and close them with curly braces.
- Custom widgets receive additional keyword arguments called options, which come after the SWT styles.
- Pure logic multi-line blocks that do not constitute GUI DSL view elements (such as `Thread.new`, `loop`, `each` and `observe` blocks) rely on the `do; end` style to clearly separate logic code from view code.
