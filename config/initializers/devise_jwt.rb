# config/initializers/devise_jwt.rb

Devise.setup do |config|
  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.jwt_secret_key || '8b4a1f491f6d66efeeeaa400c20977829810c49f12a71f7db6588d96de39a69d8d8da5a78c5a0db9b5a34176bc17efe10b0682147a8c76f8924823ed88af8fe2'
    jwt.dispatch_requests = [
      [ 'POST', %r{^/api/v1/login$} ],
      [ 'POST', %r{^/api/v1/signup$} ]
    ]
    jwt.revocation_requests = [
      [ 'DELETE', %r{^/api/v1/logout$} ]
    ]
    jwt.expiration_time = 1.day.to_i
  end
end
