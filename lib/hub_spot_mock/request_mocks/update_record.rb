# frozen_string_literal: true

module HubSpotMock
  module RequestMocks
    class UpdateRecord < RequestMockBase
      def uri
        "#{HUBSPOT_API_URL}/crm/v{version}/objects/{table_name}/{record_id}"
      end

      def stub
        WebMock.stub_request(:patch, template).to_return do |request|
          uri_match = template.match(request.uri)
          base_name = extract_base(request)
          table = check_if_table_was_created(base_name, uri_match['table_name'])
          record_id = uri_match['record_id']
          record = JSON.parse(request.body)

          raise ArgumentError unless record['properties']

          table.update_record(record_id, record['properties'])
          HubSpotResponse.create_response_for_record(table, record_id)
        end
      end
    end
  end
end
