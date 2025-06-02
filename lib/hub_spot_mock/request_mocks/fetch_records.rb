# frozen_string_literal: true

module HubSpotMock
  module RequestMocks
    class FetchRecords < RequestMockBase
      def uri
        "#{HUBSPOT_API_URL}/crm/v{version}/objects/{table_name}{?params*}"
      end

      def stub
        WebMock.stub_request(:get, template).to_return do |request|
          uri_match = template.match(request.uri)
          options = JSON.parse('{}') # get options from query
          base_name = extract_base(request)
          table = check_if_table_was_created(base_name, uri_match['table_name'])
          properties = options.fetch('properties', [])
          records = table.iterate(batch_size: 0, filter_by_formula: nil, max_records: 0)
          HubSpotResponse.create_response_for_collection(table, records, properties)
        end
      end
    end
  end
end
