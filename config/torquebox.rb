# -*- encoding : utf-8 -*-

$stdout.print "--- --- Loading torquebox.rb ...\n"

TorqueBox.configure do

  environment do
    GEM_HOME "#{ENV['rvm_path']}/gems/jruby-1.7.4@torquebox-playground"
    GEM_PATH "#{ENV['rvm_path']}/gems/jruby-1.7.4@global:#{ENV['rvm_path']}/gems/jruby-1.7.4@torquebox-playground"
    RACK_ENV "development"
  end

  queue "/queues/torquebox-playground" do
    durable false
    processor App::MessageProcessors::HpPublisher do
      concurrency 100
    end
  end

  ruby do
    version "1.9"
  end

  pool :messaging, :type => :shared

end
