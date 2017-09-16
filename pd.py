#!/bin/python
import os
import sys
args = sys.argv
input_args = args[1]
output_args = args[2]
kind = output_args.split('.', 2)[1]
if (kind == 'pdf'):
    os.system('pandoc ' + input_args + ' -o ' + output_args +
              ' -V documentclass=ltjarticle --toc --latex-engine=lualatex -V'
              + 'geometry:margin=1in -f markdown+hard_line_breaks --listings')
elif(kind == 'html'):
    os.system('pandoc ' + input_args +
              ' --self-contained --mathml -f markdown+hard_line_breaks '+ ' -o' + output_args )
elif(kind == 'tex'):
    os.system('pandoc ' + input_args +
              ' --self-contained --mathml -f markdown+hard_line_breaks '+ ' -o' + output_args )
