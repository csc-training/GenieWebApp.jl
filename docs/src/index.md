```@meta
CurrentModule = GenieWebApp
```

# Introduction
## Goal
Our goal with this tutorial is to demonstrate a practical, step-by-step approach for getting started with developing web applications with Julia language and Genie framework, deploying them on a cloud platform, and exposing them to users over the internet. As our deployment options, we explore traditional virtual machines and modern container platforms.

We attempt to facilitate learning by first developing the web application locally, that is, on our personal computer, to demonstrate fundamental web technologies. From local development, it is easier to progress to deploying the application to the virtualized cloud environments, initially to a virtual machine and then to a container platform. Additionally, we begin by performing deployment steps manually using the web and command-line interfaces. Then, we progress towards automating them using a command-line interface and configuration management.


## Why Julia Language?
[**Julia language**](https://julialang.org/) is a relatively new, general-purpose programming language designed to address challenges in technical computing such as the *expression problem* and the *two-language problem*. It addresses the expression problem using multiple-dispatch as a paradigm that enables highly expressive syntax and composable code and the two-language problem using just-in-time compilation to create high-performance code. For these reasons, the Julia language is gaining popularity in scientific computing and data analysis because it offers significant improvements in performance and composability. That is, how existing code and libraries work with one another.

Traditionally, scientific computing programs run without user interaction as batch jobs on computer clusters and supercomputers. However, modern scientific computing and data analytics increasingly requires user interaction. For example, an analytics application may receive data from multiple sources over the internet, process the data, perform analysis, store results, and offer them to end-users on demand via an API. We can expose the analytics application over the internet as an on-demand service by wrapping it inside a web application or microservice and deploying it into a cloud platform. Given the advantages of the Julia language, it would be natural to develop the analytics application and the web application or microservice in Julia language.


## About Cloud Computing
For getting started with web application development and cloud computing, we assume basic knowledge of the Linux operating system, Git version control system, Julia language, and SQL databases. We recommend reading the [Linux basics tutorial](https://docs.csc.fi/support/tutorials/env-guide/overview/) for understanding basic Linux command line usage. We will use the *Rahti* and *Pouta* cloud [computing resources](https://research.csc.fi/computing) provided by *CSC*, the Science Center for IT in Finland. Their documentation explains the main [concepts of cloud computing](https://docs.csc.fi/cloud/concepts/), such as how cloud computing differs from traditional hosted services and high-performance computing, and basic terminology such as infrastructure-, platform-, and software-as-service. If you are a part of Finnish research or higher education institutions, you can access many CSC services free of charge. If you plan to use CSC services, you can create a new project on [**My CSC**](https://my.csc.fi) and then apply for access to [Pouta](https://docs.csc.fi/accounts/how-to-add-service-access-for-project/) and [Rahti](https://docs.csc.fi/cloud/rahti/access/). Otherwise, you can try a different cloud computing platform such as Amazon Web Services, Microsoft Azure, Google Cloud Platform, or Digital Ocean.


## Developing a Genie Application
In the *Developing a Genie Application* section, we explain how to create a web application with [**Genie framework**](https://genieframework.com/), a full-stack Model-View-Controller (MVC) web framework similar to Ruby-on-Rails and Django. You can watch the [MVC explained in 4 minutes](https://www.youtube.com/watch?v=DUg2SWWK18I) for an overview of how they work.

We will use [SQLite](https://www.sqlite.org/index.html) database as a backing service in our Genie application. SQLite runs as part of the application and writes the database into a single database file to a specified location on the file system, which we should mount to persistent storage. SQLite works well for applications with small amounts of concurrent writes to the database. However, we should use a client-Server database such as PostgreSQL and MySQL if we need to perform many concurrent writes.

We recommend the [MDN Web Docs](https://developer.mozilla.org/) as a general resource about web technologies, web development, and developer tools. Especially, the sections about essential web technologies such as HTTP and HTML are helpful.

Another helpful resource is the [REST API Tutorial](https://restfulapi.net/) website. It covers the design principles of REST API, an extensively used architectural style for distributed hypermedia systems, for example, web applications. In practice, it defines how we can interact with the system and access resources, such as web pages or files.

Furthermore, we recommend [The Twelve-Factor App](https://12factor.net/) guidelines for an overview of best practices of developing web applications. It explains best practices for configuring and deploying applications, automating these processes, and dealing with backing services such as databases.

As a side note, it is also possible to develop [microservices](https://www.youtube.com/watch?v=uLhXgt_gKJc) in Julia using the [Julia SDK](https://www.youtube.com/watch?v=KixO3udfcKA) if you want to create a lightweight, customizable, single-purpose application without a front-end.


## Deploying to Virtual Machine using OpenStack (v5.5)
In the *Deploying with OpenStack* section, we explain how to deploy the application manually from source to a virtual machine on the [**Pouta**](https://pouta.csc.fi/) cloud service using [OpenStack](https://www.openstack.org/) web interface and Linux command line on the virtual machine. We also show how to set persistent storage for the application.


## Deploying to OpenShift Container Platform (v3.11)
In the *Deploying with OpenShift* section, we explain how to create a [**Docker**](https://www.docker.com/) container for the application and build and run a container image. Modern cloud architecture revolves around containers and container orchestration. We recommend reading the articles on [Demystifying Containers](https://github.com/saschagrunert/demystifying-containers) to understand how containers work in Linux. We continue by explaining how to deploy the application's container image to the [**Rahti**](https://rahti.csc.fi/) container platform using [OpenShift](https://www.openshift.com/) web interface. We also show how to set persistent storage for the application.


```@index
```

```@autodocs
Modules = [GenieWebApp]
```
