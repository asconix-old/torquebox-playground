# -*- encoding : utf-8 -*-

$stdout.print "--- Loading #{__FILE__}\n"

require "rubygems"
require "bundler/setup"

require 'benchmark'

Bundler.require

require "torquebox-messaging"
require "torquebox-rake-support"

@queue = TorqueBox::Messaging::Queue.new("/queues/torquebox-playground")
@queue.remove_messages

@counter = 0

namespace :app do

  namespace :publish_messages do

    desc "Push 1M random messages by spawning one session per message (default)"
    task :default do
      $stdout.print "Launching Rake task app:publish_messages:default ...\n"
      time = Benchmark.realtime do
        100_000.times do
          payload = Array.new(32){rand(36).to_s(36)}.join
          @queue.publish(payload)
          puts ">>> #{@counter+=1} >>> #{payload} >>> Size: #{@queue.count_messages} / #{@queue.consumer_count}"
        end
      end
      puts "Time elapsed #{time} seconds ..."
    end

    desc "Push 1M random messages by reusing one session for all messages"
    task :one_session do
      $stdout.print "Launching Rake task app:publish_messages:one_session ...\n"
      time = Benchmark.realtime do
        @queue.with_session(:tx => false) do |session| 
          100_000.times do
            payload = Array.new(32){rand(36).to_s(36)}.join
            session.publish(@queue, payload, @queue.normalize_options(:persistent => false))
            puts ">>> #{@counter+=1} >>> #{payload} >>> Size: #{@queue.count_messages} / #{@queue.consumer_count}"
          end
        end
      end
      puts "Time elapsed #{time} seconds ..."
    end

    # Blazing fast message publisher (120 times faster than simple queue.publish())
    # https://gist.github.com/asconix/5712315
    desc "Push 1M random messages by reusing one session for all messages and optimize the requests"
    task :one_session_optimized do
      $stdout.print "Launching Rake task app:publish_messages:one_session_optimized ...\n"
      time = Benchmark.realtime do
        @queue.with_session(:tx => false) do |session| 
          options = @queue.normalize_options(:persistent => false)
          producer = session.instance_variable_get('@jms_session').create_producer(session.java_destination(@queue))
          100_000.times do
            payload = Array.new(32){rand(36).to_s(36)}.join
            message = TorqueBox::Messaging::Message.new(session.instance_variable_get('@jms_session'), payload, options[:encoding])

            message.populate_message_headers(options)
            message.populate_message_properties(options[:properties])

            producer.disable_message_id = true
            producer.disable_message_timestamp = true

            producer.send( message.jms_message,
              options.fetch(:delivery_mode, producer.delivery_mode),
              options.fetch(:priority, producer.priority),
              options.fetch(:ttl, producer.time_to_live)
            )
            puts ">>> #{@counter+=1} >>> #{payload} >>> Size: #{@queue.count_messages} / #{@queue.consumer_count}"
          end
        end
      end
      puts "Time elapsed #{time} seconds ..."
    end

  end

end

