module Memo
  VERSION = '0.1.0'
  module It
    def memo(&block)
      keys = block.source_location
      keys << block.binding.local_variables.map { |name| [name, block.binding.local_variable_get(name).to_s] }

      @_memo_it ||= {}
      @_memo_it[keys] if @_memo_it.key? keys
      @_memo_it[keys] = yield
    end
  end
end

Object.include Memo::It
