require 'spec_helper'

describe RtuTopN do
  let(:rtu_top_n) do
    described_class.new('an ES query body', false, Date.new(2019, 1, 1))
  end

  describe '#top_n' do
    subject(:top_n) { rtu_top_n.top_n }

    let(:query_args) do
      {
        index: 'logstash-2019.01.01',
        body: 'an ES query body',
        size: 10_000
      }
    end

    it 'queries Elasticsearch with the expected args' do
      expect(Es::ELK.client_reader).to receive(:search).
        with(query_args).and_return({})
      top_n
    end

    context 'when the search fails' do
      before do
        allow(Es::ELK.client_reader).to receive(:search).
          and_raise(StandardError.new('search failure'))
        allow(Rails.logger).to receive(:error)
      end

      it 'returns an empty array' do
        expect(top_n).to eq([])
      end

      it 'logs the error' do
        top_n
        expect(Rails.logger).to have_received(:error).with(
          'Error querying top_n data:', instance_of(StandardError)
        )
      end
    end
  end
end
