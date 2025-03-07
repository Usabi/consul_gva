load Rails.root.join("app", "models", "machine_learning.rb")

class MachineLearning
  private

    def export_proposals_to_json
      create_data_folder
      filename = data_folder.join(MachineLearning.proposals_filename)
      Proposal::Exporter.new(Array.new).to_json_file(filename)
    end
end
