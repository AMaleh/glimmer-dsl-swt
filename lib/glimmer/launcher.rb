# Copyright (c) 2007-2020 Andy Maleh
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if ARGV.include?('--bundler') && File.exist?(File.expand_path('./Gemfile'))
  require 'bundler'
  Bundler.setup(:default)
end
require 'fileutils'
require 'os'

module Glimmer
  class Launcher
    OPERATING_SYSTEMS_SUPPORTED = ["mac", "windows", "linux"]
    
    TEXT_USAGE = <<~MULTI_LINE_STRING
      Glimmer (Ruby Desktop Development GUI Library) - JRuby Gem: glimmer-dsl-swt v#{File.read(File.expand_path('../../../VERSION', __FILE__))}      
      Usage: glimmer [--bundler] [--quiet] [--debug] [--log-level=VALUE] [[ENV_VAR=VALUE]...] [[-jruby-option]...] (application.rb or task[task_args]) [[application2.rb]...]
    
      Runs Glimmer applications and tasks.    
    
      When applications are specified, they are run using JRuby, 
      automatically preloading the glimmer Ruby gem and SWT jar dependency.
    
      Optionally, extra Glimmer options, JRuby options, and/or environment variables may be passed in.
    
      Glimmer options:
      - "--bundler=GROUP"   : Activates gems in Bundler default group in Gemfile
      - "--quiet=BOOLEAN"   : Does not announce file path of Glimmer application being launched
      - "--debug"           : Displays extra debugging information, passes "--debug" to JRuby, and enables debug logging
      - "--log-level=VALUE" : Sets Glimmer's Ruby logger level ("ERROR" / "WARN" / "INFO" / "DEBUG"; default is none)
    
      Tasks are run via rake. Some tasks take arguments in square brackets.
    
      Available tasks are below (if you do not see any, please add `require 'glimmer/rake_task'` to Rakefile and rerun or run rake -T):
      
    MULTI_LINE_STRING

    GLIMMER_LIB_LOCAL = File.expand_path(File.join('lib', 'glimmer-dsl-swt.rb'))
    GLIMMER_LIB_GEM = 'glimmer-dsl-swt'
    GLIMMER_OPTIONS = %w[--log-level --quiet --bundler]
    GLIMMER_OPTION_ENV_VAR_MAPPING = {
      '--log-level' => 'GLIMMER_LOGGER_LEVEL'   ,
      '--bundler'   => 'GLIMMER_BUNDLER_SETUP'  ,
    }
    REGEX_RAKE_TASK_WITH_ARGS = /^([^\[]+)\[?([^\]]*)\]?$/

    @@mutex = Mutex.new

    class << self
      def platform_os
        OPERATING_SYSTEMS_SUPPORTED.detect {|os| OS.send("#{os}?")}
      end

      def swt_jar_file
        @swt_jar_file ||= File.expand_path(File.join(__FILE__, '..', '..', '..', 'vendor', 'swt', platform_os, 'swt.jar'))
      end
 
      def jruby_os_specific_options
        OS.mac? ? "-J-XstartOnFirstThread" : ""
      end

      def glimmer_lib
        @@mutex.synchronize do
          unless @glimmer_lib
            @glimmer_lib = GLIMMER_LIB_GEM
            glimmer_gem_listing = `jgem list #{GLIMMER_LIB_GEM}`.split("\n").map {|l| l.split.first}
            if !glimmer_gem_listing.include?(GLIMMER_LIB_GEM) && File.exists?(GLIMMER_LIB_LOCAL)
              @glimmer_lib = GLIMMER_LIB_LOCAL
              puts "[DEVELOPMENT MODE] (detected #{@glimmer_lib})"
            end
          end
        end
        @glimmer_lib
      end
      
      def dev_mode?
        glimmer_lib == GLIMMER_LIB_LOCAL
      end

      def glimmer_option_env_vars(glimmer_options)
        GLIMMER_OPTION_ENV_VAR_MAPPING.reduce({}) do |hash, pair|
          glimmer_options[pair.first] ? hash.merge(GLIMMER_OPTION_ENV_VAR_MAPPING[pair.first] => glimmer_options[pair.first]) : hash
        end
      end

      def load_env_vars(env_vars)
        env_vars.each do |key, value|
          ENV[key] = value
        end
      end

      def launch(application, jruby_options: [], env_vars: {}, glimmer_options: {})
        jruby_options_string = jruby_options.join(' ') + ' ' if jruby_options.any?
        env_vars = env_vars.merge(glimmer_option_env_vars(glimmer_options))
        env_vars_string = env_vars.map do |k,v| 
          if OS.windows? && ENV['PROMPT'] # detect command prompt (or powershell)
            "set #{k}=#{v} && "
          else
            "export #{k}=#{v} && "
          end
        end.join
        the_glimmer_lib = glimmer_lib
        devmode_require = nil
        if the_glimmer_lib == GLIMMER_LIB_LOCAL
          devmode_require = '-r puts_debuggerer '
        end
        require_relative 'rake_task'
        rake_tasks = Rake.application.tasks.map(&:to_s).map {|t| t.sub('glimmer:', '')}
         
        # handle a bash quirk with calling package[msi] while there is a "packages" directory locally (it passes package[msi] as packages)
        application = 'package[msi]' if application == 'packages'
        
        potential_rake_task_parts = application.match(REGEX_RAKE_TASK_WITH_ARGS)
        application = potential_rake_task_parts[1]
        rake_task_args = potential_rake_task_parts[2].split(',')
        if rake_tasks.include?(application)
          load_env_vars(glimmer_option_env_vars(glimmer_options))
          rake_task = "glimmer:#{application}"
          puts "Running Glimmer rake task: #{rake_task}" if jruby_options_string.to_s.include?('--debug')
          Rake::Task[rake_task].invoke(*rake_task_args)
        else
          @@mutex.synchronize do
            puts "Launching Glimmer Application: #{application}" if jruby_options_string.to_s.include?('--debug') || glimmer_options['--quiet'].to_s.downcase != 'true'
          end
          command = "#{env_vars_string} jruby #{jruby_options_string}#{jruby_os_specific_options} #{devmode_require}-r #{the_glimmer_lib} -S #{application}"
          if !env_vars_string.empty? && OS.windows?
            command = "bash -c \"#{command}\"" if ENV['SHELL'] # do in Windows Git Bash only
            command = "cmd /C \"#{command}\"" if ENV['PROMPT'] # do in Windows Command Prompt only (or Powershell)
          end
          puts command if jruby_options_string.to_s.include?('--debug')
          if command.include?(' irb ')
            exec command
          else
            system command
          end
        end
      end
    end
    
    attr_reader :application_paths
    attr_reader :env_vars
    attr_reader :glimmer_options
    attr_reader :jruby_options

    def initialize(raw_options)
      raw_options << '--quiet' if !caller.join("\n").include?('/bin/glimmer:') && !raw_options.join.include?('--quiet=')
      raw_options << '--log-level=DEBUG' if raw_options.join.include?('--debug') && !raw_options.join.include?('--log-level=')
      @application_paths = extract_application_paths(raw_options)
      @env_vars = extract_env_vars(raw_options)
      @glimmer_options = extract_glimmer_options(raw_options)
      @jruby_options = raw_options
    end

    def launch
      if @application_paths.empty?
        display_usage
      else
        launch_application
      end
    end

    private

    def launch_application
      load File.expand_path('./Rakefile') if File.exist?(File.expand_path('./Rakefile')) && caller.join("\n").include?('/bin/glimmer:')
      threads = @application_paths.map do |application_path|
        Thread.new do
          self.class.launch(
            application_path,
            jruby_options: @jruby_options,
            env_vars: @env_vars,
            glimmer_options: @glimmer_options
          )
        end
      end
      threads.each(&:join)
    end

    def display_usage
      puts TEXT_USAGE
      display_tasks
    end
    
    def display_tasks
      if OS.windows?
        tasks = Rake.application.tasks
        task_lines = tasks.reject do |task|
          task.comment.nil?
        end.map do |task|
          max_task_size = tasks.map(&:name_with_args).map(&:size).max + 1
          task_name = task.name_with_args.sub('glimmer:', '')
          line = "glimmer #{task_name.ljust(max_task_size)} # #{task.comment}"
          bound = TTY::Screen.width - 6
          line.size <= bound ? line : "#{line[0..(bound - 3)]}..."          
        end
        puts task_lines.to_a
      else
        require 'rake-tui'
        require 'tty-screen'
        require_relative 'rake_task'
        Rake::TUI.run(branding_header: nil, prompt_question: 'Select a Glimmer task to run:') do |task, tasks|
          max_task_size = tasks.map(&:name_with_args).map(&:size).max + 1
          task_name = task.name_with_args.sub('glimmer:', '')
          line = "glimmer #{task_name.ljust(max_task_size)} # #{task.comment}"
          bound = TTY::Screen.width - 6
          line.size <= bound ? line : "#{line[0..(bound - 3)]}..."          
        end    
      end
    end

    def extract_application_paths(options)
      options.select do |option|
        !option.start_with?('-') && !option.include?('=')
      end.each do |application_path|
        options.delete(application_path)
      end
    end

    def extract_env_vars(options)
      options.select do |option|
        !option.start_with?('-') && option.include?('=')
      end.each do |env_var|
        options.delete(env_var)
      end.reduce({}) do |hash, env_var_string|
        match = env_var_string.match(/^([^=]+)=(.+)$/)
        hash.merge(match[1] => match[2])
      end
    end

    def extract_glimmer_options(options)
      options.select do |option|
        GLIMMER_OPTIONS.reduce(false) do |result, glimmer_option|
          result || option.include?(glimmer_option)
        end
      end.each do |glimmer_option|
        options.delete(glimmer_option)
      end.reduce({}) do |hash, glimmer_option_string|
        match = glimmer_option_string.match(/^([^=]+)=?(.+)?$/)
        hash.merge(match[1] => (match[2] || 'true'))
      end
    end
  end
end
