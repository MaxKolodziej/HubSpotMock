# frozen_string_literal: true

require 'hub_spot_mock'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  require 'webmock'
  WebMock.enable!

  config.before(:each, :hubspot_mock) do
    config.include(HubSpotMock)

    HubSpotMock::HubSpotStore.clear

    base1 = hs_create_base('default')
    base1.create_table('association', 'associations')
    base1.create_table('deal', 'deals')
    base1.create_table('contact', 'contacts')
    base1.create_table('company', 'companies')
    base1.create_table('address', 'addresses')
    base1.create_table('custom_table_1', 'custom_table_1')
    base1.create_table('custom_table_2', 'custom_table_2')

    stub_hubspot_requests
  end
end
