require 'rake'
require 'rake/clean'

DIMENSION = ENV['DIM'].to_i || 5
NHIDDEN = ENV['NHIDDEN'].to_i || 5
RAW_FILES = Rake::FileList.new("*features.csv.raw")
STRIP_FILES = RAW_FILES.ext(".strip")
TRANS_FILES = STRIP_FILES.ext(".trans")
SORT_FILES = TRANS_FILES.ext(".sort")
PROCESSED_FILES = SORT_FILES.ext("")
WORDS_TO_DROP = %W(bowling crow)

FEATURE_FILES = Rake::FileList.new("*_features.csv")
MODEL_FILES_TO_BUILD = FEATURE_FILES.sub("features","norm_model")
MODEL_FILES = Rake::FileList.new("*_{next,norm}_model.csv")

namespace :norms do
  STRIP_FILES.zip(RAW_FILES).each do |target, source|
    file target  => [source] do |t|
      bn = File.basename(source,".csv.raw")
      sh "sed '1,2d' #{source} > tmp01"
      sh "cut -d',' -f3- tmp01 > tmp02"
      sh "head -1 tmp02|cut -d',' -f2- | tr ',' '\\n' > #{bn}_words.txt.unsorted"
      sh "sed '1d' tmp02 > tmp03"
      sh "cut -d',' -f1 tmp03 > #{bn}_features.txt"
      sh "cut -d',' -f2- tmp03 > #{target}"
      rm "tmp01"
      rm "tmp02"
      rm "tmp03"
    end
  end
  TRANS_FILES.zip(STRIP_FILES).each do |target, source|
    file target  => [source] do |t|
      features = []
      File.foreach(t.source) do |line|
        features.push(line.chomp.split(','))
      end
      File.open(t.name, 'w') do |f|
        features.transpose.each do |row|
          f.write(row.join(',')+"\n")
        end
      end
    end
  end
  SORT_FILES.zip(TRANS_FILES).each do |target, source|
    file target  => [source] do |t|
      bn = File.basename(t.source,".csv.trans")
      words_unsorted = "#{bn}_words.txt.unsorted"
      words = "#{bn}_words.txt"
      sh "paste -d',' #{words_unsorted} #{t.source}|sort>#{t.name}"
      sh "sort #{words_unsorted} > #{words}"
    end
  end
  PROCESSED_FILES.zip(SORT_FILES).each do |target, source|
    file target  => [source] do |t|
      dropExpressions = []
      WORDS_TO_DROP.each do |w|
        dropExpressions.push("-e '/^#{w}/d'")
      end
      sh "sed #{dropExpressions.join(' ')}  #{t.source} > #{t.name}"
    end
  end
  file "combined_features.csv" => PROCESSED_FILES do |f|
    combList = []
    PROCESSED_FILES.each_with_index do |p,i|
      if (i==0) then
        combList.push(p)
      else
        sh("cut -d, -f2- #{p} > #{p.ext(".tmp")}")
        combList.push(p.ext(".tmp"))
      end
    end
    sh("paste -d, #{combList.join(' ')} > #{f.name}")
    combList.shift()
    combList.each do |c|
      rm_rf c
    end
  end

  desc "Preprocess the feature norm files"
  task :process => ["combine","clean"]

  desc "Remove junk rows and columns from raw files."
  task :strip => STRIP_FILES

  desc "Transpose feature by word to word by feature."
  task :transpose => TRANS_FILES

  desc "Sort rows alphabetically by word"
  task :sort => SORT_FILES

  desc "Drop rows corresponding to words_to_drop"
  task :drop => PROCESSED_FILES

  desc "Combine transposed feature files, columnwise."
  task :combine => "combined_features.csv"

  task :default => [:combine]

  CLEAN.include(STRIP_FILES)
  CLEAN.include(TRANS_FILES)
  CLEAN.include(SORT_FILES)
  CLOBBER.include(PROCESSED_FILES)
  CLOBBER.include("combined_features.csv")
end

namespace :models do
  MODEL_FILES_TO_BUILD.zip(FEATURE_FILES).each do |target, source|
    file target => [source] do |t|
      sh "./derive_model.R #{DIMENSION} #{t.source}|sed '1d' > #{t.name}"
    end
  end

  MODEL_FILES.each do |m|
    dropExpressions = []
    WORDS_TO_DROP.each do |w|
      dropExpressions.push("-e '/^#{w}/d'")
    end
    sh "sed -i #{dropExpressions.join(' ')} #{m}"
  end

  desc "Generate models from processed feature norms."
  task :generate => MODEL_FILES_TO_BUILD
  task :default => [:generate]

  CLOBBER.include(MODEL_FILES_TO_BUILD)
end

namespace :lens do
  EXAMPLE_FILES = []
  NETWORK_FILES = []
  RESULT_FILES = []
  inputgroupname = "embedding"
  hiddengroupname = "hidden"
  outputgroupname = "features"
  MODEL_FILES.product(FEATURE_FILES).each do |mfile,ffile|
    m = mfile.sub('_model.csv','')
    f = ffile.sub('_features.csv','')
    efile_base = "#{m}_#{f}"
    nfile = "in/#{m}_#{f}.in"
    NETWORK_FILES.push(nfile)
    file nfile => [ffile] do
      # minus one, because the first column is the row label
      nfeatures = %x( awk -F',' '{print NF; exit;}' #{ffile} ).to_i - 1

      File.open(nfile, 'w') do |net|
        net.write("addNet #{m}_#{f}\n")
        groups = []
        groups.push(inputgroupname)
        net.write("addGroup #{inputgroupname} #{DIMENSION} INPUT\n")
        if (NHIDDEN>0) then
          groups.push(hiddengroupname)
          net.write("addGroup #{hiddengroupname} #{NHIDDEN}\n")
        end
        groups.push(outputgroupname)
        net.write("addGroup #{outputgroupname} #{nfeatures} OUTPUT\n\n")
        net.write("connectGroups #{groups.join(' ')}\n")
        #net.write("loadExamples #{efile}\n")
      end
    end
    (0...4).each do |iCV|
      efile_train = File.join('ex',iCV.to_s,"#{efile_base}_train.ex")
      EXAMPLE_FILES.push(efile_train)

      file efile_train => [mfile,ffile] do |target|
        features = File.open(ffile, 'r').to_enum
        model = File.open(mfile, 'r').to_enum
        ex = File.open("#{target}", 'w')

        ex.write("actI: 1\n")
        ex.write("actT: 1\n")
        ex.write("defI: 0\n")
        ex.write("defT: 0\n")
        ex.write(";\n\n")

        features.zip(model).each_with_index do |(featureBlob,modelBlob),i|
          if ( i % 4 != iCV ) then
            target = featureBlob.chomp.split(',')
            input = modelBlob.chomp.split(',')
            wT = target.shift
            wI = input.shift
            exit unless wT==wI
            name = wT
            input.collect! {|s| "%.4f" % s.to_f}
            target.collect! {|s| "%d" % s.to_i}
            ex.write("name: #{name}\n")
            ex.write("I: (#{inputgroupname}) #{input.join(' ')}\n")
            ex.write("T: (#{outputgroupname}) #{target.join(' ')}\n")
            ex.write(";\n")
          end
        end
      end

      efile_test = File.join('ex',iCV.to_s,"#{efile_base}_test.ex")
      EXAMPLE_FILES.push(efile_test)

      file efile_test=> [mfile,ffile] do |target|
        features = File.open(ffile, 'r').to_enum
        model = File.open(mfile, 'r').to_enum
        ex = File.open("#{target}", 'w')

        ex.write("actI: 1\n")
        ex.write("actT: 1\n")
        ex.write("defI: 0\n")
        ex.write("defT: 0\n")
        ex.write(";\n\n")

        features.zip(model).each_with_index do |(featureBlob,modelBlob),i|
          if ( i % 4 == iCV ) then
            target = featureBlob.chomp.split(',')
            input = modelBlob.chomp.split(',')
            wT = target.shift
            wI = input.shift
            exit unless wT==wI
            name = wT
            input.collect! {|s| "%.4f" % s.to_f}
            target.collect! {|s| "%d" % s.to_i}
            ex.write("name: #{name}\n")
            ex.write("I: (#{inputgroupname}) #{input.join(' ')}\n")
            ex.write("T: (#{outputgroupname}) #{target.join(' ')}\n")
            ex.write(";\n")
          end
        end
      end
    end
  end
  NETWORK_FILES.each do |nfile|
    (0...4).each do |iCV|
      base = File.basename(nfile,'.in')
      ex_train = File.join('ex',iCV.to_s,"#{base}_train.ex")
      ex_test = File.join('ex',iCV.to_s,"#{base}_test.ex")
      resultFile = File.join("#{base}_#{iCV}.csv")
      RESULT_FILES.push(resultFile)
      puts resultFile
      file resultFile => [nfile,ex_train,ex_test] do
        File.open('params.tcl','w') do |f|
          f.write("set argv [list \"#{nfile}\" \"#{ex_train}\" \"#{ex_test}\"]\n")
        end
        sh("cat params.tcl trainscript.tcl > trainscript_argv.tcl")
        sh("zsh -c '/home/chris/src/lens/lens -batch trainscript_argv.tcl'")
      end
    end
  end
  task :examples => EXAMPLE_FILES
  task :networks => NETWORK_FILES
  task :train => RESULT_FILES
  task :default => [:examples,:networks]
  CLOBBER.include(EXAMPLE_FILES)
  CLOBBER.include(NETWORK_FILES)
  CLOBBER.include(RESULT_FILES)
end
