desc 'Run irb console'
task :console do
  exec 'irb -r irb/completion -r ./environment'
end
