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

require 'glimmer/swt/custom/drawable'
require 'glimmer/swt/properties'

module Glimmer
  module SWT
    # Proxy for org.eclipse.swt.graphics.Image
    #
    # Invoking `#swt_image` returns the SWT Image object wrapped by this proxy
    #
    # Follows the Proxy Design Pattern
    class ImageProxy
      include Custom::Drawable
      include Properties
            
      class << self
        include_package 'org.eclipse.swt.graphics'
        
        def create(*args, &content)
          if args.size == 1 && args.first.is_a?(ImageProxy)
            args.first
          else
            new(*args, &content)
          end
        end
        
        def create_pixel_by_pixel(*args, &each_pixel_color)
          image_proxy = create(*args)
          options = args.last.is_a?(Hash) ? args.pop : {}
          height = args[-1]
          width = args[-2]
          image_proxy.paint_pixel_by_pixel(width, height, &each_pixel_color)
          image_proxy
        end
      end
      
      include_package 'org.eclipse.swt.widgets'
      include_package 'org.eclipse.swt.graphics'
      
      attr_reader :file_path, :jar_file_path, :image_data, :swt_image
      
      # Initializes a proxy for an SWT Image object
      #
      # Takes the same args as the SWT Image class
      # Alternatively, takes a file path string or a uri:classloader file path string (generated by JRuby when invoking `File.expand_path` inside a JAR file)
      # and returns an image object.
      # Last but not least, it could serve as a parent for nesting shapes underneath to build an image with the Canvas Shape DSL
      def initialize(*args, &content)
        @args = args
        @parent_proxy = nil
        if @args.first.is_a?(WidgetProxy)
          @parent_proxy = @args.shift
          @parent = @parent_proxy.swt_widget
        end
        options = @args.last.is_a?(Hash) ? @args.delete_at(-1) : {}
        options[:swt_image] = @args.first if @args.size == 1 && @args.first.is_a?(Image)
        @file_path = @args.first if @args.first.is_a?(String)
        @args = @args.first if @args.size == 1 && @args.first.is_a?(Array)
        if options&.keys&.include?(:swt_image)
          @swt_image = options[:swt_image]
          @original_image_data = @image_data = @swt_image.image_data
        elsif args.size == 1 && args.first.is_a?(ImageProxy)
          @swt_image = @args.first.swt_image
          @original_image_data = @image_data = @swt_image.image_data
        elsif @file_path
          @original_image_data = @image_data = ImageData.new(input_stream || @file_path)
          @swt_image = Image.new(DisplayProxy.instance.swt_display, @image_data)
          width = options[:width]
          height = options[:height]
          height = (@image_data.height.to_f / @image_data.width.to_f)*width.to_f if !width.nil? && height.nil?
          width = (@image_data.width.to_f / @image_data.height.to_f)*height.to_f if !height.nil? && width.nil?
          scale_to(width, height) unless width.nil? || height.nil?
        elsif !@args.first.is_a?(ImageProxy) && !@args.first.is_a?(Image)
          @args.prepend(DisplayProxy.instance.swt_display) unless @args.first.is_a?(Display)
          @swt_image = Image.new(*@args)
          @original_image_data = @image_data = @swt_image.image_data
        end
        proxy = self
        # TODO consider adding a get_data/set_data method to conform with other SWT widgets
        @swt_image.singleton_class.define_method(:dispose) do
          proxy.clear_shapes
          super()
        end
        post_add_content if content.nil?
      end
      
      def post_add_content
        if shapes.any?
          setup_shape_painting
        end
        if @parent.respond_to?('image=') && !@parent.is_disposed
          @parent&.image = swt_image
        end
      end
      
      def shape(parent_proxy = nil, args = nil)
        parent_proxy ||= @parent_proxy
        args ||= [self] # TODO consider passing args if available
        @shape ||= Glimmer::SWT::Custom::Shape.new(parent_proxy, 'image', *args)
      end
      
      def input_stream
        if @file_path.start_with?('uri:classloader')
          @jar_file_path = @file_path
          file_path = @jar_file_path.sub(/^uri\:classloader\:/, '').sub('//', '/') # the latter sub is needed for Mac
          object = java.lang.Object.new
          file_input_stream = object.java_class.resource_as_stream(file_path)
        else
          file_input_stream = java.io.FileInputStream.new(@file_path)
        end
        java.io.BufferedInputStream.new(file_input_stream) if file_input_stream
      end

      def scale_to(width, height)
        return self if @image_data.width == width && @image_data.height == height
        scaled_image_data = @original_image_data.scaledTo(width, height)
        device = swt_image.device
        swt_image.dispose
        @swt_image = Image.new(device, scaled_image_data)
        @image_data = @swt_image.image_data
        self
      end
      
      def gc
        @gc ||= reset_gc
      end
      
      def reset_gc
        @gc = org.eclipse.swt.graphics.GC.new(swt_image)
      end
      
      def disposed?
        @swt_image.isDisposed
      end
      
      def has_attribute?(attribute_name, *args)
        @swt_image.respond_to?(attribute_setter(attribute_name), args) || respond_to?(ruby_attribute_setter(attribute_name), args)
      end

      def set_attribute(attribute_name, *args)
        # TODO consider refactoring/unifying this code with WidgetProxy and elsewhere
        if args.count == 1
          if args.first.is_a?(Symbol) || args.first.is_a?(String)
            args[0] = ColorProxy.new(args.first).swt_color
          end
          if args.first.is_a?(ColorProxy)
            args[0] = args.first.swt_color
          end
        end

        if @swt_image.respond_to?(attribute_setter(attribute_name))
          @swt_image.send(attribute_setter(attribute_name), *args) unless @swt_image.send(attribute_getter(attribute_name)) == args.first
        elsif @swt_image.respond_to?(ruby_attribute_setter(attribute_name))
          @swt_image.send(ruby_attribute_setter(attribute_name), args)
        else
          send(ruby_attribute_setter(attribute_name), args)
        end
      end

      def get_attribute(attribute_name)
        if @swt_image.respond_to?(attribute_getter(attribute_name))
          @swt_image.send(attribute_getter(attribute_name))
        elsif @swt_image.respond_to?(ruby_attribute_getter(attribute_name))
          @swt_image.send(ruby_attribute_getter(attribute_name))
        elsif @swt_image.respond_to?(attribute_name)
          @swt_image.send(attribute_name)
        elsif respond_to?(ruby_attribute_getter(attribute_name))
          send(ruby_attribute_getter(attribute_name))
        else
          send(attribute_name)
        end
      end
      
      def method_missing(method, *args, &block)
        swt_image.send(method, *args, &block)
      rescue => e
        Glimmer::Config.logger.debug {"Neither ImageProxy nor #{swt_image.class.name} can handle the method ##{method}"}
        super
      end
      
      def respond_to?(method, *args, &block)
        super || swt_image.respond_to?(method, *args, &block)
      end
    end
  end
end
