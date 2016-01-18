require_relative './ast_node'

module EXEL
  # A leaf node in the AST that contains an {Instruction} to be executed
  class InstructionNode < ASTNode
    def run(context)
      @instruction.execute(context)
    end
  end
end
