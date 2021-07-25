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
        "developing-genie-web-application.md",
        "testing-requests-with-http-jl.md",
        "creating-docker-container.md",
        "deploying-to-container-cloud-using-openshift.md",
        "deploying-to-virtual-machine-using-openstack.md",
    ],
)

deploydocs(;
    repo="github.com/jaantollander/GenieWebApp.jl",
)
