class Qtl < ActiveRecord::Base
  include Utilities

  class << self

    def output_genes(filename)
      CSV.open(filename, "wb") do |csv|
        csv << ["QTL ID", "QTL Symbol", "Gene ID", "Gene Symbol", "Matching Term Names", "Matching Term IDs"]
        Qtl.load_from_rdfstore.each do |db_qtl|
          if qtl = Qtl.find_from_rdfstore(db_qtl)
            puts "Processing: #{db_qtl}"
            rdf_terms = OntologyTerm.find_from_rdfstore_for_qtl(db_qtl)
            terms = rdf_terms.each.map { |rdf_term| rdf_term['term_id'] }
            genes = Gene.find_from_rdfstore_for_direct_annotation(qtl['chromosome'], qtl['starts_at'], qtl['ends_at'], terms)
            genes.keys.each do |gene_id|
              gene_term_ids = []
              gene_term_names = []
              genes[gene_id]['terms'].keys.each do |term_key|
                gene_term_ids << term_key
                gene_term_names << genes[gene_id]['terms'][term_key]['name']
              end
              csv << [qtl['qtl_id'], db_qtl, gene_id, genes[gene_id]['gene_symbol'], gene_term_names.join('|'), gene_term_ids.join('|')]
            end
          end
        end
      end
    end

    def insert_from_rdfstore
      qtl_names = Qtl.load_from_rdfstore
      sql = "INSERT INTO qtls(symbol) VALUES ('"+qtl_names.join("'),('")+"') ON DUPLICATE KEY UPDATE symbol = VALUES(symbol)"
      ActiveRecord::Base.connection.execute('TRUNCATE qtls')
      ActiveRecord::Base.connection.execute(sql)
    end

    def load_from_rdfstore
      result = VIRTUOSO_SERVER.select(:qtl_name).distinct(true).where([:qtl_id, RDF['type'], Constants::RGD_CORE['Qtl']]).where([:qtl_id, DC11['title'], :qtl_name]).order(:qtl_name)
      clean_solutions(result.solutions, 'qtl_name')
    end

    def find_from_rdfstore(symbol_name)
      symbol = RDF::Literal.new(symbol_name, :language => :en)
      ActiveSupport::Notifications.instrument("query.rdfstore", :query => {'format' => 'qtl', 'symbol_name' => symbol_name}) do
        result = VIRTUOSO_SERVER.select(:qtl_id, :chromosome, :start, :stop).distinct(true).where([:qtl_id, RDF['type'], Constants::RGD_CORE['Qtl']]).where([:qtl_id, DC11['title'], symbol]).where([:qtl_id, Constants::RGD_CORE['hasLocation'], :location]).where([:location, Constants::RGD_CORE['hasChromosome'], :chromosome]).where([:location, Constants::RGD_CORE['hasChrStart'], :start]).where([:location, Constants::RGD_CORE['hasChrStop'], :stop])
        # [#<RDF::Query::Solution:0x824f2090({:chromosome=>#<RDF::Literal:0x8250c29c("2")>, :start=>#<RDF::Literal::Integer:0x824f3738("155920808"^^<http://www.w3.org/2001/XMLSchema#integer>)>, :stop=>#<RDF::Literal::Integer:0x824f2900("210636008"^^<http://www.w3.org/2001/XMLSchema#integer>)>})>]
        if result.solutions.any?
          qtl_id, chromosome, starts_at, ends_at = parse_values(result.solutions.first)
          {'qtl_id' => qtl_id, 'symbol' => symbol_name, 'chromosome' => chromosome, 'starts_at' => starts_at, 'ends_at' => ends_at}
        else
          nil
        end
      end
    end

    def page_for_symbol(symbol)
      q_front = "#{symbol}%"
      cstring = "symbol LIKE ?"
      conditions = [cstring, q_front]
      qtls = page(conditions, 1, 10).map do |qtl|
        {'id' => qtl.symbol, 'label' => qtl.symbol, 'value' => qtl.symbol}
      end
    end

    def page(conditions, page=1, size=Constants::PER_PAGE)
      paginate(:order => "symbol",
               :conditions => conditions,
               :page => page,
               :per_page => size
               )
    end

    def parse_values(solution)
      [solution[:qtl_id].to_s, solution[:chromosome].to_s, solution[:start].to_i, solution[:stop].to_i]
    end

  end

end
