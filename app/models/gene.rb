class Gene
  include Utilities

  class << self

    def load_from_rdfstore
      sparql = "SELECT ?gene_name WHERE { ?gene #{RDF.type.to_ntriples} #{Constants::RGD_CORE['Gene'].to_ntriples} . ?gene #{DC11.title.to_ntriples} ?gene_name . } ORDER BY ?gene_name"
      result = VIRTUOSO_SERVER.query(sparql)
      clean_solutions(result, :gene_name)
    end

    def find_from_rdfstore(chromosome, starts_at, ends_at, terms=[])
      term_string = ""
      if terms.any?
        term_string = "?gene_id #{Constants::RGD_CORE['Annotation'].to_ntriples} ?gene_annotation . "
        term_array = terms.map do |term|
          term_uri = RDF::URI.new(term)
          "{ ?gene_annotation #{Constants::OBO_OWL['hasDbXref'].to_ntriples} #{term_uri.to_ntriples} }"
        end
        term_string << term_array.join(" UNION ")
      end

      ActiveSupport::Notifications.instrument("query.rdfstore", :query => {'format' => 'gene', 'chromosome' => chromosome, 'starts_at' => starts_at, 'ends_at' => ends_at}) do
        sparql = "SELECT DISTINCT ?gene_id ?gene_symbol WHERE { #{term_string} ?gene_id #{Constants::RGD_CORE['GenomicLocation'].to_ntriples} ?location . ?location #{Constants::RGD_CORE['Chromosome'].to_ntriples} \"#{chromosome}\" . ?location #{Constants::RGD_CORE['Start'].to_ntriples} ?start FILTER (xsd:integer(?start) >= #{starts_at}) . ?location #{Constants::RGD_CORE['Start'].to_ntriples} ?start FILTER (xsd:integer(?start) <= #{ends_at}) . ?location #{Constants::RGD_CORE['Stop'].to_ntriples} ?stop FILTER (xsd:integer(?stop) <= #{ends_at}) . ?location #{Constants::RGD_CORE['Stop'].to_ntriples} ?stop FILTER (xsd:integer(?stop) >= #{starts_at}) . ?gene_id #{DC11.title.to_ntriples} ?gene_symbol . ?gene_id #{RDF.type.to_ntriples} #{Constants::RGD_CORE['Gene'].to_ntriples} . } ORDER BY ?gene_symbol"
        Rails.logger.debug(sparql)
        result = VIRTUOSO_SERVER.query(sparql)
        clean_solutions_hash(result, ['gene_id', 'gene_symbol'])
      end
    end

  end

end
