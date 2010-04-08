task :default => ['test', 'cucumber']

ENV['PERL5LIB'] = '.'

def cucumber(args)
  options = "--format progress #{args}"
  sh "which cucumber && cucumber #{options} || bundle exec cucumber #{options}"
end

def banner_format
  $stdout.isatty ? "\033[33;01m%s\033[m" : "%s"
end

def banner(msg)
  puts banner_format % ('=' * 72)
  puts banner_format % msg
  puts banner_format % ('=' * 72)
end

desc 'Run unit tests'
task 'test' do
  banner 'Unit tests'
  sh('prove t/')
end

desc 'Run acceptance tests'
task 'cucumber' do
  banner 'Acceptance tests'
  cucumber '--tags ~@wip features/'
end

desc "Run all acceptance tests (even those marked as WIP)"
task 'cucumber:all' do
  cucumber 'features/'
end

desc "Run acceptance tests marked as WIP"
task 'cucumber:wip' do
  cucumber '--tags @wip features/'
end

desc 'updates MANIFEST from contents of git repository'
task 'manifest' do
  sh('git ls-tree -r --name-only HEAD > MANIFEST')
end

version = File.readlines('analizo').find { |item| item =~ /VERSION =/ }.strip.gsub(/.*VERSION = '(.*)'.*/, '\1')

desc 'prepares a release tarball'
task :release => [:authors, :manifest, :check_repo, :check_tag, :default] do
  sh "perl Makefile.PL"
  sh "make"
  sh "make test"
  sh "make dist"
  sh "git tag #{version}"
end

desc 'updates the AUTHORS file'
task :authors do
  sh "(echo 'Andreas Gustafsson <gson@gson.org>'; git log --pretty=format:'%aN <%aE>') | sort | uniq > AUTHORS"
end

desc 'checks if there are uncommitted changes in the repo'
task :check_repo do
  sh "git status | grep 'nothing to commit'" do |ok, res|
    if !ok
      raise "******** There are uncommited changes in the repository, cannot continue"
    end
  end
end

desc 'checks if there is already a tag for the curren version'
task :check_tag do
  sh "git tag | grep '^#{version}$' >/dev/null" do |ok, res|
    if ok
      raise "******** There is already a tag for version #{version}, cannot continue"
    end
  end
  puts "Not found tag for version #{version}, we can go on."
end
