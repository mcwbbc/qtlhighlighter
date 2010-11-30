class OntologyTerm < ActiveRecord::Base
  include Utilities

  class << self

    def page_for_term(term)
      q_front = "#{term}%"
      cstring = "name LIKE ?"
      conditions = [cstring, q_front]
      terms = page(conditions, 1, 10).map do |term|
        {'id' => term.uri, 'label' => term.name, 'value' => term.name, 'css' => term.css_klass}
      end
    end

    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => "name, uri",
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end

    def find_from_rdfstore(chromosome, starts_at, ends_at)
#      genes = Gene.find(:all, :select => 'symbol', :conditions => ["chromosome = ? AND starts_at BETWEEN ? AND ? AND ends_at BETWEEN ? AND  ?", qtl.chromosome, qtl.starts_at, qtl.ends_at, qtl.starts_at, qtl.ends_at], :order => 'symbol').map{ |gene| gene.symbol }
      ActiveSupport::Notifications.instrument("query.rdfstore", :query => {'format' => 'ontology_terms', 'chromosome' => chromosome, 'starts_at' => starts_at, 'ends_at' => ends_at}) do
        sparql = "SELECT DISTINCT ?term_id ?term_name WHERE { ?gene_id #{Constants::RGD_CORE['GenomicLocation'].to_ntriples} ?location . ?location #{Constants::RGD_CORE['Chromosome'].to_ntriples} \"#{chromosome}\" . ?location #{Constants::RGD_CORE['Start'].to_ntriples} ?start FILTER (xsd:integer(?start) >= #{starts_at}) . ?location #{Constants::RGD_CORE['Start'].to_ntriples} ?start FILTER (xsd:integer(?start) <= #{ends_at}) . ?location #{Constants::RGD_CORE['Stop'].to_ntriples} ?stop FILTER (xsd:integer(?stop) <= #{ends_at}) . ?location #{Constants::RGD_CORE['Stop'].to_ntriples} ?stop FILTER (xsd:integer(?stop) >= #{starts_at}) . ?gene_id #{DC11.title.to_ntriples} ?gene_name . ?gene_id #{RDF.type.to_ntriples} #{Constants::RGD_CORE['Gene'].to_ntriples} . ?gene_id #{Constants::RGD_CORE['Annotation'].to_ntriples} ?annotation . ?annotation #{Constants::OBO_OWL['hasDbXref'].to_ntriples} ?term_id . ?term_id #{RDFS['label'].to_ntriples} ?term_name . } ORDER BY ?term_id"
        result = VIRTUOSO_SERVER.query(sparql)
        clean_solutions_hash(result, ['term_id', 'term_name'])
      end
    end

    def find_from_rdfstore_for_qtl(qtl_name)
      qtl = RDF::Literal.new(qtl_name, :language => :en)
      ActiveSupport::Notifications.instrument("query.rdfstore", :query => {'format' => 'ontology_terms', 'qtl_name' => qtl_name}) do
        sparql = "SELECT DISTINCT ?term_id ?term_name ?ontology_name WHERE { ?qtl_id #{DC11.title.to_ntriples} #{qtl.to_ntriples} . ?qtl_id #{RDF.type.to_ntriples} #{Constants::RGD_CORE['Qtl'].to_ntriples} . ?qtl_id #{Constants::RGD_CORE['Annotation'].to_ntriples} ?annotation . ?annotation #{Constants::OBO_OWL['hasDbXref'].to_ntriples} ?term_id . ?term_id #{RDFS['label'].to_ntriples} ?term_name . ?term_id #{Constants::OBO_OWL['hasOBONamespace'].to_ntriples} ?ontology_name } ORDER BY ?qtl_id"
        result = VIRTUOSO_SERVER.query(sparql)
        clean_solutions_hash(result, ['term_id', 'term_name', 'ontology_name'])
      end
    end

    def load_ontology_names
      sparql = "SELECT DISTINCT ?ontology_name WHERE { ?s #{Constants::OBO_OWL['hasOBONamespace'].to_ntriples} ?ontology_name }"
      result = VIRTUOSO_SERVER.query(sparql)
      clean_solutions(result, :ontology_name)
    end

    def load_from_rdfstore(ontology_name)
      css_klass = Constants::TERM_CSS[ontology_name]
      sparql = "SELECT DISTINCT ?term_id ?term_name WHERE { ?term_id #{Constants::OBO_OWL['hasOBONamespace'].to_ntriples} '#{ontology_name}' . ?term_id #{RDFS['label'].to_ntriples} ?term_name . ?term_id #{RDF['type'].to_ntriples} #{OWL['Class'].to_ntriples} FILTER (langMatches(lang(?term_name), 'EN')) . } ORDER BY ?term_id"
      result = VIRTUOSO_SERVER.query(sparql)
      temp_terms = clean_solutions_hash(result, [:term_id, :term_name])
      temp_terms.map do |term|
        term[:css_klass] = css_klass
        term
      end
    end

    def insert_from_rdfstore
      ontology_names = OntologyTerm.load_ontology_names
      ontology_names.each do |ontology_name|
        terms = OntologyTerm.load_from_rdfstore(ontology_name)
        if terms.any?
          sql = "INSERT INTO ontology_terms(`uri`, `css_klass`, `name`) VALUES "
          sql_array = terms.map { |term| "(\"#{term[:term_id]}\", \"#{term[:css_klass]}\", \"#{term[:term_name]}\")"}
          sql << sql_array.join(", ")
          sql << " ON DUPLICATE KEY UPDATE name = VALUES(name)"
          ActiveRecord::Base.connection.execute(sql)
        end
      end
    end

    def add_css(terms)
      terms.map do |term|
        term['css_klass'] = Constants::TERM_CSS[term['ontology_name']]
        term
      end
    end

  end # of self

end
