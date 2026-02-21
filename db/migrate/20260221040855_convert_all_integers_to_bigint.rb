class ConvertAllIntegersToBigint < ActiveRecord::Migration[7.0]
  def up
    connection = ActiveRecord::Base.connection

    skip_tables = %w[schema_migrations ar_internal_metadata]

    connection.tables.each do |table|
      next if skip_tables.include?(table)
      columns = connection.columns(table)

      columns.each do |col|
        next unless col.type == :integer
        next if col.name == "id"
        next if col.limit == 8
        say "Converting #{table}.#{col.name} to bigint", true
        change_column table, col.name, :bigint
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Integer->Bigint conversion is not automatically reversible."
  end
end