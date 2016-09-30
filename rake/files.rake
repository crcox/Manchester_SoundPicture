require 'rake'
require 'tempfile'
require 'json'
require 'scanf'

METADATA = ENV.fetch('METADATA') {"#{ENV['HOME']}/MRI/Manchester/data/avg/metadata_avg_new.mat"}
RESULTFILES = Rake::FileList["*/results.mat"]
PARAMFILES = RESULTFILES.pathmap("%d/params.json")
COLFILTERKEY = '.colfilter.key'
SUBJKEY = '.subject.key'
SEEDKEY = '.RandomSeed.key'
CVKEY = '.cvholdout.key'

file COLFILTERKEY => PARAMFILES do
  target = COLFILTERKEY
  source_list = PARAMFILES
  File.open(target.to_s, 'w') do |tfile|
    source_list.each do |source|
      j = File.read(source)
      params = JSON.parse(j)
      x = params["filters"]
      if x.kind_of?(Array) then
        s = x.select {|y| y.include?('colfilter') || y.include?('ROI_') || y.include?('LESION_')}.join(' ')
      else
        if x.include?('colfilter') || x.include?('ROI_') || x.include?('LESION_')
          s = x.to_s
        end
      end
      tfile.write(s+"\n")
    end
  end
end

file SUBJKEY => PARAMFILES do
  target = SUBJKEY
  source_list = PARAMFILES
  File.open(target.to_s, 'w') do |tfile|
    source_list.each do |source|
      j = File.read(source)
      params = JSON.parse(j)
      x = params["data"]
      if x.kind_of?(Array) then
        s = x.collect {|y| File.basename(y).scanf('s%d_avg.mat').first}.join(' ')
      else
        s = File.basename(x).scanf('s%d_avg.mat').first.to_s
      end
      tfile.write(s+"\n")
    end
  end
end

file CVKEY => PARAMFILES do
  target = CVKEY
  source_list = PARAMFILES
  File.open(target.to_s, 'w') do |tfile|
    source_list.each do |source|
      j = File.read(source)
      params = JSON.parse(j)
      x = params["cvholdout"]
      if x.kind_of?(Array) then
        s = x.join(' ')
      else
        s = x.to_s
      end
      tfile.write(s+"\n")
    end
  end
end

file SEEDKEY => PARAMFILES do
  target = SEEDKEY
  source_list = PARAMFILES
  File.open(target.to_s, 'w') do |tfile|
    source_list.each do |source|
      j = File.read(source)
      params = JSON.parse(j)
      x = params["RandomSeed"]
      if x.kind_of?(Array) then
        s = x.join(' ')
      else
        s = x.to_s
      end
      tfile.write(s+"\n")
    end
  end
end

LINENO=270
MATLAB="matlab -nojvm -r"
FUNC="wbrsa_dumpcoords"
DEBUG="dbstop #{FUNC} #{LINENO}"
namespace :dump do
  namespace :nodestrength do
    task :cv=> [SUBJKEY,CVKEY] do
      rlist = Tempfile.new('rlist')
      begin
        File.open(rlist, 'w') {|f| f.write RESULTFILES.join("\n")}
        sh("matlab -nojvm -r \"wbrsa_dumpcoords('#{rlist.path}','nodestrength','orig','metadatafile','#{METADATA}');exit;\"")
      ensure
        rlist.close
        rlist.unlink
      end
    end
    namespace :avg do
      task :final=> [SUBJKEY,CVKEY,COLFILTERKEY] do
        rlist = Tempfile.new('rlist')
        begin
          File.open(rlist, 'w') {|f| f.write RESULTFILES.join("\n")}
          sh("matlab -nojvm -r \"wbrsa_dumpcoords('#{rlist.path}','nodestrength','orig','by',{'subject'},'metadatafile','#{METADATA}');exit;\"")
        ensure
          rlist.close
          rlist.unlink
        end
      end
      task :permtest=> [SEEDKEY,SUBJKEY,CVKEY,COLFILTERKEY] do
        rlist = Tempfile.new('rlist')
        begin
          File.open(rlist, 'w') {|f| f.write RESULTFILES.join("\n")}
          sh("matlab -nojvm -r \"wbrsa_dumpcoords('#{rlist.path}','nodestrength','orig','by',{'RandomSeed','subject'},'metadatafile','#{METADATA}');exit;\"")
        ensure
          rlist.close
          rlist.unlink
        end
      end
    end
  end
  namespace :stability do
    namespace :avg do
      task :final=> [SUBJKEY,CVKEY,COLFILTERKEY] do
        rlist = Tempfile.new('rlist')
        begin
          File.open(rlist, 'w') {|f| f.write RESULTFILES.join("\n")}
          sh("matlab -nojvm -r \"wbrsa_dumpcoords('#{rlist.path}','stability','orig','by',{'subject'},'metadatafile','#{METADATA}');exit;\"")
        ensure
          rlist.close
          rlist.unlink
        end
      end
      task :permtest=> [SEEDKEY,SUBJKEY,CVKEY,COLFILTERKEY] do
        rlist = Tempfile.new('rlist')
        begin
          File.open(rlist, 'w') {|f| f.write RESULTFILES.join("\n")}
          sh("matlab -nojvm -r \"wbrsa_dumpcoords('#{rlist.path}','stability','orig','by',{'RandomSeed','subject'},'metadatafile','#{METADATA}');exit;\"")
        ensure
          rlist.close
          rlist.unlink
        end
      end
    end
  end
end
