require 'spec_helper'

RSpec::Matchers.define :be_a_unprocessable_entity do
  match do |actual|
    actual == 422
  end
end

RSpec::Matchers.define :be_a_not_allowed_method do
  match do |actual|
    actual == 405
  end
end

RSpec::Matchers.define :be_a_not_found do
  match do |actual|
    actual == 404
  end
end

RSpec::Matchers.define :be_an_unauthorized do
  match do |actual|
    actual == 401
  end
end

RSpec::Matchers.define :be_a_forbidden do
  match do |actual|
    actual == 403
  end
end

RSpec::Matchers.define :be_a_bad_request do
  match do |actual|
    actual == 400
  end
end

RSpec::Matchers.define :be_a_requisition_created do
  match do |actual|
    actual == 201
  end
end

RSpec::Matchers.define :be_a_success_request do
  match do |actual|
    actual == 200
  end
end

RSpec::Matchers.define :be_a_no_content_request do
  match do |actual|
    actual == 204
  end
end

RSpec::Matchers.define :be_an_error do |hash_error|
  match do
    parsed_body['error'] == hash_error
  end
end

RSpec::Matchers.define :be_a_success_message_with do |success_message|
  match do
    parsed_body['message'] == success_message
  end
end

RSpec::Matchers.define :be_an_entity_of do |object, options|
  match do |body|
    options ||= {}
    body == Oj.load(object.class::Entity.represent(object, options).to_json)
  end
end

RSpec::Matchers.define :include_an_entity_of do |object, options|
  match do |body|
    options ||= {}
    body.include?(Oj.load(object.class::Entity.represent(object, options).to_json))
  end
end

RSpec::Matchers.define :match_hash do |expected|
  match do |actual|
    matches_hash?(expected, actual)
  end
end

def matches_hash?(expected, actual)
  matches_array?(expected.keys, actual.keys) &&
    actual.all? { |k, xs| matches_array?(expected[k], xs) }
end

def matches_array?(expected, actual)
  if expected.is_a?(Hash) && actual.is_a?(Hash)
    matches_hash?(expected, actual)
  elsif expected.is_a?(Array) && actual.is_a?(Array)
    RSpec::Matchers::BuiltIn::ContainExactly.new(expected).matches?(actual)
  else
    expected == actual
  end
end
