FROM elixir

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get install -y build-essential postgresql-client
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get install nodejs

COPY ./ /code
WORKDIR /code

RUN mix local.hex --force
RUN mix local.rebar --force

EXPOSE 4000
RUN /bin/bash