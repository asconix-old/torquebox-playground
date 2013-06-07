# -*- encoding : utf-8 -*-

$stdout.print "--- Loading #{__FILE__}\n"

require "rubygems"
require "bundler/setup"

Bundler.require

require "torquebox-rake-support"

namespace :app do

  desc "Push 1M random strings into HornetQ"
    task :hp_publish do
    $stdout.print "Launching Rake task app:hp_publish ...\n"
    
    puts "Launched high performance publishing ..."
    queue = TorqueBox::Messaging::Queue.new("/queues/torquebox-playground")
    queue.remove_messages  # Just for development

    # Blazing fast message publisher (120 times faster than simple queue.publish())
    # https://gist.github.com/asconix/5712315

    counter = 0

    queue.with_session(:tx => false) do |session|
      options = queue.normalize_options(:persistent => false)
      producer = session.instance_variable_get('@jms_session').create_producer(session.java_destination(queue))
      1_000_000.times do
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
        puts ">>> #{counter+=1} >>> #{payload} >>> Size: #{queue.count_messages} / #{queue.consumer_count}"
      end
    end

  end

end
