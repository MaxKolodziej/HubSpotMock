# frozen_string_literal: true

module HubSpotMock
  class HubSpotResponse
    def self.create_response_for_record(table, id)
      { body: { 'id' => id, 'properties' => table.fetch_record(id) }.to_json, headers: {} }
    end

    def self.create_response_for_collection(table, records, properties = [])
      {
        headers: {},
        body: {
          results: records.map do |record_id, _values|
            { id: record_id, properties: table.fetch_record(record_id, properties) }
          end
        }.to_json
      }
    end

    def self.create_response_for_deleted_record(record_id)
      { body: { 'id' => record_id, 'deleted' => true }.to_json, headers: {} }
    end

    def self.create_response_for_associations(rec_id, associations)
      associations_grouped_by_related_object = associations.group_by do |association|
        association[:table] + association[:record_id]
      end

      {
        headers: {},
        body: {
          results:
          {
            from: { id: rec_id },
            to: associations_grouped_by_related_object.map do |_association_key, associations_by_relation|
              {
                toObjectId: associations_by_relation.first[:record_id],
                associationTypes: associations_by_relation.map do |association|
                  {
                    category: association[:association_type],
                    typeId: 'TODO', # TODO: add type ids
                    label: 'TODO'
                  }
                end
              }
            end
          }
        }.to_json
      }
    end
  end
end
