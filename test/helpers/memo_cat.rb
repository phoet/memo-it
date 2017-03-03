class MemoCat
  def calculate; end

  def result
    memo do
      calculate
    end
  end
end
