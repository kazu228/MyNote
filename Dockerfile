FROM ruby:2.5.1
RUN apt-get update -qq && apt-get install -y nodejs
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
# bundlerのバージョンを2系にする
ENV BUNDLER_VERSION='2.1.4'
RUN gem install bundler --no-document -v '2.1.4'

# Gemfileのbundle install
RUN bundle install
ADD . $APP_ROOT

COPY . /myapp

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]