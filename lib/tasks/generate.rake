namespace :generate do

  desc "generate triples"
  task :triples, :filename, :needs => :environment do |t, args|
    filename = args.filename
    if !filename.blank? && File.exist?(filename)
      Triple.parse_file(filename)
    else
      p "You must include the file to parse. EX: rake generate:triples[metadata/rattus_genes_mp]"
    end

  end

end
