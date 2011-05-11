class RgdItem

  class << self

    def parse_file(filename)
      RDF::Writer.open("#{filename}.nt") do |writer|
        File.open(filename, "r").each do |line|
          next if !(line.chomp =~ /^\d+/)
          graph = parse(line, RDF::Graph.new)
          graph.each_statement do |statement|
            writer << statement
          end
          graph = nil
        end
      end
    end

    def load_ids(filename)
      id_array = []
      File.open(filename, "r").each do |line|
        next if !(line.chomp =~ /^\d+/)
        id_array << line.chomp.split("\t")[0]
      end
      id_array
    end

    def generate_identifier(db_name, db_id)
      case db_name
        when "RGD"
          Constants::RGD_ID[db_id]
        else
          Constants::PURL_OWL["#{db_name}##{db_name}_#{db_id}"]
      end
    end

    def generate_node(identifier)
      node = RDF::Node.uuid(:grammar => /^[A-Za-z][A-Za-z0-9]*/)
      [node, RDF::Statement.new(identifier, Constants::RGD_CORE['hasLocation'], node)]
    end

    def generate_label(identifier, label)
      RDF::Statement.new(identifier, RDFS.label, RDF::Literal.new(clean_tags(label), :language => :en)) if !label.blank?
    end

    def generate_title(identifier, title)
      RDF::Statement.new(identifier, DC11.title, RDF::Literal.new(clean_tags(title), :language => :en)) if !title.blank?
    end

    def generate_item_type(identifier, item_type)
      RDF::Statement.new(identifier, RDF.type, Constants::RGD_CORE[item_type.capitalize]) if !item_type.blank?
    end

    def generate_taxons(identifier, taxons)
      taxons.split("|").inject([]) do |a, taxon|
        a << RDF::Statement.new(identifier, Constants::UNIPROT_CORE['Taxon'], Constants::UNIPROT_TAXONOMY[taxon.split(":").last])
        a
      end if !taxons.blank?
    end

    def generate_strain_rgd_ids(identifier, strain_rgd_ids)
      strain_rgd_ids.split(";").inject([]) do |a, strain_rgd_id|
        a << RDF::Statement.new(identifier, Constants::RGD_CORE['hasStrain'], generate_identifier('RGD', strain_rgd_id))
        a
      end if !strain_rgd_ids.blank?
    end

    def generate_node_version(identifier, version)
      RDF::Statement.new(identifier, DC11['hasVersion'], RDF::Literal.new(version, :datatype => RDF::XSD.double)) if !version.blank?
    end

    def generate_chromosome(identifier, chromosome)
      RDF::Statement.new(identifier, Constants::RGD_CORE['hasChromosome'], RDF::Literal.new(chromosome)) if !chromosome.blank?
    end

    def generate_start(identifier, start)
      RDF::Statement.new(identifier, Constants::RGD_CORE['hasChrStart'], RDF::Literal.new(start, :datatype => RDF::XSD.integer)) if !start.blank?
    end

    def generate_stop(identifier, stop)
      RDF::Statement.new(identifier, Constants::RGD_CORE['hasChrStop'], RDF::Literal.new(stop, :datatype => RDF::XSD.integer)) if !stop.blank?
    end

    def generate_db_references(identifier, db_references, format)
      db_references.split(/,|;/).inject([]) do |a, db_reference|
        case format
          when "PMID"
            a << RDF::Statement.new(identifier, Constants::OBO_OWL['hasDbXref'], Constants::PMID[db_reference])
          when "RGD"
            a << RDF::Statement.new(identifier, Constants::OBO_OWL['hasDbXref'], generate_identifier(db, db_reference))
        end
        a
      end if !db_references.blank?
    end

    def clean_tags(string)
      string.gsub('<i>','').gsub('</i>','').gsub('<sup>','-').gsub('</sup>','').gsub('<em>','').gsub('</em>','')
    end

  end # of self

end