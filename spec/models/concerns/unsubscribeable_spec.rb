require 'spec_helper'

describe Unsubscribeable do
  let(:klass) do
    class DummyClass
      include ActiveModel::Model

      attr_accessor :unsubscribe_email_token

      def self.before_save(*_args)
        true
      end
    end

    DummyClass
  end

  before do
    klass.send(:include, Unsubscribeable)
  end

  describe '#unsubscribe!' do
    subject { klass.new }

    it 'returns true' do
      allow(subject).to receive(:update!).and_return(true)
      subject.unsubscribe!
      expect(subject).to have_received(:update!)
    end
  end

  describe 'generate_unsubscribe_token' do
    subject { klass.new }

    context 'unsubscribe_email_token is blank' do
      it 'populates the unsubscribe_email_token with a random hash' do
        subject.generate_unsubscribe_token
        expect(subject.unsubscribe_email_token).to_not be_blank
      end
    end

    context "unsubscribe_email_token isn't blank" do
      it "doesn't do anything" do
        token = SecureRandom.hex

        subject.unsubscribe_email_token = token
        subject.generate_unsubscribe_token
        expect(subject.unsubscribe_email_token).to eq(token)
      end
    end
  end

  describe '.unsubscribe' do
    subject { klass }
    let(:instance) { klass.new }
    let(:token) { instance.unsubscribe_email_token }

    before do
      instance.generate_unsubscribe_token

      allow(klass).to receive(:find_by).with(unsubscribe_email_token: token).and_return(instance)
      allow(instance).to receive(:unsubscribe!).and_return(true)
    end

    it 'calls unsubscribe! for the right instance' do
      subject.unsubscribe(token)
      expect(instance).to have_received(:unsubscribe!)
    end
  end
end
