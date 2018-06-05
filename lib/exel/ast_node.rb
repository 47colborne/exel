# frozen_string_literal: true

module EXEL
  # An abstract class that serves as the parent class of nodes in the AST
  class ASTNode
    attr_reader :instruction, :children

    def initialize(instruction, children: [])
      @instruction = instruction
      @children = children
    end

    def start(context)
      run(context)
    rescue EXEL::Error::JobTermination => e
      EXEL.logger.send(e.cmd, "JobTerminationError: #{e.message.chomp}")
    end

    def run(_context)
      raise "#{self.class} does not implement #process"
    end

    def add_child(node)
      @children << node
    end
  end
end
