shared_examples "csv exporter" do |factory_name, exporter_class, expected_headers|
  let(:records) { create_list(factory_name, 3) }
  let(:exporter) { exporter_class.new(records) }

  describe "#to_csv" do
    it "generates a CSV with headers" do
      csv = exporter.to_csv
      csv_lines = csv.split("\n")

      expect(csv_lines.first).to eq(expected_headers.join(","))
    end

    it "includes all records" do
      csv = exporter.to_csv
      csv_lines = csv.split("\n")

      # Header + 3 records
      expect(csv_lines.count).to eq(4)
    end

    it "includes record data in CSV" do
      csv = exporter.to_csv

      records.each do |record|
        expect(csv).to include(record.id.to_s)
      end
    end

    it "generates valid CSV format" do
      csv = exporter.to_csv

      expect { CSV.parse(csv, headers: true) }.not_to raise_error
    end
  end
end
