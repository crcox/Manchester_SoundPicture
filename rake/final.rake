require 'rake'
require 'rake/clean'
require 'tmpdir'
require File.join(ENV['HOME'],'src','Manchester_SoundPicture','rake','methods')

HOME = ENV['HOME']
XYZ_ORIENT = ENV.fetch('XYZ_ORIENT') {'RAI'} # order of xyz coordinates in txt files.
VOXDIM = ENV.fetch('VOXDIM') {3} # when applying a warp, this defines the voxelsize (in mm) for the warped data
BLURFWHM = ENV['BLURFWHM'].to_i
DATADIR = "#{HOME}/MRI/Manchester/data/raw"
PERMDIR = ENV.fetch('PERMDIR') {'../../permtest/solutionmaps'}
SHARED_ATLAS = "#{HOME}/MRI/Manchester/data/CommonBrains/MNI_EPI_funcRes.nii"
SHARED_ATLAS_TLRC = "#{HOME}/MRI/Manchester/data/CommonBrains/TT_N27_funcres.nii"
SPEC_BOTH = "#{HOME}/suma_TT_N27/TT_N27_both.spec"
SURFACE_VOLUME = "./TT_N27_SurfVol.nii"

# INDEXES
PERMUTATION_INDEX = ('001'..'100').to_a
SUBJECT_INDEX = ('01'..'23').to_a
CROSSVALIDATION_INDEX = ('01'..'09').to_a
#CVSUBSET = ENV.fetch('CVSUBSET').split {CROSSVALIDATION_INDEX}

dir_list = []
%w(afni zscore rank ranki).each do |d|
  %w(l2norm nodestrength selectioncount stability).each do |m|
    directory File.join(d,m)
    directory File.join(d,m,'cv')
    dir_list.push(File.join(d,m))
    dir_list.push(File.join(d,m,'cv'))
  end
end
task :makedirs => dir_list

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
TXT_NODESTRENGTH_ORIG_O = Rake::FileList["txt/nodestrength/??.orig"]
TXT_L2NORM_ORIG_O = Rake::FileList["txt/l2norm/??.orig"]
TXT_SELECTIONCOUNT_ORIG_O = Rake::FileList["txt/selectioncount/??.orig"]
TXT_STABILITY_ORIG_O = Rake::FileList["txt/stability/??.orig"]
TXT_MASK_ORIG_O = Rake::FileList["txt/mask/??.orig"]

TXT_NODESTRENGTH_ORIG_O_CV = CROSSVALIDATION_INDEX.collect{|c| Rake::FileList["txt/nodestrength/cv/??_??.orig"].select {|x| x.include? "_#{c}"}}.map {|s| Rake::FileList.new(s)}
TXT_L2NORM_ORIG_O_CV = CROSSVALIDATION_INDEX.collect{|c| Rake::FileList["txt/l2norm/cv/??_??.orig"].select {|x| x.include? "_#{c}"}}.map {|s| Rake::FileList.new(s)}
TXT_SELECTIONCOUNT_ORIG_O_CV = CROSSVALIDATION_INDEX.collect{|c| Rake::FileList["txt/selectioncount/cv/??_??.orig"].select {|x| x.include? "_#{c}"}}.map {|s| Rake::FileList.new(s)}

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

AFNI_NODESTRENGTH_ORIG_O_RAW_CV = TXT_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("afni/nodestrength/cv/%n_O_raw+orig.HEAD")}
AFNI_NODESTRENGTH_ORIG_O_CV = TXT_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("afni/nodestrength/cv/%n_O+orig.HEAD")}
AFNI_NODESTRENGTH_ORIG_C_CV = TXT_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("afni/nodestrength/cv/%n_C+orig.HEAD")}
AFNI_NODESTRENGTH_TLRC_C_CV = TXT_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("afni/nodestrength/cv/%n_C+tlrc.HEAD")}
AFNI_L2NORM_ORIG_O_RAW_CV = TXT_L2NORM_ORIG_O_CV.map {|s| s.pathmap("afni/l2norm/cv/%n_O_raw+orig.HEAD")}
AFNI_L2NORM_ORIG_O_CV = TXT_L2NORM_ORIG_O_CV.map {|s| s.pathmap("afni/l2norm/cv/%n_O+orig.HEAD")}
AFNI_L2NORM_ORIG_C_CV = TXT_L2NORM_ORIG_O_CV.map {|s| s.pathmap("afni/l2norm/cv/%n_C+orig.HEAD")}
AFNI_L2NORM_TLRC_C_CV = TXT_L2NORM_ORIG_O_CV.map {|s| s.pathmap("afni/l2norm/cv/%n_C+tlrc.HEAD")}
AFNI_SELECTIONCOUNT_ORIG_O_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("afni/selectioncount/cv/%n_O+orig.HEAD")}
AFNI_SELECTIONCOUNT_ORIG_C_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("afni/selectioncount/cv/%n_C+orig.HEAD")}
AFNI_SELECTIONCOUNT_TLRC_C_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("afni/selectioncount/cv/%n_C+tlrc.HEAD")}

RANK_NODESTRENGTH_ORIG_O = AFNI_NODESTRENGTH_ORIG_O.pathmap("rank/nodestrength/%f")
RANK_NODESTRENGTH_ORIG_C = AFNI_NODESTRENGTH_ORIG_C.pathmap("rank/nodestrength/%f")
RANK_NODESTRENGTH_TLRC_C = AFNI_NODESTRENGTH_TLRC_C.pathmap("rank/nodestrength/%f")
RANK_NODESTRENGTH_TLRC_C_BLUR = TXT_NODESTRENGTH_ORIG_O.pathmap("rank/nodestrength/%n.b#{BLURFWHM}_C+tlrc.HEAD")
RANK_L2NORM_ORIG_O = AFNI_L2NORM_ORIG_O.pathmap("rank/l2norm/%f")
RANK_L2NORM_ORIG_C = AFNI_L2NORM_ORIG_C.pathmap("rank/l2norm/%f")
RANK_L2NORM_TLRC_C = AFNI_L2NORM_TLRC_C.pathmap("rank/l2norm/%f")
RANK_L2NORM_TLRC_C_BLUR = TXT_L2NORM_ORIG_O.pathmap("rank/l2norm/%n.b#{BLURFWHM}_C+tlrc.HEAD")
RANK_SELECTIONCOUNT_ORIG_O = AFNI_SELECTIONCOUNT_ORIG_O.pathmap("rank/selectioncount/%f")
RANK_SELECTIONCOUNT_ORIG_C = AFNI_SELECTIONCOUNT_ORIG_C.pathmap("rank/selectioncount/%f")
RANK_SELECTIONCOUNT_TLRC_C = AFNI_SELECTIONCOUNT_TLRC_C.pathmap("rank/selectioncount/%f")
RANK_SELECTIONCOUNT_TLRC_C_BLUR = TXT_SELECTIONCOUNT_ORIG_O.pathmap("rank/selectioncount/%n.b#{BLURFWHM}_C+tlrc.HEAD")
RANK_STABILITY_ORIG_O = AFNI_STABILITY_ORIG_O.pathmap("rank/stability/%f")
RANK_STABILITY_ORIG_C = AFNI_STABILITY_ORIG_C.pathmap("rank/stability/%f")
RANK_STABILITY_TLRC_C = AFNI_STABILITY_TLRC_C.pathmap("rank/stability/%f")
RANK_STABILITY_TLRC_C_BLUR = TXT_STABILITY_ORIG_O.pathmap("rank/stability/%n.b#{BLURFWHM}_C+tlrc.HEAD")

RANK_NODESTRENGTH_ORIG_O_CV = AFNI_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("rank/nodestrength/cv/%f")}
RANK_NODESTRENGTH_ORIG_C_CV = AFNI_NODESTRENGTH_ORIG_C_CV.map {|s| s.pathmap("rank/nodestrength/cv/%f")}
RANK_NODESTRENGTH_TLRC_C_CV = AFNI_NODESTRENGTH_TLRC_C_CV.map {|s| s.pathmap("rank/nodestrength/cv/%f")}
RANK_NODESTRENGTH_TLRC_C_BLUR_CV = TXT_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("rank/nodestrength/cv/%n.b#{BLURFWHM}_C+tlrc.HEAD")}
RANK_L2NORM_ORIG_O_CV = AFNI_L2NORM_ORIG_O_CV.map {|s| s.pathmap("rank/l2norm/cv/%f")}
RANK_L2NORM_ORIG_C_CV = AFNI_L2NORM_ORIG_C_CV.map {|s| s.pathmap("rank/l2norm/cv/%f")}
RANK_L2NORM_TLRC_C_CV = AFNI_L2NORM_TLRC_C_CV.map {|s| s.pathmap("rank/l2norm/cv/%f")}
RANK_L2NORM_TLRC_C_BLUR_CV = TXT_L2NORM_ORIG_O_CV.map {|s| s.pathmap("rank/l2norm/cv/%n.b#{BLURFWHM}_C+tlrc.HEAD")}
RANK_SELECTIONCOUNT_ORIG_O_CV = AFNI_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("rank/selectioncount/cv/%f")}
RANK_SELECTIONCOUNT_ORIG_C_CV = AFNI_SELECTIONCOUNT_ORIG_C_CV.map {|s| s.pathmap("rank/selectioncount/cv/%f")}
RANK_SELECTIONCOUNT_TLRC_C_CV = AFNI_SELECTIONCOUNT_TLRC_C_CV.map {|s| s.pathmap("rank/selectioncount/cv/%f")}
RANK_SELECTIONCOUNT_TLRC_C_BLUR_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("rank/selectioncount/cv/%n.b#{BLURFWHM}_C+tlrc.HEAD")}

RANKI_NODESTRENGTH_ORIG_O = AFNI_NODESTRENGTH_ORIG_O.pathmap("ranki/nodestrength/%f")
RANKI_NODESTRENGTH_ORIG_C = AFNI_NODESTRENGTH_ORIG_C.pathmap("ranki/nodestrength/%f")
RANKI_NODESTRENGTH_TLRC_C = AFNI_NODESTRENGTH_TLRC_C.pathmap("ranki/nodestrength/%f")
RANKI_NODESTRENGTH_TLRC_C_BLUR = TXT_NODESTRENGTH_ORIG_O.pathmap("ranki/nodestrength/%n.b#{BLURFWHM}_C+tlrc.HEAD")
RANKI_L2NORM_ORIG_O = AFNI_L2NORM_ORIG_O.pathmap("ranki/l2norm/%f")
RANKI_L2NORM_ORIG_C = AFNI_L2NORM_ORIG_C.pathmap("ranki/l2norm/%f")
RANKI_L2NORM_TLRC_C = AFNI_L2NORM_TLRC_C.pathmap("ranki/l2norm/%f")
RANKI_L2NORM_TLRC_C_BLUR = TXT_L2NORM_ORIG_O.pathmap("ranki/l2norm/%n.b#{BLURFWHM}_C+tlrc.HEAD")
RANKI_SELECTIONCOUNT_ORIG_O = AFNI_SELECTIONCOUNT_ORIG_O.pathmap("ranki/selectioncount/%f")
RANKI_SELECTIONCOUNT_ORIG_C = AFNI_SELECTIONCOUNT_ORIG_C.pathmap("ranki/selectioncount/%f")
RANKI_SELECTIONCOUNT_TLRC_C = AFNI_SELECTIONCOUNT_TLRC_C.pathmap("ranki/selectioncount/%f")
RANKI_SELECTIONCOUNT_TLRC_C_BLUR = TXT_SELECTIONCOUNT_ORIG_O.pathmap("ranki/selectioncount/%n.b#{BLURFWHM}_C+tlrc.HEAD")
RANKI_STABILITY_ORIG_O = AFNI_STABILITY_ORIG_O.pathmap("ranki/stability/%f")
RANKI_STABILITY_ORIG_C = AFNI_STABILITY_ORIG_C.pathmap("ranki/stability/%f")
RANKI_STABILITY_TLRC_C = AFNI_STABILITY_TLRC_C.pathmap("ranki/stability/%f")
RANKI_STABILITY_TLRC_C_BLUR = TXT_STABILITY_ORIG_O.pathmap("ranki/stability/%n.b#{BLURFWHM}_C+tlrc.HEAD")

RANKI_NODESTRENGTH_ORIG_O_CV = AFNI_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("ranki/nodestrength/cv/%f")}
RANKI_NODESTRENGTH_ORIG_C_CV = AFNI_NODESTRENGTH_ORIG_C_CV.map {|s| s.pathmap("ranki/nodestrength/cv/%f")}
RANKI_NODESTRENGTH_TLRC_C_CV = AFNI_NODESTRENGTH_TLRC_C_CV.map {|s| s.pathmap("ranki/nodestrength/cv/%f")}
RANKI_NODESTRENGTH_TLRC_C_BLUR_CV = TXT_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("ranki/nodestrength/cv/%n.b#{BLURFWHM}_C+tlrc.HEAD")}
RANKI_L2NORM_ORIG_O_CV = AFNI_L2NORM_ORIG_O_CV.map {|s| s.pathmap("ranki/l2norm/cv/%f")}
RANKI_L2NORM_ORIG_C_CV = AFNI_L2NORM_ORIG_C_CV.map {|s| s.pathmap("ranki/l2norm/cv/%f")}
RANKI_L2NORM_TLRC_C_CV = AFNI_L2NORM_TLRC_C_CV.map {|s| s.pathmap("ranki/l2norm/cv/%f")}
RANKI_L2NORM_TLRC_C_BLUR_CV = TXT_L2NORM_ORIG_O_CV.map {|s| s.pathmap("ranki/l2norm/cv/%n.b#{BLURFWHM}_C+tlrc.HEAD")}
RANKI_SELECTIONCOUNT_ORIG_O_CV = AFNI_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("ranki/selectioncount/cv/%f")}
RANKI_SELECTIONCOUNT_ORIG_C_CV = AFNI_SELECTIONCOUNT_ORIG_C_CV.map {|s| s.pathmap("ranki/selectioncount/cv/%f")}
RANKI_SELECTIONCOUNT_TLRC_C_CV = AFNI_SELECTIONCOUNT_TLRC_C_CV.map {|s| s.pathmap("ranki/selectioncount/cv/%f")}
RANKI_SELECTIONCOUNT_TLRC_C_BLUR_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("ranki/selectioncount/cv/%n.b#{BLURFWHM}_C+tlrc.HEAD")}

ZSCORE_NODESTRENGTH_ORIG_O = TXT_NODESTRENGTH_ORIG_O.pathmap("zscore/nodestrength/%n_O+orig.HEAD")
ZSCORE_NODESTRENGTH_ORIG_C = TXT_NODESTRENGTH_ORIG_O.pathmap("zscore/nodestrength/%n_C+orig.HEAD")
ZSCORE_NODESTRENGTH_TLRC_C = TXT_NODESTRENGTH_ORIG_O.pathmap("zscore/nodestrength/%n_C+tlrc.HEAD")
ZSCORE_NODESTRENGTH_TLRC_C_BLUR = TXT_NODESTRENGTH_ORIG_O.pathmap("zscore/nodestrength/%n.b#{BLURFWHM}_C+tlrc.HEAD")
ZSCORE_L2NORM_ORIG_O = TXT_L2NORM_ORIG_O.pathmap("zscore/l2norm/%n_O+orig.HEAD")
ZSCORE_L2NORM_ORIG_C = TXT_L2NORM_ORIG_O.pathmap("zscore/l2norm/%n_C+orig.HEAD")
ZSCORE_L2NORM_TLRC_C = TXT_L2NORM_ORIG_O.pathmap("zscore/l2norm/%n_C+tlrc.HEAD")
ZSCORE_L2NORM_TLRC_C_BLUR = TXT_L2NORM_ORIG_O.pathmap("zscore/l2norm/%n.b#{BLURFWHM}_C+tlrc.HEAD")
ZSCORE_SELECTIONCOUNT_ORIG_O = TXT_SELECTIONCOUNT_ORIG_O.pathmap("zscore/selectioncount/%n_O+orig.HEAD")
ZSCORE_SELECTIONCOUNT_ORIG_C = TXT_SELECTIONCOUNT_ORIG_O.pathmap("zscore/selectioncount/%n_C+orig.HEAD")
ZSCORE_SELECTIONCOUNT_TLRC_C = TXT_SELECTIONCOUNT_ORIG_O.pathmap("zscore/selectioncount/%n_C+tlrc.HEAD")
ZSCORE_SELECTIONCOUNT_TLRC_C_BLUR = TXT_SELECTIONCOUNT_ORIG_O.pathmap("zscore/selectioncount/%n.b#{BLURFWHM}_C+tlrc.HEAD")
ZSCORE_STABILITY_ORIG_O = TXT_STABILITY_ORIG_O.pathmap("zscore/stability/%n_O+orig.HEAD")
ZSCORE_STABILITY_ORIG_C = TXT_STABILITY_ORIG_O.pathmap("zscore/stability/%n_C+orig.HEAD")
ZSCORE_STABILITY_TLRC_C = TXT_STABILITY_ORIG_O.pathmap("zscore/stability/%n_C+tlrc.HEAD")
ZSCORE_STABILITY_TLRC_C_BLUR = TXT_STABILITY_ORIG_O.pathmap("zscore/stability/%n.b#{BLURFWHM}_C+tlrc.HEAD")

ZSCORE_NODESTRENGTH_ORIG_O_CV = TXT_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("zscore/nodestrength/cv/%n_O+orig.HEAD")}
ZSCORE_NODESTRENGTH_ORIG_C_CV = TXT_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("zscore/nodestrength/cv/%n_C+orig.HEAD")}
ZSCORE_NODESTRENGTH_TLRC_C_CV = TXT_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("zscore/nodestrength/cv/%n_C+tlrc.HEAD")}
ZSCORE_NODESTRENGTH_TLRC_C_BLUR_CV = TXT_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("zscore/nodestrength/cv/%n.b#{BLURFWHM}_C+tlrc.HEAD")}
ZSCORE_L2NORM_ORIG_O_CV = TXT_L2NORM_ORIG_O_CV.map {|s| s.pathmap("zscore/l2norm/cv/%n_O+orig.HEAD")}
ZSCORE_L2NORM_ORIG_C_CV = TXT_L2NORM_ORIG_O_CV.map {|s| s.pathmap("zscore/l2norm/cv/%n_C+orig.HEAD")}
ZSCORE_L2NORM_TLRC_C_CV = TXT_L2NORM_ORIG_O_CV.map {|s| s.pathmap("zscore/l2norm/cv/%n_C+tlrc.HEAD")}
ZSCORE_L2NORM_TLRC_C_BLUR_CV = TXT_L2NORM_ORIG_O_CV.map {|s| s.pathmap("zscore/l2norm/cv/%n.b#{BLURFWHM}_C+tlrc.HEAD")}
ZSCORE_SELECTIONCOUNT_ORIG_O_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("zscore/selectioncount/cv/%n_O+orig.HEAD")}
ZSCORE_SELECTIONCOUNT_ORIG_C_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("zscore/selectioncount/cv/%n_C+orig.HEAD")}
ZSCORE_SELECTIONCOUNT_TLRC_C_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("zscore/selectioncount/cv/%n_C+tlrc.HEAD")}
ZSCORE_SELECTIONCOUNT_TLRC_C_BLUR_CV = TXT_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("zscore/selectioncount/cv/%n.b#{BLURFWHM}_C+tlrc.HEAD")}

TTEST_NODESTRENGTH_TLRC_C = "ttest_nodestrength_C+tlrc.HEAD"
TTEST_NODESTRENGTH_TLRC_C_BLUR = "ttest_nodestrength.b#{BLURFWHM}_C+tlrc.HEAD"
TTEST_L2NORM_TLRC_C = "ttest_l2norm_C+tlrc.HEAD"
TTEST_L2NORM_TLRC_C_BLUR = "ttest_l2norm.b#{BLURFWHM}_C+tlrc.HEAD"
TTEST_SELECTIONCOUNT_TLRC_C = "ttest_selectioncount_C+tlrc.HEAD"
TTEST_SELECTIONCOUNT_TLRC_C_BLUR = "ttest_selectioncount.b#{BLURFWHM}_C+tlrc.HEAD"
TTEST_STABILITY_TLRC_C = "ttest_stability_C+tlrc.HEAD"
TTEST_STABILITY_TLRC_C_BLUR = "ttest_stability.b#{BLURFWHM}_C+tlrc.HEAD"

TTEST_NODESTRENGTH_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "ttest_nodestrength_#{i}_C+tlrc.HEAD"})
TTEST_NODESTRENGTH_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "ttest_nodestrength_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})
TTEST_L2NORM_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "ttest_l2norm_#{i}_C+tlrc.HEAD"})
TTEST_L2NORM_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "ttest_l2norm_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})
TTEST_SELECTIONCOUNT_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "ttest_selectioncount_#{i}_C+tlrc.HEAD"})
TTEST_SELECTIONCOUNT_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "ttest_selectioncount_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})

NONPARAMETRIC_NODESTRENGTH_TLRC_C = "nonparametric_nodestrength_C+tlrc.HEAD"
NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR = "nonparametric_nodestrength.b#{BLURFWHM}_C+tlrc.HEAD"
NONPARAMETRIC_L2NORM_TLRC_C = "nonparametric_l2norm_C+tlrc.HEAD"
NONPARAMETRIC_L2NORM_TLRC_C_BLUR = "nonparametric_l2norm.b#{BLURFWHM}_C+tlrc.HEAD"
NONPARAMETRIC_SELECTIONCOUNT_TLRC_C = "nonparametric_selectioncount_C+tlrc.HEAD"
NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR = "nonparametric_selectioncount.b#{BLURFWHM}_C+tlrc.HEAD"
NONPARAMETRIC_STABILITY_TLRC_C = "nonparametric_stability_C+tlrc.HEAD"
NONPARAMETRIC_STABILITY_TLRC_C_BLUR = "nonparametric_stability.b#{BLURFWHM}_C+tlrc.HEAD"

NONPARAMETRIC_NODESTRENGTH_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "nonparametric_nodestrength_#{i}_C+tlrc.HEAD"})
NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "nonparametric_nodestrength_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})
NONPARAMETRIC_L2NORM_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "nonparametric_l2norm_#{i}_C+tlrc.HEAD"})
NONPARAMETRIC_L2NORM_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "nonparametric_l2norm_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})
NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "nonparametric_selectioncount_#{i}_C+tlrc.HEAD"})
NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "nonparametric_selectioncount_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})

NONPARAMETRICI_NODESTRENGTH_TLRC_C = "nonparametrici_nodestrength_C+tlrc.HEAD"
NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR = "nonparametrici_nodestrength.b#{BLURFWHM}_C+tlrc.HEAD"
NONPARAMETRICI_L2NORM_TLRC_C = "nonparametrici_l2norm_C+tlrc.HEAD"
NONPARAMETRICI_L2NORM_TLRC_C_BLUR = "nonparametrici_l2norm.b#{BLURFWHM}_C+tlrc.HEAD"
NONPARAMETRICI_SELECTIONCOUNT_TLRC_C = "nonparametrici_selectioncount_C+tlrc.HEAD"
NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR = "nonparametrici_selectioncount.b#{BLURFWHM}_C+tlrc.HEAD"
NONPARAMETRICI_STABILITY_TLRC_C = "nonparametrici_stability_C+tlrc.HEAD"
NONPARAMETRICI_STABILITY_TLRC_C_BLUR = "nonparametrici_stability.b#{BLURFWHM}_C+tlrc.HEAD"

NONPARAMETRICI_NODESTRENGTH_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "nonparametrici_nodestrength_#{i}_C+tlrc.HEAD"})
NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "nonparametrici_nodestrength_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})
NONPARAMETRICI_L2NORM_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "nonparametrici_l2norm_#{i}_C+tlrc.HEAD"})
NONPARAMETRICI_L2NORM_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "nonparametrici_l2norm_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})
NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "nonparametrici_selectioncount_#{i}_C+tlrc.HEAD"})
NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "nonparametrici_selectioncount_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})

BINOMRANK_NODESTRENGTH_TLRC_C = "binomrank_nodestrength_C+tlrc.HEAD"
BINOMRANK_NODESTRENGTH_TLRC_C_BLUR = "binomrank_nodestrength.b#{BLURFWHM}_C+tlrc.HEAD"
BINOMRANK_L2NORM_TLRC_C = "binomrank_l2norm_C+tlrc.HEAD"
BINOMRANK_L2NORM_TLRC_C_BLUR = "binomrank_l2norm.b#{BLURFWHM}_C+tlrc.HEAD"
BINOMRANK_SELECTIONCOUNT_TLRC_C = "binomrank_selectioncount_C+tlrc.HEAD"
BINOMRANK_SELECTIONCOUNT_TLRC_C_BLUR = "binomrank_selectioncount.b#{BLURFWHM}_C+tlrc.HEAD"
BINOMRANK_STABILITY_TLRC_C = "binomrank_stability_C+tlrc.HEAD"
BINOMRANK_STABILITY_TLRC_C_BLUR = "binomrank_stability.b#{BLURFWHM}_C+tlrc.HEAD"

BINOMRANK_NODESTRENGTH_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "binomrank_nodestrength_#{i}_C+tlrc.HEAD"})
BINOMRANK_NODESTRENGTH_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "binomrank_nodestrength_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})
BINOMRANK_L2NORM_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "binomrank_l2norm_#{i}_C+tlrc.HEAD"})
BINOMRANK_L2NORM_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "binomrank_l2norm_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})
BINOMRANK_SELECTIONCOUNT_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "binomrank_selectioncount_#{i}_C+tlrc.HEAD"})
BINOMRANK_SELECTIONCOUNT_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "binomrank_selectioncount_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})

WILCOXON_NODESTRENGTH_TLRC_C = "wilcoxon_nodestrength_C+tlrc.HEAD"
WILCOXON_NODESTRENGTH_TLRC_C_BLUR = "wilcoxon_nodestrength.b#{BLURFWHM}_C+tlrc.HEAD"
WILCOXON_L2NORM_TLRC_C = "wilcoxon_l2norm_C+tlrc.HEAD"
WILCOXON_L2NORM_TLRC_C_BLUR = "wilcoxon_l2norm.b#{BLURFWHM}_C+tlrc.HEAD"
WILCOXON_SELECTIONCOUNT_TLRC_C = "wilcoxon_selectioncount_C+tlrc.HEAD"
WILCOXON_SELECTIONCOUNT_TLRC_C_BLUR = "wilcoxon_selectioncount.b#{BLURFWHM}_C+tlrc.HEAD"
WILCOXON_STABILITY_TLRC_C = "wilcoxon_stability_C+tlrc.HEAD"
WILCOXON_STABILITY_TLRC_C_BLUR = "wilcoxon_stability.b#{BLURFWHM}_C+tlrc.HEAD"

WILCOXON_NODESTRENGTH_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "wilcoxon_nodestrength_#{i}_C+tlrc.HEAD"})
WILCOXON_NODESTRENGTH_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "wilcoxon_nodestrength_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})
WILCOXON_L2NORM_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "wilcoxon_l2norm_#{i}_C+tlrc.HEAD"})
WILCOXON_L2NORM_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "wilcoxon_l2norm_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})
WILCOXON_SELECTIONCOUNT_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "wilcoxon_selectioncount_#{i}_C+tlrc.HEAD"})
WILCOXON_SELECTIONCOUNT_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "wilcoxon_selectioncount_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})

MEAN_NODESTRENGTH_TLRC_C = "mean_nodestrength_C+tlrc.HEAD"
MEAN_NODESTRENGTH_TLRC_C_BLUR = "mean_nodestrength.b#{BLURFWHM}_C+tlrc.HEAD"
MEAN_L2NORM_TLRC_C = "mean_l2norm_C+tlrc.HEAD"
MEAN_L2NORM_TLRC_C_BLUR = "mean_l2norm.b#{BLURFWHM}_C+tlrc.HEAD"
MEAN_SELECTIONCOUNT_TLRC_C = "mean_selectioncount_C+tlrc.HEAD"
MEAN_SELECTIONCOUNT_TLRC_C_BLUR = "mean_selectioncount.b#{BLURFWHM}_C+tlrc.HEAD"
MEAN_STABILITY_TLRC_C = "mean_stability_C+tlrc.HEAD"
MEAN_STABILITY_TLRC_C_BLUR = "mean_stability.b#{BLURFWHM}_C+tlrc.HEAD"

MEAN_NODESTRENGTH_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "mean_nodestrength_#{i}_C+tlrc.HEAD"})
MEAN_NODESTRENGTH_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "mean_nodestrength_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})
MEAN_L2NORM_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "mean_l2norm_#{i}_C+tlrc.HEAD"})
MEAN_L2NORM_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "mean_l2norm_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})
MEAN_SELECTIONCOUNT_TLRC_C_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "mean_selectioncount_#{i}_C+tlrc.HEAD"})
MEAN_SELECTIONCOUNT_TLRC_C_BLUR_CV = Rake::FileList.new(CROSSVALIDATION_INDEX.collect {|i| "mean_selectioncount_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"})

MEAN_RANK_NODESTRENGTH_TLRC_C = "mean_rank_nodestrength_C+tlrc.HEAD"
MEAN_RANK_NODESTRENGTH_TLRC_C_BLUR = "mean_rank_nodestrength.b#{BLURFWHM}_C+tlrc.HEAD"
MEAN_RANK_L2NORM_TLRC_C = "mean_rank_l2norm_C+tlrc.HEAD"
MEAN_RANK_L2NORM_TLRC_C_BLUR = "mean_rank_l2norm.b#{BLURFWHM}_C+tlrc.HEAD"
MEAN_RANK_SELECTIONCOUNT_TLRC_C = "mean_rank_selectioncount_C+tlrc.HEAD"
MEAN_RANK_SELECTIONCOUNT_TLRC_C_BLUR = "mean_rank_selectioncount.b#{BLURFWHM}_C+tlrc.HEAD"
MEAN_RANK_STABILITY_TLRC_C = "mean_rank_stability_C+tlrc.HEAD"
MEAN_RANK_STABILITY_TLRC_C_BLUR = "mean_rank_stability.b#{BLURFWHM}_C+tlrc.HEAD"

MEAN_RANK_NODESTRENGTH_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|i| "mean_rank_nodestrength_#{i}_C+tlrc.HEAD"}.collect {|x| Rake::FileList.new(x)}
MEAN_RANK_NODESTRENGTH_TLRC_C_BLUR_CV = CROSSVALIDATION_INDEX.collect {|i| "mean_rank_nodestrength_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"}.collect {|x| Rake::FileList.new(x)}
MEAN_RANK_L2NORM_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|i| "mean_rank_l2norm_#{i}_C+tlrc.HEAD"}.collect {|x| Rake::FileList.new(x)}
MEAN_RANK_L2NORM_TLRC_C_BLUR_CV = CROSSVALIDATION_INDEX.collect {|i| "mean_rank_l2norm_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"}.collect {|x| Rake::FileList.new(x)}
MEAN_RANK_SELECTIONCOUNT_TLRC_C_CV = CROSSVALIDATION_INDEX.collect {|i| "mean_rank_selectioncount_#{i}_C+tlrc.HEAD"}.collect {|x| Rake::FileList.new(x)}
MEAN_RANK_SELECTIONCOUNT_TLRC_C_BLUR_CV = CROSSVALIDATION_INDEX.collect {|i| "mean_rank_selectioncount_#{i}.b#{BLURFWHM}_C+tlrc.HEAD"}.collect {|x| Rake::FileList.new(x)}

PERMUTATIONS_NODESTRENGTH_ORIG_O = Rake::FileList["#{PERMDIR}/afni/nodestrength/???_??_O+orig.HEAD"]
PERMUTATIONS_NODESTRENGTH_TLRC_C = Rake::FileList["#{PERMDIR}/afni/nodestrength/???_??_C+tlrc.HEAD"]
PERMUTATIONS_L2NORM_ORIG_O = Rake::FileList["#{PERMDIR}/afni/l2norm/???_??_O+orig.HEAD"]
PERMUTATIONS_L2NORM_TLRC_C = Rake::FileList["#{PERMDIR}/afni/l2norm/???_??_C+tlrc.HEAD"]
PERMUTATIONS_SELECTIONCOUNT_ORIG_O = Rake::FileList["#{PERMDIR}/afni/selectioncount/???_??_O+orig.HEAD"]
PERMUTATIONS_SELECTIONCOUNT_TLRC_C = Rake::FileList["#{PERMDIR}/afni/selectioncount/???_??_C+tlrc.HEAD"]
PERMUTATIONS_STABILITY_ORIG_O = Rake::FileList["#{PERMDIR}/afni/stability/???_??_O+orig.HEAD"]
PERMUTATIONS_STABILITY_TLRC_C = Rake::FileList["#{PERMDIR}/afni/stability/???_??_C+tlrc.HEAD"]

PERMUTATIONS_NODESTRENGTH_ORIG_O_CV = CROSSVALIDATION_INDEX.collect{|c| PERMUTATION_INDEX.product(SUBJECT_INDEX).collect {|p,s| "#{PERMDIR}/afni/nodestrength/cv/#{p}_#{s}_#{c}_O+orig.HEAD"}}
PERMUTATIONS_NODESTRENGTH_TLRC_C_CV = CROSSVALIDATION_INDEX.collect{|c| PERMUTATION_INDEX.product(SUBJECT_INDEX).collect {|p,s| "#{PERMDIR}/afni/nodestrength/cv/#{p}_#{s}_#{c}_C+tlrc.HEAD"}}
PERMUTATIONS_L2NORM_ORIG_O_CV = CROSSVALIDATION_INDEX.collect{|c| PERMUTATION_INDEX.product(SUBJECT_INDEX).collect {|p,s| "#{PERMDIR}/afni/l2norm/cv/#{p}_#{s}_#{c}_O+orig.HEAD"}}
PERMUTATIONS_L2NORM_TLRC_C_CV = CROSSVALIDATION_INDEX.collect{|c| PERMUTATION_INDEX.product(SUBJECT_INDEX).collect {|p,s| "#{PERMDIR}/afni/l2norm/cv/#{p}_#{s}_#{c}_C+tlrc.HEAD"}}
PERMUTATIONS_SELECTIONCOUNT_ORIG_O_CV = CROSSVALIDATION_INDEX.collect{|c| PERMUTATION_INDEX.product(SUBJECT_INDEX).collect {|p,s| "#{PERMDIR}/afni/selectioncount/cv/#{p}_#{s}_#{c}_O+orig.HEAD"}}
PERMUTATIONS_SELECTIONCOUNT_TLRC_C_CV = CROSSVALIDATION_INDEX.collect{|c| PERMUTATION_INDEX.product(SUBJECT_INDEX).collect {|p,s| "#{PERMDIR}/afni/selectioncount/cv/#{p}_#{s}_#{c}_C+tlrc.HEAD"}}

PERMMEAN_NODESTRENGTH_ORIG_O = AFNI_NODESTRENGTH_ORIG_O.pathmap("#{PERMDIR}/mean/nodestrength/%f")
PERMMEAN_NODESTRENGTH_TLRC_C = AFNI_NODESTRENGTH_TLRC_C.pathmap("#{PERMDIR}/mean/nodestrength/%f")
PERMMEAN_L2NORM_ORIG_O = AFNI_L2NORM_ORIG_O.pathmap("#{PERMDIR}/mean/l2norm/%f")
PERMMEAN_L2NORM_TLRC_C = AFNI_L2NORM_TLRC_C.pathmap("#{PERMDIR}/mean/l2norm/%f")
PERMMEAN_SELECTIONCOUNT_ORIG_O = AFNI_SELECTIONCOUNT_ORIG_O.pathmap("#{PERMDIR}/mean/selectioncount/%f")
PERMMEAN_SELECTIONCOUNT_TLRC_C = AFNI_SELECTIONCOUNT_TLRC_C.pathmap("#{PERMDIR}/mean/selectioncount/%f")
PERMMEAN_STABILITY_ORIG_O = AFNI_STABILITY_ORIG_O.pathmap("#{PERMDIR}/mean/stability/%f")
PERMMEAN_STABILITY_TLRC_C = AFNI_STABILITY_TLRC_C.pathmap("#{PERMDIR}/mean/stability/%f")

PERMMEAN_NODESTRENGTH_ORIG_O_CV = AFNI_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("#{PERMDIR}/mean/nodestrength/cv/%f")}
PERMMEAN_NODESTRENGTH_TLRC_C_CV = AFNI_NODESTRENGTH_TLRC_C_CV.map {|s| s.pathmap("#{PERMDIR}/mean/nodestrength/cv/%f")}
PERMMEAN_L2NORM_ORIG_O_CV = AFNI_L2NORM_ORIG_O_CV.map {|s| s.pathmap("#{PERMDIR}/mean/l2norm/cv/%f")}
PERMMEAN_L2NORM_TLRC_C_CV = AFNI_L2NORM_TLRC_C_CV.map {|s| s.pathmap("#{PERMDIR}/mean/l2norm/cv/%f")}
PERMMEAN_SELECTIONCOUNT_ORIG_O_CV = AFNI_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("#{PERMDIR}/mean/selectioncount/cv/%f")}
PERMMEAN_SELECTIONCOUNT_TLRC_C_CV = AFNI_SELECTIONCOUNT_TLRC_C_CV.map {|s| s.pathmap("#{PERMDIR}/mean/selectioncount/cv/%f")}

PERMSD_NODESTRENGTH_ORIG_O = AFNI_NODESTRENGTH_ORIG_O.pathmap("#{PERMDIR}/sd/nodestrength/%f")
PERMSD_NODESTRENGTH_TLRC_C = AFNI_NODESTRENGTH_TLRC_C.pathmap("#{PERMDIR}/sd/nodestrength/%f")
PERMSD_L2NORM_ORIG_O = AFNI_L2NORM_ORIG_O.pathmap("#{PERMDIR}/sd/l2norm/%f")
PERMSD_L2NORM_TLRC_C = AFNI_L2NORM_TLRC_C.pathmap("#{PERMDIR}/sd/l2norm/%f")
PERMSD_SELECTIONCOUNT_ORIG_O = AFNI_SELECTIONCOUNT_ORIG_O.pathmap("#{PERMDIR}/sd/selectioncount/%f")
PERMSD_SELECTIONCOUNT_TLRC_C = AFNI_SELECTIONCOUNT_TLRC_C.pathmap("#{PERMDIR}/sd/selectioncount/%f")
PERMSD_STABILITY_ORIG_O = AFNI_STABILITY_ORIG_O.pathmap("#{PERMDIR}/sd/stability/%f")
PERMSD_STABILITY_TLRC_C = AFNI_STABILITY_TLRC_C.pathmap("#{PERMDIR}/sd/stability/%f")

PERMSD_NODESTRENGTH_ORIG_O_CV = AFNI_NODESTRENGTH_ORIG_O_CV.map {|s| s.pathmap("#{PERMDIR}/sd/nodestrength/cv/%f")}
PERMSD_NODESTRENGTH_TLRC_C_CV = AFNI_NODESTRENGTH_TLRC_C_CV.map {|s| s.pathmap("#{PERMDIR}/sd/nodestrength/cv/%f")}
PERMSD_L2NORM_ORIG_O_CV = AFNI_L2NORM_ORIG_O_CV.map {|s| s.pathmap("#{PERMDIR}/sd/l2norm/cv/%f")}
PERMSD_L2NORM_TLRC_C_CV = AFNI_L2NORM_TLRC_C_CV.map {|s| s.pathmap("#{PERMDIR}/sd/l2norm/cv/%f")}
PERMSD_SELECTIONCOUNT_ORIG_O_CV = AFNI_SELECTIONCOUNT_ORIG_O_CV.map {|s| s.pathmap("#{PERMDIR}/sd/selectioncount/cv/%f")}
PERMSD_SELECTIONCOUNT_TLRC_C_CV = AFNI_SELECTIONCOUNT_TLRC_C_CV.map {|s| s.pathmap("#{PERMDIR}/sd/selectioncount/cv/%f")}


# GROUP PERMUTATION FILES SUBJECT X PERMUTATION
# ---------------------------------------------------------------
PERMUTATIONS_NODESTRENGTH_ORIG_O_BY_SUBJ = SUBJECT_INDEX.collect {|s| PERMUTATIONS_NODESTRENGTH_ORIG_O.grep(/[0-9]+_#{s}/)}
PERMUTATIONS_NODESTRENGTH_TLRC_C_BY_SUBJ = SUBJECT_INDEX.collect {|s| PERMUTATIONS_NODESTRENGTH_TLRC_C.grep(/[0-9]+_#{s}/)}
PERMUTATIONS_L2NORM_ORIG_O_BY_SUBJ = SUBJECT_INDEX.collect {|s| PERMUTATIONS_L2NORM_ORIG_O.grep(/[0-9]+_#{s}/)}
PERMUTATIONS_L2NORM_TLRC_C_BY_SUBJ = SUBJECT_INDEX.collect {|s| PERMUTATIONS_L2NORM_TLRC_C.grep(/[0-9]+_#{s}/)}
PERMUTATIONS_SELECTIONCOUNT_ORIG_O_BY_SUBJ = SUBJECT_INDEX.collect {|s| PERMUTATIONS_SELECTIONCOUNT_ORIG_O.grep(/[0-9]+_#{s}/)}
PERMUTATIONS_SELECTIONCOUNT_TLRC_C_BY_SUBJ = SUBJECT_INDEX.collect {|s| PERMUTATIONS_SELECTIONCOUNT_TLRC_C.grep(/[0-9]+_#{s}/)}
PERMUTATIONS_STABILITY_ORIG_O_BY_SUBJ = SUBJECT_INDEX.collect {|s| PERMUTATIONS_STABILITY_ORIG_O.grep(/[0-9]+_#{s}/)}
PERMUTATIONS_STABILITY_TLRC_C_BY_SUBJ = SUBJECT_INDEX.collect {|s| PERMUTATIONS_STABILITY_TLRC_C.grep(/[0-9]+_#{s}/)}

# GROUP PERMUTATION FILES PERMUTATION X SUBJECT
# ---------------------------------------------------------------
PERMUTATIONS_NODESTRENGTH_ORIG_O_BY_PERM = PERMUTATION_INDEX.collect {|p| PERMUTATIONS_NODESTRENGTH_ORIG_O.grep(/#{p}_[0-9]+/)}
PERMUTATIONS_NODESTRENGTH_TLRC_C_BY_PERM = PERMUTATION_INDEX.collect {|p| PERMUTATIONS_NODESTRENGTH_TLRC_C.grep(/#{p}_[0-9]+/)}
PERMUTATIONS_L2NORM_ORIG_O_BY_PERM = PERMUTATION_INDEX.collect {|p| PERMUTATIONS_L2NORM_ORIG_O.grep(/#{p}_[0-9]+/)}
PERMUTATIONS_L2NORM_TLRC_C_BY_PERM = PERMUTATION_INDEX.collect {|p| PERMUTATIONS_L2NORM_TLRC_C.grep(/#{p}_[0-9]+/)}
PERMUTATIONS_SELECTIONCOUNT_ORIG_O_BY_PERM = PERMUTATION_INDEX.collect {|p| PERMUTATIONS_SELECTIONCOUNT_ORIG_O.grep(/#{p}_[0-9]+/)}
PERMUTATIONS_SELECTIONCOUNT_TLRC_C_BY_PERM = PERMUTATION_INDEX.collect {|p| PERMUTATIONS_SELECTIONCOUNT_TLRC_C.grep(/#{p}_[0-9]+/)}
PERMUTATIONS_STABILITY_ORIG_O_BY_PERM = PERMUTATION_INDEX.collect {|p| PERMUTATIONS_STABILITY_ORIG_O.grep(/#{p}_[0-9]+/)}
PERMUTATIONS_STABILITY_TLRC_C_BY_PERM = PERMUTATION_INDEX.collect {|p| PERMUTATIONS_STABILITY_TLRC_C.grep(/#{p}_[0-9]+/)}


# GROUP PERMUTATION FILES CROSSVALIDATION X SUBJECT X PERMUTATION
# ---------------------------------------------------------------
PERMUTATIONS_NODESTRENGTH_ORIG_O_CV_BY_SUBJ = PERMUTATIONS_NODESTRENGTH_ORIG_O_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_NODESTRENGTH_TLRC_C_CV_BY_SUBJ = PERMUTATIONS_NODESTRENGTH_TLRC_C_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_L2NORM_ORIG_O_CV_BY_SUBJ = PERMUTATIONS_L2NORM_ORIG_O_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_L2NORM_TLRC_C_CV_BY_SUBJ = PERMUTATIONS_L2NORM_TLRC_C_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_SELECTIONCOUNT_ORIG_O_CV_BY_SUBJ = PERMUTATIONS_SELECTIONCOUNT_ORIG_O_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}
PERMUTATIONS_SELECTIONCOUNT_TLRC_C_CV_BY_SUBJ = PERMUTATIONS_SELECTIONCOUNT_TLRC_C_CV.collect {|c| SUBJECT_INDEX.collect {|s| c.grep(/[0-9]+_#{s}_[0-9]+/)}}

# GROUP PERMUTATION FILES CROSSVALIDATION X PERMUTATION X SUBJECT
# ---------------------------------------------------------------
PERMUTATIONS_NODESTRENGTH_ORIG_O_CV_BY_PERM = PERMUTATIONS_NODESTRENGTH_ORIG_O_CV.collect {|c| PERMUTATION_INDEX.collect {|p|  c.grep(/#{p}_[0-9]+_[0-9]+/)}}
PERMUTATIONS_NODESTRENGTH_TLRC_C_CV_BY_PERM = PERMUTATIONS_NODESTRENGTH_TLRC_C_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
PERMUTATIONS_L2NORM_ORIG_O_CV_BY_PERM = PERMUTATIONS_L2NORM_ORIG_O_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
PERMUTATIONS_L2NORM_TLRC_C_CV_BY_PERM = PERMUTATIONS_L2NORM_TLRC_C_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
PERMUTATIONS_SELECTIONCOUNT_ORIG_O_CV_BY_PERM = PERMUTATIONS_SELECTIONCOUNT_ORIG_O_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}
PERMUTATIONS_SELECTIONCOUNT_TLRC_C_CV_BY_PERM = PERMUTATIONS_SELECTIONCOUNT_TLRC_C_CV.collect {|c| PERMUTATION_INDEX.collect {|p| c.grep(/#{p}_[0-9]+_[0-9]+/)}}

# FIGURES
# =======
# TTEST
# -----
PNG_TTEST_NODESTRENGTH_TLRC_C = [
  TTEST_NODESTRENGTH_TLRC_C.sub('+tlrc.HEAD','_p05.png'),
  TTEST_NODESTRENGTH_TLRC_C.sub('+tlrc.HEAD','_p01.png'),
  TTEST_NODESTRENGTH_TLRC_C.sub('+tlrc.HEAD','_p001.png')]
PNG_TTEST_L2NORM_TLRC_C = [
  TTEST_L2NORM_TLRC_C.sub('+tlrc.HEAD','_p05.png'),
  TTEST_L2NORM_TLRC_C.sub('+tlrc.HEAD','_p01.png'),
  TTEST_L2NORM_TLRC_C.sub('+tlrc.HEAD','_p001.png')]
PNG_TTEST_SELECTIONCOUNT_TLRC_C = [
  TTEST_SELECTIONCOUNT_TLRC_C.sub('+tlrc.HEAD','_p05.png'),
  TTEST_SELECTIONCOUNT_TLRC_C.sub('+tlrc.HEAD','_p01.png'),
  TTEST_SELECTIONCOUNT_TLRC_C.sub('+tlrc.HEAD','_p001.png')]
PNG_TTEST_STABILITY_TLRC_C = [
  TTEST_STABILITY_TLRC_C.sub('+tlrc.HEAD','_p05.png'),
  TTEST_STABILITY_TLRC_C.sub('+tlrc.HEAD','_p01.png'),
  TTEST_STABILITY_TLRC_C.sub('+tlrc.HEAD','_p001.png')]

PNG_TTEST_NODESTRENGTH_TLRC_C_BLUR = [
  TTEST_NODESTRENGTH_TLRC_C_BLUR.sub('+tlrc.HEAD','_p05.png'),
  TTEST_NODESTRENGTH_TLRC_C_BLUR.sub('+tlrc.HEAD','_p01.png'),
  TTEST_NODESTRENGTH_TLRC_C_BLUR.sub('+tlrc.HEAD','_p001.png')]
PNG_TTEST_L2NORM_TLRC_C_BLUR = [
  TTEST_L2NORM_TLRC_C_BLUR.sub('+tlrc.HEAD','_p05.png'),
  TTEST_L2NORM_TLRC_C_BLUR.sub('+tlrc.HEAD','_p01.png'),
  TTEST_L2NORM_TLRC_C_BLUR.sub('+tlrc.HEAD','_p001.png')]
PNG_TTEST_SELECTIONCOUNT_TLRC_C_BLUR = [
  TTEST_SELECTIONCOUNT_TLRC_C_BLUR.sub('+tlrc.HEAD','_p05.png'),
  TTEST_SELECTIONCOUNT_TLRC_C_BLUR.sub('+tlrc.HEAD','_p01.png'),
  TTEST_SELECTIONCOUNT_TLRC_C_BLUR.sub('+tlrc.HEAD','_p001.png')]
PNG_TTEST_STABILITY_TLRC_C_BLUR = [
  TTEST_STABILITY_TLRC_C_BLUR.sub('+tlrc.HEAD','_p05.png'),
  TTEST_STABILITY_TLRC_C_BLUR.sub('+tlrc.HEAD','_p01.png'),
  TTEST_STABILITY_TLRC_C_BLUR.sub('+tlrc.HEAD','_p001.png')]

PNG_TTEST_NODESTRENGTH_TLRC_C_CV = [
  TTEST_NODESTRENGTH_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  TTEST_NODESTRENGTH_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  TTEST_NODESTRENGTH_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]
PNG_TTEST_L2NORM_TLRC_C_CV = [
  TTEST_L2NORM_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  TTEST_L2NORM_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  TTEST_L2NORM_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]
PNG_TTEST_SELECTIONCOUNT_TLRC_C_CV = [
  TTEST_SELECTIONCOUNT_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  TTEST_SELECTIONCOUNT_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  TTEST_SELECTIONCOUNT_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]

PNG_TTEST_NODESTRENGTH_TLRC_C_BLUR_CV = [
  TTEST_NODESTRENGTH_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  TTEST_NODESTRENGTH_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  TTEST_NODESTRENGTH_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]
PNG_TTEST_L2NORM_TLRC_C_BLUR_CV = [
  TTEST_L2NORM_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  TTEST_L2NORM_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  TTEST_L2NORM_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]
PNG_TTEST_SELECTIONCOUNT_TLRC_C_BLUR_CV = [
  TTEST_SELECTIONCOUNT_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  TTEST_SELECTIONCOUNT_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  TTEST_SELECTIONCOUNT_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]

# NON PARAMETRIC
# --------------
PNG_NONPARAMETRICI_NODESTRENGTH_TLRC_C = [
  NONPARAMETRICI_NODESTRENGTH_TLRC_C.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRICI_NODESTRENGTH_TLRC_C.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRICI_NODESTRENGTH_TLRC_C.sub('+tlrc.HEAD','_p001.png')]
PNG_NONPARAMETRICI_L2NORM_TLRC_C = [
  NONPARAMETRICI_L2NORM_TLRC_C.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRICI_L2NORM_TLRC_C.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRICI_L2NORM_TLRC_C.sub('+tlrc.HEAD','_p001.png')]
PNG_NONPARAMETRICI_SELECTIONCOUNT_TLRC_C = [
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C.sub('+tlrc.HEAD','_p001.png')]
PNG_NONPARAMETRICI_STABILITY_TLRC_C = [
  NONPARAMETRICI_STABILITY_TLRC_C.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRICI_STABILITY_TLRC_C.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRICI_STABILITY_TLRC_C.sub('+tlrc.HEAD','_p001.png')]

PNG_NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR = [
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR.sub('+tlrc.HEAD','_p001.png')]
PNG_NONPARAMETRICI_L2NORM_TLRC_C_BLUR = [
  NONPARAMETRICI_L2NORM_TLRC_C_BLUR.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRICI_L2NORM_TLRC_C_BLUR.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRICI_L2NORM_TLRC_C_BLUR.sub('+tlrc.HEAD','_p001.png')]
PNG_NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR = [
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR.sub('+tlrc.HEAD','_p001.png')]
PNG_NONPARAMETRICI_STABILITY_TLRC_C_BLUR = [
  NONPARAMETRICI_STABILITY_TLRC_C_BLUR.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRICI_STABILITY_TLRC_C_BLUR.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRICI_STABILITY_TLRC_C_BLUR.sub('+tlrc.HEAD','_p001.png')]

PNG_NONPARAMETRICI_NODESTRENGTH_TLRC_C_CV = [
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]
PNG_NONPARAMETRICI_L2NORM_TLRC_C_CV = [
  NONPARAMETRICI_L2NORM_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  NONPARAMETRICI_L2NORM_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  NONPARAMETRICI_L2NORM_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]
PNG_NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_CV = [
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]

PNG_NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR_CV = [
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]
PNG_NONPARAMETRICI_L2NORM_TLRC_C_BLUR_CV = [
  NONPARAMETRICI_L2NORM_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  NONPARAMETRICI_L2NORM_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  NONPARAMETRICI_L2NORM_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]
PNG_NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR_CV = [
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]

PNG_NONPARAMETRIC_NODESTRENGTH_TLRC_C = [
  NONPARAMETRIC_NODESTRENGTH_TLRC_C.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRIC_NODESTRENGTH_TLRC_C.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRIC_NODESTRENGTH_TLRC_C.sub('+tlrc.HEAD','_p001.png')]
PNG_NONPARAMETRIC_L2NORM_TLRC_C = [
  NONPARAMETRIC_L2NORM_TLRC_C.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRIC_L2NORM_TLRC_C.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRIC_L2NORM_TLRC_C.sub('+tlrc.HEAD','_p001.png')]
PNG_NONPARAMETRIC_SELECTIONCOUNT_TLRC_C = [
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C.sub('+tlrc.HEAD','_p001.png')]
PNG_NONPARAMETRIC_STABILITY_TLRC_C = [
  NONPARAMETRIC_STABILITY_TLRC_C.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRIC_STABILITY_TLRC_C.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRIC_STABILITY_TLRC_C.sub('+tlrc.HEAD','_p001.png')]

PNG_NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR = [
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR.sub('+tlrc.HEAD','_p001.png')]
PNG_NONPARAMETRIC_L2NORM_TLRC_C_BLUR = [
  NONPARAMETRIC_L2NORM_TLRC_C_BLUR.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRIC_L2NORM_TLRC_C_BLUR.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRIC_L2NORM_TLRC_C_BLUR.sub('+tlrc.HEAD','_p001.png')]
PNG_NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR = [
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR.sub('+tlrc.HEAD','_p001.png')]
PNG_NONPARAMETRIC_STABILITY_TLRC_C_BLUR = [
  NONPARAMETRIC_STABILITY_TLRC_C_BLUR.sub('+tlrc.HEAD','_p05.png'),
  NONPARAMETRIC_STABILITY_TLRC_C_BLUR.sub('+tlrc.HEAD','_p01.png'),
  NONPARAMETRIC_STABILITY_TLRC_C_BLUR.sub('+tlrc.HEAD','_p001.png')]

PNG_NONPARAMETRIC_NODESTRENGTH_TLRC_C_CV = [
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]
PNG_NONPARAMETRIC_L2NORM_TLRC_C_CV = [
  NONPARAMETRIC_L2NORM_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  NONPARAMETRIC_L2NORM_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  NONPARAMETRIC_L2NORM_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]
PNG_NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_CV = [
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]

PNG_NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR_CV = [
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]
PNG_NONPARAMETRIC_L2NORM_TLRC_C_BLUR_CV = [
  NONPARAMETRIC_L2NORM_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  NONPARAMETRIC_L2NORM_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  NONPARAMETRIC_L2NORM_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]
PNG_NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR_CV = [
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p05.png')},
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p01.png')},
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR_CV.collect {|x| x.sub('+tlrc.HEAD','_p001.png')}]

# BINOMRANK
# ---------
pvals = %w(_p05.png _p01.png _p001.png _p0001.png _p00001.png)
PNG_BINOMRANK_NODESTRENGTH_TLRC_C = pvals.collect {|p|
  BINOMRANK_NODESTRENGTH_TLRC_C.sub('+tlrc.HEAD',p)
}
PNG_BINOMRANK_L2NORM_TLRC_C = pvals.collect {|p|
  BINOMRANK_L2NORM_TLRC_C.sub('+tlrc.HEAD',p)
}
PNG_BINOMRANK_SELECTIONCOUNT_TLRC_C = pvals.collect {|p|
  BINOMRANK_SELECTIONCOUNT_TLRC_C.sub('+tlrc.HEAD',p)
}
PNG_BINOMRANK_STABILITY_TLRC_C = pvals.collect {|p|
  BINOMRANK_STABILITY_TLRC_C.sub('+tlrc.HEAD',p)
}

PNG_BINOMRANK_NODESTRENGTH_TLRC_C_BLUR = pvals.collect {|p|
  BINOMRANK_NODESTRENGTH_TLRC_C_BLUR.sub('+tlrc.HEAD',p)
}
PNG_BINOMRANK_L2NORM_TLRC_C_BLUR = pvals.collect {|p|
  BINOMRANK_L2NORM_TLRC_C_BLUR.sub('+tlrc.HEAD',p)
}
PNG_BINOMRANK_SELECTIONCOUNT_TLRC_C_BLUR = pvals.collect {|p|
  BINOMRANK_SELECTIONCOUNT_TLRC_C_BLUR.sub('+tlrc.HEAD',p)
}
PNG_BINOMRANK_STABILITY_TLRC_C_BLUR = pvals.collect {|p|
  BINOMRANK_STABILITY_TLRC_C_BLUR.sub('+tlrc.HEAD',p)
}

PNG_BINOMRANK_NODESTRENGTH_TLRC_C_CV =
  BINOMRANK_NODESTRENGTH_TLRC_C_CV.collect {|x|
    pvals.collect {|p| x.sub('+tlrc.HEAD',p)}
  }
PNG_BINOMRANK_L2NORM_TLRC_C_CV =
  BINOMRANK_L2NORM_TLRC_C_CV.collect {|x|
    pvals.collect {|p| x.sub('+tlrc.HEAD',p)}
  }
PNG_BINOMRANK_SELECTIONCOUNT_TLRC_C_CV =
  BINOMRANK_SELECTIONCOUNT_TLRC_C_CV.collect {|x|
    pvals.collect {|p| x.sub('+tlrc.HEAD',p)}
  }

PNG_BINOMRANK_NODESTRENGTH_TLRC_C_BLUR_CV =
  BINOMRANK_NODESTRENGTH_TLRC_C_BLUR_CV.collect {|x|
    pvals.collect {|p| x.sub('+tlrc.HEAD',p)}
  }
PNG_BINOMRANK_L2NORM_TLRC_C_BLUR_CV =
  BINOMRANK_L2NORM_TLRC_C_BLUR_CV.collect {|x|
    pvals.collect {|p| x.sub('+tlrc.HEAD',p)}
  }
PNG_BINOMRANK_SELECTIONCOUNT_TLRC_C_BLUR_CV =
  BINOMRANK_SELECTIONCOUNT_TLRC_C_BLUR_CV.collect {|x|
    pvals.collect {|p| x.sub('+tlrc.HEAD',p)}
  }

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
png_ttest_lol = [
  PNG_TTEST_NODESTRENGTH_TLRC_C,
  PNG_TTEST_NODESTRENGTH_TLRC_C_BLUR,
  PNG_TTEST_L2NORM_TLRC_C,
  PNG_TTEST_L2NORM_TLRC_C_BLUR,
  PNG_TTEST_SELECTIONCOUNT_TLRC_C,
  PNG_TTEST_SELECTIONCOUNT_TLRC_C_BLUR,
  PNG_TTEST_STABILITY_TLRC_C,
  PNG_TTEST_STABILITY_TLRC_C_BLUR
]
ttest_all_for_plotting = [
  TTEST_NODESTRENGTH_TLRC_C,
  TTEST_NODESTRENGTH_TLRC_C_BLUR,
  TTEST_L2NORM_TLRC_C,
  TTEST_L2NORM_TLRC_C_BLUR,
  TTEST_SELECTIONCOUNT_TLRC_C,
  TTEST_SELECTIONCOUNT_TLRC_C_BLUR,
  TTEST_STABILITY_TLRC_C,
  TTEST_STABILITY_TLRC_C_BLUR
]
png_ttest_lol.zip(ttest_all_for_plotting).each do |png_list, source|
  png_list.each do |target|
    file target => source do
      png_ttest(target, source)
    end
    CLOBBER.push(target)
  end
end

png_nonparametric_lol = [
  PNG_NONPARAMETRICI_NODESTRENGTH_TLRC_C,
  PNG_NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR,
  PNG_NONPARAMETRICI_L2NORM_TLRC_C,
  PNG_NONPARAMETRICI_L2NORM_TLRC_C_BLUR,
  PNG_NONPARAMETRICI_SELECTIONCOUNT_TLRC_C,
  PNG_NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR,
  PNG_NONPARAMETRICI_STABILITY_TLRC_C,
  PNG_NONPARAMETRICI_STABILITY_TLRC_C_BLUR,
  PNG_NONPARAMETRIC_NODESTRENGTH_TLRC_C,
  PNG_NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR,
  PNG_NONPARAMETRIC_L2NORM_TLRC_C,
  PNG_NONPARAMETRIC_L2NORM_TLRC_C_BLUR,
  PNG_NONPARAMETRIC_SELECTIONCOUNT_TLRC_C,
  PNG_NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR,
  PNG_NONPARAMETRIC_STABILITY_TLRC_C,
  PNG_NONPARAMETRIC_STABILITY_TLRC_C_BLUR
]
nonparametric_all_for_plotting = [
  NONPARAMETRICI_NODESTRENGTH_TLRC_C,
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR,
  NONPARAMETRICI_L2NORM_TLRC_C,
  NONPARAMETRICI_L2NORM_TLRC_C_BLUR,
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C,
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR,
  NONPARAMETRICI_STABILITY_TLRC_C,
  NONPARAMETRICI_STABILITY_TLRC_C_BLUR,
  NONPARAMETRIC_NODESTRENGTH_TLRC_C,
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR,
  NONPARAMETRIC_L2NORM_TLRC_C,
  NONPARAMETRIC_L2NORM_TLRC_C_BLUR,
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C,
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR,
  NONPARAMETRIC_STABILITY_TLRC_C,
  NONPARAMETRIC_STABILITY_TLRC_C_BLUR
]
png_nonparametric_lol.zip(nonparametric_all_for_plotting).each do |png_list, source|
  png_list.each do |target|
    file target => source do
      png_nonparametric(target, source)
    end
    CLOBBER.push(target)
  end
end

# This also needs to be rethought
png_nonparametric_lol_cv = [
  PNG_NONPARAMETRIC_NODESTRENGTH_TLRC_C_CV,
  PNG_NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR_CV,
  PNG_NONPARAMETRIC_L2NORM_TLRC_C_CV,
  PNG_NONPARAMETRIC_L2NORM_TLRC_C_BLUR_CV,
]
nonparametric_all_for_plotting_cv = [
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_CV,
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR_CV,
  NONPARAMETRIC_L2NORM_TLRC_C_CV,
  NONPARAMETRIC_L2NORM_TLRC_C_BLUR_CV,
]
png_nonparametric_lol_cv.zip(nonparametric_all_for_plotting_cv).each do |png_list, source|
  png_list.each do |target|
    file target => source do
      png_nonparametric(target, source)
    end
    CLOBBER.push(target)
  end
end

png_binomrank_lol = [
  PNG_BINOMRANK_NODESTRENGTH_TLRC_C,
  PNG_BINOMRANK_NODESTRENGTH_TLRC_C_BLUR,
  PNG_BINOMRANK_L2NORM_TLRC_C,
  PNG_BINOMRANK_L2NORM_TLRC_C_BLUR,
  PNG_BINOMRANK_SELECTIONCOUNT_TLRC_C,
  PNG_BINOMRANK_SELECTIONCOUNT_TLRC_C_BLUR,
  PNG_BINOMRANK_STABILITY_TLRC_C,
  PNG_BINOMRANK_STABILITY_TLRC_C_BLUR
]
binomrank_all_for_plotting = [
  BINOMRANK_NODESTRENGTH_TLRC_C,
  BINOMRANK_NODESTRENGTH_TLRC_C_BLUR,
  BINOMRANK_L2NORM_TLRC_C,
  BINOMRANK_L2NORM_TLRC_C_BLUR,
  BINOMRANK_SELECTIONCOUNT_TLRC_C,
  BINOMRANK_SELECTIONCOUNT_TLRC_C_BLUR,
  BINOMRANK_STABILITY_TLRC_C,
  BINOMRANK_STABILITY_TLRC_C_BLUR
]
png_binomrank_lol.zip(binomrank_all_for_plotting).each do |png_list, source|
  png_list.each do |target|
    file target => source do
      png_binomrank(target, source)
    end
    CLOBBER.push(target)
  end
end

png_binomrank_lolol_cv = [
  PNG_BINOMRANK_NODESTRENGTH_TLRC_C_CV,
  PNG_BINOMRANK_NODESTRENGTH_TLRC_C_BLUR_CV,
  PNG_BINOMRANK_L2NORM_TLRC_C_CV,
  PNG_BINOMRANK_L2NORM_TLRC_C_BLUR_CV,
  PNG_BINOMRANK_SELECTIONCOUNT_TLRC_C_CV,
  PNG_BINOMRANK_SELECTIONCOUNT_TLRC_C_BLUR_CV
]
binomrank_all_for_plotting_lol_cv = [
  BINOMRANK_NODESTRENGTH_TLRC_C_CV,
  BINOMRANK_NODESTRENGTH_TLRC_C_BLUR_CV,
  BINOMRANK_L2NORM_TLRC_C_CV,
  BINOMRANK_L2NORM_TLRC_C_BLUR_CV,
  BINOMRANK_SELECTIONCOUNT_TLRC_C_CV,
  BINOMRANK_SELECTIONCOUNT_TLRC_C_BLUR_CV
]
png_binomrank_lolol_cv.zip(binomrank_all_for_plotting_lol_cv).each do |png_lol, source_list|
  png_lol.zip(source_list).each do |png_list, source|
    png_list.each do |target|
      file target => source do
        png_binomrank(target, source)
      end
      CLOBBER.push(target)
    end
  end
end

afni_orig_o_raw = [
  AFNI_NODESTRENGTH_ORIG_O_RAW +
  AFNI_L2NORM_ORIG_O_RAW +
  AFNI_SELECTIONCOUNT_ORIG_O +
  AFNI_STABILITY_ORIG_O
]
txt_orig_o = [
  TXT_NODESTRENGTH_ORIG_O +
  TXT_L2NORM_ORIG_O +
  TXT_SELECTIONCOUNT_ORIG_O +
  TXT_STABILITY_ORIG_O
]
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

afni_orig_o_raw = [
  AFNI_NODESTRENGTH_ORIG_O_RAW_CV,
  AFNI_L2NORM_ORIG_O_RAW_CV,
  AFNI_SELECTIONCOUNT_ORIG_O_CV
]
txt_orig_o = [
  TXT_NODESTRENGTH_ORIG_O_CV,
  TXT_L2NORM_ORIG_O_CV,
  TXT_SELECTIONCOUNT_ORIG_O_CV
]
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
  ZSCORE_NODESTRENGTH_ORIG_O +
  RANKI_NODESTRENGTH_ORIG_O +
  AFNI_L2NORM_ORIG_O +
  ZSCORE_L2NORM_ORIG_O +
  RANKI_L2NORM_ORIG_O +
  AFNI_SELECTIONCOUNT_ORIG_O +
  ZSCORE_SELECTIONCOUNT_ORIG_O +
  RANKI_SELECTIONCOUNT_ORIG_O +
  AFNI_STABILITY_ORIG_O +
  ZSCORE_STABILITY_ORIG_O +
  RANKI_STABILITY_ORIG_O +
  AFNI_NODESTRENGTH_ORIG_O_CV.flatten +
  ZSCORE_NODESTRENGTH_ORIG_O_CV.flatten +
  RANKI_NODESTRENGTH_ORIG_O_CV.flatten +
  AFNI_L2NORM_ORIG_O_CV.flatten +
  ZSCORE_L2NORM_ORIG_O_CV.flatten +
  RANKI_L2NORM_ORIG_O_CV.flatten +
  AFNI_SELECTIONCOUNT_ORIG_O_CV.flatten +
  ZSCORE_SELECTIONCOUNT_ORIG_O_CV.flatten +
  RANKI_SELECTIONCOUNT_ORIG_O_CV.flatten
afni_orig_c_all =
  AFNI_NODESTRENGTH_ORIG_C +
  ZSCORE_NODESTRENGTH_ORIG_C +
  RANKI_NODESTRENGTH_ORIG_C +
  AFNI_L2NORM_ORIG_C +
  ZSCORE_L2NORM_ORIG_C +
  RANKI_L2NORM_ORIG_C +
  AFNI_SELECTIONCOUNT_ORIG_C +
  ZSCORE_SELECTIONCOUNT_ORIG_C +
  RANKI_SELECTIONCOUNT_ORIG_C +
  AFNI_STABILITY_ORIG_C +
  ZSCORE_STABILITY_ORIG_C +
  RANKI_STABILITY_ORIG_C +
  AFNI_NODESTRENGTH_ORIG_C_CV.flatten +
  ZSCORE_NODESTRENGTH_ORIG_C_CV.flatten +
  RANKI_NODESTRENGTH_ORIG_C_CV.flatten +
  AFNI_L2NORM_ORIG_C_CV.flatten +
  ZSCORE_L2NORM_ORIG_C_CV.flatten +
  RANKI_L2NORM_ORIG_C_CV.flatten +
  AFNI_SELECTIONCOUNT_ORIG_C_CV.flatten +
  ZSCORE_SELECTIONCOUNT_ORIG_C_CV.flatten +
  RANKI_SELECTIONCOUNT_ORIG_C_CV.flatten
afni_orig_c_all.zip(afni_orig_o_all).each do |target,source|
  file target => source do
    afni_deoblique(target, source)
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub('+orig.HEAD','+orig.BRIK'))
  CLOBBER.push(target.sub('+orig.HEAD','+orig.BRIK.gz'))
end

afni_orig_c_lol = [
  AFNI_NODESTRENGTH_ORIG_C,
  RANKI_NODESTRENGTH_ORIG_C,
  ZSCORE_NODESTRENGTH_ORIG_C,
  AFNI_L2NORM_ORIG_C,
  RANKI_L2NORM_ORIG_C,
  ZSCORE_L2NORM_ORIG_C,
  AFNI_SELECTIONCOUNT_ORIG_C,
  RANKI_SELECTIONCOUNT_ORIG_C,
  ZSCORE_SELECTIONCOUNT_ORIG_C,
  AFNI_STABILITY_ORIG_C,
  RANKI_STABILITY_ORIG_C,
  ZSCORE_STABILITY_ORIG_C
]
afni_tlrc_c_lol = [
  AFNI_NODESTRENGTH_TLRC_C,
  RANKI_NODESTRENGTH_TLRC_C,
  ZSCORE_NODESTRENGTH_TLRC_C,
  AFNI_L2NORM_TLRC_C,
  RANKI_L2NORM_TLRC_C,
  ZSCORE_L2NORM_TLRC_C,
  AFNI_SELECTIONCOUNT_TLRC_C,
  RANKI_SELECTIONCOUNT_TLRC_C,
  ZSCORE_SELECTIONCOUNT_TLRC_C,
  AFNI_STABILITY_TLRC_C,
  RANKI_STABILITY_TLRC_C,
  ZSCORE_STABILITY_TLRC_C
]
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

afni_orig_c_lolol = [
  AFNI_NODESTRENGTH_ORIG_C_CV,
  ZSCORE_NODESTRENGTH_ORIG_C_CV,
  RANKI_NODESTRENGTH_ORIG_C_CV,
  AFNI_L2NORM_ORIG_C_CV,
  ZSCORE_L2NORM_ORIG_C_CV,
  RANKI_L2NORM_ORIG_C_CV,
  AFNI_SELECTIONCOUNT_ORIG_C_CV,
  ZSCORE_SELECTIONCOUNT_ORIG_C_CV,
  RANKI_SELECTIONCOUNT_ORIG_C_CV
]
afni_tlrc_c_lolol = [
  AFNI_NODESTRENGTH_TLRC_C_CV,
  ZSCORE_NODESTRENGTH_TLRC_C_CV,
  RANKI_NODESTRENGTH_TLRC_C_CV,
  AFNI_L2NORM_TLRC_C_CV,
  ZSCORE_L2NORM_TLRC_C_CV,
  RANKI_L2NORM_TLRC_C_CV,
  AFNI_SELECTIONCOUNT_TLRC_C_CV,
  ZSCORE_SELECTIONCOUNT_TLRC_C_CV,
  RANKI_SELECTIONCOUNT_TLRC_C_CV
]
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

afni_lol = [
  AFNI_NODESTRENGTH_TLRC_C,
  AFNI_L2NORM_TLRC_C,
  AFNI_SELECTIONCOUNT_TLRC_C,
  AFNI_STABILITY_TLRC_C
]
avg_all = [
  MEAN_NODESTRENGTH_TLRC_C,
  MEAN_L2NORM_TLRC_C,
  MEAN_SELECTIONCOUNT_TLRC_C,
  MEAN_STABILITY_TLRC_C
]
avg_all.zip(afni_lol).each do |target,afni_list|
  file target => afni_list do
    afni_mean(target, afni_list)
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub('.HEAD','.BRIK'))
  CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
end

afni_lolol_cv = [
  AFNI_NODESTRENGTH_TLRC_C_CV,
  AFNI_L2NORM_TLRC_C_CV,
  AFNI_SELECTIONCOUNT_TLRC_C_CV
]
avg_lol_cv = [
  MEAN_NODESTRENGTH_TLRC_C_CV,
  MEAN_L2NORM_TLRC_C_CV,
  MEAN_SELECTIONCOUNT_TLRC_C_CV,
]
avg_lol_cv.zip(afni_lolol_cv).each do |target_list,source_lol|
  target_list.zip(source_lol).each do |target,source_list|
    file target => source_list do
      afni_mean(target, source_list)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub('.HEAD','.BRIK'))
    CLOBBER.push(target.sub('.HEAD','.BRIK.gz'))
  end
end

afni_lol = [
  AFNI_NODESTRENGTH_TLRC_C,
  AFNI_L2NORM_TLRC_C,
  AFNI_SELECTIONCOUNT_TLRC_C,
  AFNI_STABILITY_TLRC_C
]
avg_all_blur = [
  MEAN_NODESTRENGTH_TLRC_C_BLUR,
  MEAN_L2NORM_TLRC_C_BLUR,
  MEAN_SELECTIONCOUNT_TLRC_C_BLUR,
  MEAN_STABILITY_TLRC_C_BLUR
]
avg_all_blur.zip(afni_lol).each do |target,afni_list|
  file target => afni_list do
    afni_mean(target, afni_list, BLURFWHM)
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub(".HEAD",".BRIK"))
  CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
end

afni_lolol_cv = [
  AFNI_NODESTRENGTH_TLRC_C_CV,
  AFNI_L2NORM_TLRC_C_CV,
  AFNI_SELECTIONCOUNT_TLRC_C_CV,
]
avg_all_blur_cv_lol = [
  MEAN_NODESTRENGTH_TLRC_C_BLUR_CV,
  MEAN_L2NORM_TLRC_C_BLUR_CV,
  MEAN_SELECTIONCOUNT_TLRC_C_BLUR_CV,
]
avg_all_blur_cv_lol.zip(afni_lolol_cv).each do |target_list,source_lol|
  target_list.zip(source_lol).each do |target,source_list|
    file target => source_list do
      afni_mean(target, source_list, BLURFWHM)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

rank_lol = [
  RANKI_NODESTRENGTH_ORIG_O,
  RANKI_L2NORM_ORIG_O,
  RANKI_SELECTIONCOUNT_ORIG_O,
  RANKI_STABILITY_ORIG_O
]
a_lol = [
  AFNI_NODESTRENGTH_ORIG_O,
  AFNI_L2NORM_ORIG_O,
  AFNI_SELECTIONCOUNT_ORIG_O,
  AFNI_STABILITY_ORIG_O
]
p_lolol = [
  PERMUTATIONS_NODESTRENGTH_ORIG_O_BY_SUBJ,
  PERMUTATIONS_L2NORM_ORIG_O_BY_SUBJ,
  PERMUTATIONS_SELECTIONCOUNT_ORIG_O_BY_SUBJ,
  PERMUTATIONS_STABILITY_ORIG_O_BY_SUBJ
]
rank_lol.zip(a_lol, p_lolol).each do |target_list,source_list,perm_lol| # loop over metric
  target_list.zip(source_list,perm_lol,MASK_ORIG_O).each do |target,source,perm_list,mask| # loop over subject
    file target => source do
      nonparametric_rank_against_permutation_distribution(target, source, perm_list, mask)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

rank_lolol = [
  RANKI_NODESTRENGTH_ORIG_O_CV,
  RANKI_L2NORM_ORIG_O_CV,
  RANKI_SELECTIONCOUNT_ORIG_O_CV
]
a_lolol = [
  AFNI_NODESTRENGTH_ORIG_O_CV,
  AFNI_L2NORM_ORIG_O_CV,
  AFNI_SELECTIONCOUNT_ORIG_O_CV
]
p_lololol = [
  PERMUTATIONS_NODESTRENGTH_ORIG_O_CV_BY_SUBJ,
  PERMUTATIONS_L2NORM_ORIG_O_CV_BY_SUBJ,
  PERMUTATIONS_SELECTIONCOUNT_ORIG_O_CV_BY_SUBJ
]
rank_lolol.zip(a_lolol, p_lololol).each do |target_lol,source_lol,perm_lolol| # loop over metric
  target_lol.zip(source_lol, perm_lolol).each do |target_list,source_list,perm_lol| # loop over metric
    target_list.zip(source_list,perm_lol,MASK_ORIG_O).each do |target,source,perm_list,mask| # loop over subject
      file target => source do
        nonparametric_rank_against_permutation_distribution(target, source, perm_list, mask)
      end
      CLOBBER.push(target)
      CLOBBER.push(target.sub(".HEAD",".BRIK"))
      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
    end
  end
end


rank_lol = [
  RANK_NODESTRENGTH_TLRC_C,
  RANK_L2NORM_TLRC_C,
  RANK_SELECTIONCOUNT_TLRC_C,
  RANK_STABILITY_TLRC_C
]
a_lol = [
  AFNI_NODESTRENGTH_TLRC_C,
  AFNI_L2NORM_TLRC_C,
  AFNI_SELECTIONCOUNT_TLRC_C,
  AFNI_STABILITY_TLRC_C
]
p_lolol = [
  PERMUTATIONS_NODESTRENGTH_TLRC_C_BY_SUBJ,
  PERMUTATIONS_L2NORM_TLRC_C_BY_SUBJ,
  PERMUTATIONS_SELECTIONCOUNT_TLRC_C_BY_SUBJ,
  PERMUTATIONS_STABILITY_TLRC_C_BY_SUBJ
]
rank_lol.zip(a_lol, p_lolol).each do |target_list,source_list,perm_lol| # loop over metric
  target_list.zip(source_list,perm_lol,MASK_TLRC_C).each do |target,source,perm_list,mask| # loop over subject
    file target => source do
      nonparametric_rank_against_permutation_distribution(target, source, perm_list, mask)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

rank_lol = [
  RANK_NODESTRENGTH_TLRC_C_BLUR,
  RANK_L2NORM_TLRC_C_BLUR,
  RANK_SELECTIONCOUNT_TLRC_C_BLUR,
  RANK_STABILITY_TLRC_C_BLUR
]
a_lol = [
  AFNI_NODESTRENGTH_TLRC_C,
  AFNI_L2NORM_TLRC_C,
  AFNI_SELECTIONCOUNT_TLRC_C,
  AFNI_STABILITY_TLRC_C
]
p_lolol = [
  PERMUTATIONS_NODESTRENGTH_TLRC_C_BY_SUBJ,
  PERMUTATIONS_L2NORM_TLRC_C_BY_SUBJ,
  PERMUTATIONS_SELECTIONCOUNT_TLRC_C_BY_SUBJ,
  PERMUTATIONS_STABILITY_TLRC_C_BY_SUBJ
]
rank_lol.zip(a_lol, p_lolol).each do |target_list,source_list,perm_lol| # loop over metric
  target_list.zip(source_list,perm_lol,MASK_TLRC_C).each do |target,source,perm_list,mask| # loop over subject
    file target => source do
      nonparametric_rank_against_permutation_distribution(target, source, perm_list, mask, BLURFWHM)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

rank_lolol = [
  RANK_NODESTRENGTH_TLRC_C_CV,
  RANK_L2NORM_TLRC_C_CV,
  RANK_SELECTIONCOUNT_TLRC_C_CV
]
a_lolol = [
  AFNI_NODESTRENGTH_TLRC_C_CV,
  AFNI_L2NORM_TLRC_C_CV,
  AFNI_SELECTIONCOUNT_TLRC_C_CV
]
p_lololol = [
  PERMUTATIONS_NODESTRENGTH_TLRC_C_CV_BY_SUBJ,
  PERMUTATIONS_L2NORM_TLRC_C_CV_BY_SUBJ,
  PERMUTATIONS_SELECTIONCOUNT_TLRC_C_CV_BY_SUBJ
]
rank_lolol.zip(a_lolol, p_lololol).each do |target_lol,source_lol,perm_lolol| # loop over metric
  target_lol.zip(source_lol, perm_lolol).each do |target_list,source_list,perm_lol| # loop over metric
    target_list.zip(source_list,perm_lol,MASK_TLRC_C).each do |target,source,perm_list,mask| # loop over subject
      file target => source do
        nonparametric_rank_against_permutation_distribution(target, source, perm_list, mask)
      end
      CLOBBER.push(target)
      CLOBBER.push(target.sub(".HEAD",".BRIK"))
      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
    end
  end
end

rank_lolol = [
  RANK_NODESTRENGTH_TLRC_C_BLUR_CV,
  RANK_L2NORM_TLRC_C_BLUR_CV,
  RANK_SELECTIONCOUNT_TLRC_C_BLUR_CV
]
a_lolol = [
  AFNI_NODESTRENGTH_TLRC_C_CV,
  AFNI_L2NORM_TLRC_C_CV,
  AFNI_SELECTIONCOUNT_TLRC_C_CV
]
p_lololol = [
  PERMUTATIONS_NODESTRENGTH_TLRC_C_CV_BY_SUBJ,
  PERMUTATIONS_L2NORM_TLRC_C_CV_BY_SUBJ,
  PERMUTATIONS_SELECTIONCOUNT_TLRC_C_CV_BY_SUBJ
]
rank_lolol.zip(a_lolol, p_lololol).each do |target_lol,source_lol,perm_lolol| # loop over metric
  target_lol.zip(source_lol, perm_lolol).each do |target_list,source_list,perm_lol| # loop over metric
    target_list.zip(source_list,perm_lol,MASK_TLRC_C).each do |target,source,perm_list,mask| # loop over subject
      file target => source do
        nonparametric_rank_against_permutation_distribution(target, source, perm_list, mask, BLURFWHM)
      end
      CLOBBER.push(target)
      CLOBBER.push(target.sub(".HEAD",".BRIK"))
      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
    end
  end
end

rank_lol = [
  RANKI_NODESTRENGTH_TLRC_C,
  RANKI_NODESTRENGTH_TLRC_C_BLUR,
  RANKI_L2NORM_TLRC_C,
  RANKI_L2NORM_TLRC_C_BLUR,
  RANKI_SELECTIONCOUNT_TLRC_C,
  RANKI_SELECTIONCOUNT_TLRC_C_BLUR,
  RANKI_STABILITY_TLRC_C,
  RANKI_STABILITY_TLRC_C_BLUR,
  RANK_NODESTRENGTH_TLRC_C,
  RANK_NODESTRENGTH_TLRC_C_BLUR,
  RANK_L2NORM_TLRC_C,
  RANK_L2NORM_TLRC_C_BLUR,
  RANK_SELECTIONCOUNT_TLRC_C,
  RANK_SELECTIONCOUNT_TLRC_C_BLUR,
  RANK_STABILITY_TLRC_C,
  RANK_STABILITY_TLRC_C_BLUR
]
nonparametric_all = [
  NONPARAMETRICI_NODESTRENGTH_TLRC_C,
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR,
  NONPARAMETRICI_L2NORM_TLRC_C,
  NONPARAMETRICI_L2NORM_TLRC_C_BLUR,
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C,
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR,
  NONPARAMETRICI_STABILITY_TLRC_C,
  NONPARAMETRICI_STABILITY_TLRC_C_BLUR,
  NONPARAMETRIC_NODESTRENGTH_TLRC_C,
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR,
  NONPARAMETRIC_L2NORM_TLRC_C,
  NONPARAMETRIC_L2NORM_TLRC_C_BLUR,
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C,
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR,
  NONPARAMETRIC_STABILITY_TLRC_C,
  NONPARAMETRIC_STABILITY_TLRC_C_BLUR
]
avg_all = [
  MEAN_NODESTRENGTH_TLRC_C,
  MEAN_NODESTRENGTH_TLRC_C_BLUR,
  MEAN_L2NORM_TLRC_C,
  MEAN_L2NORM_TLRC_C_BLUR,
  MEAN_SELECTIONCOUNT_TLRC_C,
  MEAN_SELECTIONCOUNT_TLRC_C_BLUR,
  MEAN_STABILITY_TLRC_C,
  MEAN_STABILITY_TLRC_C_BLUR,
  MEAN_NODESTRENGTH_TLRC_C,
  MEAN_NODESTRENGTH_TLRC_C_BLUR,
  MEAN_L2NORM_TLRC_C,
  MEAN_L2NORM_TLRC_C_BLUR,
  MEAN_SELECTIONCOUNT_TLRC_C,
  MEAN_SELECTIONCOUNT_TLRC_C_BLUR,
  MEAN_STABILITY_TLRC_C,
  MEAN_STABILITY_TLRC_C_BLUR
]
nonparametric_all.zip(rank_lol,avg_all).each do |target,rank_list,avg|
  file target => rank_list+[avg] do
    nonparametric_count_median_thresholded_ranks(target,rank_list,avg)
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub(".HEAD",".BRIK"))
  CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
end

perm_lololol = [
  PERMUTATIONS_NODESTRENGTH_TLRC_C_CV_BY_PERM,
  PERMUTATIONS_L2NORM_TLRC_C_CV_BY_PERM,
  PERMUTATIONS_SELECTIONCOUNT_TLRC_C_CV_BY_PERM
]
afni_lolol = [
  AFNI_NODESTRENGTH_TLRC_C_CV,
  AFNI_L2NORM_TLRC_C_CV,
  AFNI_SELECTIONCOUNT_TLRC_C_CV
]
binomrank_cv = [
  BINOMRANK_NODESTRENGTH_TLRC_C_CV,
  BINOMRANK_L2NORM_TLRC_C_CV,
  BINOMRANK_SELECTIONCOUNT_TLRC_C_CV
]
binomrank_cv.zip(afni_lolol,perm_lololol).each do |target_list,source_lol,perm_lolol|
  target_list.zip(source_lol,perm_lolol).each do |target,source_list,perm_lol|
    file target => source_list + perm_lol.flatten do
      binomrank_test(target, source_list, perm_lol, SHARED_ATLAS_TLRC)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

perm_lololol = [
  PERMUTATIONS_NODESTRENGTH_TLRC_C_CV_BY_PERM,
  PERMUTATIONS_L2NORM_TLRC_C_CV_BY_PERM,
  PERMUTATIONS_SELECTIONCOUNT_TLRC_C_CV_BY_PERM
]
afni_lolol = [
  AFNI_NODESTRENGTH_TLRC_C_CV,
  AFNI_L2NORM_TLRC_C_CV,
  AFNI_SELECTIONCOUNT_TLRC_C_CV
]
binomrank_cv = [
  BINOMRANK_NODESTRENGTH_TLRC_C_BLUR_CV,
  BINOMRANK_L2NORM_TLRC_C_BLUR_CV,
  BINOMRANK_SELECTIONCOUNT_TLRC_C_BLUR_CV
]
binomrank_cv.zip(afni_lolol,perm_lololol).each do |target_list,source_lol,perm_lolol|
  target_list.zip(source_lol,perm_lolol).each do |target,source_list,perm_lol|
    file target => source_list + perm_lol.flatten do
      binomrank_test(target, source_list, perm_lol, SHARED_ATLAS_TLRC, BLURFWHM)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

rank_lolol = [
  RANKI_NODESTRENGTH_TLRC_C_CV,
  RANKI_NODESTRENGTH_TLRC_C_BLUR_CV,
  RANKI_L2NORM_TLRC_C_CV,
  RANKI_L2NORM_TLRC_C_BLUR_CV,
  RANKI_SELECTIONCOUNT_TLRC_C_CV,
  RANKI_SELECTIONCOUNT_TLRC_C_BLUR_CV,
  RANK_NODESTRENGTH_TLRC_C_CV,
  RANK_NODESTRENGTH_TLRC_C_BLUR_CV,
  RANK_L2NORM_TLRC_C_CV,
  RANK_L2NORM_TLRC_C_BLUR_CV,
  RANK_SELECTIONCOUNT_TLRC_C_CV,
  RANK_SELECTIONCOUNT_TLRC_C_BLUR_CV
]
nonparametric_lol = [
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_CV,
  NONPARAMETRICI_NODESTRENGTH_TLRC_C_BLUR_CV,
  NONPARAMETRICI_L2NORM_TLRC_C_CV,
  NONPARAMETRICI_L2NORM_TLRC_C_BLUR_CV,
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_CV,
  NONPARAMETRICI_SELECTIONCOUNT_TLRC_C_BLUR_CV,
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_CV,
  NONPARAMETRIC_NODESTRENGTH_TLRC_C_BLUR_CV,
  NONPARAMETRIC_L2NORM_TLRC_C_CV,
  NONPARAMETRIC_L2NORM_TLRC_C_BLUR_CV,
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_CV,
  NONPARAMETRIC_SELECTIONCOUNT_TLRC_C_BLUR_CV
]
avg_lol = [
  MEAN_NODESTRENGTH_TLRC_C_CV,
  MEAN_NODESTRENGTH_TLRC_C_BLUR_CV,
  MEAN_L2NORM_TLRC_C_CV,
  MEAN_L2NORM_TLRC_C_BLUR_CV,
  MEAN_SELECTIONCOUNT_TLRC_C_CV,
  MEAN_SELECTIONCOUNT_TLRC_C_BLUR_CV,
  MEAN_NODESTRENGTH_TLRC_C_CV,
  MEAN_NODESTRENGTH_TLRC_C_BLUR_CV,
  MEAN_L2NORM_TLRC_C_CV,
  MEAN_L2NORM_TLRC_C_BLUR_CV,
  MEAN_SELECTIONCOUNT_TLRC_C_CV,
  MEAN_SELECTIONCOUNT_TLRC_C_BLUR_CV
]
nonparametric_lol.zip(rank_lolol,avg_lol).each do |target_list,source_lol,avg_list|
  target_list.zip(source_lol,avg_list).each do |target,rank_list,avg|
    file target => rank_list+[avg] do
      nonparametric_count_median_thresholded_ranks(target,rank_list,avg)
    end
    CLOBBER.push(target)
    CLOBBER.push(target.sub(".HEAD",".BRIK"))
    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
  end
end

afni_all =
  AFNI_NODESTRENGTH_ORIG_O +
  AFNI_L2NORM_ORIG_O +
  AFNI_SELECTIONCOUNT_ORIG_O +
  AFNI_STABILITY_ORIG_O
zscore_all =
  ZSCORE_NODESTRENGTH_ORIG_O +
  ZSCORE_L2NORM_ORIG_O +
  ZSCORE_SELECTIONCOUNT_ORIG_O +
  ZSCORE_STABILITY_ORIG_O
permmean_all =
  PERMMEAN_NODESTRENGTH_ORIG_O +
  PERMMEAN_L2NORM_ORIG_O +
  PERMMEAN_SELECTIONCOUNT_ORIG_O +
  PERMMEAN_STABILITY_ORIG_O
permsd_all =
  PERMSD_NODESTRENGTH_ORIG_O +
  PERMSD_L2NORM_ORIG_O +
  PERMSD_SELECTIONCOUNT_ORIG_O +
  PERMSD_STABILITY_ORIG_O
zscore_all.zip(afni_all,permmean_all,permsd_all) do |target,source,mean,sd|
  file target => [source,mean,sd] do
    parametric_zscore(target, source, mean, sd)
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub(".HEAD",".BRIK"))
  CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
end

zscore_all_tlrc =
  RANKI_NODESTRENGTH_TLRC_C +
  RANKI_L2NORM_TLRC_C +
  RANKI_SELECTIONCOUNT_TLRC_C +
  RANKI_STABILITY_TLRC_C +
  RANKI_NODESTRENGTH_TLRC_C_CV.flatten() +
  RANKI_L2NORM_TLRC_C_BLUR_CV.flatten() +
  RANKI_SELECTIONCOUNT_TLRC_C_CV.flatten() +
  ZSCORE_NODESTRENGTH_TLRC_C +
  ZSCORE_L2NORM_TLRC_C +
  ZSCORE_SELECTIONCOUNT_TLRC_C +
  ZSCORE_STABILITY_TLRC_C
zscore_all_blur =
  RANKI_NODESTRENGTH_TLRC_C_BLUR +
  RANKI_L2NORM_TLRC_C_BLUR +
  RANKI_SELECTIONCOUNT_TLRC_C_BLUR +
  RANKI_STABILITY_TLRC_C_BLUR +
  RANKI_NODESTRENGTH_TLRC_C_BLUR_CV.flatten() +
  RANKI_L2NORM_TLRC_C_BLUR_CV.flatten() +
  RANKI_SELECTIONCOUNT_TLRC_C_BLUR_CV.flatten() +
  ZSCORE_NODESTRENGTH_TLRC_C_BLUR +
  ZSCORE_L2NORM_TLRC_C_BLUR +
  ZSCORE_SELECTIONCOUNT_TLRC_C_BLUR +
  ZSCORE_STABILITY_TLRC_C_BLUR
zscore_all_blur.zip(zscore_all_tlrc).each do |target,source|
  file target => source do
    afni_blur(target, source, BLURFWHM)
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub(".HEAD",".BRIK"))
  CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
end

#namespace :nodestrength do
#  task :afni => AFNI_NODESTRENGTH
#  task :mean => [MEAN_NODESTRENGTH]
#  task :zscore => ZSCORE_NODESTRENGTH
#  task :rank => RANK_NODESTRENGTH
#  task :ttest => [TTEST_NODESTRENGTH,TTEST_NODESTRENGTH_BLUR]
#  task :nonparametric => NONPARAMETRIC_NODESTRENGTH
#  namespace :plot do
#    task :ttest => PNG_TTEST_NODESTRENGTH + PNG_TTEST_NODESTRENGTH_BLUR
#    task :nonparametric => PNG_NONPARAMETRIC_NODESTRENGTH + PNG_NONPARAMETRIC_NODESTRENGTH_BLUR
#  end
#  namespace :cv do
#    task :afni => AFNI_NODESTRENGTH_CV
#    task :zscore => ZSCORE_NODESTRENGTH_CV
#    task :ttest => TTEST_NODESTRENGTH_CV + TTEST_NODESTRENGTH_BLUR_CV
#    namespace :plot do
#      task :ttest => PNG_TTEST_NODESTRENGTH_CV.flatten + PNG_TTEST_NODESTRENGTH_BLUR_CV.flatten
#    end
#  end
#end
#
#namespace :l2norm do
#  task :afni => AFNI_L2NORM
#  task :mean => [MEAN_L2NORM]
#  task :zscore => ZSCORE_L2NORM
#  task :rank => RANK_L2NORM
#  task :ttest => [TTEST_L2NORM,TTEST_L2NORM_BLUR]
#  task :nonparametric => NONPARAMETRIC_L2NORM
#  namespace :plot do
#    task :ttest => PNG_TTEST_L2NORM + PNG_TTEST_L2NORM_BLUR
#    task :nonparametric => PNG_NONPARAMETRIC_L2NORM + PNG_NONPARAMETRIC_L2NORM_BLUR
#  end
#  namespace :cv do
#    task :afni => AFNI_L2NORM_CV
#    task :zscore => ZSCORE_L2NORM_CV
#    task :ttest => TTEST_L2NORM_CV + TTEST_L2NORM_BLUR_CV
#    namespace :plot do
#      task :ttest => PNG_TTEST_L2NORM_CV.flatten + PNG_TTEST_L2NORM_BLUR_CV.flatten
#    end
#  end
#end
#
#namespace :selectioncount do
#  task :afni => AFNI_SELECTIONCOUNT
#  task :mean => [MEAN_SELECTIONCOUNT]
#  task :zscore => ZSCORE_SELECTIONCOUNT
#  task :rank => RANK_SELECTIONCOUNT
#  task :ttest => [TTEST_SELECTIONCOUNT,TTEST_BLUR_SELECTIONCOUNT]
#  task :nonparametric => NONPARAMETRIC_SELECTIONCOUNT
#  namespace :plot do
#    task :ttest => PNG_TTEST_SELECTIONCOUNT + PNG_TTEST_BLUR_SELECTIONCOUNT
#    task :nonparametric => PNG_NONPARAMETRIC_SELECTIONCOUNT + PNG_NONPARAMETRIC_BLUR_SELECTIONCOUNT
#  end
#  namespace :cv do
#    task :afni => AFNI_SELECTIONCOUNT_CV
#    task :zscore => ZSCORE_SELECTIONCOUNT_CV
#    task :ttest => TTEST_SELECTIONCOUNT_CV + TTEST_BLUR_SELECTIONCOUNT_CV
#    namespace :plot do
#      task :ttest => PNG_TTEST_SELECTIONCOUNT_CV.flatten + PNG_TTEST_BLUR_SELECTIONCOUNT_CV.flatten
#    end
#  end
#end
#
#task :makedirs => dir_list
#namespace :stability do
#  task :afni => AFNI_STABILITY
#  task :mean => [MEAN_STABILITY]
#  task :zscore => ZSCORE_STABILITY
#  task :rank => RANK_STABILITY
#  task :ttest => [TTEST_STABILITY,TTEST_BLUR_STABILITY]
#  task :nonparametric => NONPARAMETRIC_STABILITY
#  namespace :plot do
#    task :ttest => PNG_TTEST_STABILITY + PNG_TTEST_BLUR_STABILITY
#    task :nonparametric => PNG_NONPARAMETRIC_STABILITY + PNG_NONPARAMETRIC_BLUR_STABILITY
#  end
##  namespace :cv do
##    task :afni => AFNI_STABILITY_CV
##    task :zscore => ZSCORE_STABILITY_CV
##    namespace :plot do
##    end
##  end
#end
#
#namespace :mask do
#  task :afni => AFNI_MASK
#  task :group => GROUP_MASK
#end

## metric x subject x crossvalidation
#rank_lolol = [
#  RANK_NODESTRENGTH_ORIG_O_CV,
#  RANK_L2NORM_ORIG_O_CV,
#  RANK_SELECTIONCOUNT_ORIG_O_CV,
#]
## metric x subject x crossvalidation
#a_lolol = [
#  AFNI_NODESTRENGTH_ORIG_O_CV,
#  AFNI_L2NORM_ORIG_O_CV,
#  AFNI_SELECTIONCOUNT_ORIG_O_CV,
#]
## metric x subject x crossvalidation x permutation
#p_lololol = [
#  PERMUTATIONS_NODESTRENGTH_ORIG_O_CV_BY_SUBJ,
#  PERMUTATIONS_L2NORM_ORIG_O_CV_BY_SUBJ,
#  PERMUTATIONS_SELECTIONCOUNT_ORIG_O_CV_BY_SUBJ,
#]
#rank_lolol.zip(a_lolol, p_lololol).each do |target_lol,source_lol,perm_lolol| # loop over metric
#  if target_lol.map {|x| x.empty?}.all? then
#    next
#  end
#  target_lol.zip(source_lol,perm_lolol).each do |target_list,source_list,perm_lol| # loop over subject
#    target_list.zip(source_list,perm_lol,MASK_ORIG_O).each do |target,source,perm_list,mask| # loop over crossvalidation
#      file target => source do
#        nonparametric_rank_against_permutation_distribution(target, source, perm_list, mask)
#      end
#      CLOBBER.push(target)
#      CLOBBER.push(target.sub(".HEAD",".BRIK"))
#      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
#    end
#  end
#end

# rank_all_tlrc =
#   RANK_NODESTRENGTH_TLRC_C +
#   RANK_SELECTIONCOUNT_TLRC_C +
#   RANK_STABILITY_TLRC_C
# rank_all_blur =
#   RANK_NODESTRENGTH_TLRC_C_BLUR +
#   RANK_SELECTIONCOUNT_TLRC_C_BLUR +
#   RANK_STABILITY_TLRC_C_BLUR
# rank_all_blur.zip(rank_all_tlrc).each do |target,source|
#   file target => source do
#     afni_blur(target, source)
#   end
#   CLOBBER.push(target)
#   CLOBBER.push(target.sub(".HEAD",".BRIK"))
#   CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
# end

#rank_blur_lol = [
#  RANK_NODESTRENGTH_ORIG_O_BLUR,
#  RANK_L2NORM_ORIG_O_BLUR,
#  RANK_SELECTIONCOUNT_ORIG_O_BLUR,
#  RANK_STABILITY_ORIG_O_BLUR
#]
#a_lol = [
#  AFNI_NODESTRENGTH_ORIG_O,
#  AFNI_L2NORM_ORIG_O,
#  AFNI_SELECTIONCOUNT_ORIG_O,
#  AFNI_STABILITY_ORIG_O
#]
#p_lolol = [
#  PERMUTATIONS_NODESTRENGTH_ORIG_O_BY_SUBJ,
#  PERMUTATIONS_L2NORM_ORIG_O_BY_SUBJ,
#  PERMUTATIONS_SELECTIONCOUNT_ORIG_O_BY_SUBJ,
#  PERMUTATIONS_STABILITY_ORIG_O_BY_SUBJ
#]
#rank_blur_lol.zip(a_lol, p_lolol).each do |target_list,source_list,perm_lol| # loop over metric
#  target_list.zip(source_list,perm_lol,MASK_ORIG_O).each do |target,source,perm_list,mask| # loop over subject
#    file target => source do
#      nonparametric_rank_against_permutation_distribution(target, source, perm_list, mask)
#    end
#    CLOBBER.push(target)
#    CLOBBER.push(target.sub(".HEAD",".BRIK"))
#    CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
#  end
#end

## metric x subject x crossvalidation
#rank_blur_lolol = [
#  RANK_NODESTRENGTH_ORIG_O_BLUR_CV,
#  RANK_L2NORM_ORIG_O_BLUR_CV,
#  RANK_SELECTIONCOUNT_ORIG_O_BLUR_CV,
#]
## metric x subject x crossvalidation
#a_lolol = [
#  AFNI_NODESTRENGTH_ORIG_O_CV,
#  AFNI_L2NORM_ORIG_O_CV,
#  AFNI_SELECTIONCOUNT_ORIG_O_CV,
#]
## metric x subject x crossvalidation x permutation
#p_lololol = [
#  PERMUTATIONS_NODESTRENGTH_ORIG_O_CV_BY_SUBJ,
#  PERMUTATIONS_L2NORM_ORIG_O_CV_BY_SUBJ,
#  PERMUTATIONS_SELECTIONCOUNT_ORIG_O_CV_BY_SUBJ,
#]
#rank_blur_lolol.zip(a_lolol, p_lololol).each do |target_lol,source_lol,perm_lolol| # loop over metric
#  target_lol.zip(source_lol,perm_lolol).each do |target_list,source_list,perm_lol| # loop over subject
#    target_list.zip(source_list,perm_lol,MASK_ORIG_O).each do |target,source,perm_list,mask| # loop over crossvalidation
#      file target => source do
#        nonparametric_rank_against_permutation_distribution(target, source, perm_list, mask)
#      end
#      CLOBBER.push(target)
#      CLOBBER.push(target.sub(".HEAD",".BRIK"))
#      CLOBBER.push(target.sub(".HEAD",".BRIK.gz"))
#    end
#  end
#end
