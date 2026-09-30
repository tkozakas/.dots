# frozen_string_literal: true

require "ruby_lsp/addon"

module RubyLsp
  module FastReferences
    # ruby-lsp parses every workspace file per references request; only files
    # containing the target's identifier as a word can hold a reference.
    module Candidates
      def self.for(workspace_path, name)
        word = name.split("::").last.to_s.delete_prefix("@").sub(/[=?!]\z/, "")
        return unless word.match?(/\A\w+\z/)

        out = IO.popen(
          ["rg", "--files-with-matches", "--fixed-strings", "--word-regexp", "--no-ignore",
           "--glob", "*.rb", "--", word, workspace_path],
          err: File::NULL,
          &:read
        )
        out.lines(chomp: true) if $?.exitstatus <= 1
      rescue SystemCallError
        nil
      end
    end

    module ReferencesPatch
      private

      def create_reference_target(target_node, node_context)
        target = super
        if target
          Thread.current[:fast_references] = {
            pattern: File.join(@global_state.workspace_path, "**/*.rb"),
            files: Candidates.for(@global_state.workspace_path, target_name(target)),
          }
        end
        target
      end

      def target_name(target)
        case target
        when RubyIndexer::ReferenceFinder::ConstTarget then target.fully_qualified_name
        when RubyIndexer::ReferenceFinder::MethodTarget then target.method_name
        else target.name
        end
      end

      public

      def perform
        super
      ensure
        Thread.current[:fast_references] = nil
      end
    end

    module GlobPatch
      def glob(pattern, *args, **kwargs, &block)
        scope = Thread.current[:fast_references]
        return super unless scope && scope[:files] && pattern == scope[:pattern] && args.empty? && kwargs.empty?

        block ? scope[:files].each(&block) : scope[:files]
      end
    end

    class Addon < ::RubyLsp::Addon
      def activate(_global_state, _outgoing_queue)
        Requests::References.prepend(ReferencesPatch)
        Dir.singleton_class.prepend(GlobPatch)
      end

      def deactivate; end

      def name
        "Fast References"
      end

      def version
        "0.1.0"
      end
    end
  end
end
