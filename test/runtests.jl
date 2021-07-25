using Test
using Genie
using HTTP

const app_dir = dirname(@__DIR__)

# TODO: run app in "test" environment
# TODO: set up temporary folder for database

@testset "Testing GenieWebApp.jl" begin
    cd(app_dir)
    loadapp(app_dir; autostart=false)
    host = "127.0.0.1"
    port = 8000
    server = up(port, host; open_browser=false)
    response = HTTP.request("GET", "http://$(host):$(port)/")
    @test response.status == 200
    down()
end
