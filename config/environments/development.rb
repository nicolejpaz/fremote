Fremote::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # config.action_dispatch.best_standards_support = :builtin﻿
  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  config.action_mailer.delivery_method = :smtp

  ## Settings for testing ActionMailer:

  # config.action_mailer.smtp_settings = {
  #   address: "smtp.gmail.com",
  #   port: "587",
  #   domain: "gmail.com",
  #   authentication: "plain",
  #   enable_starttls_auto: true,
  #   user_name: "<username>",
  #   password: "<password>"
  # }

  # config.action_mailer.smtp_settings = {
  #   address: "smtp.sendgrid.net",
  #   port: "587",
  #   domain: "heroku.com",
  #   authentication: "plain",
  #   enable_starttls_auto: true,
  #   user_name: "<username>",
  #   password: "<password>"
  # }

end
