FROM ruby:2.5.7

ENV APP_HOME /app

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile $APP_HOME/
ADD Gemfile.lock $APP_HOME/

RUN bundle install --without development test

ADD main.rb $APP_HOME
ADD apps $APP_HOME
ADD public $APP_HOME

EXPOSE 4567

CMD ["bundle", "exec", "ruby", "--host", "0.0.0.0", "-p", "4567"]
