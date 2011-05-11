class Triple

  @queue = :triples

  class << self


    def perform(filename, line)
      graph = Triple.parse(line)

      string = RDF::NTriples::Writer.buffer do |writer|
        graph.each_statement do |statement|
          writer << statement
        end
      end

      Resque.enqueue(WriteGraph, filename, string)
    end

    def parse_file(filename)
      RDF::Writer.open("#{filename}.nt") do |writer|
        File.open(filename, "r").each do |line|
#       db_name, db_id, db_object_symbol, qualifier, go_id, db_references, evidence_code, with_from, aspect, db_object_name, db_object_synonyms, db_object_type, taxons, date, assigned_by, annotation_extensions, gene_product_form_id
#       RGD, 631210, Bw3, , MP:0000010, RGD:619690|PMID:11087657, QTM, , N, Obesity QTL 3, , qtl, taxon:10116, , RGD, ,
#       RGD, 1598849, Memor17, , MP:0001449, RGD:1581615|PMID:16837653, IED, , N, Memory QTL 17, , qtl, taxon:10116, 20070103, RGD, ,
          next if !!(line.chomp =~ /^!gaf-version: 2.0/)
          graph = Triple.parse(line)
          graph.each_statement do |statement|
            writer << statement
          end
        end
      end
    end


    def distribute_file(filename)
      File.open(filename, "r").each do |line|
#       db_name, db_id, db_object_symbol, qualifier, go_id, db_references, evidence_code, with_from, aspect, db_object_name, db_object_synonyms, db_object_type, taxons, date, assigned_by, annotation_extensions, gene_product_form_id
#       RGD, 631210, Bw3, , MP:0000010, RGD:619690|PMID:11087657, QTM, , N, Obesity QTL 3, , qtl, taxon:10116, , RGD, ,
#       RGD, 1598849, Memor17, , MP:0001449, RGD:1581615|PMID:16837653, IED, , N, Memory QTL 17, , qtl, taxon:10116, 20070103, RGD, ,
        next if !!(line.chomp =~ /^!gaf-version: 2.0/)
        Resque.enqueue(Triple, filename, line)
      end
    end


    def check_file(filename, id_array)
      File.open(filename, "r").each do |line|
        next if !!(line.chomp =~ /^!gaf-version: 2.0/)
        id = line.chomp.split("\t")[1]
        puts "MISSING: #{id}" if !id_array.include?(id)
      end
    end

    def parse(line)
      graph = RDF::Graph.new
      db_name, db_id, db_object_symbol, qualifier, go_id, db_references, evidence_code, with_from, aspect, db_object_name, db_object_synonyms, db_object_type, taxons, date, assigned_by, annotation_extensions, gene_product_form_id = line.chomp.split("\t")
      identifier = Triple.generate_identifier(db_name, db_id)

      node, node_triple = Triple.generate_node(identifier)
      graph << node_triple

#      if label_triple = generate_label(identifier, db_object_name)
#        graph << label_triple
#      end

#      if title_triple = generate_title(identifier, db_object_symbol)
#        graph << title_triple
#      end

      if item_type_triple = Triple.generate_item_type(identifier, db_object_type)
        graph << item_type_triple
      end

      if date_triple = Triple.generate_date(node, date)
        graph << date_triple
      end

      if annotation_triple = Triple.generate_annotation(node, go_id)
        graph << annotation_triple
      end

      if evidence_code_triple = Triple.generate_evidence_code(node, evidence_code)
        graph << evidence_code_triple
      end

      if domain_triple = Triple.generate_domain(node, assigned_by)
        graph << domain_triple
      end

      if taxons_triples = Triple.generate_taxons(node, taxons)
        taxons_triples.each do |triple|
          graph << triple
        end
      end

      if db_references_triples = Triple.generate_db_references(node, db_references)
        db_references_triples.each do |triple|
          graph << triple
        end
      end

      if synonyms_triples = Triple.generate_synonyms(node, db_object_synonyms)
        synonyms_triples.each do |triple|
          graph << triple
        end
      end
      graph
    end

    def generate_identifier(db_name, db_id)
      case db_name
        when "RGD"
          Constants::RGD_ID[db_id]
        when "D"
          Constants::DISEASE[db_id]
        else
          Constants::PURL_OWL["#{db_name}##{db_name}_#{db_id}"]
      end
    end

    def generate_node(identifier)
      node = RDF::Node.uuid(:grammar => /^[A-Za-z][A-Za-z0-9]*/)
      [node, RDF::Statement.new(identifier, Constants::RGD_CORE['hasOntologyAnnotation'], node)]
    end

    def generate_date(identifier, date)
      RDF::Statement.new(identifier, Constants::OBO_OWL['hasDate'], RDF::Literal.new(Date.parse(date))) if !date.blank?
    end

    def generate_domain(identifier, domain)
      RDF::Statement.new(identifier, RDFS.domain, Constants::PURL_OWL[domain]) if !domain.blank?
    end

    def generate_taxons(identifier, taxons)
      taxons.split("|").inject([]) do |a, taxon|
        a << RDF::Statement.new(identifier, Constants::UNIPROT_CORE['Taxon'], Constants::UNIPROT_TAXONOMY[taxon.split(":").last])
        a
      end if !taxons.blank?
    end

    def generate_item_type(identifier, item_type)
      RDF::Statement.new(identifier, RDF.type, Constants::RGD_CORE[item_type.capitalize]) if !item_type.blank?
    end

    def generate_label(identifier, label)
      RDF::Statement.new(identifier, RDFS.label, RDF::Literal.new(clean_tags(label), :language => :en)) if (!label.blank? && label != "null")
    end

    def generate_title(identifier, title)
      RDF::Statement.new(identifier, DC11.title, RDF::Literal.new(clean_tags(title), :language => :en)) if (!title.blank? && title != "null")
    end

    def generate_annotation(identifier, annotation)
      if !annotation.blank?
        db, id = annotation.split(":")
        if !!(id.blank? && db =~ /^D/)
          id = db
          db = "D"
        end
        generated_identifier = generate_identifier(db, id)
        RDF::Statement.new(identifier, Constants::RGD_CORE['hasOntologyId'], generated_identifier)
      end
    end

    def generate_evidence_code(identifier, evidence_code)
      RDF::Statement.new(identifier, Constants::RGD_CORE['hasEvidenceCode'], RDF::Literal.new(evidence_code, :language => :en)) if !evidence_code.blank?
    end

    def generate_db_references(identifier, db_references)
      db_references.split("|").inject([]) do |a, db_reference|
        db, id = db_reference.split(":")
        case db
          when "PMID"
            a << RDF::Statement.new(identifier, Constants::OBO_OWL['hasDbXref'], Constants::PMID[id])
          when "RGD"
            a << RDF::Statement.new(identifier, Constants::OBO_OWL['hasDbXref'], generate_identifier(db, id))
        end
        a
      end if !db_references.blank?
    end

    def generate_synonyms(identifier, synonyms)
      synonyms.split("|").inject([]) do |a, synonym|
        db, id = synonym.split(":")
        a << RDF::Statement.new(identifier, Constants::OBO_OWL['hasSynonym'], generate_identifier(db, id))
        a
      end if !synonyms.blank?
    end

    def clean_tags(string)
      string.gsub(/<i>/i,'').gsub(/<\/i>/i,'').gsub(/<sup>/i,'-').gsub(/<\/sup>/i,'').gsub(/<em>/i,'').gsub(/<\/em>/i,'')
    end

  end #of self
end

#d = Date.parse("20070103").to_formatted_s(:w3cdtf)


# <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://bio2rdf.org/ns/rgd#QTL>
# <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.w3.org/2000/01/rdf-schema#label> "Bw3"@en
# <http://purl.org/obo/owl/RGD#RGD_631210> <http://purl.org/dc/elements/1.1/title> "Obesity QTL 3"@en
# <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.uniprot.org/core/Annotation> <http://purl.org/obo/owl/MP#MP_0004390>
# <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.uniprot.org/core/Taxon> <http://www.uniprot.org/taxonomy/10116>
# <http://purl.org/obo/owl/RGD#RGD_631210> <http://bio2rdf.org/ns/rgd#evidenceCode> <http://bio2rdf.org/ns/rgd#QTM>
# <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.geneontology.org/formats/oboInOwl#hasDbXref> <http://purl.org/commons/html/pmid/11166570>
# <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.geneontology.org/formats/oboInOwl#hasDbXref> <http://purl.org/obo/owl/RGD#RGD_619690>
# <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.w3.org/2000/01/rdf-schema#domain> <http://purl.org/obo/owl/RGD>
# <http://purl.org/obo/owl/RGD#RGD_631210> <http://purl.org/dc/elements/1.1/date> "2007-01-03"



# <http://www.geneontology.org/formats/oboInOwl#hasSynonym>