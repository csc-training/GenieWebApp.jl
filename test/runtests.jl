using Test
using Genie
using SearchLight
using HTTP

const app_dir = dirname(@__DIR__)
const tmp = mktempdir()
const tmp_database = joinpath(tmp, "test.sqlite")
const link_database = joinpath(app_dir, "data", "test.sqlite")

ENV["GENIE_ENV"] = "test"

@testset "Testing GenieWebApp.jl" begin
    rm(link_database; force=true)
    touch(tmp_database)
    symlink(tmp_database, link_database)

    cd(app_dir)
    loadapp(app_dir; autostart=false)
    host = "127.0.0.1"
    port = 8000
    server = up(port, host; open_browser=false)
    response = HTTP.request("GET", "http://$(host):$(port)/")
    @test response.status == 200
    down()
end
