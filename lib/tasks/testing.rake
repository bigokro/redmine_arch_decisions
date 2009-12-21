desc 'Execute the chosen tests for the Redmine Arch Decisions plugin.'

namespace :rad do

  namespace :test do
    Rake::TestTask.new(:units) do |t|
      t.libs << "test"
      t.pattern = 'vendor/plugins/redmine_arch_decisions/test/unit/*_test.rb'
      t.verbose = true
    end  

    Rake::TestTask.new(:functionals) do |t|
      t.libs << "test"
      t.pattern = 'vendor/plugins/redmine_arch_decisions/test/functional/*_test.rb'
      t.verbose = true
    end  

#    Rake::Task['test:units'].invoke
#    Rake::Task['test:functionals'].invoke
  end
end