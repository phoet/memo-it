require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test

task :benchmark do
  require_relative 'lib/memo/it'
  require 'benchmark/ips'
  require 'memoist'

  class Tester
    extend Memoist

    def memo_it
      memo { false }
    end

    def memoist
      false
    end

    memoize :memoist
  end

  tester = Tester.new
  Benchmark.ips do |x|
    x.warmup = 3
    x.time = 10
    x.report('memo-it') { tester.memo_it }
    x.report('memoist') { tester.memoist }
  end
end
