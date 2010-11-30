namespace :load do

  desc "copy the qtls from rdfstore and insert them into mysql qtls table"
  task :qtls, :needs => :environment do |t, args|
    Qtl.insert_from_rdfstore
  end

  desc "copy the terms from the rdf store into mysql ontology_terms table"
  task :ontology_terms, :needs => :environment do |t, args|
    OntologyTerm.insert_from_rdfstore
  end

end