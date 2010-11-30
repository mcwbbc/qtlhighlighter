class QtlsController < ApplicationController

  def index
    @qtls = Qtl.page_for_symbol(params['term'])

    respond_to do |format|
      format.html {}
      format.js  {
        render(:json => @qtls)
      }
    end
  end

  def ontology_terms
    term_hash = {'chromosome' => "error", 'starts_at' => "error", 'ends_at' => "error", 'qtl_symbol' => "error", 'terms' => [], 'valid' => false, 'message' => 'No results returned.'}
    qtl_symbol = params['qtl_symbol']
    if qtl = Qtl.find_from_rdfstore(qtl_symbol)
      rdf_terms = OntologyTerm.find_from_rdfstore_for_qtl(qtl['symbol']) || []
      terms = OntologyTerm.add_css(rdf_terms)
      term_hash = {'qtl_symbol' => qtl['symbol'], 'chromosome' => qtl['chromosome'], 'starts_at' => qtl['starts_at'], 'ends_at' => qtl['ends_at'], 'terms' => terms, 'valid' => true, 'message' => "#{qtl['symbol']} (chr:#{qtl['chromosome']} start:#{qtl['starts_at']} end:#{qtl['ends_at']}) added #{pluralize(terms.size, 'ontology term')}."}
    end
    render(:json => term_hash)
  end


  def genes
    hash = {'chromosome' => "error", 'starts_at' => "error", 'ends_at' => "error", 'genes' => [], 'terms' => [], 'valid' => false, 'message' => 'No results returned.'}
    if qtl = Qtl.find_from_rdfstore(params['qtl_symbol'])
      genes = Gene.find_from_rdfstore(qtl['chromosome'], qtl['starts_at'], qtl['ends_at']) || ['none found']
      terms = OntologyTerm.find_from_rdfstore(qtl['chromosome'], qtl['starts_at'], qtl['ends_at']) || ['none found']
      hash = {'chromosome' => qtl['chromosome'], 'starts_at' => qtl['starts_at'], 'ends_at' => qtl['ends_at'], 'genes' => genes, 'terms' => terms, 'valid' => true}
    end
    render(:json => hash)
  end

end
