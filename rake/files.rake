require 'rake'
require 'tempfile'
require 'json'
require 'scanf'

METADATA = ENV.fetch('METADATA') {"D:/MRI/SoundPicture/data/MAT/avg/bystudy/metadata_avg.mat"}#{"#{ENV['HOME']}/MRI/Manchester/data/avg/metadata_avg_new.mat"}
RESULTFILES = Rake::FileList["*/results.mat"]
PARAMFILES = RESULTFILES.pathmap("%d/params.json")
RESULTKEY = '.results.key'
PARAMKEY = '.params.key'
COLFILTERKEY = '.colfilter.key'
SUBJKEY = '.subject.key'
SEEDKEY = '.RandomSeed.key'
CVKEY = '.cvholdout.key'

LINENO = ENV['DBLINENO'].to_i || nil
FUNC = ENV['FUNC'] || "wbrsa_dumpcoords"
def run_matlab(func,args,debug: nil)
  matlab="matlab -nojvm -r"
  debug = 'error'
  if debug.eql?('error') then
    debugcmd = "dbstop if error"
  elsif debug.is_a? Numeric
    debugcmd = "dbstop #{func} #{debug}"
  elsif debug.nil?
    debugcmd = nil
  else
    debugcmd = nil
  end
  args = [%{'#{RESULTKEY}'},args].join(',')
  path = "C:/Users/mbmhscc4/GitHub/Manchester_SoundPicture/rake" # "#{ENV['HOME']}/src/Manchester_SoundPicture/rake"
  addpath = %{addpath('#{path}')}
  if debugcmd.nil? || debugcmd == 0 then
    sh(%{#{matlab} "#{addpath};#{func}(#{args});exit;"})
  else
    sh(%{#{matlab} "#{addpath};#{debugcmd};#{func}(#{args});exit;"})
  end
end

file RESULTKEY => RESULTFILES do
  File.open(RESULTKEY, 'w') {|f| f.write(RESULTFILES.join("\n"))}
end
file PARAMKEY => RESULTFILES do
  File.open(PARAMKEY, 'w') {|f| f.write(PARAMFILES.join("\n"))}
end
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

namespace :dump do
  namespace :nodestrength do
    task :cv=> [RESULTKEY,SUBJKEY,CVKEY] do
      pargs=%W{'nodestrength' 'orig'}
      kwargs=%W{
        'metadatafile' '#{METADATA}'
      }
      args=(pargs+kwargs).join(',')
      run_matlab(FUNC,args,debug: LINENO)
    end

    namespace :avg do
      task :final=> [RESULTKEY,SUBJKEY,CVKEY,COLFILTERKEY] do
        pargs=%W{'nodestrength' 'orig'}
        kwargs=%W{
          'metadatafile' '#{METADATA}'
          'by' {'subject'}
        }
        args=(pargs+kwargs).join(',')
        run_matlab(FUNC,args,debug: LINENO)
      end

      task :permtest=> [RESULTKEY,SEEDKEY,SUBJKEY,CVKEY,COLFILTERKEY] do
        pargs=%W{'nodestrength' 'orig'}
        kwargs=%W{
          'metadatafile' '#{METADATA}'
          'by' {'RandomSeed','subject'}
        }
        args=(pargs+kwargs).join(',')
        run_matlab(FUNC,args,debug: LINENO)
      end

    end
  end
  namespace :stability do
    namespace :avg do
      task :final=> [RESULTKEY,SUBJKEY,CVKEY,COLFILTERKEY] do
        pargs=%W{'stability' 'orig'}
        kwargs=%W{
          'metadatafile' '#{METADATA}'
          'by' {'subject'}
        }
        args=(pargs+kwargs).join(',')
        run_matlab(FUNC,args,debug: LINENO)
      end

      task :permtest=> [RESULTKEY,SEEDKEY,SUBJKEY,CVKEY,COLFILTERKEY] do
        pargs=%W{'stability' 'orig'}
        kwargs=%W{
          'metadatafile' '#{METADATA}'
          'by' {'RandomSeed','subject'}
        }
        args=(pargs+kwargs).join(',')
        run_matlab(FUNC,args,debug: LINENO)
      end

    end
  end
end
