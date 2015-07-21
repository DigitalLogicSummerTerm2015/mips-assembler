require "rake/testtask"

task :default => :gen_code

Rake::TestTask.new do |t|
  t.libs << "test"
  t.verbose = true
end

task :gen_code => :test do
    system "ruby", "-Ilib", "bin/assembly.rb", "test/gcd.asm", "test/rom.v"
end
