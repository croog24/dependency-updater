require "http/client"

GRADLE                = "build.gradle"
MVN_REPO_ARTIFACT_URL = "https://mvnrepository.com/artifact/"

GRADLE_DEP_RE = /(test)?compile group: '(?<group>\S*)', name: '(?<artifact>\S*)', version: '?(?<version>\S*)'?/i
MVN_REPO_RE   = /vbtn release">(?<release>\S*)<\/a>/

class Dependency
  property group, artifact, version

  def initialize(@group : String, @artifact : String, @version : String)
  end
end

# Recursively scan directories for Gradle build files
def parse_dirs(start, dependencies)
  Dir.foreach(start) do |x|
    path = File.join(start, x)
    if x == "." || x == ".."
      next
    end
    if File.directory?(path)
      parse_dirs(path, dependencies)
    else
      if path.ends_with?(GRADLE)
        dependencies[path] = [] of Dependency
      end
    end
  end
end

# Get the dependencies and associated versions
def parse_build_file(path, dependencies)
  File.each_line(path) do |line|
    if found = line.match(GRADLE_DEP_RE)
      group = found["group"]
      artifact = found["artifact"]
      version = found["version"].chomp('\'')
      dep = Dependency.new(group, artifact, version)
      dependencies[path].push(dep)
    end
  end
end

# TODO Find more efficient way to do this without reparsing the file
# Need to become more familiar with the language...
def determine_variable_versions(path, dep : Dependency)
  File.each_line(path) do |line|
    if found = line.match(/#{dep.version}\s?=\s?'(?<version>\S*)'/)
      dep.version = found["version"]
      return
    end
  end
end

def find_update(dep)
  response = HTTP::Client.get("#{MVN_REPO_ARTIFACT_URL}#{dep.group}/#{dep.artifact}")
  if update = response.body.match(MVN_REPO_RE)
    newVer = update["release"]
    if (dep.version != newVer)
      puts "#{dep.group}:#{dep.artifact}:#{dep.version} -> #{newVer}"
    end
  end
end

begin
  base_dir : Dir = Dir.new(ARGV[0])
rescue
  puts "Must supply 1 directory to recursively scan!"
  exit 1
end

puts "Scanning for build files in: #{base_dir.path}"
dependencies = {} of String => Array(Dependency)
parse_dirs(base_dir.path, dependencies)

puts "\n"

dependencies.each do |k, v|
  puts "Found build file: #{k}"
  parse_build_file(k, dependencies)
  v.each do |d|
    determine_variable_versions(k, d)
    find_update(d)
  end
end
