# Copyright (c) 2007-2021 Andy Maleh
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'glimmer-dsl-swt'

class HelloCanvasDataBinding
  include Glimmer::GUI::CustomWindow # alias for Glimmer::UI::CustomShell
  
  CANVAS_WIDTH  = 300
  CANVAS_HEIGHT = 300
  
  attr_accessor :x1_value, :y1_value, :x2_value, :y2_value, :foreground_red, :foreground_green, :foreground_blue, :line_width_value, :line_style_value
  
  def foreground_value
    rgb(foreground_red, foreground_green, foreground_blue)
  end
  
  def line_style_value_options
    [:solid, :dash, :dot, :dashdot, :dashdotdot]
  end
  
  before_body {
    self.x1_value = 0
    self.y1_value = 0
    self.x2_value = CANVAS_WIDTH
    self.y2_value = CANVAS_HEIGHT
    self.foreground_red = 28
    self.foreground_green = 128
    self.foreground_blue = 228
    self.line_width_value = 3
    self.line_style_value = :dot
  }
  
  body {
    shell {
      text 'Hello, Canvas Data-Binding!'
      
      tab_folder {
        tab_item {
          grid_layout(6, true) {
            margin_width 0
            margin_height 0
            horizontal_spacing 0
            vertical_spacing 0
          }
          text 'line'
          
          label {
            layout_data(:fill, :center, false, false) {
              horizontal_span 3
            }
            text 'x1'
          }
          label {
            layout_data(:fill, :center, false, false) {
              horizontal_span 3
            }
            text 'y1'
          }
          spinner {
            layout_data(:fill, :center, false, false) {
              horizontal_span 3
            }
            maximum CANVAS_WIDTH
            increment 3
            selection <=> [self, :x1_value]
          }
          spinner {
            layout_data(:fill, :center, false, false) {
              horizontal_span 3
            }
            maximum CANVAS_HEIGHT
            increment 3
            selection <=> [self, :y1_value]
          }
          label {
            layout_data(:fill, :center, false, false) {
              horizontal_span 3
            }
            text 'x2'
          }
          label {
            layout_data(:fill, :center, false, false) {
              horizontal_span 3
            }
            text 'y2'
          }
          spinner {
            layout_data(:fill, :center, false, false) {
              horizontal_span 3
            }
            maximum CANVAS_WIDTH
            increment 3
            selection <=> [self, :x2_value]
          }
          spinner {
            layout_data(:fill, :center, false, false) {
              horizontal_span 3
            }
            maximum CANVAS_HEIGHT
            increment 3
            selection <=> [self, :y2_value]
          }
          label {
            layout_data(:fill, :center, false, false) {
              horizontal_span 2
            }
            text 'foreground red'
          }
          label {
            layout_data(:fill, :center, false, false) {
              horizontal_span 2
            }
            text 'foreground green'
          }
          label {
            layout_data(:fill, :center, false, false) {
              horizontal_span 2
            }
            text 'foreground blue'
          }
          spinner {
            layout_data(:fill, :center, false, false) {
              horizontal_span 2
            }
            maximum 255
            increment 10
            selection <=> [self, :foreground_red]
          }
          spinner {
            layout_data(:fill, :center, false, false) {
              horizontal_span 2
            }
            maximum 255
            increment 10
            selection <=> [self, :foreground_green]
          }
          spinner {
            layout_data(:fill, :center, false, false) {
              horizontal_span 2
            }
            maximum 255
            increment 10
            selection <=> [self, :foreground_blue]
          }
          label {
            layout_data(:fill, :center, false, false) {
              horizontal_span 3
            }
            text 'line width'
          }
          label {
            layout_data(:fill, :center, false, false) {
              horizontal_span 3
            }
            text 'line style'
          }
          spinner {
            layout_data(:fill, :center, false, false) {
              horizontal_span 3
            }
            maximum 255
            selection <=> [self, :line_width_value]
          }
          combo(:read_only) {
            layout_data(:fill, :center, false, false) {
              horizontal_span 3
            }
            selection <=> [self, :line_style_value]
          }
          canvas {
            layout_data(:center, :center, false, false) {
              horizontal_span 6
              width_hint CANVAS_WIDTH
              height_hint CANVAS_WIDTH
            }
            background :white
            
            line {
              x1 <=> [self, :x1_value]
              y1 <=> [self, :y1_value]
              x2 <=> [self, :x2_value]
              y2 <=> [self, :y2_value]
              foreground <=> [self, :foreground_value, computed_by: [:foreground_red, :foreground_green, :foreground_blue]]
              line_width <=> [self, :line_width_value]
              line_style <=> [self, :line_style_value]
            }
          }
        }
      }
    }
  }
  
end

HelloCanvasDataBinding.launch
