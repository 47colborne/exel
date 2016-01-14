module EXEL
  module Job
    class << self
      def define(job_name, &block)
        fail "Job #{job_name.inspect} is already defined" unless registry[job_name].nil?
        registry[job_name] = block
      end

      def registry
        @registry ||= {}
      end

      def run(dsl_code_or_name, context = {})
        context = EXEL::Context.new(context) if context.is_a?(Hash)
        (ast = parse(dsl_code_or_name)) ? ast.start(context) : fail(%(Job "#{dsl_code_or_name}" not found))
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
        add_instruction_node('process', processor_class, block, options)
      end

      def async(options = {}, &block)
        add_instruction_node('async', Processors::AsyncProcessor, block, options)
      end

      def split(options = {}, &block)
        add_instruction_node('split', Processors::SplitProcessor, block, options)
      end

      def run(options = {}, &block)
        add_instruction_node('run', Processors::RunProcessor, block, options)
      end

      def context
        DeferredContextValue.new
      end

      private

      def add_instruction_node(name, processor, block, args = {})
        sub_tree = block.nil? ? nil : Parser.parse(block)
        instruction = EXEL::Instruction.new(name, processor, args, sub_tree)
        node = sub_tree.nil? ? InstructionNode.new(instruction) : InstructionNode.new(instruction, [sub_tree])
        @ast.add_child(node)
      end
    end
  end
end
