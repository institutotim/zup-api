require 'app_helper'

describe ErrorHandler do
  let(:exception) { StandardError }
  let(:user)      { double(:user, id: 1000, email: 'user@mail.com') }
  let(:request)   { double(:request, path: '/api/url') }
  let(:params)    { { id: 1 } }
  let(:headers)   { { accept: '*/*', host: 'localhost:3000', version: 'HTTP/1.1' } }

  let(:api_env) do
    double(:api_env, safe_params: params, current_user: user, headers: headers,
      request: request, app_token: 'token')
  end

  subject { described_class }

  describe 'send exception to Raiven' do
    let(:options) do
      {
        level: 'info',
        user: {
          id: 1000,
          email: 'user@mail.com'
        },
        extra: {
          params: { id: 1 },
          token: 'token',
          headers: { accept: '*/*', host: 'localhost:3000', version: 'HTTP/1.1' },
          path: '/api/url'
        }
      }
    end

    it 'send only exception and event level' do
      expect(Raven).to receive(:capture_exception).with(exception, level: 'error')
      subject.capture_exception(exception)
    end

    it 'send params, user and token with exception' do
      expect(Raven).to receive(:capture_exception).with(exception, options)
      subject.capture_exception(exception, :info, api_env)
    end
  end

  describe 'raise errors' do
    it 'raise error when `RAISE_ERRORS` is setted' do
      allow(ENV).to receive(:[]).with('RAISE_ERRORS').and_return('true')
      expect { subject.capture_exception(exception) }.to raise_error(StandardError)
    end

    it 'do not raise error when `RAISE_ERRORS` is empty' do
      expect { subject.capture_exception(exception) }.to_not raise_error
    end
  end

  describe 'log errors' do
    it 'log error when event level is equal to "error"' do
      expect(ZUP::API.logger).to receive(:error).with(exception)
      subject.capture_exception(exception, :error)
    end

    it 'do not log error when level is different to "error"' do
      expect(ZUP::API.logger).to_not receive(:error).with(exception)

      %w{info debug info warning}.each do |level|
        subject.capture_exception(exception, level)
      end
    end
  end
end
