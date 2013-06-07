# -*- encoding : utf-8 -*-

# $stdout.print "--- Loading #{__FILE__}\n"

module App

  module MessageProcessors

    class HpPublisher < TorqueBox::Messaging::MessageProcessor

      def on_message(msg)
        begin
          puts "*** *** *** #{msg}"
        rescue Exception => e_exception
          $stderr.print "FAILED #{__FILE__}\n".foreground(:red)
          $stderr.print "ERROR => #{e_exception.message}\n".foreground(:red)
          $stderr.print "Backtrace: #{e_exception.backtrace.join("\n\t")}\n"
          java.lang.System.exit(0)
        end
      end

    end

  end

end
