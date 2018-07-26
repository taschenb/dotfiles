# Put everything into a output directory
$out_dir = "output";

# Compile to PDF
$pdf_mode = 1;

# Update continiously whenever changes are made to source files (-pvc)
$preview_continuous_mode = 1;

# Use synctex and nonstopmode to sync output for previewers
$pdflatex = 'pdflatex -synctex=1 -interaction=nonstopmode %O %S';

# Use zathura as pdf-viewer
$pdf_previewer = "zathura";