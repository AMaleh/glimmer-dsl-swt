require 'glimmer-dsl-swt'

include Glimmer

class HelloCanvasTransform
  include Glimmer::UI::CustomShell

  attr_accessor :scale_value
  
  before_body {
    @glimmer_logo = File.expand_path('../../icons/scaffold_app.png', __dir__)
    @scale_value = 0.21
  }
  
  body {
    shell {
      grid_layout(1, true) {
        margin_width 0
        margin_height 0
      }
      text 'Hello, Canvas Transform!'
      minimum_size 330, 352

      label(:center) {
        layout_data :fill, :false, true, false
        text <= [self, :scale_value]
      }
      scale {
        layout_data :fill, :false, true, false
        minimum 0
        maximum 100
        selection <=> [self, :scale_value, on_write: -> (v) {v / 100.0}, on_read: -> (v) {v * 100.0}]
      }
                  
      canvas {
        layout_data :fill, :fill, true, true
        background :white
    
        image(@glimmer_logo, 0, 0) {
          transform {
            translation 110, 110
            rotation 90
            scale <= [self, :scale_value, on_read: -> (v) {[v, v]}]
            # also supports inversion, identity, shear, and multiplication {transform properties}
          }
        }
        image(@glimmer_logo, 0, 0) {
          transform {
            translation 110, 220
            scale 0.21, 0.21
          }
        }
        image(@glimmer_logo, 0, 0) {
          transform {
            translation 220, 220
            rotation 270
            scale 0.21, 0.21
          }
        }
        image(@glimmer_logo, 0, 0) {
          transform {
            translation 220, 110
            rotation 180
            scale 0.21, 0.21
          }
        }
      }
    }
  }
end

HelloCanvasTransform.launch
