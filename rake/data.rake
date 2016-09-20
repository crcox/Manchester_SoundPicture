require 'rake'
require 'rake/clean'

SOURCE_ANAT = [
  './s02_rightyes/T1/MD106_050913_T1W_IR_1150_SENSE_3_1.hdr',
  './s03_leftyes/T1/MD106_050913B_T1W_IR_1150_SENSE_3_1.hdr',
  './s04_rightyes/T1/MRH026_201_T1W_IR_1150_SENSE_3_1.hdr',
  './s05_leftyes/T1/MRH026_202_T1W_IR_1150_SENSE_3_1.hdr',
  './s06_rightyes/T1/MRH026_203_T1W_IR_1150_SENSE_3_1.hdr',
  './s07_leftyes/T1/MRH026_204_T1W_IR_1150_SENSE_3_1.hdr',
  './s08_rightyes/T1/MRH026_205_T1W_IR_1150_SENSE_3_1.hdr',
  './s09_leftyes/T1/MRH026_206_T1W_IR_1150_SENSE_3_1.hdr',
  './s10_rightyes/T1/MRH026_207_T1W_IR_1150_SENSE_3_1.hdr',
  './s11_leftyes/T1/MRH026_208_T1W_IR_1150_SENSE_3_1.hdr',
  './s12_rightyes/T1/MRH026_209_T1W_IR_1150_SENSE_3_1.hdr',
  './s13_leftyes/T1/MRH026_210_T1W_IR_1150_SENSE_3_1.hdr',
  './s14_rightyes/T1/MRH026_211_T1W_IR_1150_SENSE_3_1.hdr',
  './s15_leftyes/T1/MRH026_212_T1W_IR_1150_SENSE_3_1.hdr',
  './s16_rightyes/T1/MRH026_213_T1W_IR_1150_SENSE_3_1.hdr',
  './s17_leftyes/T1/MRH026_214_T1W_IR_1150_SENSE_3_1.hdr',
  './s18_rightyes/T1/MRH026_215_T1W_IR_1150_SENSE_3_1.hdr',
  './s19_leftyes/T1/MRH026_216_T1W_IR_1150_SENSE_3_1.hdr',
  './s20_rightyes/T1/MRH026_217_T1W_IR_1150_SENSE_3_1.hdr',
  './s21_leftyes/T1/MRH026_218_T1W_IR_1150_SENSE_3_1.hdr',
  './s22_rightyes/T1/MRH026_219_T1W_IR_1150_SENSE_3_1.hdr',
  './s23_leftyes/T1/MRH026_220_T1W_IR_1150_SENSE_3_1.hdr',
  './s24_rightyes/T1/MRH026_221_T1W_IR_1150_SENSE_3_1.hdr'
]

SOURCE_MASK = [
  './s02_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s03_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s04_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s05_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s06_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s07_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s08_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s09_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s10_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s11_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s12_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s13_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s14_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s15_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s16_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s17_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s18_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s19_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s20_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s21_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s22_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s23_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s24_rightyes/mask/nS_c1_mask_nocerebellum.hdr'
]

AFNI_MASK_O_BADHEADER = [
  './s02_rightyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s03_leftyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s04_rightyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s05_leftyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s06_rightyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s07_leftyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s08_rightyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s09_leftyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s10_rightyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s11_leftyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s12_rightyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s13_leftyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s14_rightyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s15_leftyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s16_rightyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s17_leftyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s18_rightyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s19_leftyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s20_rightyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s21_leftyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s22_rightyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s23_leftyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD',
  './s24_rightyes/mask/nS_c1_mask_nocerebellum+tlrc.HEAD'
]

AFNI_MASK_O = [
  './s02_rightyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s03_leftyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s04_rightyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s05_leftyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s06_rightyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s07_leftyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s08_rightyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s09_leftyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s10_rightyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s11_leftyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s12_rightyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s13_leftyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s14_rightyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s15_leftyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s16_rightyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s17_leftyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s18_rightyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s19_leftyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s20_rightyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s21_leftyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s22_rightyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s23_leftyes/mask/nS_c1_mask_nocerebellum+orig.HEAD',
  './s24_rightyes/mask/nS_c1_mask_nocerebellum+orig.HEAD'
]

AFNI_ORIG_O_BADHEADER = [
  './s02_rightyes/T1/MD106_050913_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s03_leftyes/T1/MD106_050913B_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s04_rightyes/T1/MRH026_201_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s05_leftyes/T1/MRH026_202_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s06_rightyes/T1/MRH026_203_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s07_leftyes/T1/MRH026_204_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s08_rightyes/T1/MRH026_205_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s09_leftyes/T1/MRH026_206_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s10_rightyes/T1/MRH026_207_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s11_leftyes/T1/MRH026_208_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s12_rightyes/T1/MRH026_209_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s13_leftyes/T1/MRH026_210_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s14_rightyes/T1/MRH026_211_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s15_leftyes/T1/MRH026_212_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s16_rightyes/T1/MRH026_213_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s17_leftyes/T1/MRH026_214_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s18_rightyes/T1/MRH026_215_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s19_leftyes/T1/MRH026_216_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s20_rightyes/T1/MRH026_217_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s21_leftyes/T1/MRH026_218_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s22_rightyes/T1/MRH026_219_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s23_leftyes/T1/MRH026_220_T1W_IR_1150_SENSE_3_1+tlrc.HEAD',
  './s24_rightyes/T1/MRH026_221_T1W_IR_1150_SENSE_3_1+tlrc.HEAD'
]

AFNI_ORIG_O = [
  './s02_rightyes/T1/MD106_050913_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s03_leftyes/T1/MD106_050913B_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s04_rightyes/T1/MRH026_201_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s05_leftyes/T1/MRH026_202_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s06_rightyes/T1/MRH026_203_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s07_leftyes/T1/MRH026_204_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s08_rightyes/T1/MRH026_205_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s09_leftyes/T1/MRH026_206_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s10_rightyes/T1/MRH026_207_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s11_leftyes/T1/MRH026_208_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s12_rightyes/T1/MRH026_209_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s13_leftyes/T1/MRH026_210_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s14_rightyes/T1/MRH026_211_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s15_leftyes/T1/MRH026_212_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s16_rightyes/T1/MRH026_213_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s17_leftyes/T1/MRH026_214_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s18_rightyes/T1/MRH026_215_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s19_leftyes/T1/MRH026_216_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s20_rightyes/T1/MRH026_217_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s21_leftyes/T1/MRH026_218_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s22_rightyes/T1/MRH026_219_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s23_leftyes/T1/MRH026_220_T1W_IR_1150_SENSE_3_1+orig.HEAD',
  './s24_rightyes/T1/MRH026_221_T1W_IR_1150_SENSE_3_1+orig.HEAD'
]

AFNI_ORIG_C = [
  './s02_rightyes/T1/MD106_050913_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s03_leftyes/T1/MD106_050913B_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s04_rightyes/T1/MRH026_201_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s05_leftyes/T1/MRH026_202_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s06_rightyes/T1/MRH026_203_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s07_leftyes/T1/MRH026_204_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s08_rightyes/T1/MRH026_205_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s09_leftyes/T1/MRH026_206_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s10_rightyes/T1/MRH026_207_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s11_leftyes/T1/MRH026_208_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s12_rightyes/T1/MRH026_209_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s13_leftyes/T1/MRH026_210_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s14_rightyes/T1/MRH026_211_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s15_leftyes/T1/MRH026_212_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s16_rightyes/T1/MRH026_213_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s17_leftyes/T1/MRH026_214_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s18_rightyes/T1/MRH026_215_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s19_leftyes/T1/MRH026_216_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s20_rightyes/T1/MRH026_217_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s21_leftyes/T1/MRH026_218_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s22_rightyes/T1/MRH026_219_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s23_leftyes/T1/MRH026_220_T1W_IR_1150_SENSE_3_1_C+orig.HEAD',
  './s24_rightyes/T1/MRH026_221_T1W_IR_1150_SENSE_3_1_C+orig.HEAD'
]

AFNI_TLRC_C = [
  './s02_rightyes/T1/MD106_050913_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s03_leftyes/T1/MD106_050913B_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s04_rightyes/T1/MRH026_201_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s05_leftyes/T1/MRH026_202_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s06_rightyes/T1/MRH026_203_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s07_leftyes/T1/MRH026_204_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s08_rightyes/T1/MRH026_205_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s09_leftyes/T1/MRH026_206_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s10_rightyes/T1/MRH026_207_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s11_leftyes/T1/MRH026_208_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s12_rightyes/T1/MRH026_209_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s13_leftyes/T1/MRH026_210_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s14_rightyes/T1/MRH026_211_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s15_leftyes/T1/MRH026_212_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s16_rightyes/T1/MRH026_213_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s17_leftyes/T1/MRH026_214_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s18_rightyes/T1/MRH026_215_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s19_leftyes/T1/MRH026_216_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s20_rightyes/T1/MRH026_217_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s21_leftyes/T1/MRH026_218_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s22_rightyes/T1/MRH026_219_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s23_leftyes/T1/MRH026_220_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD',
  './s24_rightyes/T1/MRH026_221_T1W_IR_1150_SENSE_3_1_C+tlrc.HEAD'
]

MASK_OBLIQUE = [
  './s02_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s03_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s04_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s05_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s06_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s07_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s08_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s09_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s10_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s11_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s12_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s13_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s14_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s15_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s16_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s17_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s18_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s19_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s20_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s21_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s22_rightyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s23_leftyes/mask/nS_c1_mask_nocerebellum.hdr',
  './s24_rightyes/mask/nS_c1_mask_nocerebellum.hdr'
]
MASK_OBLIQUE_DUMP = [
  './s02_rightyes/mask/nS_c1_mask_nocerebellum.rai',
  './s03_leftyes/mask/nS_c1_mask_nocerebellum.rai',
  './s04_rightyes/mask/nS_c1_mask_nocerebellum.rai',
  './s05_leftyes/mask/nS_c1_mask_nocerebellum.rai',
  './s06_rightyes/mask/nS_c1_mask_nocerebellum.rai',
  './s07_leftyes/mask/nS_c1_mask_nocerebellum.rai',
  './s08_rightyes/mask/nS_c1_mask_nocerebellum.rai',
  './s09_leftyes/mask/nS_c1_mask_nocerebellum.rai',
  './s10_rightyes/mask/nS_c1_mask_nocerebellum.rai',
  './s11_leftyes/mask/nS_c1_mask_nocerebellum.rai',
  './s12_rightyes/mask/nS_c1_mask_nocerebellum.rai',
  './s13_leftyes/mask/nS_c1_mask_nocerebellum.rai',
  './s14_rightyes/mask/nS_c1_mask_nocerebellum.rai',
  './s15_leftyes/mask/nS_c1_mask_nocerebellum.rai',
  './s16_rightyes/mask/nS_c1_mask_nocerebellum.rai',
  './s17_leftyes/mask/nS_c1_mask_nocerebellum.rai',
  './s18_rightyes/mask/nS_c1_mask_nocerebellum.rai',
  './s19_leftyes/mask/nS_c1_mask_nocerebellum.rai',
  './s20_rightyes/mask/nS_c1_mask_nocerebellum.rai',
  './s21_leftyes/mask/nS_c1_mask_nocerebellum.rai',
  './s22_rightyes/mask/nS_c1_mask_nocerebellum.rai',
  './s23_leftyes/mask/nS_c1_mask_nocerebellum.rai',
  './s24_rightyes/mask/nS_c1_mask_nocerebellum.rai'
]

MASK_OBLIQUE_DUMP_RPI = [
  './s02_rightyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s03_leftyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s04_rightyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s05_leftyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s06_rightyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s07_leftyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s08_rightyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s09_leftyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s10_rightyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s11_leftyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s12_rightyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s13_leftyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s14_rightyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s15_leftyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s16_rightyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s17_leftyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s18_rightyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s19_leftyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s20_rightyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s21_leftyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s22_rightyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s23_leftyes/mask/nS_c1_mask_nocerebellum.rpi',
  './s24_rightyes/mask/nS_c1_mask_nocerebellum.rpi'
]
AFNI_ORIG_O_BADHEADER.zip(SOURCE_ANAT).each do |target,source|
  file target => source do
    target_prefix = target.sub('+orig.HEAD','')
    sh("3dcopy #{source} #{target_prefix}")
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub('+tlrc.HEAD','+tlrc.BRIK'))
  CLOBBER.push(target.sub('+tlrc.HEAD','+tlrc.BRIK.gz'))
end

AFNI_ORIG_O.zip(AFNI_ORIG_O_BADHEADER).each do |target,source|
  file target => source do
    sh("3drefit -view 'orig' -space 'ORIG' #{source}")
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub('+orig.HEAD','+orig.BRIK'))
  CLOBBER.push(target.sub('+orig.HEAD','+orig.BRIK.gz'))
end

AFNI_ORIG_C.zip(AFNI_ORIG_O).each do |target,source|
  file target => source do
    target_prefix = target.sub('+orig.HEAD','')
    sh("3dWarp -deoblique -prefix #{target_prefix} #{source}")
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub('+orig.HEAD','+orig.BRIK'))
  CLOBBER.push(target.sub('+orig.HEAD','+orig.BRIK.gz'))
end

AFNI_TLRC_C.zip(AFNI_ORIG_C).each do |target,source|
  file target => source do
   dir, base = File.split(source)
    Dir.chdir(dir) do
      sh("@auto_tlrc -base TT_N27+tlrc -input #{base}")
    end
  end
  CLOBBER.push(target)
  CLOBBER.push(target.sub('+tlrc.HEAD','+tlrc.BRIK'))
  CLOBBER.push(target.sub('+tlrc.HEAD','+tlrc.BRIK.gz'))
  CLOBBER.push(target.sub('+tlrc.HEAD','_ns+orig.HEAD'))
  CLOBBER.push(target.sub('+tlrc.HEAD','_ns+orig.BRIK'))
  CLOBBER.push(target.sub('+tlrc.HEAD','_ns+orig.BRIK.gz'))
  CLOBBER.push(target.sub('+tlrc.HEAD','_ns.Xaff12.1D'))
  CLOBBER.push(target.sub('+tlrc.HEAD','_ns_WarpDrive.1D'))
  CLOBBER.push(target.sub('+tlrc.HEAD','Xat.1D'))
end

MASK_OBLIQUE_DUMP.zip(MASK_OBLIQUE).each do |target,source|
  file target => source do
    sh("3dmaskdump -mask #{source} -index -xyz -o #{target} #{source}")
  end
end

MASK_OBLIQUE_DUMP_RPI.zip(MASK_OBLIQUE_DUMP).each do |target,source|
  file target => source do
    sh("awk '{ if( $6 ~ /^-/ ){sub(/-/, \"\", $6); print $0;} else { $6=\"-\"$6; print $0}}' #{source} > #{target}")
  end
end

AFNI_MASK_O_BADHEADER.zip(SOURCE_MASK).each do |target,source|
  file target => source do
    target_prefix = target.sub('+orig.HEAD','')
    sh("3dcopy #{source} #{target_prefix}")
  end
  CLEAN.push(target)
  CLEAN.push(target.sub('+tlrc.HEAD','+tlrc.BRIK'))
  CLEAN.push(target.sub('+tlrc.HEAD','+tlrc.BRIK.gz'))
end

AFNI_MASK_O.zip(AFNI_MASK_O_BADHEADER).each do |target,source|
  file target => source do
    sh("3drefit -view 'orig' -space 'ORIG' #{source}")
  end
  CLEAN.push(target)
  CLEAN.push(target.sub('+orig.HEAD','+orig.BRIK'))
  CLEAN.push(target.sub('+orig.HEAD','+orig.BRIK.gz'))
end

task :anat2tlrc => AFNI_TLRC_C
task :dumpobliquemask => MASK_OBLIQUE_DUMP_RPI
task :spmmask2afni=> AFNI_MASK_O
