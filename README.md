# HubSpotMock

HubSpotMock is a memory database to test HubSpot API in RSpec.  
It uses webmock gem to stub requests, store data in memory and mock a response.  
Check spec/hub_spot_mock_spec.rb to see API usages

## Usage

Add this configuration to RSpec
```ruby
  config.before(:each, :hubspot_mock) do
    config.include(HubSpotMock)

    HubSpotMock::HubSpotStore.clear

    base1 = hs_create_base("default")
    base1.create_table("association", "associations")
    base1.create_table("deal", "deals")
    base1.create_table("contact", "contacts")
    base1.create_table("company", "companies")
    base1.create_table("address", "addresses")
    base1.create_table("custom_table_1", "custom_table_1")
    base1.create_table("custom_table_2", "custom_table_2")

    stub_hubspot_requests
  end
```

## Development

This library is under development and still needs more of API to cover

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/MaxKolodziej/HubSpotMock

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
