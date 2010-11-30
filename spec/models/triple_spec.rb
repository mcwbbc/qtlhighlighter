require 'spec_helper'

describe Triple do

  before(:each) do
    @filename = "rattus_qtls_mp"
    @graph = RDF::Graph.new
    @new_graph = mock(RDF::Graph)
    @purl_owl = RDF::Vocabulary.new("http://purl.org/obo/owl/")
    @rgd_core = RDF::Vocabulary.new("http://rgd.mcw.edu/core/")
    @rgd_id = RDF::Vocabulary.new("http://rgd.mcw.edu/id/")

    @identifier = @rgd_id['631210']
    @item_type = "QTL"
    @uniprot_core = RDF::Vocabulary.new("http://www.uniprot.org/core/")
    @uniprot_taxonomy = RDF::Vocabulary.new("http://www.uniprot.org/taxonomy/")
    @purl_owl = RDF::Vocabulary.new("http://purl.org/obo/owl/")
    @obo_owl = RDF::Vocabulary.new("http://www.geneontology.org/formats/oboInOwl#")
    @pmid = RDF::Vocabulary.new("http://purl.org/commons/html/pmid/")
    @node = RDF::Node.uuid
    @node_triple = RDF::Statement.new(@identifier, @obo_owl['Subset'], @node)
  end

  describe "parse_file" do
    it "should generate triples from the loaded line" do
      RDF::Graph.stub(:new).and_return(@graph)
      @header = "!gaf-version: 2.0"
      @line = "RGD	631210	Bw3		MP:0000010	RGD:619690|PMID:11087657	QTM		N	Obesity QTL 3		qtl	taxon:10116		RGD		"
      statement = mock(Statement)
      writer = mock(RDF::Writer)

      RDF::Writer.should_receive(:open).with("#{@filename}.nt").and_yield(writer)
      File.should_receive(:open).with(@filename, "r").and_return([@header, @line])
      Triple.should_receive(:parse).with(@line, RDF::Graph.new).and_return(@new_graph)
      @new_graph.should_receive(:each_statement).and_yield(statement)

      writer.should_receive(:<<).with(statement).and_return(true)
      Triple.parse_file(@filename)
    end
  end

  describe "parse" do
    it "should parse the line" do
      #db_name, db_id, db_object_symbol, qualifier, go_id, db_references, evidence_code, with_from, aspect, db_object_name, db_object_synonyms, db_object_type, taxons, date, assigned_by, annotation_extensions, gene_product_form_id = line.split("\t")
      #"RGD", "631210", "Bw3", "", "MP:0000010", "RGD:619690|PMID:11087657", "QTM", "", "N", "Obesity QTL 3", "", "qtl", "taxon:10116", "", "RGD", "", ""
      #"RGD", "727972", "Zar1", "", "GO:0007275", "RGD:1600115", "IEA", "SP_KW:KW-0217", "P", "zygote arrest 1", "", "gene", "taxon:10116", "20100821", "UniProtKB", "", ""
      taxon_array = [RDF::Statement.new(@identifier, @uniprot_core['Taxon'], @uniprot_taxonomy['10116'])]
      Triple.should_receive(:generate_identifier).with("RGD", "631210").and_return(@identifier)
      Triple.should_receive(:generate_node).and_return([@node, @node_triple])
      Triple.should_receive(:generate_label).with(@identifier, "Obesity QTL 3")
      Triple.should_receive(:generate_title).with(@identifier, "Bw3")
      Triple.should_receive(:generate_item_type).with(@identifier, "qtl")
      Triple.should_receive(:generate_date).with(@node, "20100821")
      Triple.should_receive(:generate_annotation).with(@node, "MP:0000010")
      Triple.should_receive(:generate_evidence_code).with(@node, "QTM")
      Triple.should_receive(:generate_db_references).with(@node, "RGD:619690|PMID:11087657")
      Triple.should_receive(:generate_taxons).with(@node, "taxon:10116").and_return(taxon_array)
      Triple.should_receive(:generate_domain).with(@node, "RGD")
      Triple.should_receive(:generate_synonyms).with(@node, "")
      Triple.parse("RGD	631210	Bw3		MP:0000010	RGD:619690|PMID:11087657	QTM		N	Obesity QTL 3		qtl	taxon:10116	20100821	RGD		", @graph).should == @graph
    end
  end

  describe "creating triples" do

    describe "identifier" do
      # <http://purl.org/obo/owl/RGD#RGD_631210>
       it "should generate the identifier uri" do
        Triple.generate_identifier("RGD", "631210").should == @identifier
        Triple.generate_identifier("MP", "0000010").should == @purl_owl['MP#MP_0000010']
      end
    end

    describe "node" do
      it "should generate a blank node" do
        node, node_triple = Triple.generate_node(@identifier)
        node.class.should == RDF::Node
        node_triple.subject.should == @identifier
        node_triple.predicate.should == @rgd_core['Annotation']
        node_triple.object.should == node
      end
    end

    describe "label" do
      # <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.w3.org/2000/01/rdf-schema#label> "Bw3"@en
      it "should return the label triple" do
        label = Triple.generate_label(@identifier, "Bw3")
        label.subject.should == @identifier
        label.predicate.should == RDFS.label
        label.object.to_ntriples.should ==  "\"Bw3\"@en"
      end

      it "should return the nil for empty string" do
        Triple.generate_label(@identifier, "").should == nil
      end
    end

    describe "title" do
      # <http://purl.org/obo/owl/RGD#RGD_631210> <http://purl.org/dc/elements/1.1/title> "Obesity QTL 3"@en
      it "should return the title triple" do
        title = Triple.generate_title(@identifier, "Obesity QTL 3")
        title.subject.should == @identifier
        title.predicate.should == DC11.title
        title.object.to_ntriples.should ==  "\"Obesity QTL 3\"@en"
      end

      it "should return the nil for empty string" do
        Triple.generate_title(@identifier, "").should == nil
      end
    end

    describe "item_type" do
      # <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://bio2rdf.org/ns/rgd#QTL>
      it "should return the item type triple" do
        item_type = Triple.generate_item_type(@identifier, "qtl")
        item_type.subject.should == @identifier
        item_type.predicate.should == RDF.type
        item_type.object.should ==  @rgd_core['Qtl']
      end

      it "should return the nil for empty string" do
        Triple.generate_item_type(@identifier, "").should == nil
      end
    end

    describe "date" do
      # <http://purl.org/obo/owl/RGD#RGD_631210> <http://purl.org/dc/elements/1.1/date> "2007-01-03"
      it "should return the date triple" do
        date = Triple.generate_date(@node, "20070103")
        date.subject.should == @node
        date.predicate.should == @obo_owl['hasDate']
        date.object.to_ntriples.should ==  "\"2007-01-03Z\"^^<http://www.w3.org/2001/XMLSchema#date>"
      end

      it "should return nil for no date" do
        Triple.generate_date(@node, "").should == nil
      end
    end

    describe "annotation" do
      # <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.uniprot.org/core/Annotation> <http://purl.org/obo/owl/MP#MP_0000010>
      it "should return the annotation triple" do
        annotation = Triple.generate_annotation(@node, "MP:0000010")
        annotation.subject.should == @node
        annotation.predicate.should == @obo_owl['hasDbXref']
        annotation.object.should ==  Triple.generate_identifier('MP', '0000010')
      end

      it "should return the nil for empty string" do
        Triple.generate_annotation(@node, "").should == nil
      end
    end

    describe "evidence_code" do
      # <http://purl.org/obo/owl/RGD#RGD_631210> <http://bio2rdf.org/ns/rgd#evidenceCode> <http://bio2rdf.org/ns/rgd#QTM>
      it "should return the evidence_code triple" do
        evidence_code = Triple.generate_evidence_code(@node, "QTM")
        evidence_code.subject.should == @node
        evidence_code.predicate.should == @rgd_core['evidenceCode']
        evidence_code.object.should ==  @rgd_core['QTM']
      end

      it "should return the nil for empty string" do
        Triple.generate_evidence_code(@node, "").should == nil
      end
    end

    describe "domain" do
      # <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.w3.org/2000/01/rdf-schema#domain> <http://purl.org/obo/owl/RGD>
      it "should return the domain triple" do
        domain = Triple.generate_domain(@node, "RGD")
        domain.subject.should == @node
        domain.predicate.should == RDFS.domain
        domain.object.should ==  @purl_owl['RGD']
      end

      it "should return the nil for empty string" do
        Triple.generate_domain(@node, "").should == nil
      end
    end

    describe "taxons" do
      # <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.uniprot.org/core/Taxon> <http://www.uniprot.org/taxonomy/10116>
      it "should return the taxons triples for single" do
        taxons = Triple.generate_taxons(@node, "taxon:10116")
        ['10116'].each_with_index do |taxon_id, i|
          taxons[i].subject.should == @node
          taxons[i].predicate.should == @uniprot_core['Taxon']
          taxons[i].object.should ==  @uniprot_taxonomy[taxon_id]
        end
      end

      it "should return the taxons triples" do
        taxons = Triple.generate_taxons(@node, "taxon:10116|taxon:9606")
        ['10116', '9606'].each_with_index do |taxon_id, i|
          taxons[i].subject.should == @node
          taxons[i].predicate.should == @uniprot_core['Taxon']
          taxons[i].object.should ==  @uniprot_taxonomy[taxon_id]
        end
      end

      it "should return the nil for empty string" do
        Triple.generate_taxons(@node, "").should == nil
      end
    end

    describe "synonyms" do
      # http://www.geneontology.org/formats/oboInOwl#hasSynonym
      it "should return the synonyms triples for single" do
        # <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.geneontology.org/formats/oboInOwl#hasSynonym> <http://purl.org/obo/owl/RGD#RGD_1234>
        synomyms = Triple.generate_synonyms(@node, "RGD:1234")
        [['RGD', '1234']].each_with_index do |synonym, i|
          synomyms[i].subject.should == @node
          synomyms[i].predicate.should == @obo_owl['hasSynonym']
          synomyms[i].object.should == Triple.generate_identifier(synonym[0], synonym[1])
        end
      end

      it "should return the synonyms triples" do
        synomyms = Triple.generate_synonyms(@node, "RGD:1234|RGD:9876")
        [['RGD', '1234'], ['RGD', '9876']].each_with_index do |synonym, i|
          synomyms[i].subject.should == @node
          synomyms[i].predicate.should == @obo_owl['hasSynonym']
          synomyms[i].object.should == Triple.generate_identifier(synonym[0], synonym[1])
        end
      end

      it "should return the nil for empty string" do
        Triple.generate_synonyms(@node, "").should == nil
      end
    end

    describe "db_references" do
      # <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.geneontology.org/formats/oboInOwl#hasDbXref> <http://purl.org/commons/html/pmid/11166570>
      # <http://purl.org/obo/owl/RGD#RGD_631210> <http://www.geneontology.org/formats/oboInOwl#hasDbXref> <http://purl.org/obo/owl/RGD#RGD_619690>
      it "should return the db_references triples for single rgd" do
        db_references = Triple.generate_db_references(@node, "RGD:619690")
        db_references[0].subject.should == @node
        db_references[0].predicate.should == @obo_owl['hasDbXref']
        db_references[0].object.should == Triple.generate_identifier('RGD', '619690')
      end

      it "should return the db_references triples for single pmid" do
        db_references = Triple.generate_db_references(@node, "PMID:11087657")
        db_references[0].subject.should == @node
        db_references[0].predicate.should == @obo_owl['hasDbXref']
        db_references[0].object.should == @pmid['11087657']
      end

      it "should return the db_references triples" do
        db_references = Triple.generate_db_references(@node, "RGD:619690|PMID:11087657")
        db_references[0].subject.should == @node
        db_references[0].predicate.should == @obo_owl['hasDbXref']
        db_references[0].object.should == Triple.generate_identifier('RGD', '619690')

        db_references[1].subject.should == @node
        db_references[1].predicate.should == @obo_owl['hasDbXref']
        db_references[1].object.should == @pmid['11087657']
      end

      it "should return the nil for empty string" do
        Triple.generate_db_references(@node, "").should == nil
      end
    end

    describe "clean tags" do
      it "should remove <em></em> tags" do
        string = "hello <em>there</EM> buddy"
        Triple.clean_tags(string).should == "hello there buddy"
      end

      it "should remove <i></i> tags" do
        string = "hello <i>there</i> buddy"
        Triple.clean_tags(string).should == "hello there buddy"
      end

      it "should remove <I></I> tags" do
        string = "hello <I>there</I> buddy"
        Triple.clean_tags(string).should == "hello there buddy"
      end

      it "should remove </sup> tags" do
        string = "hello there</sup> buddy"
        Triple.clean_tags(string).should == "hello there buddy"
      end

      it "should replace <sup> tags with -" do
        string = "hello<sup>there buddy"
        Triple.clean_tags(string).should == "hello-there buddy"
      end

      it "should replace clean the string" do
        string = "hello<sup><i>there</sup></i> <em>buddy</em>"
        Triple.clean_tags(string).should == "hello-there buddy"
      end

    end

  end

end
