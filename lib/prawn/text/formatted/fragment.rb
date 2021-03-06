# encoding: utf-8

# text/formatted/fragment.rb : Implements information about a formatted fragment
#
# Copyright March 2010, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  module Text
    module Formatted
      class Fragment

        attr_reader :text, :format_state
        attr_writer :width
        attr_accessor :line_height, :descender, :ascender
        attr_accessor :word_spacing, :left, :baseline

        def initialize(text, format_state, document)
          @text = text
          @format_state = format_state
          @document = document
          @word_spacing = 0
        end

        def width
          if @word_spacing == 0 then @width
          else @width + @word_spacing * @text.count(" ")
          end
        end

        def subscript?
          styles.include?(:subscript)
        end

        def superscript?
          styles.include?(:superscript)
        end

        def y_offset
          if subscript? then -descender
          elsif superscript? then 0.85 * ascender
          else 0
          end
        end

        def height
          descender + ascender
        end          

        def bounding_box
          [left, baseline - descender, left + width, baseline + ascender].extend(ArrayExt)
        end

        def absolute_bounding_box
          box = bounding_box.extend(ArrayExt)
          box[0] += @document.bounds.absolute_left
          box[2] += @document.bounds.absolute_left
          box[1] += @document.bounds.absolute_bottom
          box[3] += @document.bounds.absolute_bottom
          box
        end

        def underline_points
          box = bounding_box
          y = baseline - 1.25
          [[box[0], y], [box[2], y]]
        end

        def strikethrough_points
          box = bounding_box
          y = baseline + ascender * 0.3
          [[box[0], y], [box[2], y]]
        end

        def styles
          @format_state[:styles] || []
        end

        def link
          @format_state[:link]
        end

        def anchor
          @format_state[:anchor]
        end

        def color
          @format_state[:color]
        end

        def fill_color
          @format_state[:fill_color]
        end

        def border_width
          @format_state[:border_width]
        end

        def border_color
          @format_state[:border_color]
        end

        def border_style
          @format_state[:border_style]
        end

        def margin
          @format_state[:margin] || {:left => 0, :right => 0, :top => 0, :bottom => 0}
        end

        def padding
          @format_state[:padding] || {:left => 0, :right => 0, :top => 0, :bottom => 0}
        end

        def font
          @format_state[:font]
        end

        def size
          @format_state[:size]
        end

        def callback_object
          callback[:object]
        end

        def callback_method
          callback[:method]
        end

        def callback_arguments
          callback[:arguments]
        end

        def finished
          if callback_object && callback_method
            if callback_arguments
              callback_object.send(callback_method, self, *callback_arguments)
            else
              callback_object.send(callback_method, self)
            end
          end
        end

        def callback_start_object
          callback[:start_object]
        end

        def callback_start_method
          callback[:start_method]
        end

        def callback_start_arguments
          callback[:start_arguments]
        end

        def started
          if callback_start_object && callback_start_method
            if callback_start_arguments
              callback_start_object.send(callback_start_method, self, *callback_start_arguments)
            else
              callback_start_object.send(callback_start_method, self)
            end
          end
        end
        private

        def callback_start
          @format_state[:callback_start] || {}
        end

        def callback
          @format_state[:callback] || {}
        end
        
      end
    end
  end
end
