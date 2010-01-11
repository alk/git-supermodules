
def sh(cmd)
  puts "# #{cmd}"
  ok = system cmd
  unless ok
    puts "FAILED! #{$?.inspect}"
    exit(1)
  end
end

class RecurseFuther
  attr_reader :path, :recursed
  def initialize(path, proc)
    @path = File.expand_path(path)
    @proc = proc
    @recursed = false
  end
  def call
    return if @recursed
    @recursed = true
    Dir.chdir(@path) do
      submodules = IO.popen('git submodule status', 'r') {|f| f.readlines.map {|l| l.strip.split(/\s+/,3)[1]}}
      submodules.each {|p| @proc.call(p)}
    end
  end
end

def recurse_submodule(path, &block)
  rec = proc do |p|
    recurse_submodule(p, &block)
  end
  further = RecurseFuther.new(path, rec)
  Dir.chdir(path) do
    puts "# cd #{path}"
    yield further
    further.call
  end
end
