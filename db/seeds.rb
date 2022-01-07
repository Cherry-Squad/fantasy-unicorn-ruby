# frozen_string_literal: true

User.create(username: 'admin', email: 'info@a6raywa1cher.com', password: '123456')

tickers = %w[TSLA AAPL NVDA AMD INTC AMZN MSFT
             F FB GOOGL PFE BAC JPM GM NFLX
             DIS MA PYPL BA ADBE V BABA MRNA
             CSCO MU WMT T QCOM KO TOYOF SPCE
             SNAP TWTR]

tickers.each do |ticker|
  Stock.create(name: ticker)
end
