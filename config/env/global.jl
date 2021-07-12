# Place here configuration options that will be set for all environments

using Genie
using SearchLight
using SearchLightSQLite

@info "Writing the secrets file"
Genie.Generator.write_secrets_file()

@info "Creating database and tables"
SearchLight.Configuration.load() |> SearchLight.connect
try
    SearchLight.Migrations.create_migrations_table()
    SearchLight.Migrations.last_up()
catch
    nothing
end
