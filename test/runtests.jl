using Test
using HTTP
using HTTP.ExceptionRequest
using Genie
using SearchLight

const app_dir = dirname(@__DIR__)

# Create `data` directory if it doesn't exist.
mkpath(joinpath(app_dir, "data"))

const tmp_dir = mktempdir()
const tmp_database = joinpath(tmp_dir, "test.sqlite")
const link_database = joinpath(app_dir, "data", "test.sqlite")

# Create symbolic link from `data/test.sqlite` to a temporary database.
rm(link_database; force=true)
touch(tmp_database)
symlink(tmp_database, link_database)

# Set genie environment to `test`.
ENV["GENIE_ENV"] = "test"

@testset "Testing GenieWebApp.jl" begin
    # Load the application in the project root directory.
    cd(app_dir)
    loadapp(app_dir; autostart=false)

    # Set port and host.
    port = 8000
    host = "127.0.0.1"
    base = "http://$(host):$(port)"

    # Open server with port and host values without opening browser.
    server = up(port, host; open_browser=false)

    # Views requests
    response = HTTP.request("GET", "$(base)/")
    @test response.status == 200

    @test_throws StatusError HTTP.request("GET", "$(base)/non-existent")

    response = HTTP.request("GET", "$(base)/items")
    @test response.status == 200

    # response = HTTP.request("POST", "$(base)/items",
    #     [],
    #     HTTP.Form(Dict("a"=>"Hello World", "b"=>"1")))
    # @test response.status == 200

    # API requests
    response = HTTP.request("GET", "$(base)/api/items")
    @test response.status == 200

    response = HTTP.request("POST", "$(base)/api/items",
        [("Content-Type", "application/json")],
        """{"a":"Hello World", "b":"2"}""")
    @test response.status == 200

    @test_throws(
        StatusError,
        HTTP.request("POST", "$(base)/api/items",
        [("Content-Type", "application/json")],
        """{"a":"Hello World", "b":"Text"}""")
    )

    # Close the server.
    down()
end
