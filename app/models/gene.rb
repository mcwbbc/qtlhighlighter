class Gene
  include Utilities

  class << self

    def load_from_rdfstore
      result = VIRTUOSO_SERVER.select(:gene_name).distinct(true).where([:gene, RDF['type'], Constants::RGD_CORE['Gene']]).where([:gene, DC11['title'], :gene_name]).order(:gene_name)
      clean_solutions(result.solutions, 'gene_name')
    end

    def find_from_rdfstore_via_pathway_for_id(gene_id)
      gene_uri = RDF::URI.new(gene_id)
      ActiveSupport::Notifications.instrument("query.rdfstore", :query => {'format' => 'gene', 'gene_id' => gene_id}) do
        result = VIRTUOSO_SERVER.select(:gene_id, :gene_symbol, :pathway_ontology_id, :pathway_name).distinct(true).where([gene_uri, Constants::RGD_CORE['hasOntologyAnnotation'], :pathway_annotation]).where([:pathway_annotation, Constants::RGD_CORE['hasOntologyId'], :pathway_ontology_id]).where([:gene_id, DC11['title'], :gene_symbol]).where([:gene_id, Constants::RGD_CORE['hasOntologyAnnotation'], :annotation]).where([:annotation, Constants::RGD_CORE['hasOntologyId'], :pathway_ontology_id]).where([:pathway_ontology_id, RDFS['label'], :pathway_name]).filter("regex(?pathway_ontology_id, '^http://purl.org/obo/owl/PW', 'i')").order(:gene_id)
        clean_solutions_hash(result.solutions, ['gene_id', 'gene_symbol', 'pathway_ontology_id', 'pathway_name'])
      end
    end

    def find_from_rdfstore_via_pathway(chromosome, starts_at, ends_at, terms=[])
      cleaned = []
      ActiveSupport::Notifications.instrument("query.rdfstore", :query => {'format' => 'for_pathway', 'chromosome' => chromosome, 'starts_at' => starts_at, 'ends_at' => ends_at}) do
        query = VIRTUOSO_SERVER.select(:qtl_gene_id, :qtl_gene_symbol, :pathway_ontology_id, :pathway_name).distinct(true).where([:qtl_gene_id, DC11['title'], :qtl_gene_symbol]).where([:qtl_gene_id, RDF['type'], Constants::RGD_CORE['Gene']]).where([:qtl_gene_id, Constants::RGD_CORE['hasOntologyAnnotation'], :qtl_pathway_annotation]).where([:qtl_pathway_annotation, Constants::RGD_CORE['hasOntologyId'], :pathway_ontology_id]).where([:pathway_ontology_id, RDFS['label'], :pathway_name]).where([:qtl_gene_id, Constants::RGD_CORE['hasLocation'], :location]).where([:location, Constants::RGD_CORE['hasChromosome'], :chr]).where([:location, Constants::RGD_CORE['hasChrStart'], :start]).where([:location, Constants::RGD_CORE['hasChrStop'], :stop]).filter("xsd:integer(?start) >= #{starts_at}").filter("xsd:integer(?start) <= #{ends_at}").filter("xsd:integer(?stop) >= #{starts_at}").filter("xsd:integer(?stop) <= #{ends_at}").filter("?chr = '#{chromosome}'").filter("regex(?pathway_ontology_id, '^http://purl.org/obo/owl/PW', 'i')").order(:qtl_gene_id)
#        Rails.logger.debug("SPARQL: #{query}")
        cleaned = clean_solutions_hash(query.solutions, ['qtl_gene_id', 'qtl_gene_symbol', 'pathway_ontology_id', 'pathway_name'])
      end

      cleaned.each do |located_gene_hash|
        located_gene_hash['pw_genes'] = {}
        pathway_uri = RDF::URI.new(located_gene_hash['pathway_ontology_id'])
        ActiveSupport::Notifications.instrument("query.rdfstore", :query => {'format' => 'gene_hash_for_pathway', 'pathway_ontology_id' => pathway_uri}) do
          query = VIRTUOSO_SERVER.select(:gene_id, :gene_symbol).distinct(true).where([:gene_id, DC11['title'], :gene_symbol]).where([:gene_id, RDF['type'], Constants::RGD_CORE['Gene']]).where([:gene_id, Constants::RGD_CORE['hasOntologyAnnotation'], :pathway_annotation]).where([:pathway_annotation, Constants::RGD_CORE['hasOntologyId'], :pathway_ontology_id]).filter("?pathway_ontology_id = #{pathway_uri.to_ntriples}").order(:gene_id)
          pathway_gene_array = clean_solutions_hash(query.solutions, ['gene_id', 'gene_symbol'])

          pathway_gene_array.each do |pathway_gene_hash|
            if located_gene_hash['qtl_gene_id'] != pathway_gene_hash['gene_id']
              located_gene_hash['pw_genes'][pathway_gene_hash['gene_id']] = {'gene_symbol' => pathway_gene_hash['gene_symbol']}
            end
          end
        end
      end

      ag_hash = {}
      cleaned.each do |solution|
        if ag_hash.has_key?(solution['qtl_gene_id'])
          ag_hash[solution['qtl_gene_id']]['pathways'][solution['pathway_ontology_id']] = {'pathway_name' => solution['pathway_name'], 'pw_genes' => solution['pw_genes']}
        else
          ag_hash[solution['qtl_gene_id']] = {'qtl_gene_symbol' => solution['qtl_gene_symbol'], 'pathways' => { solution['pathway_ontology_id'] => {'pathway_name' => solution['pathway_name'], 'pw_genes' => solution['pw_genes']}}}
        end
      end

      qtl_gene_ids = ag_hash.keys
      qtl_gene_ids.each do |qtl_gene_id|
        ag_hash[qtl_gene_id]['pathways'].keys.each do |pathway_key|
          pathway = ag_hash[qtl_gene_id]['pathways'][pathway_key]
          pathway['genes'] = {}
          pathway['pw_genes'].keys.each do |pw_gene_id|
            matched_terms = Gene.find_matched_terms_for_gene_id(pw_gene_id, terms)
            if matched_terms.any?
              pathway['genes'][pw_gene_id] = {'gene_name' => pathway['pw_genes'][pw_gene_id]['gene_symbol'], 'terms' => matched_terms}
            end
          end
          pathway.delete('pw_genes')
        end
      end

      qtl_gene_ids.each do |qtl_gene_id|
        ag_hash[qtl_gene_id]['pathways'].keys.each do |pathway_key|
          pathway = ag_hash[qtl_gene_id]['pathways'][pathway_key]
          ag_hash[qtl_gene_id]['pathways'].delete(pathway_key) if pathway['genes'].empty?
        end
        ag_hash.delete(qtl_gene_id) if ag_hash[qtl_gene_id]['pathways'].empty?
      end

      ag_hash
    end

    def find_matched_terms_for_gene_id(gene_id, terms)
      term_string = ""
      cleaned_solutions = []
      gene_uri = RDF::URI.new(gene_id)
      if terms.any?
        terms.each do |term|
          term_uri = RDF::URI.new(term)
          term_string = "#{gene_uri.to_ntriples} #{Constants::RGD_CORE['hasOntologyAnnotation'].to_ntriples} ?gene_annotation .
          { ?gene_annotation #{Constants::RGD_CORE['hasOntologyId'].to_ntriples} #{term_uri.to_ntriples} .
            #{term_uri.to_ntriples} #{RDFS['label'].to_ntriples} ?subterm_name .
            #{term_uri.to_ntriples} #{Constants::OBO_OWL['hasOBONamespace'].to_ntriples} ?subterm_ontology .
          } UNION
          { ?gene_annotation #{Constants::RGD_CORE['hasOntologyId'].to_ntriples} ?subterm_id .
            ?subterm_id #{RDFS['label'].to_ntriples} ?subterm_name .
            ?subterm_id #{Constants::OBO_OWL['hasOBONamespace'].to_ntriples} ?subterm_ontology .
            ?subterm_id #{RDFS['subClassOf'].to_ntriples} #{term_uri.to_ntriples} OPTION (T_DISTINCT) .
           }"
          ActiveSupport::Notifications.instrument("query.rdfstore", :query => {'format' => 'for_gene_id', 'gene_id' => gene_id, 'term' => term}) do
            sparql = "DEFINE input:inference 'ruleset' SELECT DISTINCT ?subterm_id ?subterm_name ?subterm_ontology WHERE { #{term_string}
            #{gene_uri.to_ntriples} #{DC11['title'].to_ntriples} ?gene_symbol .
            } ORDER BY ?gene_symbol"
#            Rails.logger.debug("SPARQL: #{sparql}")
            result = VIRTUOSO_SERVER.query(sparql)
            cleaned_solutions << clean_solutions_hash(result, ['subterm_id', 'subterm_name', 'subterm_ontology'])
            cleaned_solutions.flatten!.each do |solution|
              subterm_id = solution['subterm_id'].blank? ? term : solution['subterm_id']
              solution['subterm_id'] = subterm_id
            end
          end
        end # of terms.each
      end #of terms.any?
      #Rails.logger.debug("Cleaned solutions: #{cleaned_solutions}")
      cleaned_solutions.inject({}) do |h, solution|
        h[solution['subterm_id']] = {'term_name' => solution['subterm_name'], 'ontology' => solution['subterm_ontology']}
        h
      end
    end # of find_matched_terms_for_gene_id

    def find_from_rdfstore(chromosome, starts_at, ends_at, terms=[])
      result_hash = Gene.find_from_rdfstore_for_direct_annotation(chromosome, starts_at, ends_at, terms)
      pathway_hash = Gene.find_from_rdfstore_via_pathway(chromosome, starts_at, ends_at, terms)
      pathway_hash.keys.each do |key|
        if result_hash.has_key?(key)
          result_hash[key]['pathways'] = pathway_hash[key]['pathways']
        else
          result_hash[key] = {'gene_symbol' => pathway_hash[key]['qtl_gene_symbol'], 'terms' => {}, 'pathways' => pathway_hash[key]['pathways'] }
        end
      end

      result_hash
    end

    def find_from_rdfstore_for_direct_annotation(chromosome, starts_at, ends_at, terms=[])
      term_string = ""
      result_hash = {}
      if terms.any?
        terms.each do |term|
          term_uri = RDF::URI.new(term)
          term_string = "?gene_id #{Constants::RGD_CORE['hasOntologyAnnotation'].to_ntriples} ?gene_annotation .
          { ?gene_annotation #{Constants::RGD_CORE['hasOntologyId'].to_ntriples} #{term_uri.to_ntriples} .
            #{term_uri.to_ntriples} #{RDFS['label'].to_ntriples} ?subterm_name .
            #{term_uri.to_ntriples} #{Constants::OBO_OWL['hasOBONamespace'].to_ntriples} ?subterm_ontology .
          } UNION
          { ?gene_annotation #{Constants::RGD_CORE['hasOntologyId'].to_ntriples} ?subterm_id .
            ?subterm_id #{RDFS['label'].to_ntriples} ?subterm_name .
            ?subterm_id #{Constants::OBO_OWL['hasOBONamespace'].to_ntriples} ?subterm_ontology .
            ?subterm_id #{RDFS['subClassOf'].to_ntriples} #{term_uri.to_ntriples} OPTION (T_DISTINCT) .
          }"
          ActiveSupport::Notifications.instrument("query.rdfstore", :query => {'format' => 'gene', 'chromosome' => chromosome, 'starts_at' => starts_at, 'ends_at' => ends_at, 'term' => term}) do
            sparql = "DEFINE input:inference 'ruleset' SELECT DISTINCT ?gene_id ?gene_symbol ?subterm_id ?subterm_name ?subterm_ontology WHERE { #{term_string}
            ?gene_id #{DC11['title'].to_ntriples} ?gene_symbol .
            ?gene_id #{RDF['type'].to_ntriples} #{Constants::RGD_CORE['Gene'].to_ntriples} .
            ?gene_id #{Constants::RGD_CORE['hasLocation'].to_ntriples} ?location .
            ?location #{Constants::RGD_CORE['hasChromosome'].to_ntriples} ?chr .
            ?location #{Constants::RGD_CORE['hasChrStart'].to_ntriples} ?start .
            ?location #{Constants::RGD_CORE['hasChrStop'].to_ntriples} ?stop .
            FILTER (xsd:integer(?start) >= #{starts_at})
            FILTER (xsd:integer(?start) <= #{ends_at})
            FILTER (xsd:integer(?stop) <= #{ends_at})
            FILTER (xsd:integer(?stop) >= #{starts_at})
            FILTER (?chr = \"#{chromosome}\")
            } ORDER BY ?gene_symbol"
#            Rails.logger.debug("SPARQL: #{sparql}")
            result = VIRTUOSO_SERVER.query(sparql)
            cleaned = clean_solutions_hash(result, ['gene_id', 'gene_symbol', 'subterm_id', 'subterm_name', 'subterm_ontology'])
            cleaned.each do |solution|
              if result_hash.has_key?(solution['gene_id'])
                subterm_id = solution['subterm_id'].blank? ? term : solution['subterm_id']
                if !result_hash[solution['gene_id']]['terms'].has_key?(subterm_id)
                  result_hash[solution['gene_id']]['terms'][subterm_id] = {'name' => solution['subterm_name'], 'ontology_name' => solution['subterm_ontology'] }
                end
              else
                subterm_id = solution['subterm_id'].blank? ? term : solution['subterm_id']
                result_hash[solution['gene_id']] = {'gene_symbol' => solution['gene_symbol'], 'terms' => {subterm_id => {'name' => solution['subterm_name'], 'ontology_name' => solution['subterm_ontology']} }, 'pathways' => {} }
              end
            end
          end
        end # of terms.each
      end #of terms.any?
      Rails.logger.debug("RESULT HASH: #{result_hash}")
      result_hash
    end # of find_from_rdfstore

  end # class self

end
