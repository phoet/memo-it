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
  end
end
