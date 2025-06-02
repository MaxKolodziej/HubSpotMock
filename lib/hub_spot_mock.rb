# frozen_string_literal: true

require 'addressable'
Dir[File.join(__dir__, 'hub_spot_mock', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'hub_spot_mock', 'request_mocks', '*.rb')].each { |file| require file }

module HubSpotMock
  def hs_create_base(base_id)
    raise ValueError, "Base: #{base_id} already exists" if HubSpotStore.bases.key?(base_id)

    HubSpotStore.bases[base_id] = HubSpotBase.new(base_id:)
  end

  def hs_fetch_records(table_name)
    HubSpotStore.bases['default'].fetch_table(table_name.to_s).records
  end

  def hs_fetch_record(table_name, id)
    HubSpotStore.bases['default'].fetch_table(table_name.to_s).fetch_record(id)
  end

  def hs_create(table_name, properties)
    HubSpotStore.bases['default'].fetch_table(table_name.to_s).create_record(properties)
  end

  def authorization_headers(request); end

  def stub_hubspot_requests
    RequestMocks::FetchRecords.new.stub
    RequestMocks::FetchSingleRecord.new.stub
    RequestMocks::CreateRecord.new.stub
    RequestMocks::AssociateRecords.new.stub
    RequestMocks::FetchAssociatedRecords.new.stub
    RequestMocks::SearchRecords.new.stub
    RequestMocks::UpdateRecord.new.stub
    RequestMocks::DeleteRecord.new.stub
  end
end
