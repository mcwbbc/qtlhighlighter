module GeneSearchesHelper

  def gene_link_output(gene_symbol)
    link_to(gene_symbol, "http://rgd.mcw.edu/rgdweb/search/genes.html?term=#{gene_symbol}", :target => "_blank")
  end

  def gene_evidence_chart(gene)
    string = ""
    if (gene['terms'] && gene['terms'].any?)
      string << content_tag(:div, "", :class => 'has-terms', :title => 'Has direct term annotations')
    else
      string << content_tag(:div, "", :class => 'empty-marker', :title => 'No term annotations')
    end

    if (gene['pathways'] && gene['pathways'].any?)
      string << content_tag(:div, "", :class => 'has-pathways', :title => 'Has common pathway gene with term annotation')
    else
      string << content_tag(:div, "", :class => 'empty-marker', :title => 'No pathway annotations')
    end

    string.html_safe
  end

end
