FROM julia:1.6-buster

RUN useradd --create-home --shell /bin/bash genie

RUN mkdir /home/genie/app
COPY . /home/genie/app
WORKDIR /home/genie/app

RUN chgrp root /home/genie
RUN chown genie:root -R *
RUN chmod -R g+rw /home/genie/app
RUN chmod g+rwX bin/server
RUN chmod -R g+rwX /usr/local/julia

USER genie:root

ENV JULIA_DEPOT_PATH "/home/genie/.julia"
ENV GENIE_ENV "prod"
ENV HOST "0.0.0.0"
ENV PORT "8000"
ENV EARLYBIND "true"

RUN julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate(); Pkg.precompile(); "

RUN rm -rf /genie/.julia/registries

RUN chmod -R -f g+rwX \
    /home/genie/.julia/packages \
    /home/genie/.julia/artifacts \
    /home/genie/.julia/compiled \
    /home/genie/.julia/logs

EXPOSE 8000/tcp
# EXPOSE 8000/udp

CMD ["bin/server"]
