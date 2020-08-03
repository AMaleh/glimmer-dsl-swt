require 'glimmer/launcher'
require Glimmer::Launcher.swt_jar_file
require 'glimmer/dsl/engine'
Dir[File.expand_path('../*_expression.rb', __FILE__)].each {|f| require f}

# Glimmer DSL expression configuration module
#
# When DSL engine interprets an expression, it attempts to handle
# with expressions listed here in the order specified.

# Every expression has a corresponding Expression subclass
# in glimmer/dsl

module Glimmer
  module DSL
    module SWT
      Engine.add_dynamic_expressions(
        SWT,
        %w[
          layout
          widget_listener
          combo_selection_data_binding
          list_selection_data_binding
          tree_items_data_binding
          table_items_data_binding
          data_binding
          font
          property
          block_property
          widget
          custom_widget
        ]
      )
    end
  end
end
