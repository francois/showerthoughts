# frozen_string_literal: true
require "sinatra"
require "sequel"
require "logger"

configure do
  DB = Sequel.connect(ENV.fetch("DATABASE_URL", "postgresql://localhost/shower_development"), logger: Logger.new(STDERR))
end

def hours_between(a, b)
  raise ArgumentError, "a" unless a
  raise ArgumentError, "b" unless b
  ((a - b) / 3600).round
end

# Given a list of shower times, return a list of shower/pause times
def split_showers(showers)
  showers.
    each_slice(2).
    flat_map{|before, after|
      next unless after
      [ [:shower, before], [:pause, hours_between(before, after)] ].
      push([ :shower, showers.last ]).
      unshift([ :pause, hours_between(Time.now, showers.first) ])
    }
end

get "/favicon.ico" do
  [404, {}, ""]
end

get "/:family_id" do |family_id|
  @showers = DB[:showers].
    select_append(
      Sequel::SQL::PlaceholderLiteralString.new("round(extract(epoch from coalesce(lag(shower_at) over (partition by family_id, name order by shower_at desc), current_timestamp) - shower_at) / 3600)", []).as(:delta),
      Sequel::SQL::PlaceholderLiteralString.new("shower_at AT TIME ZONE 'America/Montreal", []).as(:local_shower_at),
    ).
    where(family_id: family_id).
    order(:family_id, :name, Sequel.desc(:shower_at)).
    each_with_object(Hash.new{|h, k| h[k] = Array.new}){|row, memo| memo[row[:name]] << row[:delta] << row[:local_shower_at]}. # group_by(row[:name])
    map{|name, rows| [name, rows.flatten.first(10)]}.
    to_h

  @family_id = family_id
  erb :family
end

post "/:family_id/:name" do |family_id, name|
  DB[:showers].
    insert(family_id: family_id, name: name, shower_at: Time.now)
  redirect "/#{family_id}"
end
