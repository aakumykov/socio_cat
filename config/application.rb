require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SocioCat
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Bangkok'
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.action_mailer.smtp_settings = {
        address: 'smtp.yandex.ru',
        user_name: 'my.sender.personal',
        password: ENV['SMTP_PASSWORD'],
        #password: File.read("#{Rails.root}/config/smtp-password.txt").strip,
    }
    config.action_mailer.default_url_options = { host: 'localhost:3000' }

    #config.action_dispatch.default_url_options = { host: 'localhost:3000' }

    config.active_job.queue_adapter = :delayed_job

    config.paperclip_defaults = {
        storage: :s3,
        s3_region: ENV['AWS_REGION'],
        #s3_permissions: 'public-read',
        s3_hostname: 's3-us-west-2.amazonaws.com',
        url: ':s3_domain_url',
        s3_credentials: {
            access_key_id: ENV['AWS_ACCESS_KEY_ID'],
            secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        },
        bucket: 'test-a3rf3g34',
    }
  end
end
