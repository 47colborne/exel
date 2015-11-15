require_relative './ast_node'

module EXEL
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
