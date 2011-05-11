class Constants

  PER_PAGE = 15

  RGD_CORE = RDF::Vocabulary.new("http://www.purl.org/RGD/core#")
  RGD_ID = RDF::Vocabulary.new("http://www.purl.org/RGD/")

  UNIPROT_CORE = RDF::Vocabulary.new("http://www.uniprot.org/core/")
  UNIPROT_TAXONOMY = RDF::Vocabulary.new("http://www.uniprot.org/taxonomy/")
  UNIPROT_ID = RDF::Vocabulary.new("http://purl.uniprot.org/uniprot/")

  PURL_OWL = RDF::Vocabulary.new("http://purl.org/obo/owl/")
  OBO_OWL = RDF::Vocabulary.new("http://www.geneontology.org/formats/oboInOwl#")
  PMID = RDF::Vocabulary.new("http://purl.org/commons/html/pmid/")
  ECO = RDF::Vocabulary.new("http://purl.org/obo/owl/ECO#")
  DISEASE = RDF::Vocabulary.new("http://purl.org/obo/owl/obo#")

  COMMONS_NCBI_GENE = RDF::Vocabulary.new("http://purl.org/commons/record/ncbi_gene/")
  GENBANK_NUCLEOTIDE = RDF::Vocabulary.new("http://www.ncbi.nlm.nih.gov/nuccore/")
  GENBANK_PROTEIN = RDF::Vocabulary.new("http://www.ncbi.nlm.nih.gov/protein/")


  TAXON = {'rattus norvegicus' => '10116',
        'rat' => '10116',
        'homo sapiens' => '9606',
        'human' => '9606',
        'mus musculus' => '10090',
        'mouse' => '10090'
        }

  TERM_CSS = {
    'adult_mouse_anatomy.gxd' => 'adult-mouse',
    'biological_process' => 'biological-process',
    'gene_ontology' => 'gene-ontology',
    'molecular_function' => 'molecular-function',
    'cellular_component' => 'cellular-component',
    'cell' => 'cell',
    'MPheno.ontology' => 'mamalian-phenotype',
    'evidence_code2.obo' => 'evidence-code',
    'Disease_Ontology' => 'disease'
  }

end