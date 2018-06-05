# frozen_string_literal: true

require_relative './ast_node'

module EXEL
  # A leaf node in the AST that contains an instruction ({Instruction}, {ListenInstruction}) to be executed
  class InstructionNode < ASTNode
    def run(context)
      @instruction.execute(context)
    end
  end
end
