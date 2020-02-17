FROM ruby:2.5.3

WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

RUN gem install bundler
RUN bundle install --system

ADD . /app

RUN bundle install --system

EXPOSE 4567

CMD ["bundle", "exec", "ruby", "main.rb", "-p", "4567"]
