task default: [:lint, :syntax, :spec]

# Linting
require 'foodcritic'
desc ':lint == :foodcritic. Just less typing.'
task lint: [:foodcritic]
FoodCritic::Rake::LintTask.new

# Rubocop
require 'rubocop/rake_task'
RuboCop::RakeTask.new(:syntax)

# Unit tests
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
