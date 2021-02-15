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

class HelloCursor
  include Glimmer::UI::CustomShell
  
  attr_accessor :selected_cursor
  
  def selected_cursor_options
    org.eclipse.swt.SWT.constants.select {|c| c.to_s.start_with?('CURSOR_')}.map {|c| c.to_s.sub('CURSOR_', '').downcase}
  end
  
  after_body {
    observe(self, :selected_cursor) {
      body_root.cursor = selected_cursor
    }
  }
  
  body {
    shell {
      grid_layout
      
      text 'Hello, Cursor!'
      cursor :wait
      
      label {
        text 'Please select a cursor style and see it change the mouse cursor (varies per platform):'
        font style: :bold
        cursor :no
      }
      radio_group {
        grid_layout 5, true
        selection bind(self, :selected_cursor)
      }
    }
  }
end

HelloCursor.launch
