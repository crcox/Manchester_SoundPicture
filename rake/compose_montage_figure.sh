#!/bin/bash
dirname=$1
prefix=$2
imcat \
  -prefix ${prefix} \
  -nx 3 -ny 2 \
  ${dirname}/${prefix}.left.*.ppm \
  ${dirname}/${prefix}.back.*.ppm \
  ${dirname}/${prefix}.right.*.ppm \
  ${dirname}/${prefix}.left_medial.*.ppm \
  ${dirname}/${prefix}.bottom.*.ppm \
  ${dirname}/${prefix}.right_medial.*.ppm
