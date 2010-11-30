class Qtl < ActiveRecord::Base
  include Utilities

  class << self

    def insert_from_rdfstore
      qtl_names = Qtl.load_from_rdfstore
      sql = "INSERT INTO qtls(symbol) VALUES ('"+qtl_names.join("'),('")+"') ON DUPLICATE KEY UPDATE symbol = VALUES(symbol)"
      ActiveRecord::Base.connection.execute(sql)
    end

    def load_from_rdfstore
      sparql = "SELECT ?qtl_name WHERE { ?qtl #{RDF.type.to_ntriples} #{Constants::RGD_CORE['Qtl'].to_ntriples} . ?qtl #{DC11.title.to_ntriples} ?qtl_name . } ORDER BY ?qtl_name"
      result = VIRTUOSO_SERVER.query(sparql)
      clean_solutions(result, :qtl_name)
    end

    def find_from_rdfstore(symbol_name)
      symbol = RDF::Literal.new(symbol_name, :language => :en)
      #    qtl = Qtl.find(:first, :conditions => ["symbol = ?", params['qtl_symbol']])
      ActiveSupport::Notifications.instrument("query.rdfstore", :query => {'format' => 'qtl', 'symbol_name' => symbol_name}) do
        sparql = "SELECT ?chromosome ?start ?stop WHERE { ?qtl #{RDF.type.to_ntriples} #{Constants::RGD_CORE['Qtl'].to_ntriples} . ?qtl #{DC11.title.to_ntriples} #{symbol.to_ntriples} . ?qtl #{Constants::RGD_CORE['GenomicLocation'].to_ntriples} ?location . ?location #{Constants::RGD_CORE['Chromosome'].to_ntriples} ?chromosome . ?location #{Constants::RGD_CORE['Start'].to_ntriples} ?start . ?location #{Constants::RGD_CORE['Stop'].to_ntriples} ?stop . }"
        result = VIRTUOSO_SERVER.query(sparql)

        # [#<RDF::Query::Solution:0x824f2090({:chromosome=>#<RDF::Literal:0x8250c29c("2")>, :start=>#<RDF::Literal::Integer:0x824f3738("155920808"^^<http://www.w3.org/2001/XMLSchema#integer>)>, :stop=>#<RDF::Literal::Integer:0x824f2900("210636008"^^<http://www.w3.org/2001/XMLSchema#integer>)>})>]
        if result.any?
          chromosome, starts_at, ends_at = parse_values(result.first)
          {'symbol' => symbol_name, 'chromosome' => chromosome, 'starts_at' => starts_at, 'ends_at' => ends_at}
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
      [solution[:chromosome].to_s, solution[:start].to_i, solution[:stop].to_i]
    end

  end

end
