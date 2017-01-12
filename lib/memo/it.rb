module Memo
  VERSION = '0.1.2'
  module It
    def memo(ignore: [], &block)
      keys = block.source_location
      ignore = Array(ignore)
      keys << block.binding.local_variables.map do |name|
        next if ignore.include?(name)
        [name, block.binding.local_variable_get(name)]
      end
      keys = keys.flatten.map(&:to_s)

      @_memo_it ||= {}
      return @_memo_it[keys] if @_memo_it.key? keys
      @_memo_it[keys] = yield
    end
  end
end

Object.include Memo::It
