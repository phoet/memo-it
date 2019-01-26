require 'test_helper'

module Memo
  class ItTest < Minitest::Test
    def setup
      @mock = MiniTest::Mock.new
    end

    def test_disabling
      assert Memo.enabled?
      Memo.disable
      refute Memo.enabled?
    ensure
      Memo.enable
    end

    def test_no_memoization_when_disabled
      Memo.disable
      10.times { @mock.expect(:slow, :stuff) }
      10.times { assert memo_without_parameters == :stuff }
      @mock.verify
    ensure
      Memo.enable
    end

    def test_memoizes_stuff
      @mock.expect(:slow, :stuff)
      10.times { assert memo_without_parameters == :stuff }
      @mock.verify
    end

    def test_memoizes_stuff_on_class_level
      @mock.expect(:slow, :stuff)
      10.times { assert Memoizer.new(@mock).memo_without_parameters_on_class_level == :stuff }
      @mock.verify
    end

    def test_memoizes_stuff_on_instance_level
      10.times { @mock.expect(:slow, :stuff) }
      10.times { assert Memoizer.new(@mock).memo_without_parameters_on_instance_level == :stuff }
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

    def test_memoizes_with_single_only_variable
      @mock.expect(:slow, :stuff12, [1, 2])
      10.times { assert memo_with_single_only_parameter(1, 2) == :stuff12 }

      # does not call the block if ignored parameter is changed
      10.times { assert memo_with_single_only_parameter(2, 2) == :stuff12 }

      # but calls the block if not-ignored parameters is changed
      @mock.expect(:slow, :stuff13, [1, 3])
      10.times { assert memo_with_single_only_parameter(1, 3) == :stuff13 }

      @mock.verify
    end

    def test_memoizes_with_multiple_only_variables
      @mock.expect(:slow, :stuff123, [1, 2, 3])
      10.times { assert memo_with_multiple_only_parameters(1, 2, 3) == :stuff123 }

      # does not call the block if first ignored parameter is changed
      10.times { assert memo_with_multiple_only_parameters(4, 2, 3) == :stuff123 }

      # but calls the block if not-ignored parameters is changed
      @mock.expect(:slow, :stuff143, [1, 4, 3])
      10.times { assert memo_with_multiple_only_parameters(1, 4, 3) == :stuff143 }

      @mock.verify
    end

    def test_memoizes_without_single_except_variable
      @mock.expect(:slow, :stuff12, [1, 2])
      10.times { assert memo_with_single_except_parameter(1, 2) == :stuff12 }

      # does not call the block if ignored parameter is changed
      10.times { assert memo_with_single_except_parameter(3, 2) == :stuff12 }

      # but calls the block if not-ignored parameters is changed
      @mock.expect(:slow, :stuff14, [1, 4])
      10.times { assert memo_with_single_except_parameter(1, 4) == :stuff14 }

      @mock.verify
    end

    def test_memoizes_without_multiple_except_variables
      @mock.expect(:slow, :stuff123, [1, 2, 3])
      10.times { assert memo_with_multiple_except_parameters(1, 2, 3) == :stuff123 }

      # does not call the block if first ignored parameter is changed
      10.times { assert memo_with_multiple_except_parameters(4, 2, 3) == :stuff123 }

      # does not call the block if second ignored parameter is changed
      10.times { assert memo_with_multiple_except_parameters(1, 2, 4) == :stuff123 }

      # but calls the block if not-ignored parameters is changed
      @mock.expect(:slow, :stuff143, [1, 4, 3])
      10.times { assert memo_with_multiple_except_parameters(1, 4, 3) == :stuff143 }

      @mock.verify
    end

    class MyMemoTest
      attr_accessor :what

      def one_line
        memo { @what } ? memo { :foo } : memo { :bar }
      end
    end

    def test_memo_thrice_in_row_left
      dut = MyMemoTest.new
      dut.what = true
      assert_equal(:foo, dut.one_line)
      assert_equal(2, dut.instance_variable_get(:@_memo_it).size, "Two memos should have two entries")
    end

    def test_memo_thrice_in_row_right
      dut = MyMemoTest.new
      dut.what = false
      assert_equal(:bar, dut.one_line)
      assert_equal(2, dut.instance_variable_get(:@_memo_it).size, "Two memos should have two entries")
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

    def memo_with_single_only_parameter(some = 1, parameters = 2)
      memo(only: :parameters) do
        @mock.slow(some, parameters)
      end
    end

    def memo_with_multiple_only_parameters(some = 1, more = 2, parameters = 3)
      memo(only: [:more, :parameters]) do
        @mock.slow(some, more, parameters)
      end
    end

    def memo_with_single_except_parameter(some = 1, parameters = 2)
      memo(except: :some) do
        @mock.slow(some, parameters)
      end
    end

    def memo_with_multiple_except_parameters(some = 1, more = 2, parameters = 3)
      memo(except: [:some, :parameters]) do
        @mock.slow(some, more, parameters)
      end
    end

    class Memoizer
      def initialize(mock)
        @mock = mock
      end

      def memo_without_parameters_on_class_level
        Memo::It.memo do
          @mock.slow
        end
      end

      def memo_without_parameters_on_instance_level
        memo do
          @mock.slow
        end
      end
    end
  end
end
