class Rule

  class << self
    def generate_rules(filename)
      RDF::Writer.open("#{filename}.nt") do |writer|
        graph = RDF::Graph.new('ruleset')
        graph = subclass(graph)
        graph = subproperty(graph)
        graph.each_statement do |statement|
          writer << statement
        end
      end
    end

    def subclass(graph)
      sparql = "SELECT DISTINCT ?s ?o WHERE { ?s #{RDFS['subClassOf'].to_ntriples} ?o FILTER regex(?o, '^http', 'i') }"
      result = VIRTUOSO_SERVER.query(sparql)
      result.each do |terms|
        graph << [terms[:s], RDFS.subClassOf, terms[:o]]
      end
      graph
    end

    def subproperty(graph)
      sparql = "SELECT DISTINCT ?s ?o WHERE {
      ?s #{RDFS['subClassOf'].to_ntriples} ?a .
      ?a #{RDF['type'].to_ntriples} #{OWL['Restriction'].to_ntriples} .
      ?a #{OWL['onProperty'].to_ntriples} #{Constants::PURL_OWL['OBO_REL#part_of'].to_ntriples} .
      ?a #{OWL['someValuesFrom'].to_ntriples} ?o .
       FILTER regex(?o, '^http', 'i') }"
      result = VIRTUOSO_SERVER.query(sparql)
      result.each do |terms|
        graph << [terms[:s], RDFS.subClassOf, terms[:o]]
      end
      graph
    end
  end


end