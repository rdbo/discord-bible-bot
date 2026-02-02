FROM alpine:edge

RUN apk update
RUN apk add ruby ruby-doc ruby-rdoc ruby-full ruby-dev ruby-bundler git
WORKDIR /app
COPY Gemfile lib bin assets discord-bible-bot .

RUN adduser -S runner
RUN chown -R runner:root /app
USER runner

ENV GEM_HOME="/app/.gem"
RUN mkdir -p "$GEM_HOME"
RUN gem install bundler
RUN rm /app/Gemfile.lock
RUN bundle install
CMD "/app/discord-bible-bot"
