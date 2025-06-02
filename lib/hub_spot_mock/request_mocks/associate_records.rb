# frozen_string_literal: true

module HubSpotMock
  module RequestMocks
    class AssociateRecords < RequestMockBase
      def uri
        "#{HUBSPOT_API_URL}/crm/v{version}/objects/{table_name1}/{record1_id}/associations"\
          '/{table_name2}/{record2_id}{/association_type*}'
      end

      def stub
        WebMock.stub_request(:put, template).to_return do |request|
          uri_match = template.match(Addressable::URI.parse(request.uri))
          base_name = extract_base(request)
          table1 = check_if_table_was_created(base_name, uri_match['table_name1'])
          table2 = check_if_table_was_created(base_name, uri_match['table_name2'])

          raise ArgumentError, 'invalid associations' if uri_match['record1_id'].nil? || uri_match['record2_id'].nil?

          table1.fetch_record(uri_match['record1_id'])
          table2.fetch_record(uri_match['record2_id'])
          association_types = if uri_match['association_type']
                                uri_match['association_type'].map(&:to_i)
                              elsif request.body && JSON.parse(request.body).size.positive?
                                JSON.parse(request.body).map { |assoc| assoc['associationTypeId'].to_i }
                              else
                                ['default']
                              end

          base = HubSpotStore.bases.fetch(base_name)
          assoc_table = base.fetch_table('associations')
          association_types.each do |association_type|
            assoc_table.create_association(table1.table_name, uri_match['record1_id'], table2.table_name,
                                           uri_match['record2_id'], association_type)
          end

          { body: {}.to_json, headers: {} }
        end
      end
    end
  end
end
