class GenesController < ApplicationController

  def direct
    chromosome = params['chromosome'] ? params['chromosome'] : "1"
    starts_at = params['starts_at'] ? params['starts_at'].to_i : 0
    ends_at = params['ends_at'] ? params['ends_at'].to_i : 0
    genes = Gene.find_from_rdfstore(chromosome, starts_at, ends_at) || []
    terms = OntologyTerm.find_from_rdfstore(chromosome, starts_at, ends_at) || []
    hash = {'chromosome' => chromosome, 'starts_at' => starts_at, 'ends_at' => ends_at, 'genes' => genes, 'terms' => terms}
    render(:json => hash)
  end

end
