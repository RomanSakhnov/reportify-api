# Be sure to restart your server when you modify this file.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(
      'rs-test.net',
      'www.rs-test.net',
      'reportify.rs-development.net',
      'https://rs-test.net',
      'https://www.rs-test.net',
      'https://reportify.rs-development.net',
      'http://localhost:3000',
      'http://localhost:5173'
    )

    resource(
      '*',
      headers: :any,
      methods: %i[get post put patch delete options head],
      credentials: true,
      expose: ['Authorization']
    )
  end
end
