require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.warning = true
end

task :prepare do
  `npm install systemjs-builder`
end

task default: :prepare
