module Shlog
  class CLI
    include Shlog::BasicCLI

    program_desc  "Command-line logging made easy"
    version       Shlog::VERSION

    desc "Path to the config file to use"
    arg_name "FILE"
    flag [:config]

    set_default_options!
    commands_from File.expand_path(File.join(File.dirname(File.realpath(__FILE__)), "commands"))

    pre do |global, command, options, args|
      config_files = CONFIG_FILES
      default_config_file = config_files.shift

      if global[:config]
        # If a config file is explicitely specified, it MUST exist!
        unless File.exists?(global[:config])
          raise RuntimeError, "Unable to find config file: #{global[:config]}"
        end

        config_files << global[:config]
      end

      config_files.each do |cf|
        begin
          next unless File.exists?(cf) && File.readable?(cf)

          config = Psych.load(ERB.new(IO.read(cf)).result)
          options.merge!(config_to_options_for(command, config["commands"][command.name.to_sym]))

          # TODO: Add a flag to skip other config files, maybe?
        rescue => e
          raise RuntimeError, "Unable to load config from '#{cf}': #{e.message}"
        end
      end

      options.merge!(options[:cli])

      true
    end

    on_error do |exception|
      puts exception.message.color(:red)

      false
    end
  end
end
