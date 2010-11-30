# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  FLASH_NOTICE_KEYS = [:success, :notice, :warning, :failure, :invalid, :alert, :unauthenticated, :unconfirmed, :invalid_token, :timeout, :inactive, :locked]

  def admin?
    !current_user.blank? && current_user.admin?
  end

  def admin_only(&block)
    if !current_user.blank? && current_user.admin?
      block.call
    end
  end

  def me?(user)
    user == current_user
  end

  def login_logout
    if user_signed_in?
      link_to(t('link.sign-out'), destroy_user_session_url, :confirm => t('confirm.areyousure'))
    else
      content_tag(:div, link_to(t('link.sign-in'), new_user_session_url)+" - "+link_to(t('link.sign-up'), new_registration_url(User)), :class => 'login-box')
    end
  end

  def flash_messages
    return unless messages = flash.keys.select{|k| FLASH_NOTICE_KEYS.include?(k)}
    formatted_messages = messages.map do |type|
      content_tag(:div, :class => type.to_s) do
        message_for_item(flash[type], flash["#{type}_item".to_sym])
      end
    end
    flash.clear
    formatted_messages.join
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      message % link_to(*item)
    else
      message % item
    end
  end

  def error_messages_for(resource)
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = "#{pluralize(resource.errors.count, "error")} prohibited this #{resource.class.name.downcase} from being saved:"

    html = content_tag(:div, :class => 'error_explanation') do
      content_tag(:h2, sentence)
      content_tag(:ul, messages.html_safe)
    end
    html.html_safe
  end

  def page_title(title)
    content_tag(:div, title, :class => 'page-title')
  end

end
