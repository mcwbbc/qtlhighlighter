class GeneSearchesController < ApplicationController

  def index
  end

  def new
  end

  def create
    @qtl_symbol = params['qtl_symbol']
    @chromosome = params['qtl_chromosome_name']
    @starts_at = params['qtl_starts_at']
    @ends_at = params['qtl_ends_at']
    @terms = params['terms']

    @genes = Gene.find_from_rdfstore(@chromosome, @starts_at, @ends_at, @terms)

    respond_to do |format|
      format.html {}
      format.js  {
          render(:layout => false)
        }
    end
  end

  def upload
    hash = {'genes' => []}

    params['file'].each_line do |line|
      hash['genes'] << line.chomp
    end

    if hash['genes'].any?
      hash['genes'].sort!
      hash['success'] = true
    else
      hash['error'] = "The file did not upload properly."
    end

    respond_to do |format|
      format.html {}
      format.js {
        render(:json => hash)
      }
    end

  end

end
