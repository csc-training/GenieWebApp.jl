module CreateTableItems

import SearchLight.Migrations: create_table, column, primary_key, add_index, drop_table

function up()
  create_table(:items) do
    [
      primary_key()
      column(:a, :string, limit=100)
      column(:b, :int)
    ]
  end

  add_index(:items, :a)
end

function down()
  drop_table(:items)
end

end
