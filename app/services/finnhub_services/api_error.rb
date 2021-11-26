# frozen_string_literal: true

module FinnhubServices
  class ApiError < StandardError
  end

  class TooManyRequests < StandardError
  end
end
