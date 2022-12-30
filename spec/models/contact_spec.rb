require 'spec_helper'

describe Contact do
  describe '.valid_email?' do
    subject { Contact.valid_email?(email) }

    context 'blocked email' do
      let(:email) { 'No-ReplyHAT@gmail.com' }

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end

    context 'unblocked email' do
      let(:email) { 'frank@zappa.com' }

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end
  end
end
