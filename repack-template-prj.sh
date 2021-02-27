#!/bin/bash

mv -f template-prj.tar template-prj.tar.xz /tmp
cd .template-prj
tar -cf - *  > ../template-prj.tar
tar -rvf ../template-prj.tar .vscode/
cd ..
xz -z template-prj.tar

