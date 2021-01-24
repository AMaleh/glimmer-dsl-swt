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

require_relative 'block'

require 'matrix'

class Tetris
  module Model
    class Tetromino
      ORIENTATIONS = [:north, :east, :south, :west]
      
      LETTER_COLORS = {
        I: :cyan,
        J: :blue,
        L: :dark_yellow,
        O: :yellow,
        S: :green,
        T: :magenta,
        Z: :red,
      }
      
      attr_reader :letter, :preview
      alias preview? preview
      attr_accessor :orientation, :blocks, :row, :column
      
      def initialize
        @letter = LETTER_COLORS.keys.sample
        @orientation = :north
        @blocks = default_blocks
        @preview = true
        new_row = 0
        new_column = 0
        update_playfield(new_row, new_column)
      end
      
      def playfield
        @preview ? Game.preview_playfield : Game.playfield
      end
      
      def launch!
        remove_from_playfield
        @preview = false
        new_row = 1 - height
        new_column = (PLAYFIELD_WIDTH - width)/2
        update_playfield(new_row, new_column)
        Game.tetrominoes << self
      end
      
      def update_playfield(new_row = nil, new_column = nil)
        # TODO consider using an observer instead
        remove_from_playfield
        if !new_row.nil? && !new_column.nil?
          @row = new_row
          @column = new_column
          add_to_playfield
        end
      end
      
      def add_to_playfield
        update_playfield_block do |playfield_row, playfield_column, row_index, column_index|
          playfield[playfield_row][playfield_column].color = blocks[row_index][column_index].color if playfield_row >= 0 && playfield[playfield_row][playfield_column]&.clear? && !blocks[row_index][column_index].clear?
        end
      end
      
      def remove_from_playfield
        return if @row.nil? || @column.nil?
        update_playfield_block do |playfield_row, playfield_column, row_index, column_index|
          playfield[playfield_row][playfield_column].clear if playfield_row >= 0 && !blocks[row_index][column_index].clear? && playfield[playfield_row][playfield_column]&.color == color
        end
      end
      
      def stopped?
        return true if @stopped || @preview
        # TODO add time delay for when stopped? status sticks so user can move block left and right still for a short period of time
        playfield_remaining_heights = Game.playfield_remaining_heights(self)
        result = bottom_most_blocks.any? do |bottom_most_block|
          playfield_column = @column + bottom_most_block[:column_index]
          !bottom_most_block[:block].clear? &&
            playfield_remaining_heights[playfield_column] &&
            @row + bottom_most_block[:row] >= playfield_remaining_heights[playfield_column] - 1
        end
        # TODO consider using an observer instead for when a move is made
        if result && !Game.hypothetical?
          @stopped = result
          Game.consider_eliminating_lines
          Model::Game.consider_adding_tetromino
        end
        result
      end
      
      # Returns bottom-most blocks of a tetromino, which could be from multiple rows depending on shape (e.g. T)
      def bottom_most_blocks
        width.times.map do |column_index|
          row_blocks_with_row_index = @blocks.each_with_index.to_a.reverse.detect do |row_blocks, row_index|
            !row_blocks[column_index].clear?
          end
          bottom_most_block = row_blocks_with_row_index[0][column_index]
          bottom_most_block_row = row_blocks_with_row_index[1]
          {
            block: bottom_most_block,
            row: bottom_most_block_row,
            column_index: column_index
          }
        end
      end
      
      def bottom_most_block_for_column(column)
        bottom_most_blocks.detect {|bottom_most_block| (@column + bottom_most_block[:column_index]) == column}
      end
      
      def right_blocked?
        # TODO do a more elaborate right blocks check (just like bottom blocks)
        # TODO check it is not an existing block location if it is a rotation
        (@column == PLAYFIELD_WIDTH - width) || playfield[row][column + width].occupied?
      end
      
      # Returns right-most blocks of a tetromino, which could be from multiple columns depending on shape (e.g. T)
      # TODO
#       def right_most_blocks(blocks = nil)
#         width.times.map do |column_index|
#           row_blocks_with_row_index = @blocks.each_with_index.to_a.reverse.detect do |row_blocks, row_index|
#             !row_blocks[column_index].clear?
#           end
#           bottom_most_block = row_blocks_with_row_index[0][column_index]
#           bottom_most_block_row = row_blocks_with_row_index[1]
#           {
#             block: bottom_most_block,
#             row: bottom_most_block_row,
#             column_index: column_index
#           }
#         end
#       end
      
      def left_blocked?
        # TODO do a more elaborate left blocks check (just like bottom blocks)
        # TODO check it is not an existing block location if it is a rotation
        (@column == 0) || playfield[row][column - 1].occupied?
      end
      
      def width
         # TODO update row and/or column based on rotation, recentering the tetromino
        @blocks[0].size
      end
      
      def height
        @blocks.size
      end
      
      def down
        launch! if preview?
        unless stopped?
          new_row = @row + 1
          update_playfield(new_row, @column)
        end
      end
      
      def left
        unless left_blocked?
          new_column = @column - 1
          update_playfield(@row, new_column)
        end
      end
      
      def right
        unless right_blocked?
          new_column = @column + 1
          update_playfield(@row, new_column)
        end
      end
      
      # Rotate in specified direcation, which can be :right (clockwise) or :left (counterclockwise)
      def rotate(direction)
        return if stopped?
        can_rotate = nil
        new_blocks = nil
        Game.hypothetical do
          hypothetical_rotated_tetromino = hypothetical_tetromino
          new_blocks = hypothetical_rotated_tetromino.rotate_blocks(direction)
          can_rotate = !hypothetical_rotated_tetromino.stopped? && !hypothetical_rotated_tetromino.right_blocked? && !hypothetical_rotated_tetromino.left_blocked?
        end
        if can_rotate
          remove_from_playfield
          self.orientation = ORIENTATIONS[ORIENTATIONS.rotate(direction == :right ? -1 : 1).index(@orientation)]
          self.blocks = new_blocks
          update_playfield(@row, @column)
        end
      rescue => e
        puts e.full_message
      end
      
      def rotate_blocks(direction)
          new_blocks = Matrix[*@blocks].transpose.to_a
          if direction == :right
            new_blocks = new_blocks.map(&:reverse)
          else
            new_blocks = new_blocks.reverse
          end
          Matrix[*new_blocks].to_a
      end
      
      def hypothetical_tetromino
        clone.tap do |hypo_clone|
          remove_from_playfield
          hypo_clone.blocks = @blocks.map do |row_blocks|
            row_blocks.map do |column_block|
              column_block.clone
            end
          end
        end
      end
      
      def default_blocks
        case @letter
        when :I
          [
            [block, block, block, block]
          ]
        when :J
          [
            [block, block, block],
            [empty, empty, block],
          ]
        when :L
          [
            [block, block, block],
            [block, empty, empty],
          ]
        when :O
          [
            [block, block],
            [block, block],
          ]
        when :S
          [
            [empty, block, block],
            [block, block, empty],
          ]
        when :T
          [
            [block, block, block],
            [empty, block, empty],
          ]
        when :Z
          [
            [block, block, empty],
            [empty, block, block],
          ]
        end
      end
      
      def color
        LETTER_COLORS[@letter]
      end
      
      def include_block?(block)
        @blocks.flatten.include?(block)
      end
      
      private
      
      def block
        Block.new(color)
      end
      
      def empty
        Block.new
      end
      
      def update_playfield_block(&updater)
        @row.upto(@row + height - 1) do |playfield_row|
          @column.upto(@column + width - 1) do |playfield_column|
            row_index = playfield_row - @row
            column_index = playfield_column - @column
            updater.call(playfield_row, playfield_column, row_index, column_index)
          end
        end
      end
    end
  end
end
