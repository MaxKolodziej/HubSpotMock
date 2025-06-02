# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'HubspotMock', :hubspot_mock do
  let!(:hubspot_contact1) do
    hs_create(:contact, first_name: 'Joe', email: 'email1@t.com')
  end
  let!(:hubspot_contact2) do
    hs_create(:contact, first_name: 'Johny', email: 'email2@t.com')
  end
  let!(:hubspot_contact3) do
    hs_create(:contact, first_name: 'Joey', email: 'email3@t.com')
  end
  let!(:hubspot_deal1) do
    hs_create(:deal, name: 'deal1')
  end
  let!(:hubspot_deal2) do
    hs_create(:deal, name: 'deal2')
  end
  let!(:hubspot_deal3) do
    hs_create(:deal, name: 'deal3')
  end

  describe 'fetch records' do
    it 'returns all records' do
      body = get_url('/crm/v4/objects/contact')
      expect(body['results'].count).to eq(3)
    end

    context 'when plural form is used' do
      it 'returns all records' do
        body = get_url('/crm/v4/objects/contacts')
        expect(body['results'].count).to eq(3)
      end
    end
  end

  describe 'create & fetch' do
    it 'creates new record' do
      body = post_url('/crm/v4/objects/contacts', { properties: { name: 'Jane' } })
      id = body['id']
      expect(id).to include('rec')

      body = get_url("/crm/v4/objects/contacts/#{id}")
      expect(body.dig('properties', 'name')).to eq('Jane')
    end
  end

  describe 'update & fetch' do
    it 'updates the record' do
      patch_url("/crm/v4/objects/contacts/#{hubspot_contact1}", { properties: { name: 'Jane' } })

      body = get_url("/crm/v4/objects/contacts/#{hubspot_contact1}")
      expect(body.dig('properties', 'name')).to eq('Jane')
    end
  end

  describe 'delete' do
    it 'updates the record' do
      delete_url("/crm/v4/objects/contacts/#{hubspot_contact1}")

      body = get_url('/crm/v4/objects/contacts')
      expect(body['results'].count).to eq(2)
    end
  end

  describe 'associate' do
    it 'associate 2 records' do
      put_url("/crm/v4/objects/contacts/#{hubspot_contact1}/associations/deals/#{hubspot_deal1}/default")
      put_url("/crm/v4/objects/contacts/#{hubspot_contact1}/associations/deals/#{hubspot_deal1}/test")

      body = get_url("/crm/v4/objects/contacts/#{hubspot_contact1}/associations/deals")
      expect(body).to eq(
        'results' => {
          'from' => { 'id' => hubspot_contact1 },
          'to' => [
            {
              'toObjectId' => hubspot_deal1,
              'associationTypes' => [
                { 'category' => nil, 'typeId' => 'TODO', 'label' => 'TODO' },
                { 'category' => nil, 'typeId' => 'TODO', 'label' => 'TODO' }
              ]
            }
          ]
        }
      )
    end
  end

  def get_url(path)
    uri = URI("#{hubspot_url}#{path}")
    JSON.parse(Net::HTTP.get_response(uri, json_headers).body)
  end

  def post_url(path, body)
    uri = URI("#{hubspot_url}#{path}")
    JSON.parse(Net::HTTP.post(uri, body.to_json, json_headers).body)
  end

  def put_url(path, body = {})
    uri = URI("#{hubspot_url}#{path}")
    JSON.parse(Net::HTTP.put(uri, body.to_json, json_headers).body)
  end

  def patch_url(path, body)
    net_http = Net::HTTP.new(hubspot_domain, 443)
    net_http.use_ssl = true
    JSON.parse(net_http.patch(path, body.to_json, json_headers).body)
  end

  def delete_url(path)
    net_http = Net::HTTP.new(hubspot_domain, 443)
    net_http.use_ssl = true
    JSON.parse(net_http.delete(path, json_headers).body)
  end

  def json_headers
    { 'Content-Type': 'application/json' }
  end

  def hubspot_url
    HubSpotMock::RequestMockBase::HUBSPOT_API_URL
  end

  def hubspot_domain
    HubSpotMock::RequestMockBase::HUBSPOT_DOMAIN
  end
end
