class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  def after_sign_in_path_for(resource)
    if resource.is_a?(User)
      user_url(resource)
    else
      super
    end
  end

  protected
    def pluralize(count, singular, plural = nil)
      "#{count || 0} " + ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
    end

end
