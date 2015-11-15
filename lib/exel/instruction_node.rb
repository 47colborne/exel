require_relative './ast_node'

module EXEL
  class InstructionNode < ASTNode
    def run(context)
      @instruction.execute(context)
    end
  end
end
