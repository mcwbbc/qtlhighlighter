class RgdGene < RgdItem

  class << self

    def parse(line, graph)
      # GENE_RGD_ID; SYMBOL; NAME; GENE_DESC; CHROMOSOME_CELERA; CHROMOSOME_31; CHROMOSOME_34; FISH_BAND; START_POS_CELERA; STOP_POS_CELERA; STRAND_CELERA; START_POS_31; STOP_POS_31; STRAND_31; START_POS_34; STOP_POS_34; STRAND_34; CURATED_REF_RGD_ID; CURATED_REF_PUBMED_ID; UNCURATED_PUBMED_ID; RATMAP_ID; ENTREZ_GENE; UNIPROT_ID; RHDB_ID; UNCURATED_REF_MEDLINE_ID; GENBANK_NUCLEOTIDE; TIGR_ID; GENBANK_PROTEIN; UNIGENE_ID; GDB_ID; SSLP_RGD_ID; SSLP_SYMBOL; OLD_SYMBOL; OLD_NAME; QTL_RGD_ID; QTL_SYMBOL; NOMENCLATURE_STATUS; SPLICE_RGD_ID; SPLICE_SYMBOL; GENE_TYPE; ENSEMBL_ID
      # 2004; A2m; alpha-2-macroglobulin; plays a role in acute phase response; activated form induces a decrease in N-methyl-D-aspartate (NMDA) mediated calcium signaling; 4; 4; 4; q42; 143730195; 143781190; +; 158348624; 158398358; +; 158103711; 158153423; +; 1549857,1549856,1600115,2298922,1598407,2298948,70068,70249,704363,704364,1298539,1298570,1300048,1598506,1598509,1598510,1302534,1300321,1598710,1598511,1598512,1598513,1331525,1300322,1358261,1358260,1580654,1580655,67925,619610; 11498265,11779202,11839752,11952820,12042906,12221929,12223092,12477932,12494268,14960360,15272003,15489334,15509519,16538883,17071617,1725450,17487688,17565389,18701465,2414291,2432068,2436819,2448189,2466233,2468362,2581948,9446838,9697696,9843780; 1549857,1549856,2298922,2298948,70249,704363,704364,1298539,1298570,1598506,1598509,1598510,1302534,1300321,1598710,1598511,1598512,1598513,1331525,1300322,1358261,1358260,67925; 5; 24153; Q6LDR4,P06238; ; ; AY887133,AY919611,AY921651,BC098922,CH473964,J02635,M11793,M22670,M23567,M84370,NM_012488; TC239648,TC229016; AAA40636,AAA40638,AAA41592,AAA41595,AAA77658,AAH98922,AAW65786,AAX11376,AAX12488,EDM02007,EDM02008,EDM02009,NP_036620,P06238,Q5D178,Q5D1M8,Q5FX35,Q63335,Q6LDG8,Q6LDR4,NP_036620.2; Rn.109457; ; 10048,10049,42147; D4Mit20,D4Wox16,D4Arb15; A2MAC1|A2m|A2m1|A2maa|AI893533|MGC114358|Mam|RATA2MAC1; alpha-2-M|alpha-2-macroglobulin|alpha-2-macroglobulin-P; 724558; Plsm2; APPROVED; ; ; protein-coding; ENSRNOG00000028896,ENSRNOG00000028896

      gene_rgd_id, symbol, name, gene_desc, chromosome_celera, chromosome_31, chromosome_34, fish_band, start_pos_celera, stop_pos_celera, strand_celera, start_pos_31, stop_pos_31, strand_31, start_pos_34, stop_pos_34, strand_34, curated_ref_rgd_id, curated_ref_pubmed_id, uncurated_pubmed_id, ratmap_id, entrez_gene, uniprot_id, rhdb_id, uncurated_ref_medline_id, genbank_nucleotide, tigr_id, genbank_protein, unigene_id, gdb_id, sslp_rgd_id, sslp_symbol, old_symbol, old_name, qtl_rgd_id, qtl_symbol, nomenclature_status, splice_rgd_id, splice_symbol, gene_type, ensembl_id = line.chomp.split("\t")

      identifier = generate_identifier('RGD', gene_rgd_id)

      if item_type_triple = generate_item_type(identifier, 'gene')
        graph << item_type_triple
      end

      if label_triple = generate_label(identifier, name)
        graph << label_triple
      end

      if title_triple = generate_title(identifier, symbol)
        graph << title_triple
      end

      if gene_type_triple = generate_gene_type(identifier, gene_type)
        graph << gene_type_triple
      end

      if entrez_gene_triple = generate_entrez_gene(identifier, entrez_gene)
        graph << entrez_gene_triple
      end

      node, node_triple = generate_node(identifier)
      graph << node_triple

      if node_version_triple = generate_node_version(node, '3.4')
        graph << node_version_triple
      end

      if chromosome_triple = generate_chromosome(node, chromosome_34)
        graph << chromosome_triple
      end

      if start_triple = generate_start(node, start_pos_34)
        graph << start_triple
      end

      if stop_triple = generate_stop(node, stop_pos_34)
        graph << stop_triple
      end

      # uncurated
      # TODO decide if I want to treat curated and uncurated the same....
      if db_references_triples = generate_db_references(identifier, uncurated_pubmed_id, 'PMID')
        db_references_triples.each do |triple|
          graph << triple
        end
      end

      # curated
      if db_references_triples = generate_db_references(identifier, curated_ref_pubmed_id, 'PMID')
        db_references_triples.each do |triple|
          graph << triple
        end
      end

      if uniprot_ids_triples = generate_uniprot_ids(identifier, uniprot_id)
        uniprot_ids_triples.each do |triple|
          graph << triple
        end
      end

      if genbank_proteins_triples = generate_genbank_ids(identifier, genbank_protein, "protein")
        genbank_proteins_triples.each do |triple|
          graph << triple
        end
      end

      if genbank_nucleotides_triples = generate_genbank_ids(identifier, genbank_nucleotide, "nucleotide")
        genbank_nucleotides_triples.each do |triple|
          graph << triple
        end
      end

      graph
    end

    def generate_gene_type(identifier, gene_type)
      RDF::Statement.new(identifier, RDFS['subClassOf'], RDF::Literal.new(gene_type)) if !gene_type.blank?
    end

    def generate_uniprot_ids(identifier, uniprot_ids)
      uniprot_ids.split(",").inject([]) do |a, uniprot_id|
        a << RDF::Statement.new(identifier, Constants::OBO_OWL['hasDbXref'], Constants::UNIPROT_ID[uniprot_id])
        a
      end if !uniprot_ids.blank?
    end

    def generate_entrez_gene(identifier, entrez_gene)
      RDF::Statement.new(identifier, Constants::OBO_OWL['hasDbXref'], Constants::COMMONS_NCBI_GENE[entrez_gene]) if !entrez_gene.blank?
    end

    def generate_genbank_ids(identifier, genbank_ids, format)
      genbank_ids.split(",").inject([]) do |a, genbank_id|
        case format
          when "nucleotide"
            obj = Constants::GENBANK_NUCLEOTIDE[genbank_id]
          when "protein"
            obj = Constants::GENBANK_PROTEIN[genbank_id]
        end
        a << RDF::Statement.new(identifier, Constants::OBO_OWL['hasDbXref'], obj)
        a
      end if !genbank_ids.blank?
    end

  end #of self

end