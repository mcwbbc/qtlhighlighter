namespace :output do

  desc "output all qtl genes"
  task :genes, :filename, :needs => :environment do |t, args|
    filename = args.filename
    if !filename.blank?
      Qtl.output_genes(filename)
    else
      p "You must include the output filename. EX: rake output:genes[metadata/qtl_gene_list.csv]"
    end
  end

end
