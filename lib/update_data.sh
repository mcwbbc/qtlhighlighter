#!/bin/sh

cd /usr/local/agraph
rm -rf *.nt

# download the owl files
wget -N http://www.berkeleybop.org/ontologies/obo-all/adult_mouse_anatomy/adult_mouse_anatomy.owl
wget -N http://www.berkeleybop.org/ontologies/obo-all/biological_process/biological_process.owl
wget -N http://www.berkeleybop.org/ontologies/obo-all/cell/cell.owl
wget -N http://www.berkeleybop.org/ontologies/obo-all/cellular_component/cellular_component.owl
wget -N http://www.berkeleybop.org/ontologies/obo-all/evidence_code/evidence_code.owl
wget -N http://www.berkeleybop.org/ontologies/obo-all/mammalian_phenotype/mammalian_phenotype.owl
wget -N http://www.berkeleybop.org/ontologies/obo-all/molecular_function/molecular_function.owl
wget -N http://www.berkeleybop.org/ontologies/obo-all/pathway/pathway.owl

wget -N http://purl.obolibrary.org/obo/iao/dev/iao.owl
wget -N http://purl.obolibrary.org/obo/iao/dev/ontology-metadata.owl
wget -N http://purl.obolibrary.org/obo/iao/dev/obsolete.owl
wget -N http://purl.obolibrary.org/obo/iao/dev/iao-main.owl
wget -N http://purl.obolibrary.org/obo/iao/dev/externalDerived.owl
wget -N http://purl.obolibrary.org/obo/iao/dev/external.owl
wget -N http://purl.obolibrary.org/obo/iao/dev/externalByHand.owl
wget -N http://www.obofoundry.org/ro/ro.owl
wget -N http://protege.stanford.edu/plugins/owl/dc/protege-dc.owl
wget -N http://www.ifomis.org/bfo/1.1

# download the RGD data
wget -N ftp://ftp.rgd.mcw.edu/pub/data_release/QTLS_RAT
wget -N ftp://ftp.rgd.mcw.edu/pub/data_release/GENES_RAT
wget -N ftp://ftp.rgd.mcw.edu/pub/data_release/annotated_rgd_objects_by_ontology/rattus_genes_do
wget -N ftp://ftp.rgd.mcw.edu/pub/data_release/annotated_rgd_objects_by_ontology/rattus_genes_go
wget -N ftp://ftp.rgd.mcw.edu/pub/data_release/annotated_rgd_objects_by_ontology/rattus_genes_mp
wget -N ftp://ftp.rgd.mcw.edu/pub/data_release/annotated_rgd_objects_by_ontology/rattus_genes_pw
wget -N ftp://ftp.rgd.mcw.edu/pub/data_release/annotated_rgd_objects_by_ontology/rattus_qtls_do
wget -N ftp://ftp.rgd.mcw.edu/pub/data_release/annotated_rgd_objects_by_ontology/rattus_qtls_mp

# copy the inference file
cp /www/servers/qtlhighlighter/current/lib/inference.nt /usr/local/agraph/inference.nt

# convert the downloaded files into ntriples
cd /www/servers/qtlhighlighter/current && RAILS_ENV=production bundle exec rake generate:triples[/usr/local/agraph/rattus_genes_pw] &
cd /www/servers/qtlhighlighter/current && RAILS_ENV=production bundle exec rake generate:triples[/usr/local/agraph/rattus_genes_mp] &
cd /www/servers/qtlhighlighter/current && RAILS_ENV=production bundle exec rake generate:triples[/usr/local/agraph/rattus_genes_do] &
cd /www/servers/qtlhighlighter/current && RAILS_ENV=production bundle exec rake generate:triples[/usr/local/agraph/rattus_qtls_mp] &
cd /www/servers/qtlhighlighter/current && RAILS_ENV=production bundle exec rake generate:triples[/usr/local/agraph/rattus_qtls_do] &
cd /www/servers/qtlhighlighter/current && RAILS_ENV=production bundle exec rake generate:genes[/usr/local/agraph/GENES_RAT] &
cd /www/servers/qtlhighlighter/current && RAILS_ENV=production bundle exec rake generate:qtls[/usr/local/agraph/QTLS_RAT] &
# this one isn't in the bg since it will take the longest and we need it to complete before taking the next steps
cd /www/servers/qtlhighlighter/current && RAILS_ENV=production bundle exec rake generate:triples[/usr/local/agraph/rattus_genes_go]

# load the owl and triples into virtuoso
/usr/local/bin/isql localhost 'dba' 'v!rtu0s0' /www/servers/qtlhighlighter/current/lib/insert_data.txt

# generate the rules file
#cd /www/servers/qtlhighlighter/current && RAILS_ENV=production bundle exec rake generate:rules[/usr/local/agraph/rules]

# load the rules file into virtuoso
/usr/local/bin/isql localhost 'dba' 'v!rtu0s0' /www/servers/qtlhighlighter/current/lib/insert_rules.txt

cd /www/servers/qtlhighlighter/current && RAILS_ENV=production bundle exec rake load:qtls
cd /www/servers/qtlhighlighter/current && RAILS_ENV=production bundle exec rake load:ontology_terms

cd /www/servers/qtlhighlighter/current && RAILS_ENV=production bundle exec rake output:genes[/www/servers/qtlhighlighter/current/public/downloads/qtl_candidate_gene_list.csv]
