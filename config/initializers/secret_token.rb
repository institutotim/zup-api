# Be sure to restart your server when you modify this file.

# Your secret key is used for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
# You can use `rake secret` to generate a secure secret key.

# Make sure your secret_key_base is kept private
# if you're sharing your code publicly.
Application.config.secret_key_base = ENV['COOKIE_SECRET'] || '344e9db0bb64ee636d8992b4f0832ea5a12143a5721d18f2640f4a416ddfc04641a6e1d5089f145e4772f4ed3da15ec86c545960e49560de1d98782da61f96b4'
