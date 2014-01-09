module Shlog
  class CLI
    desc "Add a log entry"
    arg_name "MESSAGE"
    command :log do |c|
      c.desc "Name of the program that is logging the message"
      c.arg_name "PROGNAME"
      c.flag [:p, :progname], must_match: /\A[a-zA-Z0-9_.-]+\Z/

      c.desc "Level of severity"
      c.default_value self.options[:log][:level]
      c.arg_name "LEVEL"
      c.flag [:l, :level], must_match: /\A[a-zA-Z0-9]+\Z/

      c.desc "Path to or name of the log file"
      c.long_desc <<-DESC
          This option can either be a full path to a log file, or just the name
          of a log file. In both cases, the file does not have to exist and the
          `.log` extension is not required.
      DESC
      c.default_value File.join(self.options[:log][:dir], self.options[:log][:filename])
      c.arg_name "FILE"
      c.flag [:f, :file]

      c.desc "The maximum size of the log file"
      c.long_desc <<-DESC
          This size represents the number of log entries in the log file.
          If the size of the log file has reached the maximum value, it will
          be "archived" and a new log file will be created. The new log entry
          will then go in the new log file.
      DESC
      c.default_value self.options[:log][:"max-size"]
      c.arg_name "SIZE"
      c.flag [:s, :"max-size"], must_match: /\A[0-9]+\Z/

      c.desc "Vebose mode"
      c.switch :v, :verbose

      c.action do |global_options, options, args|
        if args.empty?
          raise ArgumentError, "Cannot add a log entry without a message"
        end

        template = lambda do |e|
          t  = "[#{e.time} #{e.severity_label}"
          t << " (#{e.progname})" if e.progname
          t << "] #{e.message}"
          t
        end

        logger = Lumberjack::Logger.new(options[:file], time_format: "%m/%d/%Y %H:%M:%S", template: template, max_size: options[:"max-size"])
        logger.progname = options[:progname]
        logger.send(options[:level].to_s.downcase, args.join(" "))

        if options[:verbose]
          puts "Log entry added".color(:green)
        end
      end
    end
  end
end
