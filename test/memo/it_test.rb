require 'test_helper'

module Memo
  class ItTest < Minitest::Test
    def setup
      @mock = MiniTest::Mock.new
    end

    def test_memoizes_stuff
      @mock.expect(:slow, :stuff)
      10.times { assert memo_without_parameters == :stuff }
      @mock.verify
    end

    def test_memoizes_nil
      @mock.expect(:slow, nil)
      10.times { assert memo_without_parameters.nil? }
      @mock.verify
    end

    def test_memoizes_stuff_with_parameters
      @mock.expect(:slow, :stuff12, [1, 2])
      10.times { assert memo_with_parameters == :stuff12 }
      @mock.expect(:slow, :stuff34, [3, 4])
      10.times { assert memo_with_parameters(3, 4) == :stuff34 }
      @mock.verify
    end

    def test_memoizes_without_leaking
      10.times do |i|
        j = rand
        ret_val = :"stuff#{i}#{j}"
        @mock.expect(:slow, ret_val, [i, j])
        10.times { assert memo_with_parameters(i, j) == ret_val }
      end
      @mock.verify
    end

    def test_memoizes_without_single_ignored_variable
      @mock.expect(:slow, :stuff12, [1, 2])
      10.times { assert memo_with_single_ignored_parameter(1,2) == :stuff12 }

      # does not call the block if ignored parameter is changed
      10.times { assert memo_with_single_ignored_parameter(3,2) == :stuff12 }

      # but calls the block if not-ignored parameters is changed
      @mock.expect(:slow, :stuff14, [1, 4])
      10.times { assert memo_with_single_ignored_parameter(1,4) == :stuff14 }

      @mock.verify
    end

    def test_memoizes_without_multiple_ignored_variables
      @mock.expect(:slow, :stuff123, [1, 2, 3])
      10.times { assert memo_with_multiple_ignored_parameters(1,2,3) == :stuff123 }

      # does not call the block if first ignored parameter is changed
      10.times { assert memo_with_multiple_ignored_parameters(4,2,3) == :stuff123 }

      # does not call the block if second ignored parameter is changed
      10.times { assert memo_with_multiple_ignored_parameters(1,2,4) == :stuff123 }

      # but calls the block if not-ignored parameters is changed
      @mock.expect(:slow, :stuff143, [1, 4, 3])
      10.times { assert memo_with_multiple_ignored_parameters(1,4, 3) == :stuff143 }

      @mock.verify
    end

    private

    def memo_without_parameters
      memo do
        @mock.slow
      end
    end

    def memo_with_parameters(some = 1, parameters = 2)
      memo do
        @mock.slow(some, parameters)
      end
    end

    def memo_with_single_ignored_parameter(some = 1, parameters = 2)
      memo(ignore: :some) do
        @mock.slow(some, parameters)
      end
    end

    def memo_with_multiple_ignored_parameters(some = 1, more = 2, parameters = 3)
      memo(ignore: [:some, :parameters]) do
        @mock.slow(some, more, parameters)
      end
    end
  end
end
