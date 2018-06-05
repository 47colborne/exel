# frozen_string_literal: true

require_relative './ast_node'

module EXEL
  # A node in the AST that has as its children a sequence of nodes to be run sequentially
  class SequenceNode < ASTNode
    def initialize(*children)
      @instruction = NullInstruction.new
      @children = children
    end

    def run(context)
      @children.each { |child| child.run(context) }
    end
  end
end
