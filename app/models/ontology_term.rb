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
      ActiveSupport::Notifications.instrument("query.rdfstore", :query => {'format' => 'ontology_terms', 'chromosome' => chromosome, 'starts_at' => starts_at, 'ends_at' => ends_at}) do
        result = VIRTUOSO_SERVER.select(:term_id, :term_name).distinct(true).where([:gene_id, Constants::RGD_CORE['hasLocation'], :location]).where([:location, Constants::RGD_CORE['hasChromosome'], RDF::Literal.new(chromosome)]).where([:location, Constants::RGD_CORE['hasChrStart'], :start]).where([:location, Constants::RGD_CORE['hasChrStop'], :stop]).where([:gene_id, DC11['title'], :gene_name]).where([:gene_id, RDF['type'], Constants::RGD_CORE['Gene']]).where([:gene_id, Constants::RGD_CORE['hasOntologyAnnotation'], :annotation]).where([:annotation, Constants::RGD_CORE['hasOntologyId'], :term_id]).where([:term_id, RDFS['label'], :term_name]).filter("xsd:integer(?start) >= #{starts_at}").filter("xsd:integer(?start) <= #{ends_at}").filter("xsd:integer(?stop) >= #{starts_at}").filter("xsd:integer(?stop) <= #{ends_at}").order(:term_id)
        clean_solutions_hash(result.solutions, ['term_id', 'term_name'])
      end
    end

    def find_from_rdfstore_for_qtl(qtl_name)
      qtl = RDF::Literal.new(qtl_name, :language => :en)
      ActiveSupport::Notifications.instrument("query.rdfstore", :query => {'format' => 'ontology_terms', 'qtl_name' => qtl_name}) do
        result = VIRTUOSO_SERVER.select(:term_id, :term_name, :ontology_name).distinct(true).where([:qtl_id, DC11['title'], qtl]).where([:qtl_id, RDF['type'], Constants::RGD_CORE['Qtl']]).where([:qtl_id, Constants::RGD_CORE['hasOntologyAnnotation'], :annotation]).where([:annotation, Constants::RGD_CORE['hasOntologyId'], :term_id]).where([:term_id, RDFS['label'], :term_name]).where([:term_id, Constants::OBO_OWL['hasOBONamespace'], :ontology_name]).order(:qtl_id)
        clean_solutions_hash(result.solutions, ['term_id', 'term_name', 'ontology_name'])
      end
    end

    def load_ontology_names
      result = VIRTUOSO_SERVER.select(:ontology_name).distinct(true).where([:s, Constants::OBO_OWL['hasOBONamespace'], :ontology_name])
      clean_solutions(result.solutions, 'ontology_name')
    end

    def load_from_rdfstore(ontology_name)
      css_klass = Constants::TERM_CSS[ontology_name]
      ontology = RDF::Literal.new(ontology_name)
      result = VIRTUOSO_SERVER.select(:term_id, :term_name).distinct(true).where([:term_id, Constants::OBO_OWL['hasOBONamespace'], ontology]).where([:term_id, RDFS['label'], :term_name]).where([:term_id, RDF['type'], OWL['Class']]).filter("langMatches(lang(?term_name), 'EN')").order(:term_id)
      temp_terms = clean_solutions_hash(result.solutions, ['term_id', 'term_name'])
      ontology_terms = temp_terms.map do |term|
        term['css_klass'] = css_klass
        term
      end
    end

    def insert_from_rdfstore
      ontology_names = OntologyTerm.load_ontology_names
      ActiveRecord::Base.connection.execute('TRUNCATE ontology_terms')
      ontology_names.each do |ontology_name|
        terms = OntologyTerm.load_from_rdfstore(ontology_name)
        if terms.any?
          sql = "INSERT INTO ontology_terms(`uri`, `css_klass`, `name`) VALUES "
          sql_array = terms.map { |term| "(\"#{term['term_id']}\", \"#{term['css_klass']}\", \"#{term['term_name']}\")"}
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
