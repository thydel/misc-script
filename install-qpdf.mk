top:; @date

main: /usr/local/bin/qpdf

qpdf/INSTALL:; git clone git@github.com:qpdf/qpdf.git
/usr/include/jpeglib.h:; sudo aptitude install libjpeg62-turbo-dev
qpdf/config.log: qpdf/INSTALL /usr/include/jpeglib.h; (cd $(@D); ./configure)
qpdf/qpdf/build/qpdf: qpdf/config.log; (cd $(<D); make)
/usr/local/bin/qpdf: qpdf/qpdf/build/qpdf; (cd $(@F); sudo make install)
