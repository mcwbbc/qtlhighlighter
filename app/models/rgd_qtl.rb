class RgdQtl < RgdItem

  class << self

    def parse(line, graph)
      # QTL_RGD_ID, SPECIES, QTL_SYMBOL, QTL_NAME, CHROMOSOME_FROM_REF, LOD, P_VALUE, VARIANCE, FLANK_1_RGD_ID, FLANK_1_SYMBOL, FLANK_2_RGD_ID, FLANK_2_SYMBOL, PEAK_RGD_ID, PEAK_MARKER_SYMBOL, TRAIT_NAME, SUBTRAIT_NAME, TRAIT_METHODOLOGY, PHENOTYPES, ASSOCIATED_DISEASES, CURATED_REF_RGD_ID, CURATED_REF_PUBMED_ID, CANDIDATE_GENE_RGD_IDS, CANDIDATE_GENE_SYMBOLS, INHERITANCE_TYPE, RELATED_QTLS, RATMAP_ID, 3.4_MAP_POS_CHR, 3.4_MAP_POS_START, 3.4_MAP_POS_STOP, 3.4_MAP_POS_METHOD, 3.1_MAP_POS_CHR, 3.1_MAP_POS_START, 3.1_MAP_POS_STOP, 3.1_MAP_POS_METHOD, STRAIN_RGD_IDS, STRAIN_RGD_SYMBOLS, CROSS_TYPE, CROSS_PAIR
      # 61324, rat, Eae5, Experimental allergic encephalomyelitis QTL 5, 12, 13.0, , , 11051, D12Mit2, 34925, D12Rat9, , , Brain/spinal cord inflammation, relapsing disease, inflammation severity was assayed daily following injection with DA rat spinal cord homogenate with rats scored for degree of tail and limb paralysis on a nine point scale; relapsing disease is defined as more than one period of three-day increase in clinical score , paresis, Multiple Sclerosis;Encephalomyelitis, Experimental Autoimmune, 61031, 10640775, , , , Pia 4, 44536, 12, 20932559, 24470522, 1 - by flanking markers, 12, 20922171, 24333738, 1 - by flanking markers, 60997;61013, DA;E3, F2, E3 x DA

      qtl_rgd_id, species, qtl_symbol, qtl_name, chromosome_from_ref, lod, p_value, variance, flank_1_rgd_id, flank_1_symbol, flank_2_rgd_id, flank_2_symbol, peak_rgd_id, peak_marker_symbol, trait_name, subtrait_name, trait_methodology, phenotypes, associated_diseases, curated_ref_rgd_id, curated_ref_pubmed_id, candidate_gene_rgd_ids, candidate_gene_symbols, inheritance_type, related_qtls, ratmap_id, map_pos_chr_3_4, map_pos_start_3_4, map_pos_stop_3_4, map_pos_method_3_4, map_pos_chr_3_1, map_pos_start_3_1, map_pos_stop_3_1, map_pos_method_3_1, strain_rgd_ids, strain_rgd_symbols, cross_type, cross_pair = line.chomp.split("\t")

      identifier = generate_identifier('RGD', qtl_rgd_id)

      if item_type_triple = generate_item_type(identifier, 'qtl')
        graph << item_type_triple
      end

      if label_triple = generate_label(identifier, qtl_name)
        graph << label_triple
      end

      if title_triple = generate_title(identifier, qtl_symbol)
        graph << title_triple
      end

      if pvalue_triple = generate_pvalue(identifier, p_value)
        graph << pvalue_triple
      end

      if lod_triple = generate_lod(identifier, lod)
        graph << lod_triple
      end

      node, node_triple = generate_node(identifier)
      graph << node_triple

      if node_version_triple = generate_node_version(node, '3.4')
        graph << node_version_triple
      end

      if chromosome_triple = generate_chromosome(node, map_pos_chr_3_4)
        graph << chromosome_triple
      end

      if start_triple = generate_start(node, map_pos_start_3_4)
        graph << start_triple
      end

      if stop_triple = generate_stop(node, map_pos_stop_3_4)
        graph << stop_triple
      end

      if taxons_triples = generate_taxons(identifier, Constants::TAXON[species])
        taxons_triples.each do |triple|
          graph << triple
        end
      end

      if strain_rgd_ids_triples = generate_strain_rgd_ids(identifier, strain_rgd_ids)
        strain_rgd_ids_triples.each do |triple|
          graph << triple
        end
      end

      if db_references_triples = generate_db_references(identifier, curated_ref_pubmed_id, 'PMID')
        db_references_triples.each do |triple|
          graph << triple
        end
      end

      graph
    end

    def generate_pvalue(identifier, pvalue)
      RDF::Statement.new(identifier, Constants::RGD_CORE['hasPValue'], RDF::Literal.new(pvalue, :datatype => RDF::XSD.double)) if !pvalue.blank?
    end

    def generate_lod(identifier, lod)
      RDF::Statement.new(identifier, Constants::RGD_CORE['hasLodScore'], RDF::Literal.new(lod, :datatype => RDF::XSD.double)) if !lod.blank?
    end

  end #of self

end
