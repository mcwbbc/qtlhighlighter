class OntologyTermsController < ApplicationController

  def index
    @terms = OntologyTerm.page_for_term(params['term'])

    respond_to do |format|
      format.html {}
      format.js  {
          render(:json => @terms)
        }
    end
  end

end
