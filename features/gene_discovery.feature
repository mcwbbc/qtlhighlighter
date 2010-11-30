# Feature:
#   In order identify candidate genes
#   As a user
#   I want to be able connect data sets
#
#   Scenario: Show QTL information
#     Given I am on the search page
#     When I select the QTL "Bp101"
#
#
#
#
# Then I should see the annotations associated with that QTL (So I know what this QTL is for and what existing annotations have been made to it)
#
# Then I should see which ontologies those annotations come from (Could be shown by color, the ontology term prefix MP, etc)
#
# Then I should be able to add some/all of the QTL annotations to Ontology Terms list (chances are I want to find a gene related to the phenotype that the QTL was measured for)
#
# Then I should be able to add other ontology terms to the list (Just in case Im looking for some Phenotype or Disease not already annotated to the QTL)
#
# And it would be nice to see an updated scoreboard/results summary - an ajax query showing there are 10 genes linked to Ontology term X, then when I add term Y, this scoreboard changes to say ther are 15 genes linked to Y, 3 genes to X and Y, etc. - no sure if this is doable given the triple store speed)
#
# Then I should be able to click Search (or simlar) and see the results
#
# If there are no results
# Then I should see a message telling me nothing matches
# And I should see some options suggesting some alternative searches (ideally searches that would return some results, not sure if this is doable)
#
# (eg. "there are no genes in your region linked to Hypertension, however, there are 123 genes in the genome linked to Hypertension, of these 123 genes, 50 are annotated to 10 different KEGG (or Pathway Ontology) pathways - do you want to look for genes in your region that are also involved in these pathways? [Yes|No]")
#
#
# If there are some results
# Then I should be able to see if there are any genes that have exact matching Ontology terms (This is the most basic match)
#
# And I should be able to see if there are any genes that match child terms (match to a subcategory of the ontology term)
# And I should be able to see if there are any genes that match parent terms (match to a supercategory of the ontology term, less precise, only go up 1, maybe 2 levels in ontology?)
#
# And I would really like to see some graphical representation of this (Cytoscape web or other network widget/visualization - graphviz?)
#
# Then I would like to have some options to expand my search outwards - even if there are some direct matches to the ontology terms, I might want to broaden my search (as described above, find links to pathways that have links to genes that are connected to the ontology terms of interest)
#
