using GenieWebApp
using Documenter

DocMeta.setdocmeta!(GenieWebApp, :DocTestSetup, :(using GenieWebApp); recursive=true)

makedocs(;
    modules=[GenieWebApp],
    authors="Jaan Tollander de Balsch",
    repo="https://github.com/jaantollander/GenieWebApp.jl/blob/{commit}{path}#{line}",
    sitename="GenieWebApp.jl",
    format=Documenter.HTML(;
        # prettyurls=get(ENV, "CI", "false") == "true",
        prettyurls = true,
        canonical="https://jaantollander.github.io/GenieWebApp.jl",
        assets=String[],
    ),
    pages=[
        "Introduction" => "index.md",
        "Developing Genie Applications" => [
            joinpath("genie", "developing-the-application.md"),
            joinpath("genie", "testing-requests-with-http-jl.md"),
        ],
        "Deploying with OpenStack" => [
            joinpath("openstack", "deploying-manually-to-virtual-machine.md"),
        ],
        "Deploying with OpenShift" => [
            joinpath("openshift", "creating-docker-container.md"),
            joinpath("openshift", "deploying-manually-to-container-platform.md"),
        ],
    ],
)

deploydocs(;
    repo="github.com/jaantollander/GenieWebApp.jl",
)
