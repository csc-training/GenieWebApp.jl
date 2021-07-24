using Test
using Genie

# TODO: run app in "test" environment
const root = dirname(@__DIR__)
Genie.loadapp(root; autostart=false)

@test 1 == 1
