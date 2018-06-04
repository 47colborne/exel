# frozen_string_literal: true
module EXEL
  # The +Job+ module provides the main interface for defining and running EXEL jobs
  module Job
    class << self
      # Registers a new job
      #
      # @param job_name [Symbol] A symbol to set as the name of this job. Used to run it later.
      # @param block A block of code that calls the EXEL DSL methods
      def define(job_name, &block)
        raise "Job #{job_name.inspect} is already defined" unless registry[job_name].nil?
        registry[job_name] = block
      end

      # @return [Hash] A hash of all the defined jobs
      def registry
        @registry ||= {}
      end

      # If given a symbol as the first parameter, it attempts to run a previously registered job using that name.
      # Alternatively, a string of code can be passed to be parsed and run directly.
      #
      # @param dsl_code_or_name [String, Symbol] As a symbol, the name of a registered job. As a string, the EXEL code
      #   to be run.
      # @param context [Context, Hash] (Optional) The initial {Context} to be passed to the job.
      # @raise If no job has been registered with the given name
      def run(dsl_code_or_name, context = {})
        context = EXEL::Context.new(context) if context.instance_of?(Hash)
        (ast = parse(dsl_code_or_name)) ? ast.start(context) : raise(%(Job "#{dsl_code_or_name}" not found))
        context
      end

      private

      def parse(dsl_code_or_name)
        if dsl_code_or_name.is_a?(Symbol)
          job = registry[dsl_code_or_name]
          Parser.parse(job) if job
        else
          Parser.parse(dsl_code_or_name)
        end
      end
    end

    # Defines the EXEL DSL methods and is used to convert a block of Ruby code into an abstract syntax tree (AST)
    class Parser
      attr_reader :ast

      def initialize
        @ast = SequenceNode.new
      end

      def self.parse(dsl_proc_or_code)
        parser = Parser.new
        if dsl_proc_or_code.is_a?(::Proc)
          parser.instance_eval(&dsl_proc_or_code)
        else
          parser.instance_eval(dsl_proc_or_code)
        end
        parser.ast
      end

      def process(options, &block)
        processor_class = options.delete(:with)
        add_instruction_node(processor_class, parse(block), options)
      end

      def async(options = {}, &block)
        add_instruction_node(Processors::AsyncProcessor, parse(block), options)
      end

      def split(options = {}, &block)
        add_instruction_node(Processors::SplitProcessor, parse(block), options)
      end

      def run(options = {}, &block)
        add_instruction_node(Processors::RunProcessor, parse(block), options)
      end

      def listen(options)
        instruction = ListenInstruction.new(options.fetch(:for), options.fetch(:with))
        @ast.add_child(InstructionNode.new(instruction))
      end

      def context
        DeferredContextValue.new
      end

      private

      def parse(block)
        block.nil? ? nil : Parser.parse(block)
      end

      def add_instruction_node(processor, sub_tree, args = {})
        instruction = EXEL::Instruction.new(processor, args, sub_tree)
        node = sub_tree.nil? ? InstructionNode.new(instruction) : InstructionNode.new(instruction, [sub_tree])
        @ast.add_child(node)
      end
    end
  end
end
