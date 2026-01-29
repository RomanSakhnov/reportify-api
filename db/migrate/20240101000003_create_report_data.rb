class CreateReportData < ActiveRecord::Migration[7.1]
  def change
    create_table :report_data do |t|
      t.string :report_type, null: false
      t.date :date, null: false
      t.jsonb :data, default: {}, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :report_data, %i[report_type date], unique: true
    add_index :report_data, :date
  end
end
