require 'test_helper'

module Memo
  class ItTest < Minitest::Test
    def test_memoizes_stuff
      assert memo_without_parameters == :stuff
    end

    def test_memoizes_stuff_with_parameters
      assert memo_with_parameters == :stuff_with_parameters_1_2
      assert memo_with_parameters(3, 4) == :stuff_with_parameters_3_4
    end

    def test_memoizes_without_leaking
      10.times do |i|
        j = rand
        assert memo_with_parameters(i, j) == :"stuff_with_parameters_#{i}_#{j}"
      end
    end

    def memo_without_parameters
      memo do
        :stuff
      end
    end

    def memo_with_parameters(some = 1, parameters = 2)
      memo do
        :"stuff_with_parameters_#{some}_#{parameters}"
      end
    end
  end
end
