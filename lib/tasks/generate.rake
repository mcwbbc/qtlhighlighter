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

  desc "distribute triples"
  task :distribute, :filename, :needs => :environment do |t, args|
    filename = args.filename
    if !filename.blank? && File.exist?(filename)
      Triple.distribute_file(filename)
    else
      p "You must include the file to distribute. EX: rake generate:distribute[metadata/rattus_genes_mp]"
    end
  end

  desc "generate rules"
  task :rules, :filename, :needs => :environment do |t, args|
    filename = args.filename
    if !filename.blank?
      Rule.generate_rules(filename)
    else
      p "You must include the file to save to. EX: rake generate:rules[metadata/rules]"
    end
  end

  desc "generate gene triples, EX: rake generate:genes[metadata/GENES_RAT]"
  task :genes, :filename, :needs => :environment do |t, args|
    filename = args.filename
    if !filename.blank? && File.exist?(filename)
      RgdGene.parse_file(filename)
    else
      p "You must include the file to parse. EX: rake generate:genes[metadata/GENES_RAT]"
    end
  end

  desc "generate qtl triples, EX: rake generate:qtls[metadata/QTLS_RAT]"
  task :qtls, :filename, :needs => :environment do |t, args|
    filename = args.filename
    if !filename.blank? && File.exist?(filename)
      RgdQtl.parse_file(filename)
    else
      p "You must include the file to parse. EX: rake generate:qtls[metadata/QTLS_RAT]"
    end
  end

  desc "verify all ids in annotation files exsist in the data files"
  task :verification, :needs => :environment do |t, args|
    id_array = RgdItem.load_ids('metadata/QTLS_RAT')
    id_array << RgdItem.load_ids('metadata/GENES_RAT')
    id_array.flatten!
    ['metadata/rattus_genes_do', 'metadata/rattus_genes_go', 'metadata/rattus_genes_mp', 'metadata/rattus_genes_pw', 'metadata/rattus_qtls_do', 'metadata/rattus_qtls_mp'].each do |filename|
      puts "Checking: #{filename}"
      Triple.check_file(filename, id_array)
    end
  end


end
