require 'rake'
require 'rake/clean'
require 'tmpdir'
require File.join(ENV['HOME'],'src','Manchester_SoundPicture','rake','methods')

HOME = ENV['HOME']
XYZ_ORIENT = ENV.fetch('XYZ_ORIENT') {'RAI'} # order of xyz coordinates in txt files.
VOXDIM = ENV.fetch('VOXDIM') {3} # when applying a warp, this defines the voxelsize (in mm) for the warped data
BLURFWHM = ENV['BLURFWHM'].to_i
DATADIR = "#{HOME}/MRI/Manchester/data/raw"
PERMDIR = "../../permtest/solutionmaps"
SHARED_ATLAS = "#{HOME}/MRI/Manchester/data/CommonBrains/MNI_EPI_funcRes.nii"
SHARED_ATLAS_TLRC = "#{HOME}/MRI/Manchester/data/CommonBrains/TT_N27_funcres.nii"
SPEC_BOTH = "#{HOME}/suma_TT_N27/TT_N27_both.spec"
SURFACE_VOLUME = "./TT_N27_SurfVol.nii"

dir_list = []
%w(afni mean sd).each do |d|
  %w(l2norm nodestrength selectioncount stability).each do |m|
    directory File.join(d,m)
    directory File.join(d,m,'cv')
    dir_list.push(File.join(d,m))
    dir_list.push(File.join(d,m,'cv'))
  end
end
task :makedirs => dir_list

# INDEXES
PERMUTATION_INDEX = ('001'..'100').to_a
SUBJECT_INDEX = ('01'..'23').to_a
CROSSVALIDATION_INDEX = ('01'..'09').to_a

# MASKS AND REFERENCE ANATOMY
MASK_ORIG_O = ["#{DATADIR}/s02_rightyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s03_leftyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s04_rightyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s05_leftyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s06_rightyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s07_leftyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s08_rightyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s09_leftyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s10_rightyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s11_leftyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s12_rightyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s13_leftyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s14_rightyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s15_leftyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s16_rightyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s17_leftyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s18_rightyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s19_leftyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s20_rightyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s21_leftyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s22_rightyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s23_leftyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD",
               "#{DATADIR}/s24_rightyes/mask/nS_c1_mask_nocerebellum_O+orig.HEAD"
              ]
MASK_TLRC_C = ["#{DATADIR}/s02_rightyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s03_leftyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s04_rightyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s05_leftyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s06_rightyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s07_leftyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s08_rightyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s09_leftyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s10_rightyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s11_leftyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s12_rightyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s13_leftyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s14_rightyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s15_leftyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s16_rightyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s17_leftyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s18_rightyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s19_leftyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s20_rightyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s21_leftyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s22_rightyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s23_leftyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD",
               "#{DATADIR}/s24_rightyes/mask/nS_c1_mask_nocerebellum_C+tlrc.HEAD"
              ]
SUBJ_TLRC_REF = ["#{DATADIR}/s02_rightyes/T1/MD106_050913_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s03_leftyes/T1/MD106_050913B_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s04_rightyes/T1/MRH026_201_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s05_leftyes/T1/MRH026_202_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s06_rightyes/T1/MRH026_203_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s07_leftyes/T1/MRH026_204_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s08_rightyes/T1/MRH026_205_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s09_leftyes/T1/MRH026_206_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s10_rightyes/T1/MRH026_207_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s11_leftyes/T1/MRH026_208_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s12_rightyes/T1/MRH026_209_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s13_leftyes/T1/MRH026_210_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s14_rightyes/T1/MRH026_211_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s15_leftyes/T1/MRH026_212_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s16_rightyes/T1/MRH026_213_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s17_leftyes/T1/MRH026_214_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s18_rightyes/T1/MRH026_215_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s19_leftyes/T1/MRH026_216_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s20_rightyes/T1/MRH026_217_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s21_leftyes/T1/MRH026_218_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s22_rightyes/T1/MRH026_219_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s23_leftyes/T1/MRH026_220_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD",
                 "#{DATADIR}/s24_rightyes/T1/MRH026_221_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD"
                ]

# "RAW" DATA (BEGINNING OF PIPELINE)
TXT_NODESTRENGTH_ORIG_O = Rake::FileList["txt/nodestrength/???_??.orig"]
TXT_L2NORM_ORIG_O = Rake::FileList["txt/l2norm/???_??.orig"]
TXT_SELECTIONCOUNT_ORIG_O = Rake::FileList["txt/selectioncount/???_??.orig"]
TXT_STABILITY_ORIG_O = Rake::FileList["txt/stability/???_??.orig"]

filelist = Rake::FileList["txt/nodestrength/cv/???_??_??.orig"]
TXT_NODESTRENGTH_ORIG_O_CV = CROSSVALIDATION_INDEX.collect {|c|
  filelist.grep(/[0-9]+_[0-9]+_#{c}/)
}.collect {|c| Rake::FileList.new(c)}

filelist = Rake::FileList["txt/l2norm/cv/???_??_??.orig"]
TXT_L2NORM_ORIG_O_CV = CROSSVALIDATION_INDEX.collect {|c|
  filelist.grep(/[0-9]+_[0-9]+_#{c}/)
}.collect {|c| Rake::FileList.new(c)}

filelist = Rake::FileList["txt/selectioncount/cv/???_??_??.orig"]
TXT_SELECTIONCOUNT_ORIG_O_CV = CROSSVALIDATION_INDEX.collect {|c|
  filelist.grep(/[0-9]+_[0-9]+_#{c}/)
}.collect {|c| Rake::FileList.new(c)}

filelist = Rake::FileList["txt/stability/cv/???_??_??.orig"]
TXT_STABILITY_ORIG_O_CV = CROSSVALIDATION_INDEX.collect {|c|
  filelist.grep(/[0-9]+_[0-9]+_#{c}/)
}.collect {|c| Rake::FileList.new(c)}

# DERIVATIVE FILES
AFNI_NODESTRENGTH_ORIG_O_RAW = TXT_NODESTRENGTH_ORIG_O.pathmap("afni/nodestrength/%n_O_raw+orig.HEAD")
AFNI_NODESTRENGTH_ORIG_O = TXT_NODESTRENGTH_ORIG_O.pathmap("afni/nodestrength/%n_O+orig.HEAD")
AFNI_NODESTRENGTH_ORIG_C = TXT_NODESTRENGTH_ORIG_O.pathmap("afni/nodestrength/%n_C+orig.HEAD")
AFNI_NODESTRENGTH_TLRC_C = TXT_NODESTRENGTH_ORIG_O.pathmap("afni/nodestrength/%n_C+tlrc.HEAD")
AFNI_L2NORM_ORIG_O_RAW = TXT_L2NORM_ORIG_O.pathmap("afni/l2norm/%n_O_raw+orig.HEAD")
AFNI_L2NORM_ORIG_O = TXT_L2NORM_ORIG_O.pathmap("afni/l2norm/%n_O+orig.HEAD")
AFNI_L2NORM_ORIG_C = TXT_L2NORM_ORIG_O.pathmap("afni/l2norm/%n_C+orig.HEAD")
AFNI_L2NORM_TLRC_C = TXT_L2NORM_ORIG_O.pathmap("afni/l2norm/%n_C+tlrc.HEAD")
AFNI_STABILITY_ORIG_O = TXT_STABILITY_ORIG_O.pathmap("afni/stability/%n_O+orig.HEAD")
AFNI_STABILITY_ORIG_C = TXT_STABILITY_ORIG_O.pathmap("afni/stability/%n_C+orig.HEAD")
AFNI_STABILITY_TLRC_C = TXT_STABILITY_ORIG_O.pathmap("afni/stability/%n_C+tlrc.HEAD")
AFNI_SELECTIONCOUNT_ORIG_O = TXT_SELECTIONCOUNT_ORIG_O.pathmap("afni/selectioncount/%n_O+orig.HEAD")
AFNI_SELECTIONCOUNT_ORIG_C = TXT_SELECTIONCOUNT_ORIG_O.pathmap("afni/selectioncount/%n_C+orig.HEAD")
AFNI_SELECTIONCOUNT_TLRC_C = TXT_SELECTIONCOUNT_ORIG_O.pathmap("afni/selectioncount/%n_C+tlrc.HEAD")

AFNI_NODESTRENGTH_ORIG_O_RAW_CV = TXT_NODESTRENGTH_ORIG_O_CV.collect {|c| c.pathmap("afni/nodestrength/cv/%n_O_raw+orig.HEAD")}
AFNI_NODESTRENGTH_ORIG_O_CV = TXT_NODESTRENGTH_ORIG_O_CV.collect {|c| c.pathmap("afni/nodestrength/cv/%n_O+orig.HEAD")}
AFNI_NODESTRENGTH_ORIG_C_CV = TXT_NODESTRENGTH_ORIG_O_CV.collect {|c| c.pathmap("afni/nodestrength/cv/%n_C+orig.HEAD")}
AFNI_NODESTRENGTH_TLRC_C_CV = TXT_NODESTRENGTH_ORIG_O_CV.collect {|c| c.pathmap("afni/nodestrength/cv/%n_C+tlrc.HEAD")}
AFNI_L2NORM_ORIG_O_RAW_CV = TXT_L2NORM_ORIG_O_CV.collect {|c| c.pathmap("afni/l2norm/cv/%n_O_raw+orig.HEAD")}
AFNI_L2NORM_ORIG_O_CV = TXT_L2NORM_ORIG_O_CV.collect {|c| c.pathmap("afni/l2norm/cv/%n_O+orig.HEAD")}
AFNI_L2NORM_ORIG_C_CV = TXT_L2NORM_ORIG_O_CV.collect {|c| c.pathmap("afni/l2norm/cv/%n_C+orig.HEAD")}
AFNI_L2NORM_TLRC_C_CV = TXT_L2NORM_ORIG_O_CV.collect {|c| c.pathmap("afni/l2norm/cv/%n_C+tlrc.HEAD")}
AFNI_STABILITY_ORIG_O_CV = TXT_STABILITY_ORIG_O_CV.collect {|c| c.pathmap("afni/stability/cv/%n_O+orig.HEAD")}
AFNI_STABILITY_ORIG_C_CV = TXT_STABILITY_ORIG_O_CV.collect {|c| c.pathmap("afni/stability/cv/%n_C+orig.HEAD")}
AFNI_STABILITY_TLRC_C_CV = TXT_STABILITY_ORIG_O_CV.collect {|c| c.pathmap("afni/stability/cv/%n_C+tlrc.HEAD")}
AFNI_SELECTIONCOUNT_ORIG_O_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.collect {|c| c.pathmap("afni/selectioncount/cv/%n_O+orig.HEAD")}
AFNI_SELECTIONCOUNT_ORIG_C_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.collect {|c| c.pathmap("afni/selectioncount/cv/%n_C+orig.HEAD")}
AFNI_SELECTIONCOUNT_TLRC_C_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.collect {|c| c.pathmap("afni/selectioncount/cv/%n_C+tlrc.HEAD")}

SUBJMEAN_NODESTRENGTH_ORIG_O = SUBJECT_INDEX.collect {|s| "mean/nodestrength/#{s}_O+orig.HEAD"}
SUBJMEAN_NODESTRENGTH_ORIG_C = SUBJECT_INDEX.collect {|s| "mean/nodestrength/#{s}_C+orig.HEAD"}
SUBJMEAN_NODESTRENGTH_TLRC_C = SUBJECT_INDEX.collect {|s| "mean/nodestrength/#{s}_C+tlrc.HEAD"}
SUBJMEAN_NODESTRENGTH_TLRC_C_BLUR = SUBJECT_INDEX.collect {|s| "mean/nodestrength/#{s}.b#{BLURFWHM}_C+tlrc.HEAD"}
SUBJMEAN_L2NORM_ORIG_O = SUBJECT_INDEX.collect {|s| "mean/l2norm/#{s}_O+orig.HEAD"}
SUBJMEAN_L2NORM_ORIG_C = SUBJECT_INDEX.collect {|s| "mean/l2norm/#{s}_C+orig.HEAD"}
SUBJMEAN_L2NORM_TLRC_C = SUBJECT_INDEX.collect {|s| "mean/l2norm/#{s}_C+tlrc.HEAD"}
SUBJMEAN_L2NORM_TLRC_C_BLUR = SUBJECT_INDEX.collect {|s| "mean/l2norm/#{s}.b#{BLURFWHM}_C+tlrc.HEAD"}
SUBJMEAN_SELECTIONCOUNT_ORIG_O = SUBJECT_INDEX.collect {|s| "mean/selectioncount/#{s}_O+orig.HEAD"}
SUBJMEAN_SELECTIONCOUNT_ORIG_C = SUBJECT_INDEX.collect {|s| "mean/selectioncount/#{s}_C+orig.HEAD"}
SUBJMEAN_SELECTIONCOUNT_TLRC_C = SUBJECT_INDEX.collect {|s| "mean/selectioncount/#{s}_C+tlrc.HEAD"}
SUBJMEAN_SELECTIONCOUNT_TLRC_C_BLUR = SUBJECT_INDEX.collect {|s| "mean/selectioncount/#{s}.b#{BLURFWHM}_C+tlrc.HEAD"}
SUBJMEAN_STABILITY_ORIG_O = SUBJECT_INDEX.collect {|s| "mean/stability/#{s}_O+orig.HEAD"}
SUBJMEAN_STABILITY_ORIG_C = SUBJECT_INDEX.collect {|s| "mean/stability/#{s}_C+orig.HEAD"}
SUBJMEAN_STABILITY_TLRC_C = SUBJECT_INDEX.collect {|s| "mean/stability/#{s}_C+tlrc.HEAD"}
SUBJMEAN_STABILITY_TLRC_C_BLUR = SUBJECT_INDEX.collect {|s| "mean/stability/#{s}.b#{BLURFWHM}_C+tlrc.HEAD"}

SUBJMEAN_NODESTRENGTH_ORIG_O_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/nodestrength/cv/#{s}_#{c}_O+orig.HEAD"}}
SUBJMEAN_NODESTRENGTH_ORIG_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/nodestrength/cv/#{s}_#{c}_C+orig.HEAD"}}
SUBJMEAN_NODESTRENGTH_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/nodestrength/cv/#{s}_#{c}_C+tlrc.HEAD"}}
SUBJMEAN_NODESTRENGTH_TLRC_C_BLUR_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/nodestrength/cv/#{s}_#{c}_b#{BLURFWHM}_C+tlrc.HEAD"}}
SUBJMEAN_L2NORM_ORIG_O_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/l2norm/cv/#{s}_#{c}_O+orig.HEAD"}}
SUBJMEAN_L2NORM_ORIG_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/l2norm/cv/#{s}_#{c}_C+orig.HEAD"}}
SUBJMEAN_L2NORM_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/l2norm/cv/#{s}_#{c}_C+tlrc.HEAD"}}
SUBJMEAN_L2NORM_TLRC_C_BLUR_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/l2norm/cv/#{s}_#{c}_b#{BLURFWHM}_C+tlrc.HEAD"}}
SUBJMEAN_SELECTIONCOUNT_ORIG_O_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/selectioncount/cv/#{s}_#{c}_O+orig.HEAD"}}
SUBJMEAN_SELECTIONCOUNT_ORIG_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/selectioncount/cv/#{s}_#{c}_C+orig.HEAD"}}
SUBJMEAN_SELECTIONCOUNT_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/selectioncount/cv/#{s}_#{c}_C+tlrc.HEAD"}}
SUBJMEAN_SELECTIONCOUNT_TLRC_C_BLUR_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/selectioncount/#{s}_#{c}_b#{BLURFWHM}_C+tlrc.HEAD"}}
SUBJMEAN_STABILITY_ORIG_O_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/stability/cv/#{s}_#{c}_O+orig.HEAD"}}
SUBJMEAN_STABILITY_ORIG_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/stability/cv/#{s}_#{c}_C+orig.HEAD"}}
SUBJMEAN_STABILITY_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/stability/cv/#{s}_#{c}_C+tlrc.HEAD"}}
SUBJMEAN_STABILITY_TLRC_C_BLUR_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "mean/stability/cv/#{s}_#{c}_b#{BLURFWHM}_C+tlrc.HEAD"}}

SUBJSD_NODESTRENGTH_ORIG_O = SUBJECT_INDEX.collect {|s| "sd/nodestrength/#{s}_O+orig.HEAD"}
SUBJSD_NODESTRENGTH_ORIG_C = SUBJECT_INDEX.collect {|s| "sd/nodestrength/#{s}_C+orig.HEAD"}
SUBJSD_NODESTRENGTH_TLRC_C = SUBJECT_INDEX.collect {|s| "sd/nodestrength/#{s}_C+tlrc.HEAD"}
SUBJSD_NODESTRENGTH_TLRC_C_BLUR = SUBJECT_INDEX.collect {|s| "sd/nodestrength/#{s}.b#{BLURFWHM}_C+tlrc.HEAD"}
SUBJSD_L2NORM_ORIG_O = SUBJECT_INDEX.collect {|s| "sd/l2norm/#{s}_O+orig.HEAD"}
SUBJSD_L2NORM_ORIG_C = SUBJECT_INDEX.collect {|s| "sd/l2norm/#{s}_C+orig.HEAD"}
SUBJSD_L2NORM_TLRC_C = SUBJECT_INDEX.collect {|s| "sd/l2norm/#{s}_C+tlrc.HEAD"}
SUBJSD_L2NORM_TLRC_C_BLUR = SUBJECT_INDEX.collect {|s| "sd/l2norm/#{s}.b#{BLURFWHM}_C+tlrc.HEAD"}
SUBJSD_SELECTIONCOUNT_ORIG_O = SUBJECT_INDEX.collect {|s| "sd/selectioncount/#{s}_O+orig.HEAD"}
SUBJSD_SELECTIONCOUNT_ORIG_C = SUBJECT_INDEX.collect {|s| "sd/selectioncount/#{s}_C+orig.HEAD"}
SUBJSD_SELECTIONCOUNT_TLRC_C = SUBJECT_INDEX.collect {|s| "sd/selectioncount/#{s}_C+tlrc.HEAD"}
SUBJSD_SELECTIONCOUNT_TLRC_C_BLUR = SUBJECT_INDEX.collect {|s| "sd/selectioncount/#{s}.b#{BLURFWHM}_C+tlrc.HEAD"}
SUBJSD_STABILITY_ORIG_O = SUBJECT_INDEX.collect {|s| "sd/stability/#{s}_O+orig.HEAD"}
SUBJSD_STABILITY_ORIG_C = SUBJECT_INDEX.collect {|s| "sd/stability/#{s}_C+orig.HEAD"}
SUBJSD_STABILITY_TLRC_C = SUBJECT_INDEX.collect {|s| "sd/stability/#{s}_C+tlrc.HEAD"}
SUBJSD_STABILITY_TLRC_C_BLUR = SUBJECT_INDEX.collect {|s| "sd/stability/#{s}.b#{BLURFWHM}_C+tlrc.HEAD"}

SUBJSD_NODESTRENGTH_ORIG_O_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/nodestrength/cv/#{s}_#{c}_O+orig.HEAD"}}
SUBJSD_NODESTRENGTH_ORIG_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/nodestrength/cv/#{s}_#{c}_C+orig.HEAD"}}
SUBJSD_NODESTRENGTH_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/nodestrength/cv/#{s}_#{c}_C+tlrc.HEAD"}}
SUBJSD_NODESTRENGTH_TLRC_C_BLUR_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/nodestrength/cv/#{s}_#{c}_b#{BLURFWHM}_C+tlrc.HEAD"}}
SUBJSD_L2NORM_ORIG_O_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/l2norm/cv/#{s}_#{c}_O+orig.HEAD"}}
SUBJSD_L2NORM_ORIG_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/l2norm/cv/#{s}_#{c}_C+orig.HEAD"}}
SUBJSD_L2NORM_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/l2norm/cv/#{s}_#{c}_C+tlrc.HEAD"}}
SUBJSD_L2NORM_TLRC_C_BLUR_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/l2norm/cv/#{s}_#{c}_b#{BLURFWHM}_C+tlrc.HEAD"}}
SUBJSD_SELECTIONCOUNT_ORIG_O_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/selectioncount/cv/#{s}_#{c}_O+orig.HEAD"}}
SUBJSD_SELECTIONCOUNT_ORIG_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/selectioncount/cv/#{s}_#{c}_C+orig.HEAD"}}
SUBJSD_SELECTIONCOUNT_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/selectioncount/cv/#{s}_#{c}_C+tlrc.HEAD"}}
SUBJSD_SELECTIONCOUNT_TLRC_C_BLUR_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/selectioncount/cv/#{s}_#{c}_b#{BLURFWHM}_C+tlrc.HEAD"}}
SUBJSD_STABILITY_ORIG_O_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/stability/cv/#{s}_#{c}_O+orig.HEAD"}}
SUBJSD_STABILITY_ORIG_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/stability/cv/#{s}_#{c}_C+orig.HEAD"}}
SUBJSD_STABILITY_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/stability/cv/#{s}_#{c}_C+tlrc.HEAD"}}
SUBJSD_STABILITY_TLRC_C_BLUR_CV = CROSSVALIDATION_INDEX.collect {|c| SUBJECT_INDEX.collect {|s| "sd/stability/cv/#{s}_#{c}_b#{BLURFWHM}_C+tlrc.HEAD"}}

GROUPMEAN_NODESTRENGTH_TLRC_C = "mean/nodestrength/group_C+tlrc.HEAD"
GROUPMEAN_L2NORM_TLRC_C = "mean/l2norm/group_C+tlrc.HEAD"
GROUPMEAN_SELECTIONCOUNT_TLRC_C = "mean/selectioncount/group_C+tlrc.HEAD"
GROUPMEAN_STABILITY_TLRC_C = "mean/stability/group_C+tlrc.HEAD"

GROUPMEAN_NODESTRENGTH_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| "mean/nodestrength/cv/group_#{c}_C+tlrc.HEAD"}
GROUPMEAN_L2NORM_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| "mean/l2norm/cv/group_#{c}_C+tlrc.HEAD"}
GROUPMEAN_SELECTIONCOUNT_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| "mean/selectioncount/cv/group_#{c}_C+tlrc.HEAD"}
GROUPMEAN_STABILITY_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| "mean/stability/cv/group_#{c}_C+tlrc.HEAD"}

GROUPSD_NODESTRENGTH_TLRC_C = "sd/nodestrength/group_C+tlrc.HEAD"
GROUPSD_L2NORM_TLRC_C = "sd/l2norm/group_C+tlrc.HEAD"
GROUPSD_SELECTIONCOUNT_TLRC_C = "sd/selectioncount/group_C+tlrc.HEAD"
GROUPSD_STABILITY_TLRC_C = "sd/stability/group_C+tlrc.HEAD"

GROUPSD_NODESTRENGTH_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| "sd/nodestrength/cv/group_#{c}_C+tlrc.HEAD"}
GROUPSD_L2NORM_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| "sd/l2norm/cv/group_#{c}_C+tlrc.HEAD"}
GROUPSD_SELECTIONCOUNT_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| "sd/selectioncount/cv/group_#{c}_C+tlrc.HEAD"}
GROUPSD_STABILITY_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|c| "sd/stability/cv/group_#{c}_C+tlrc.HEAD"}

# GROUP PERMUTATION FILES BY SUBJECT
# ----------------------------------
PERMUTATIONS_NODESTRENGTH_ORIG_O = []
PERMUTATIONS_NODESTRENGTH_ORIG_C = []
PERMUTATIONS_NODESTRENGTH_TLRC_C = []
PERMUTATIONS_L2NORM_ORIG_O = []
PERMUTATIONS_L2NORM_ORIG_C = []
PERMUTATIONS_L2NORM_TLRC_C = []
PERMUTATIONS_SELECTIONCOUNT_ORIG_O = []
PERMUTATIONS_SELECTIONCOUNT_ORIG_C = []
PERMUTATIONS_SELECTIONCOUNT_TLRC_C = []
PERMUTATIONS_STABILITY_ORIG_O = []
PERMUTATIONS_STABILITY_ORIG_C = []
PERMUTATIONS_STABILITY_TLRC_C = []
SUBJECT_INDEX.each do |s|
  PERMUTATIONS_NODESTRENGTH_ORIG_O.push(AFNI_NODESTRENGTH_ORIG_O.select {|f| f.include? "_#{s}"})
  PERMUTATIONS_NODESTRENGTH_ORIG_C.push(AFNI_NODESTRENGTH_ORIG_C.select {|f| f.include? "_#{s}"})
  PERMUTATIONS_NODESTRENGTH_TLRC_C.push(AFNI_NODESTRENGTH_TLRC_C.select {|f| f.include? "_#{s}"})
  PERMUTATIONS_L2NORM_ORIG_O.push(AFNI_L2NORM_ORIG_O.select {|f| f.include? "_#{s}"})
  PERMUTATIONS_L2NORM_ORIG_C.push(AFNI_L2NORM_ORIG_C.select {|f| f.include? "_#{s}"})
  PERMUTATIONS_L2NORM_TLRC_C.push(AFNI_L2NORM_TLRC_C.select {|f| f.include? "_#{s}"})
  PERMUTATIONS_SELECTIONCOUNT_ORIG_O.push(AFNI_SELECTIONCOUNT_ORIG_O.select {|f| f.include? "_#{s}"})
  PERMUTATIONS_SELECTIONCOUNT_ORIG_C.push(AFNI_SELECTIONCOUNT_ORIG_C.select {|f| f.include? "_#{s}"})
  PERMUTATIONS_SELECTIONCOUNT_TLRC_C.push(AFNI_SELECTIONCOUNT_TLRC_C.select {|f| f.include? "_#{s}"})
  PERMUTATIONS_STABILITY_ORIG_O.push(AFNI_STABILITY_ORIG_O.select {|f| f.include? "_#{s}"})
  PERMUTATIONS_STABILITY_ORIG_C.push(AFNI_STABILITY_ORIG_C.select {|f| f.include? "_#{s}"})
  PERMUTATIONS_STABILITY_TLRC_C.push(AFNI_STABILITY_TLRC_C.select {|f| f.include? "_#{s}"})
end

SUBJECTS_NODESTRENGTH_ORIG_O_TXT = []
SUBJECTS_NODESTRENGTH_ORIG_O_RAW = []
SUBJECTS_NODESTRENGTH_ORIG_O = []
SUBJECTS_NODESTRENGTH_ORIG_C = []
SUBJECTS_NODESTRENGTH_TLRC_C = []
SUBJECTS_L2NORM_ORIG_O_TXT = []
SUBJECTS_L2NORM_ORIG_O_RAW = []
SUBJECTS_L2NORM_ORIG_O = []
SUBJECTS_L2NORM_ORIG_C = []
SUBJECTS_L2NORM_TLRC_C = []
SUBJECTS_SELECTIONCOUNT_ORIG_O_TXT = []
SUBJECTS_SELECTIONCOUNT_ORIG_O = []
SUBJECTS_SELECTIONCOUNT_ORIG_C = []
SUBJECTS_SELECTIONCOUNT_TLRC_C = []
SUBJECTS_STABILITY_ORIG_O_TXT = []
SUBJECTS_STABILITY_ORIG_O = []
SUBJECTS_STABILITY_ORIG_C = []
SUBJECTS_STABILITY_TLRC_C = []
PERMUTATION_INDEX.each do |p|
  SUBJECTS_NODESTRENGTH_ORIG_O_TXT.push(TXT_NODESTRENGTH_ORIG_O.select {|f| f.include? "#{p}_"})
  SUBJECTS_NODESTRENGTH_ORIG_O_RAW.push(AFNI_NODESTRENGTH_ORIG_O_RAW.select {|f| f.include? "#{p}_"})
  SUBJECTS_NODESTRENGTH_ORIG_O.push(AFNI_NODESTRENGTH_ORIG_O.select {|f| f.include? "#{p}_"})
  SUBJECTS_NODESTRENGTH_ORIG_C.push(AFNI_NODESTRENGTH_ORIG_C.select {|f| f.include? "#{p}_"})
  SUBJECTS_NODESTRENGTH_TLRC_C.push(AFNI_NODESTRENGTH_TLRC_C.select {|f| f.include? "#{p}_"})
  SUBJECTS_L2NORM_ORIG_O_TXT.push(TXT_L2NORM_ORIG_O.select {|f| f.include? "#{p}_"})
  SUBJECTS_L2NORM_ORIG_O_RAW.push(AFNI_L2NORM_ORIG_O_RAW.select {|f| f.include? "#{p}_"})
  SUBJECTS_L2NORM_ORIG_O.push(AFNI_L2NORM_ORIG_O.select {|f| f.include? "#{p}_"})
  SUBJECTS_L2NORM_ORIG_C.push(AFNI_L2NORM_ORIG_C.select {|f| f.include? "#{p}_"})
  SUBJECTS_L2NORM_TLRC_C.push(AFNI_L2NORM_TLRC_C.select {|f| f.include? "#{p}_"})
  SUBJECTS_SELECTIONCOUNT_ORIG_O_TXT.push(TXT_SELECTIONCOUNT_ORIG_O.select {|f| f.include? "#{p}_"})
  SUBJECTS_SELECTIONCOUNT_ORIG_O.push(AFNI_SELECTIONCOUNT_ORIG_O.select {|f| f.include? "#{p}_"})
  SUBJECTS_SELECTIONCOUNT_ORIG_C.push(AFNI_SELECTIONCOUNT_ORIG_C.select {|f| f.include? "#{p}_"})
  SUBJECTS_SELECTIONCOUNT_TLRC_C.push(AFNI_SELECTIONCOUNT_TLRC_C.select {|f| f.include? "#{p}_"})
  SUBJECTS_STABILITY_ORIG_O_TXT.push(TXT_STABILITY_ORIG_O.select {|f| f.include? "#{p}_"})
  SUBJECTS_STABILITY_ORIG_O.push(AFNI_STABILITY_ORIG_O.select {|f| f.include? "#{p}_"})
  SUBJECTS_STABILITY_ORIG_C.push(AFNI_STABILITY_ORIG_C.select {|f| f.include? "#{p}_"})
  SUBJECTS_STABILITY_TLRC_C.push(AFNI_STABILITY_TLRC_C.select {|f| f.include? "#{p}_"})
end

# GROUP PERMUTATION FILES BY SUBJECT AND CROSSVALIDATION
# ------------------------------------------------------
PERMUTATIONS_NODESTRENGTH_ORIG_O_CV = AFNI_NODESTRENGTH_ORIG_O_CV.collect {|c| SUBJECT_INDEX.collect {|s|  c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_NODESTRENGTH_ORIG_C_CV = AFNI_NODESTRENGTH_ORIG_C_CV.collect {|c| SUBJECT_INDEX.collect {|s|  c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_NODESTRENGTH_TLRC_C_CV = AFNI_NODESTRENGTH_TLRC_C_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_L2NORM_ORIG_O_CV = AFNI_L2NORM_ORIG_O_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_L2NORM_ORIG_C_CV = AFNI_L2NORM_ORIG_C_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_L2NORM_TLRC_C_CV = AFNI_L2NORM_TLRC_C_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_SELECTIONCOUNT_ORIG_O_CV = AFNI_SELECTIONCOUNT_ORIG_O_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_SELECTIONCOUNT_ORIG_C_CV = AFNI_SELECTIONCOUNT_ORIG_C_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_SELECTIONCOUNT_TLRC_C_CV = AFNI_SELECTIONCOUNT_TLRC_C_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_STABILITY_ORIG_O_CV = AFNI_STABILITY_ORIG_O_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_STABILITY_ORIG_C_CV = AFNI_STABILITY_ORIG_C_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_STABILITY_TLRC_C_CV = AFNI_STABILITY_TLRC_C_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}

SUBJECTS_NODESTRENGTH_ORIG_O_TXT_CV = TXT_NODESTRENGTH_ORIG_O_CV.collect {|c| PERMUTATION_INDEX.collect {|p|  c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_NODESTRENGTH_ORIG_O_RAW_CV = AFNI_NODESTRENGTH_ORIG_O_RAW_CV.collect {|c| PERMUTATION_INDEX.collect {|p|  c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_NODESTRENGTH_ORIG_O_CV = AFNI_NODESTRENGTH_ORIG_O_CV.collect {|c| PERMUTATION_INDEX.collect {|p|  c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_NODESTRENGTH_ORIG_C_CV = AFNI_NODESTRENGTH_ORIG_C_CV.collect {|c| PERMUTATION_INDEX.collect {|p|  c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_NODESTRENGTH_TLRC_C_CV = AFNI_NODESTRENGTH_TLRC_C_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_L2NORM_ORIG_O_TXT_CV = TXT_L2NORM_ORIG_O_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_L2NORM_ORIG_O_RAW_CV = AFNI_L2NORM_ORIG_O_RAW_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_L2NORM_ORIG_O_CV = AFNI_L2NORM_ORIG_O_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_L2NORM_ORIG_C_CV = AFNI_L2NORM_ORIG_C_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_L2NORM_TLRC_C_CV = AFNI_L2NORM_TLRC_C_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_SELECTIONCOUNT_ORIG_O_TXT_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_SELECTIONCOUNT_ORIG_O_CV = AFNI_SELECTIONCOUNT_ORIG_O_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_SELECTIONCOUNT_ORIG_C_CV = AFNI_SELECTIONCOUNT_ORIG_C_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_SELECTIONCOUNT_TLRC_C_CV = AFNI_SELECTIONCOUNT_TLRC_C_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_STABILITY_ORIG_O_TXT_CV = TXT_STABILITY_ORIG_O_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_STABILITY_ORIG_O_CV = AFNI_STABILITY_ORIG_O_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_STABILITY_ORIG_C_CV = AFNI_STABILITY_ORIG_C_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
SUBJECTS_STABILITY_TLRC_C_CV = AFNI_STABILITY_TLRC_C_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}

# AFNI TASKS
# ==========
namespace :afni do
  desc 'Launch AFNI and SUMA'
  task :start do
    afni_start(SURFACE_VOLUME,SPEC_BOTH)
  end

  desc 'Close AFNI and SUMA'
  task :stop do
    afni_stop()
  end
end

afni_orig_o_raw =
  SUBJECTS_NODESTRENGTH_ORIG_O_RAW +
  SUBJECTS_L2NORM_ORIG_O_RAW +
  SUBJECTS_SELECTIONCOUNT_ORIG_O +
  SUBJECTS_STABILITY_ORIG_O
txt_orig_o =
  SUBJECTS_NODESTRENGTH_ORIG_O_TXT +
  SUBJECTS_L2NORM_ORIG_O_TXT +
  SUBJECTS_SELECTIONCOUNT_ORIG_O_TXT +
  SUBJECTS_STABILITY_ORIG_O_TXT
afni_orig_o_raw.zip(txt_orig_o).each do |afni_list,txt_list|
  afni_list.zip(txt_list,MASK_ORIG_O).each do |target,source,anat|
    file target => [source,anat] do
      afni_undump(target,source,anat,XYZ_ORIENT)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

afni_orig_o_raw =
  SUBJECTS_NODESTRENGTH_ORIG_O_RAW_CV +
  SUBJECTS_L2NORM_ORIG_O_RAW_CV +
  SUBJECTS_SELECTIONCOUNT_ORIG_O_CV +
  SUBJECTS_STABILITY_ORIG_O_CV
txt_orig_o =
  SUBJECTS_NODESTRENGTH_ORIG_O_TXT_CV +
  SUBJECTS_L2NORM_ORIG_O_TXT_CV +
  SUBJECTS_SELECTIONCOUNT_ORIG_O_TXT_CV +
  SUBJECTS_STABILITY_ORIG_O_TXT_CV
afni_orig_o_raw.zip(txt_orig_o).each do |afni_lol,txt_lol|
  afni_lol.zip(txt_lol).each do |afni_list,txt_list|
    afni_list.zip(txt_list,MASK_ORIG_O).each do |target,source,anat|
      file target => [source,anat] do
        afni_undump(target,source,anat,XYZ_ORIENT)
      end
      CLOBBER.push(target)
      CLOBBER.push(target.sub(".HEAD",".BRIK"))
      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
    end
  end
end

afni_orig_o_to_scale =
  AFNI_NODESTRENGTH_ORIG_O_RAW +
  AFNI_L2NORM_ORIG_O_RAW +
  AFNI_NODESTRENGTH_ORIG_O_RAW_CV.flatten +
  AFNI_L2NORM_ORIG_O_RAW_CV.flatten
afni_orig_o_scaled =
  AFNI_NODESTRENGTH_ORIG_O+
  AFNI_L2NORM_ORIG_O +
  AFNI_NODESTRENGTH_ORIG_O_CV.flatten +
  AFNI_L2NORM_ORIG_O_CV.flatten
afni_orig_o_scaled.zip(afni_orig_o_to_scale).each do |target,source|
  file target => [source] do
    afni_scale(target, source, 1000)
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub(".HEAD",".BRIK"))
  CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
end

afni_orig_o_all =
  AFNI_NODESTRENGTH_ORIG_O +
  AFNI_L2NORM_ORIG_O +
  AFNI_SELECTIONCOUNT_ORIG_O +
  AFNI_STABILITY_ORIG_O +
  AFNI_NODESTRENGTH_ORIG_O_CV.flatten +
  AFNI_L2NORM_ORIG_O_CV.flatten +
  AFNI_SELECTIONCOUNT_ORIG_O_CV.flatten +
  AFNI_STABILITY_ORIG_O_CV.flatten
afni_orig_c_all =
  AFNI_NODESTRENGTH_ORIG_C +
  AFNI_L2NORM_ORIG_C +
  AFNI_SELECTIONCOUNT_ORIG_C +
  AFNI_STABILITY_ORIG_C +
  AFNI_NODESTRENGTH_ORIG_C_CV.flatten +
  AFNI_L2NORM_ORIG_C_CV.flatten +
  AFNI_SELECTIONCOUNT_ORIG_C_CV.flatten +
  AFNI_STABILITY_ORIG_C_CV.flatten
afni_orig_c_all.zip(afni_orig_o_all).each do |target,source|
  file target => source do
    afni_deoblique(target, source)
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub('+orig.HEAD','+orig.BRIK'))
  CLOBBER.push(target.sub('+orig.HEAD','+orig.BRIK.gz'))
end

afni_orig_c_lol =
  SUBJECTS_NODESTRENGTH_ORIG_C +
  SUBJECTS_L2NORM_ORIG_C +
  SUBJECTS_SELECTIONCOUNT_ORIG_C +
  SUBJECTS_STABILITY_ORIG_C
afni_tlrc_c_lol =
  SUBJECTS_NODESTRENGTH_TLRC_C +
  SUBJECTS_L2NORM_TLRC_C +
  SUBJECTS_SELECTIONCOUNT_TLRC_C +
  SUBJECTS_STABILITY_TLRC_C
afni_tlrc_c_lol.zip(afni_orig_c_lol).each do |tlrc_list,orig_list|
  tlrc_list.zip(orig_list,SUBJ_TLRC_REF).each do |target,source,anat|
    file target => [source,anat] do
      afni_adwarp(source, anat, VOXDIM)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub('.HEAD','.BRIK'))
    CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
  end
end

afni_orig_c_lolol =
  SUBJECTS_NODESTRENGTH_ORIG_C_CV +
  SUBJECTS_L2NORM_ORIG_C_CV +
  SUBJECTS_SELECTIONCOUNT_ORIG_C_CV +
  SUBJECTS_STABILITY_ORIG_C_CV
afni_tlrc_c_lolol =
  SUBJECTS_NODESTRENGTH_TLRC_C_CV +
  SUBJECTS_L2NORM_TLRC_C_CV +
  SUBJECTS_SELECTIONCOUNT_TLRC_C_CV +
  SUBJECTS_STABILITY_TLRC_C_CV
afni_tlrc_c_lolol.zip(afni_orig_c_lolol).each do |tlrc_lol,orig_lol|
  tlrc_lol.zip(orig_lol).each do |tlrc_list,orig_list|
    tlrc_list.zip(orig_list,SUBJ_TLRC_REF).each do |target,source,anat|
      file target => [source,anat] do
        afni_adwarp(source, anat, VOXDIM)
      end
      CLOBBER.push(target)
      CLOBBER.push(target.sub('.HEAD','.BRIK'))
      CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
    end
  end
end

afni_lolol = [
  PERMUTATIONS_NODESTRENGTH_ORIG_O,
  PERMUTATIONS_NODESTRENGTH_ORIG_C,
  PERMUTATIONS_NODESTRENGTH_TLRC_C,
  PERMUTATIONS_L2NORM_ORIG_O,
  PERMUTATIONS_L2NORM_ORIG_C,
  PERMUTATIONS_L2NORM_TLRC_C,
  PERMUTATIONS_SELECTIONCOUNT_ORIG_O,
  PERMUTATIONS_SELECTIONCOUNT_ORIG_C,
  PERMUTATIONS_SELECTIONCOUNT_TLRC_C,
  PERMUTATIONS_STABILITY_ORIG_O,
  PERMUTATIONS_STABILITY_ORIG_C,
  PERMUTATIONS_STABILITY_TLRC_C
]
subjmean_lol = [
  SUBJMEAN_NODESTRENGTH_ORIG_O,
  SUBJMEAN_NODESTRENGTH_ORIG_C,
  SUBJMEAN_NODESTRENGTH_TLRC_C,
  SUBJMEAN_L2NORM_ORIG_O,
  SUBJMEAN_L2NORM_ORIG_C,
  SUBJMEAN_L2NORM_TLRC_C,
  SUBJMEAN_SELECTIONCOUNT_ORIG_O,
  SUBJMEAN_SELECTIONCOUNT_ORIG_C,
  SUBJMEAN_SELECTIONCOUNT_TLRC_C,
  SUBJMEAN_STABILITY_ORIG_O,
  SUBJMEAN_STABILITY_ORIG_C,
  SUBJMEAN_STABILITY_TLRC_C
]
subjmean_lol.zip(afni_lolol).each do |target_list,afni_lol|
  target_list.zip(afni_lol).each do |target,afni_list|
    file target => afni_list do
      afni_mean(target, afni_list)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub('.HEAD','.BRIK'))
    CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
  end
end

# metric x crossvalidation x subject
afni_lololol_cv = [
  PERMUTATIONS_NODESTRENGTH_ORIG_O_CV,
  PERMUTATIONS_NODESTRENGTH_ORIG_C_CV,
  PERMUTATIONS_NODESTRENGTH_TLRC_C_CV,
  PERMUTATIONS_L2NORM_ORIG_O_CV,
  PERMUTATIONS_L2NORM_ORIG_C_CV,
  PERMUTATIONS_L2NORM_TLRC_C_CV,
  PERMUTATIONS_SELECTIONCOUNT_ORIG_O_CV,
  PERMUTATIONS_SELECTIONCOUNT_ORIG_C_CV,
  PERMUTATIONS_SELECTIONCOUNT_TLRC_C_CV,
  PERMUTATIONS_STABILITY_ORIG_O_CV,
  PERMUTATIONS_STABILITY_ORIG_C_CV,
  PERMUTATIONS_STABILITY_TLRC_C_CV
]
# metric x crossvalidation
subjmean_lolol_cv = [
  SUBJMEAN_NODESTRENGTH_ORIG_O_CV,
  SUBJMEAN_NODESTRENGTH_ORIG_C_CV,
  SUBJMEAN_NODESTRENGTH_TLRC_C_CV,
  SUBJMEAN_L2NORM_ORIG_O_CV,
  SUBJMEAN_L2NORM_ORIG_C_CV,
  SUBJMEAN_L2NORM_TLRC_C_CV,
  SUBJMEAN_SELECTIONCOUNT_ORIG_O_CV,
  SUBJMEAN_SELECTIONCOUNT_ORIG_C_CV,
  SUBJMEAN_SELECTIONCOUNT_TLRC_C_CV,
  SUBJMEAN_STABILITY_ORIG_O_CV,
  SUBJMEAN_STABILITY_ORIG_C_CV,
  SUBJMEAN_STABILITY_TLRC_C_CV
]
subjmean_lolol_cv.zip(afni_lololol_cv).each do |target_lol,source_lolol|
  target_lol.zip(source_lolol).each do |target_list,source_lol|
    target_list.zip(source_lol).each do |target,source_list|
      file target => source_list do
        afni_mean(target, source_list)
      end
      CLOBBER.push(target)
      CLOBBER.push(target.sub('.HEAD','.BRIK'))
      CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
    end
  end
end

subjmean_lol = [
  SUBJMEAN_NODESTRENGTH_TLRC_C,
  SUBJMEAN_L2NORM_TLRC_C,
  SUBJMEAN_SELECTIONCOUNT_TLRC_C,
  SUBJMEAN_STABILITY_TLRC_C
]
group_all = [
  GROUPMEAN_NODESTRENGTH_TLRC_C,
  GROUPMEAN_L2NORM_TLRC_C,
  GROUPMEAN_SELECTIONCOUNT_TLRC_C,
  GROUPMEAN_STABILITY_TLRC_C
]
group_all.zip(subjmean_lol).each do |target, subj_list|
  file target => subj_list do
    afni_mean(target, subj_list)
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub(".HEAD",".BRIK"))
  CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
end

subjmean_lol = [
  SUBJMEAN_NODESTRENGTH_TLRC_C_CV,
  SUBJMEAN_L2NORM_TLRC_C_CV,
  SUBJMEAN_SELECTIONCOUNT_TLRC_C_CV,
  SUBJMEAN_STABILITY_TLRC_C_CV
]
group_all = [
  GROUPMEAN_NODESTRENGTH_TLRC_C_CV,
  GROUPMEAN_L2NORM_TLRC_C_CV,
  GROUPMEAN_SELECTIONCOUNT_TLRC_C_CV,
  GROUPMEAN_STABILITY_TLRC_C_CV
]
group_all.zip(subjmean_lol).each do |target_list, source_lol|
  target_list.zip(source_lol).each do |target, source_list|
    file target => source_list do
      afni_mean(target, source_list)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

# STANDARD DEVIATION
# ==================
# Average models, no blur
# -----------------------
afni_lolol = [
  PERMUTATIONS_NODESTRENGTH_ORIG_O,
  PERMUTATIONS_L2NORM_ORIG_O,
  PERMUTATIONS_SELECTIONCOUNT_ORIG_O,
  PERMUTATIONS_STABILITY_ORIG_O,
]
subjsd_lol = [
  SUBJSD_NODESTRENGTH_ORIG_O,
  SUBJSD_L2NORM_ORIG_O,
  SUBJSD_SELECTIONCOUNT_ORIG_O,
  SUBJSD_STABILITY_ORIG_O
]
subjmean_lol = [
  SUBJMEAN_NODESTRENGTH_ORIG_O,
  SUBJMEAN_L2NORM_ORIG_O,
  SUBJMEAN_SELECTIONCOUNT_ORIG_O,
  SUBJMEAN_STABILITY_ORIG_O
]
subjsd_lol.zip(subjmean_lol,afni_lolol).each do |target_list,mean_list,source_lol|
  target_list.zip(mean_list,source_lol).each do |target,mean,source_list|
    file target => source_list+[mean] do
      afni_sd(target, mean, source_list)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub('.HEAD','.BRIK'))
    CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
  end
end

# Average models, blur
# --------------------
afni_lolol = [
  PERMUTATIONS_NODESTRENGTH_TLRC_C,
  PERMUTATIONS_L2NORM_TLRC_C,
  PERMUTATIONS_SELECTIONCOUNT_TLRC_C,
  PERMUTATIONS_STABILITY_TLRC_C,
]
subjsd_lol = [
  SUBJSD_NODESTRENGTH_TLRC_C_BLUR,
  SUBJSD_L2NORM_TLRC_C_BLUR,
  SUBJSD_SELECTIONCOUNT_TLRC_C_BLUR,
  SUBJSD_STABILITY_TLRC_C_BLUR
]
subjmean_lol = [
  SUBJMEAN_NODESTRENGTH_TLRC_C_BLUR,
  SUBJMEAN_L2NORM_TLRC_C_BLUR,
  SUBJMEAN_SELECTIONCOUNT_TLRC_C_BLUR,
  SUBJMEAN_STABILITY_TLRC_C_BLUR
]
subjsd_lol.zip(subjmean_lol,afni_lolol).each do |target_list,mean_list,source_lol|
  target_list.zip(mean_list,source_lol).each do |target,mean,source_list|
    file target => source_list+[mean] do
      afni_sd(target, mean, source_list, BLURFWHM)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub('.HEAD','.BRIK'))
    CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
  end
end

# Individual models, no blur
# --------------------------
afni_lololol_cv = [
  PERMUTATIONS_NODESTRENGTH_ORIG_O_CV,
  PERMUTATIONS_L2NORM_ORIG_O_CV,
  PERMUTATIONS_SELECTIONCOUNT_ORIG_O_CV,
  PERMUTATIONS_STABILITY_ORIG_O_CV
]
subjsd_lolol_cv = [
  SUBJSD_NODESTRENGTH_ORIG_O_CV,
  SUBJSD_L2NORM_ORIG_O_CV,
  SUBJSD_SELECTIONCOUNT_ORIG_O_CV,
  SUBJSD_STABILITY_ORIG_O_CV
]
subjmean_lolol_cv = [
  SUBJMEAN_NODESTRENGTH_ORIG_O_CV,
  SUBJMEAN_L2NORM_ORIG_O_CV,
  SUBJMEAN_SELECTIONCOUNT_ORIG_O_CV,
  SUBJMEAN_STABILITY_ORIG_O_CV
]
subjsd_lolol_cv.zip(subjmean_lolol_cv,afni_lololol_cv).each do |target_lol,mean_lol,source_lolol|
  target_lol.zip(mean_lol,source_lolol).each do |target_list,mean_list,source_lol|
    target_list.zip(mean_list,source_lol).each do |target,mean,source_list|
      file target => source_list+[mean] do
        afni_sd(target, mean, source_list)
      end
      CLOBBER.push(target)
      CLOBBER.push(target.sub('.HEAD','.BRIK'))
      CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
    end
  end
end

# Individual models, blur
# -----------------------
afni_lololol_cv = [
  PERMUTATIONS_NODESTRENGTH_TLRC_C_CV,
  PERMUTATIONS_L2NORM_TLRC_C_CV,
  PERMUTATIONS_SELECTIONCOUNT_TLRC_C_CV,
  PERMUTATIONS_STABILITY_TLRC_C_CV
]
subjsd_lolol_cv_blur = [
  SUBJSD_NODESTRENGTH_TLRC_C_BLUR_CV,
  SUBJSD_L2NORM_TLRC_C_BLUR_CV,
  SUBJSD_SELECTIONCOUNT_TLRC_C_BLUR_CV,
  SUBJSD_STABILITY_TLRC_C_BLUR_CV
]
subjmean_lolol_cv_blur = [
  SUBJMEAN_NODESTRENGTH_TLRC_C_BLUR_CV,
  SUBJMEAN_L2NORM_TLRC_C_BLUR_CV,
  SUBJMEAN_SELECTIONCOUNT_TLRC_C_BLUR_CV,
  SUBJMEAN_STABILITY_TLRC_C_BLUR_CV
]
subjsd_lolol_cv_blur.zip(subjmean_lolol_cv_blur,afni_lololol_cv).each do |target_lol,mean_lol,source_lolol|
  target_lol.zip(mean_lol,source_lolol).each do |target_list,mean_list,source_lol|
    target_list.zip(mean_list,source_lol).each do |target,mean,source_list|
      file target => source_list+[mean] do
        afni_sd(target, mean, source_list, BLURFWHM)
      end
      CLOBBER.push(target)
      CLOBBER.push(target.sub('.HEAD','.BRIK'))
      CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
    end
  end
end

namespace :nodestrength do
  task :afni => AFNI_NODESTRENGTH_ORIG_O
  task :mean => SUBJMEAN_NODESTRENGTH_ORIG_O + [GROUPMEAN_NODESTRENGTH_TLRC_C]
  task :sd => SUBJSD_NODESTRENGTH_ORIG_O + [GROUPSD_NODESTRENGTH_TLRC_C]
  namespace :cv do
    task :afni => AFNI_NODESTRENGTH_ORIG_O_CV
    task :mean => SUBJMEAN_NODESTRENGTH_ORIG_O_CV + [GROUPMEAN_NODESTRENGTH_TLRC_C_CV]
    task :sd => SUBJSD_NODESTRENGTH_ORIG_O_CV + [GROUPSD_NODESTRENGTH_TLRC_C_CV]
  end
end

namespace :l2norm do
  task :afni => AFNI_L2NORM_ORIG_O
  task :mean => SUBJMEAN_L2NORM_ORIG_O + [GROUPMEAN_L2NORM_TLRC_C]
  task :sd => SUBJSD_L2NORM_ORIG_O + [GROUPSD_L2NORM_TLRC_C]
  namespace :cv do
    task :afni => AFNI_L2NORM_ORIG_O_CV
    task :mean => SUBJMEAN_L2NORM_ORIG_O_CV + [GROUPMEAN_L2NORM_TLRC_C_CV]
    task :sd => SUBJSD_L2NORM_ORIG_O_CV + [GROUPSD_L2NORM_TLRC_C_CV]
  end
end

namespace :selectioncount do
  task :afni => AFNI_SELECTIONCOUNT_ORIG_O
  task :mean => SUBJMEAN_SELECTIONCOUNT_ORIG_O + [GROUPMEAN_SELECTIONCOUNT_TLRC_C]
  task :sd => SUBJSD_SELECTIONCOUNT_ORIG_O + [GROUPSD_SELECTIONCOUNT_TLRC_C]
  namespace :cv do
    task :afni => AFNI_SELECTIONCOUNT_ORIG_O_CV
    task :mean => SUBJMEAN_SELECTIONCOUNT_ORIG_O_CV + [GROUPMEAN_SELECTIONCOUNT_TLRC_C_CV]
    task :sd => SUBJSD_SELECTIONCOUNT_ORIG_O_CV + [GROUPSD_SELECTIONCOUNT_TLRC_C_CV]
  end
end

namespace :stability do
  task :afni => AFNI_STABILITY_ORIG_O
  task :mean => SUBJMEAN_STABILITY_ORIG_O + [GROUPMEAN_STABILITY_TLRC_C]
  task :sd => SUBJSD_STABILITY_ORIG_O + [GROUPSD_STABILITY_TLRC_C]
  namespace :cv do
    task :afni => AFNI_STABILITY_ORIG_O_CV
    task :mean => SUBJMEAN_STABILITY_ORIG_O_CV + [GROUPMEAN_STABILITY_TLRC_C_CV]
    task :sd => SUBJSD_STABILITY_ORIG_O_CV + [GROUPSD_STABILITY_TLRC_C_CV]
  end
end

task :makedirs => dir_list
