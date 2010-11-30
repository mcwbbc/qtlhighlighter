When /^I click on the "([^"]*)" autocomplete option$/ do |link_text|
  # this should work in future versions but no in current stable
  # page.evaluate_script %Q{ $('.ui-menu-item a:contains("#{link_text}")').trigger("mouseenter").click(); }
  page.driver.browser.execute_script %Q{ $('.ui-menu-item a:contains("#{link_text}")').trigger("mouseenter").click(); }
end

When /^I wait for (\d+) seconds?$/ do |secs|
  sleep secs.to_i
end

Given /^the following ontology terms exist:$/ do |ontology_terms_table|
  ontology_terms_table.hashes.each do |h|
    Factory.create(:ontology_term, h)
  end
end

Given /^the following fake qtl urls exist:$/ do |fake_url_table|
  fake_url_table.hashes.each do |h|
    url = /.+sparql\?query=SELECT.+chromosome.+start.+stop.+#{h['symbol']}.+/
  #  fw = FakeWeb.register_uri(:get, url, :body => h['content'], :content_type => "application/json")
  end
end

Given /^the following fake gene urls exist:$/ do |fake_url_table|
  fake_url_table.hashes.each do |h|
    url = /.+sparql\?query=PREFIX.+gene_name.+#{h['chromosome']}.+#{h['starts_at']}.+#{h['ends_at']}.+/
  #  fw = FakeWeb.register_uri(:get, url, :body => h['content'], :content_type => "application/json")
  end
end

Given /^the following qtls exist:$/ do |qtls_table|
  qtls_table.hashes.each do |h|
    Factory.create(:qtl, h)
  end
end

And /^I upload "([^\"]*)"$/ do |filename|
  path = File.join(::Rails.root, filename)
  attach_file("file", path)
end
