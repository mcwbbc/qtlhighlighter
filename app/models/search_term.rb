class SearchTerm

  class << self

    def for_dropdown(query)
      if !query.blank?
        limit = 10
        sparql = "SELECT ?o WHERE { ?s ?p ?o . FILTER (regex(str(?o), '^#{query}')) . } ORDER BY (str(?o)) LIMIT #{limit}"
        ag = Agraph.new('qtlhighlighter')
        @terms = clean_results(ag.sparql(sparql))
      else
        @terms = []
      end
      @terms
    end

    def clean_results(hash)
#      hash = ActiveSupport::JSON.decode(json)
      results = hash['values']
      results.inject([]) do |array, result|
        cleaned_result = clean(result.first)
        if cleaned_result
          array << {'id' => cleaned_result, 'label' => cleaned_result, 'value' => cleaned_result}
        end
        array
      end
    end

    def clean(result)
      regex = /"(.+)"@en/
      m = regex.match(result)
      return m[1] if m
    end

  end


end
