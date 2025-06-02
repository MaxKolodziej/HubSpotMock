# frozen_string_literal: true

module HubSpotMock
  module RequestMocks
    class SearchRecords < RequestMockBase
      def uri
        "#{HUBSPOT_API_URL}/crm/v{version}/objects/{table_name}/search"
      end

      def stub
        WebMock.stub_request(:post, template).to_return do |request|
          uri_match = template.match(Addressable::URI.parse(request.uri))
          base_name = extract_base(request)

          options = JSON.parse(request.body) # get options from query
          table = check_if_table_was_created(base_name, uri_match['table_name'])
          records = table.iterate(batch_size: 0, filter_by_formula: options['filterGroups'], view: nil, max_records: 0)
          properties = options.fetch('properties', [])
          HubSpotResponse.create_response_for_collection(table, records, properties)
        end
      end
    end
  end
end
