# frozen_string_literal: true

module HubSpotMock
  module RequestMocks
    class CreateRecord < RequestMockBase
      def uri
        "#{HUBSPOT_API_URL}/crm/v{version}/objects/{table_name}"
      end

      def stub
        WebMock.stub_request(:post, template).to_return do |request|
          uri_match = template.match(Addressable::URI.parse(request.uri))
          base_name = extract_base(request)
          table = check_if_table_was_created(base_name, uri_match['table_name'])
          record = JSON.parse(request.body)

          raise ArgumentError unless record['properties']

          record_id = table.create_record(record['properties'])
          HubSpotResponse.create_response_for_record(table, record_id)
        end
      end
    end
  end
end
