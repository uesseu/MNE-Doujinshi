files = files/introduction.md \
  files/review.md \
  files/experiment.md \
  files/photosensor.md \
  files/install-hardware.md \
  files/install-os.md \
  files/install-jupyter.md \
  files/install-cuda.md \
  files/install-git.md \
  files/install-maxfilter.md \
  files/install-freesurfer.md \
  files/install-mne.md \
  files/freesurfer.md \
  files/install-mricron.md \
  files/before-mne.md \
  files/install-jupyter-omajinai.md \
  files/mne-readdata.md \
  files/mne-preprocessing.md \
  files/mne-plot.md \
  files/mne-wavelet.md \
  files/mne-shukei.md \
  files/mne-connectivity.md \
  files/mne-source.md \
  files/math-wavelet.md \
  files/math-hilbert.md \
  files/math-connectivity.md \
  files/math-mne.md \
  files/math-inverse.md \
  files/speedup-python.md \
  files/graph.md \
  files/books.md \
  files/python-tips.md \
  files/pitfall.md \
  files/atogaki.md

outfile = out.pdf
twoside = twoside.pdf
outhtml = out.html

latex_twoside = -V documentclass=ltjarticle \
  -V geometry:left=3cm \
  -V geometry:right=1cm \
  -V geometry:twoside# \
  -V CJKmainfont=IPAexGothic

latex = -V documentclass=ltjarticle \
  -V geometry:left=2cm \
  -V geometry:right=2cm# \
  -V CJKmainfont=IPAexGothic

markdown_extention = -f markdown+hard_line_breaks+emoji
latex_packages = --listings
writer = --toc \
    --toc-depth=3 \
    -T MNE同人誌 \
    --indented-code-classes=python,bash \
    --pdf-engine=lualatex\
	-V mainfont=NotoSerifCJK-Regular

all: $(files)
	pandoc -o $(outfile) $(writer) $(latex_packages) $(latex) $(markdown_extention) $(files)
	xdg-open $(outfile)

twoside:
	pandoc -o $(twoside) $(writer) $(latex_packages) $(latex_twoside) $(markdown_extention) $(files)

html: $(files)
	pandoc -o $(html) $(writer) $(markdown_extention) $(files) -c github.css
