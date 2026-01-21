class PhpTestController < ApplicationController
  skip_authorization_check
  def censo
    file = params["file"]
    @result = `php -f bin/#{file}`
  end
end
