files = files/introduction.md \
  files/install-hardware.md \
  files/install-os.md \
  files/install-jupyter.md \
  files/install-cuda.md \
  files/install-git.md \
  files/experiment.md \
  files/photosensor.md \
  files/install-maxfilter.md \
  files/install-freesurfer.md \
  files/install-mne.md \
  files/freesurfer.md \
  files/install-mricron.md \
  files/before-mne.md \
  files/mne-omajinai.md \
  files/mne-readdata.md \
  files/mne-preprocessing.md \
  files/mne-plot.md \
  files/mne-wavelet.md \
  files/mne-shukei.md \
  files/mne-connectivity.md \
  files/mne-source.md \
  files/math-wavelet.md \
  files/math-connectivity.md \
  files/math-mne.md \
  files/speedup-python.md \
  files/graph.md \
  files/books.md \
  files/python-tips.md

outfile = out.pdf

latex_twoside = -V documentclass=ltjarticle \
  -V geometry:left=3cm \
  -V geometry:right=1cm \
  -V geometry:twoside \
  -V CJKmainfont=IPAexGothic \
  -V lang=en-US

latex = -V documentclass=ltjarticle \
  -V geometry:left=2cm \
  -V geometry:right=2cm \
  -V CJKmainfont=IPAexGothic \
  -V lang=en-US

markdown_extention = -f markdown+hard_line_breaks
latex_packages = --listings --template eisvogel.tex
writer = --toc \
    --toc-depth=3 \
    -T MNE同人誌 \
    --indented-code-classes=python,bas \
    --pdf-engine=lualatex
oldwriter = --toc \
    --toc-depth=3 \
    -T MNE同人誌 \
    --indented-code-classes=python,bas \
    --latex-engine=lualatex

all: $(files)
	pandoc -o out.pdf $(writer) $(latex_packages) $(latex) $(markdown_extention) $(files)

old: $(files)
	pandoc -o out.pdf $(oldwriter) $(latex_packages) $(latex) $(markdown_extention) $(files)

twoside:
	pandoc -o twoside.pdf $(writer) $(latex_packages) $(latex_twoside) $(markdown_extention) $(files)
