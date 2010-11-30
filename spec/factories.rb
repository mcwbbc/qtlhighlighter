Factory.define :user, :class => User do |u|
  u.email 'minimal@example.com'
  u.password 'test1234'
  u.password_confirmation 'test1234'
end

Factory.define :ontology_term, :class => OntologyTerm do |m|
  m.uri "<http://purl.org/obo/owl/CL#CL_0000000>"
  m.name "cell"
end

Factory.define :qtl, :class => Qtl do |m|
  m.symbol "Bp1"
end
