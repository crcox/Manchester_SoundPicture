def configure_afni_figure(funcfile,scalemax,threshold,sign)
  sh("plugout_drive -com 'RESCAN_THIS' -quit")
  sh("plugout_drive -com 'SET_FUNCTION #{funcfile}' -quit")
  sh("plugout_drive -com 'SET_FUNC_RANGE #{scalemax}' -quit")
  sh("plugout_drive -com 'SET_THRESHNEW #{threshold}' -quit")
  sh("plugout_drive -com 'SET_PBAR_SIGN #{sign}' -quit")
end

def drive_afni_suma_record_figures(dirname,prefix)
  sh("DriveSuma -com viewer_cont -autorecord '#{dirname}/#{prefix}.left.ppm' -key:d 'ctrl+left' -key 'ctrl+r'")
  sh("DriveSuma -com viewer_cont -autorecord '#{dirname}/#{prefix}.right_medial.ppm' -key:d '[' -key 'ctrl+r' -key:d '['")
  sh("DriveSuma -com viewer_cont -autorecord '#{dirname}/#{prefix}.bottom.ppm' -key:d 'ctrl+down' -key 'ctrl+r'")
  sh("DriveSuma -com viewer_cont -autorecord '#{dirname}/#{prefix}.right.ppm' -key:d 'ctrl+right' -key 'ctrl+r'")
  sh("DriveSuma -com viewer_cont -autorecord '#{dirname}/#{prefix}.left_medial.ppm' -key:d ']' -key 'ctrl+r' -key:d ']'")
  sh("DriveSuma -com viewer_cont -key:r17 'right'")
  sh("DriveSuma -com viewer_cont -autorecord '#{dirname}/#{prefix}.back.ppm' -key:d 'right' -key 'ctrl+r'")
end

def compose_montage_figure(dirname,prefix)
  sh("compose_montage_figure.sh #{dirname} #{prefix}")
  sh("mogrify -format png #{prefix}.ppm")
end

def png_ttest(target, source)
  spath = File.dirname(source).to_s
  prefix = target.sub('.png','')

  funcfile = File.basename(source)

  if (!(spath.eql? '.')) then
    sh("3dcopy #{source} #{funcfile}")
  end

  scalemax = 0  # autorange
  if target.include? "p05" then
    threshold="0.05 *p"
  elsif target.include? "p01" then
    threshold="0.01 *p"
  end
  sign = '+'
  configure_afni_figure(funcfile,scalemax,threshold,sign)

  Dir.mktmpdir do |tmpdir|
    drive_afni_suma_record_figures(tmpdir, prefix)
    compose_montage_figure(tmpdir, prefix)
  end

  if (!(spath.eql? '.')) then
    rm_f(funcfile)
    rm_f(funcfile.sub(".HEAD",".BRIK"))
    rm_f(funcfile.sub(".HEAD",".BRIK.gz"))
  end
end

def png_nonparametric(target, source)
  prefix = target.sub('.png','')
  funcfile = source

  if (!(spath.eql? '.')) then
    sh("3dcopy #{source} #{funcfile}")
  end

  if target.include? "p05" then
    threshold = '16 *'
  elsif target.include? "p01" then
    threshold = '18 *'
  elsif target.include? "p001" then
    threshold = '20 *'
  end

  sign = '+'
  scalemax = 0  # autorange
  configure_afni_figure(funcfile,scalemax,threshold,sign)

  Dir.mktmpdir do |tmpdir|
    drive_afni_suma_record_figures(tmpdir, prefix)
    compose_montage_figure(tmpdir, prefix)
  end

  if (!(spath.eql? '.')) then
    rm_f(funcfile)
    rm_f(funcfile.sub(".HEAD",".BRIK"))
    rm_f(funcfile.sub(".HEAD",".BRIK.gz"))
  end
end

def afni_start(surfvol,spec)
  # sh() uses /bin/sh
  # system() uses either the system's default shell or the shell from which
  # rake was called (not sure which).
  system("afni -niml -yesplugouts &")
  sh("plugout_drive -com 'SWITCH_ANATOMY #{surfvol}' -quit")
  sh("plugout_drive -com 'SET_THRESHNEW 0' -quit")
  sh("plugout_drive -com 'SET_PBAR_SIGN -' -quit")
  sh("plugout_drive -com 'SEE_OVERLAY +' -quit")

  if ENV['SESSION']
    sh("plugout_drive -com 'SET_SESSION #{ENV['SESSION']}' -quit")
  end

  system("suma -niml -spec #{spec} -sv #{surfvol} &")
  sh("DriveSuma -com  viewer_cont -key:d 't'")           # talk to afni
  sh("DriveSuma -com  viewer_cont -key:r2 '.'")          # Select the inflated surfaces
  sh("DriveSuma -com  viewer_cont -key 'F3'")            # toggle the crosshair (off)
  sh("DriveSuma -com  viewer_cont -key 'F6'")            # toggle background color (to white from black)
  sh("DriveSuma -com  viewer_cont -key 'F9'")            # toggle the label at the crosshair (off)
  sh("DriveSuma -com  viewer_cont -viewer_size 700 600") # adjust viewer size (which effects figure size)
end

def afni_stop()
  sh("DriveSuma -com kill_suma")
  sh("plugout_drive -com 'QUIT' -quit")
end

def afni_undump(target, source, anat, orient='')
  target_prefix = target.split("+").first
  if orient.empty? then
    sh("3dUndump -master #{anat} -xyz -datum float -prefix #{target_prefix} #{source}")
  else
    sh("3dUndump -master #{anat} -xyz -orient #{orient} -datum float -prefix #{target_prefix} #{source}")
  end
end

def afni_scale(target, source, multiple=1)
  target_prefix = target.split("+").first
  sh("3dcalc -a #{source} -expr 'a*#{multiple}' -prefix #{target_prefix}")
end

def afni_deoblique(target, source)
  target_prefix = target.split("+").first
  sh("3dWarp -deoblique -prefix #{target_prefix} #{source}")
end

def afni_adwarp(source, reference, voxdim=3)
  sh("adwarp -apar #{reference} -dpar #{source} -dxyz #{voxdim}")
end

def afni_mean(target, source_list, blur=0)
  target_prefix = target.split("+").first
  if blur > 0 then
    sh("3dmerge -1blur_fwhm #{blur} -gmean -prefix #{target_prefix} #{source_list.join(' ')}")
  else
    sh("3dmerge -gmean -prefix #{target_prefix} #{source_list.join(' ')}")
  end
end

def afni_sd(target, mean, source_list, blur=0)
  target_prefix, target_ext = target.split('+',2)
  Dir.mktmpdir do |dir|
    variance_prefix = File.join(dir,'variance')
    variance_full = [variance_prefix,target_ext].join('+')
    squarederror_list = []

    source_list.each do |source|
      source_prefix, source_ext = source.split('+', 2)
      source_prefix_b  = File.basename(source_prefix)
      squarederror_prefix = File.join(dir,['sqerr',source_prefix_b].join('_'))
      squarederror_full = [squarederror_prefix,target_ext].join('+')

      if blur > 0
        bsource_prefix = File.join(dir,['b',source_prefix_b].join('_'))
        bsource_full = [bsource_prefix,source_ext].join('+')
        sh("3dmerge -1blur_fwhm #{blur} -prefix #{bsource_prefix} #{source}")
        sh("3dcalc -a #{bsource_full} -b #{mean} -expr '(a-b)*(a-b)' -prefix #{squarederror_prefix}")
      else
        sh("3dcalc -a #{source} -b #{mean} -expr 'step(a-b)' -prefix #{squarederror_prefix}")
      end

      squarederror_list.push(squarederror_full)
    end
    sh("3dmerge -gmean -prefix #{variance_prefix} #{squarederror_list.join(" ")}")
    sh("3dcalc -a #{variance_full} -expr 'sqrt(a)' -prefix #{target_prefix}")
  end
end

def afni_count(target, source_list, blur=0)
  target_prefix = target.split("+").first
  if blur then
    sh("3dmerge -1blur_fwhm #{blur} -gcount -prefix #{target_prefix} #{source_list.join(' ')}")
  else
    sh("3dmerge -gcount -prefix #{target_prefix} #{source_list.join(' ')}")
  end
end

def afni_blur(target, source, blur)
  target_prefix = target.split("+").first
  sh("3dmerge -1blur_fwhm #{blur} -prefix #{target_prefix} #{source}")
end

def binomrank_test(target, source_list, perm_lol, blur=0, prob=0.5)
  # source_list will contain a file for each subject.
  # perm_lol will contain a list of each permutation, each containing a list of
  # files for each subject.
  # If a blur option is passed, then temporary blurred versions of the source
  # and permutation files are generated and the rank is computed wrt those
  # blurred datasets. These blurred datasets are deleted after use.
  target_prefix, target_ext = target.split('+')
  nsubj = source_list.size
  p perm_lol
  Dir.mktmpdir do |dir|
    pcount_full_list = (1..perm_lol.size).collect {|i| File.join(dir,["pcount_#{i}",target_ext].join('+'))}
    pcount_prefix_list = (1..perm_lol.size).collect {|i| File.join(dir,"pcount_#{i}")}
    count_full = File.join(dir,["count",target_ext].join('+'))
    count_prefix = File.join(dir,"count")
    bucket_full = File.join(dir,["bucket",target_ext].join('+'))
    bucket_prefix = File.join(dir,"bucket")
    #rank_full = File.join(dir,["rank",target_ext].join('+'))
    #rank_prefix = File.join(dir,"rank")
    #binom_pval_full = File.join(dir,["binom_pval",target_ext].join('+'))
    #binom_pval_prefix = File.join(dir,"binom_pval")
    ltreal_full = File.join(dir,["ltreal",target_ext].join('+'))
    ltreal_prefix = File.join(dir,"ltreal")
    ltcount_full = File.join(dir,["ltcount",target_ext].join('+'))
    ltcount_prefix = File.join(dir,"ltcount")
    eqreal_full = File.join(dir,["eqreal",target_ext].join('+'))
    eqreal_prefix = File.join(dir,"eqreal")
    eqcount_full = File.join(dir,["eqcount",target_ext].join('+'))
    eqcount_prefix = File.join(dir,"eqcount")

    pcount_prefix_list.zip(perm_lol).each do |prefix,perm_list|
      if (blur > 0)
        sh("3dmerge -1blur_fwhm #{blur} -gcount -prefix #{prefix} #{perm_list.join(' ')}")
      else
        sh("3dmerge -gcount -prefix #{prefix} #{perm_list.join(' ')}")
      end
    end

    if blur > 0
      sh("3dmerge -1blur_fwhm #{blur} -gcount -prefix #{count_prefix} #{source_list.join(' ')}")
    else
      sh("3dmerge -gcount -prefix #{count_prefix} #{source_list.join(' ')}")
    end

    # Combine permutation voxel selection datasets into a single dataset
    sh("3dbucket -fbuc -prefix #{bucket_prefix} #{pcount_full_list.join(' ')}")
    # Flag voxels in permutations where the real value at that voxel is larger.
    sh("3dcalc -prefix #{ltreal_prefix} -a #{count_full} -b #{bucket_full} -expr 'ispositive(a-b)'")
    # Flag voxels in permutations where the real value at that voxel is equal.
    sh("3dcalc -prefix #{eqreal_prefix} -a #{count_full} -b #{bucket_full} -expr 'equals(a,b)'")
    # Count the number of permutations that the real value is greater.
    sh("3dTstat -nzcount -prefix #{ltcount_prefix} #{ltreal_full}")
    # Count the number of permutations that the real value is equal (ties).
    sh("3dTstat -nzcount -prefix #{eqcount_prefix} #{eqreal_full}")
    # Compute the rank (number of values less than the real value + half the
    # number of ties with the real value)
    sh("3dcalc -prefix #{target_prefix} -a #{ltcount_full} -b #{eqcount_full} -expr 'a+(b/2)'")
    # Compute binomial p-value
#    sh("3dcalc -t #{rank_full} -expr 'fibn_t2p(t,#{nsubj},#{prob})' -prefix #{binom_pval_prefix}")
#    # Concatenate the rank and the p-value.
#    sh("3dbucket -fbuc -prefix #{target_prefix} #{rank_full} #{binom_pval_full}")
    # Mark the dataset as intensity+threshold
    sh("3drefit -fim #{target}")
    # Compute binomial p-value
    sh("3drefit -substatpar 0 fibn #{nsubj} #{prob} #{target}")
    # Add FDR curves
    sh("3drefit -addFDR #{target}")
  end
end

def nonparametric_rank_against_permutation_distribution(target, source, perm_list, mask, blur=0)
  # If a blur option is passed, then temporary blurred versions of the source
  # and permutation files are generated and the rank is computed wrt those
  # blurred datasets. These blurred datasets are deleted after use.
  target_prefix, target_ext = target.split('+')
  target_prefix_b  = File.basename(target_prefix)
  source_prefix, source_ext = source.split('+')
  source_prefix_b  = File.basename(source_prefix)
  Dir.mktmpdir do |dir|
    nzcount_prefix = File.join(dir,['nzcount',target_prefix_b].join('_'))
    nzcount_full = [nzcount_prefix,target_ext].join('+')
    gtcount_prefix = File.join(dir,['gtcount',target_prefix_b].join('_'))
    gtcount_full = [gtcount_prefix,target_ext].join('+')
    gtperm_list = []

    if (blur) then
      bsource_prefix = File.join(dir,['b',source_prefix_b].join('_'))
      bsource_full = [bsource_prefix,source_ext].join('+')
      sh("3dmerge -1blur_fwhm #{blur} -prefix #{bsource_prefix} #{source}")
    end

    perm_list.each do |permutation|
      perm_prefix_b, perm_ext = File.basename(permutation).split('+')
      gtperm_prefix = File.join(dir,'gt'+perm_prefix_b)
      gtperm_full = [gtperm_prefix,perm_ext].join('+')

      if blur > 0 then
        bperm_prefix  = File.join(dir,'b'+perm_prefix_b)
        bperm_full  = [bperm_prefix,perm_ext].join('+')
        sh("3dmerge -1blur_fwhm #{blur} -prefix #{bperm_prefix} #{permutation}")
        sh("3dcalc -a #{bsource_full} -b #{bperm_full} -expr 'step(a-b)' -prefix #{gtperm_prefix}")
      else
        sh("3dcalc -a #{source} -b #{permutation} -expr 'step(a-b)' -prefix #{gtperm_prefix}")
      end

      gtperm_list.push(gtperm_full.join('+'))
    end
    sh("3dmerge -gcount -prefix #{nzcount_prefix} #{perm_list.join(' ')}")
    sh("3dmerge -gcount -prefix #{gtcount_prefix} #{gtperm_list.join(' ')}")
    expression = "'ifelse(and(iszero(d),c),(100-b)/2,ifelse(and(ispositive(d),c),a,50))'"
    sh("3dcalc -a #{gtcount_full} -b #{nzcount_full} -c #{mask} -d #{source} -prefix #{target_prefix} -expr #{expression}")
  end
end

def nonparametric_count_median_thresholded_ranks(target,rank_list,intensitymap='')
  # This function takes the rank values for each subject, thresholds them at
  # the median rank (50), and then counts the number of subjects that survive
  # thresholding at each voxel. These counts are intended to be used as a
  # threshold. If you provide an intensity map, the count threshold will be
  # combined with it to create a new intensity+threshold dataset.
    target_prefix, target_ext = target.split('+')
    target_prefix_b  = File.basename(target_prefix)
    medianrank = rank_list.size / 2
    Dir.mktmpdir do |dir|
      rankcount_prefix = File.join(dir,['rankcount',target_prefix_b].join('_'))
      rankcount_full = [rankcount_prefix,target_ext].join('+')
      sh("3dmerge -1clip #{medianrank + 0.01} -gcount -prefix #{rankcount_prefix} #{rank_list.join(' ')}")
      if (intenstitymap) then
        sh("3dbucket -fbuc -prefix #{target_prefix} #{intensitymap} #{rankcount_full}")
        sh("3drefit -fith #{target}")
      else
        sh("3dbucket -fbuc -prefix #{target_prefix} #{rankcount_full}")
      end
    end
end

def parametric_zscore(target, source, mean, sd)
  target_prefix = target.split('+').first
  sh("3dcalc -a #{source} -b #{mean} -c #{sd} -expr 'min((a-b)/c,5)*notzero(a)' -prefix #{target_prefix}")
end
