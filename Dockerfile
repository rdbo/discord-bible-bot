FROM alpine:edge

RUN apk update
RUN apk add ruby ruby-doc ruby-rdoc ruby-full ruby-dev ruby-bundler git
WORKDIR /app
COPY . .

RUN adduser -S runner
RUN chown -R runner:root /app
USER runner

ENV GEM_HOME="/app/.gem"
RUN mkdir -p "$GEM_HOME"
RUN rm Gemfile.lock
RUN gem install bundler
RUN bundle install

CMD "./discord-bible-bot"
