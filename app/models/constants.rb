class Constants

  PER_PAGE = 15

  RGD_CORE = RDF::Vocabulary.new("http://rgd.mcw.edu/core/")
  RGD_ID = RDF::Vocabulary.new("http://rgd.mcw.edu/id/")

  UNIPROT_CORE = RDF::Vocabulary.new("http://www.uniprot.org/core/")
  UNIPROT_TAXONOMY = RDF::Vocabulary.new("http://www.uniprot.org/taxonomy/")
  PURL_OWL = RDF::Vocabulary.new("http://purl.org/obo/owl/")
  OBO_OWL = RDF::Vocabulary.new("http://www.geneontology.org/formats/oboInOwl#")
  PMID = RDF::Vocabulary.new("http://purl.org/commons/html/pmid/")

  TERM_CSS = {
    'adult_mouse_anatomy.gxd' => 'adult-mouse',
    'biological_process' => 'biological-process',
    'gene_ontology' => 'gene-ontology',
    'molecular_function' => 'molecular-function',
    'cellular_component' => 'cellular-component',
    'cell' => 'cell',
    'MPheno.ontology' => 'mamalian-phenotype'
  }

end