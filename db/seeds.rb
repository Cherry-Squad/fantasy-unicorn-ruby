# frozen_string_literal: true

User.find_or_create_by(username: 'admin') do |user|
  user.email = 'info@a6raywa1cher.com'
  user.password = '123456'
end

puts 'seeded admin'

tickers = %w[TSLA AAPL NVDA AMD INTC AMZN MSFT
             F FB GOOGL PFE BAC JPM GM NFLX
             DIS MA PYPL BA ADBE V BABA MRNA
             CSCO MU WMT T QCOM KO TOYOF SPCE
             SNAP TWTR]

tickers.each do |ticker|
  Stock.find_or_create_by(name: ticker)
  puts "seeded stock #{ticker}"
end
