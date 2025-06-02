# frozen_string_literal: true

module HubSpotMock
  module RequestMocks
    class DeleteRecord < RequestMockBase
      def uri
        "#{HUBSPOT_API_URL}/crm/v{version}/objects/{table_name}/{record_id}"
      end

      def stub
        WebMock.stub_request(:delete, template).to_return do |request|
          uri_match = template.match(request.uri)
          base_name = extract_base(request)
          table = check_if_table_was_created(base_name, uri_match['table_name'])
          record_id = uri_match['record_id']
          table.delete_record(record_id)
          HubSpotResponse.create_response_for_deleted_record(record_id)
        end
      end
    end
  end
end
