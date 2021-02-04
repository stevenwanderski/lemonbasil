require 'spec_helper'

describe Api::EventsController do
  def encode_token(token)
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  describe '#create' do
    let(:params) { {} }
    subject { post :create, params: params }

    context 'token is not present' do
      it 'returns a 401' do
        expect(subject.code).to eq('401')
      end
    end

    context 'token is present' do
      let(:date) { '2020-10-12' }
      let(:params) { { date: date } }

      before do
        headers = { 'Authorization' => encode_token('secret-token') }
        request.headers.merge! headers
      end

      context 'event exists' do
        let!(:event) { Event.create!(starts_at: date) }

        it 'it destroys the event' do
          expect(subject.code).to eq('204')
          expect(Event.count).to eq(0)
        end
      end

      context 'event does not exist' do
        let!(:event) { nil }

        it 'creates the event' do
          expect(subject.code).to eq('201')
          expect(Event.count).to eq(1)
        end
      end
    end
  end
end
