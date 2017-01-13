module Memo
  VERSION = '0.2.0'
  module It
    def memo(only: [], ignore: [], &block)
      only = Array(only)
      if only.empty?
        ignore = Array(ignore)
        key_names = block.binding.local_variables
        key_names -= ignore unless ignore.empty?
      else
        key_names = only
      end

      keys = block.source_location
      keys << key_names.map { |name| [name, block.binding.local_variable_get(name)] }
      keys = keys.flatten.map(&:to_s)

      @_memo_it ||= {}
      return @_memo_it[keys] if @_memo_it.key? keys
      @_memo_it[keys] = yield
    end
  end
end

Object.include Memo::It
