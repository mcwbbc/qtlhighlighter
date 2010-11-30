class PagesController < ApplicationController

  def home
  end

  def css_test
  end

  def kaboom
    User.first.kaboom!
  end

  def help
  end

  def upgrade
  end

  def graphs
  end

end
