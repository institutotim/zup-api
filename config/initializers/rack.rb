if Rack::Utils.respond_to?('key_space_limit=')
  Rack::Utils.key_space_limit = 100_262_144
end
