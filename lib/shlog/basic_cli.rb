module Shlog
  module BasicCLI
    def self.included(mod)
      mod.class_eval do
        extend GLI::App

        const_set(:CONFIG_FILE_NAME, "shlogrc")

        const_set(:CONFIG_FILES, [
          File.expand_path(File.join(File.dirname(File.realpath(__FILE__)), "..", "..", const_get(:CONFIG_FILE_NAME))),
          File.join(ENV["HOME"], ".#{const_get(:CONFIG_FILE_NAME)}"),
          File.join(Dir.getwd, ".#{const_get(:CONFIG_FILE_NAME)}")
        ])

        class << self
          attr_accessor :cli_command

          def cli_defaults
            @cli_defaults ||= Hash.new
          end

          def cli_defaults=(value)
            @cli_defaults = value
          end

          def config_to_options_for(command, config)
            self.cli_command ||= command

            setup_cli!

            config.each do |k, v|
              base_option_name = base_option_name_for(k, @cli_options[:list])

              @cli_options[:list][base_option_name].each do |f|
                @cli_options[:values][f] = v
              end
            end

            @cli_options.fetch(:values)
          end

          def setup_cli!
            raise RuntimeError, "Command not set!" unless cli_command

            unless @cli_options
              @cli_options = { list: Hash.new, values: Hash.new }

              flags_array = cli_command.flags.map(&:last).map { |f| [f.name, f.aliases].flatten }
              flags_array.each do |o|
                @cli_options[:list][o.first.to_sym] = [o.map(&:to_sym), o.map(&:to_s)].flatten.compact unless @cli_options.fetch(:list).has_key?(o.first.to_sym)

                o.each do |oo|
                  @cli_options[:values][oo.to_sym] = nil unless @cli_options.fetch(:values).has_key?(oo.to_sym)
                  @cli_options[:values][oo.to_s]   = nil unless @cli_options.fetch(:values).has_key?(oo.to_s)
                end
              end

              switches_array = cli_command.switches.map(&:last).map { |s| [s.name, s.aliases].flatten.compact }
              switches_array.each do |o|
                @cli_options[:list][o.first.to_sym] = [o.map(&:to_sym), o.map(&:to_s)].flatten.compact unless @cli_options.fetch(:list).has_key?(o.first.to_sym)

                o.each do |oo|
                  @cli_options[:values][oo.to_sym] = false unless @cli_options.fetch(:values).has_key?(oo.to_sym)
                  @cli_options[:values][oo.to_s]   = false unless @cli_options.fetch(:values).has_key?(oo.to_s)
                end
              end
            end
          end

          def base_option_name_for(option, option_list)
            name = nil

            option_list.each do |n, o|
              if o.include?(option)
                name = n
                break
              end
            end

            name
          end
        end

        private

        def self.set_default_options!
          config_file = const_get(:CONFIG_FILES).first

          if File.exists?(config_file) && File.readable?(config_file)
            config = Psych.load(ERB.new(IO.read(config_file)).result)
          else
            config = {}
          end

          self.cli_defaults = config["commands"]
        end
      end
    end
  end
end
