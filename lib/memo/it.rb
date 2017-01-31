module Memo
  VERSION = '0.3.1'

  @enabled = true

  def self.enabled?
    @enabled
  end

  def self.enable
    @enabled = true
  end

  def self.disable
    @enabled = false
  end

  module It
    def memo(only: [], except: [], &block)
      only = Array(only)
      if only.empty?
        except = Array(except)
        key_names = block.binding.local_variables
        key_names -= except unless except.empty?
      else
        key_names = only
      end

      keys = block.source_location
      keys << key_names.flat_map { |name| [name, block.binding.local_variable_get(name)] }

      @_memo_it ||= {}
      return @_memo_it[keys] if Memo.enabled? && @_memo_it.key?(keys)
      @_memo_it[keys] = yield
    end
  end
end

Object.include Memo::It
