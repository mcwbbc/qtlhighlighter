class CreateOntologyTerms < ActiveRecord::Migration
  def self.up
    create_table :ontology_terms do |t|
      t.string :uri
      t.string :css_klass
      t.string :name
    end
    add_index :ontology_terms, :uri, :unique => true
    add_index :ontology_terms, :name
  end

  def self.down
    drop_table :ontology_terms
  end
end
