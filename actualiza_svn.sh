echo Adding new files
for i in `svn status | grep --color=never "^?" | grep -v git | grep -v "storage$" | awk '{ print $2 }'`; do echo $i; svn add $i; done

echo Adding ignored .so binaries in vendor/bundle
find vendor/bundle -type f -name '*.so' -print0 \
  | xargs -0 -I{} svn add --parents --force "{}"

echo Removing old files
for i in `svn status | grep --color=never "^\!" | grep -v git | awk '{ print $2 }'`; do echo $i; svn remove $i; done

echo Status
svn status

echo "REVISE QUE LA CARPETA storage NO SE HA AÑADIDO DE NUEVO (NO SALE CON A)"
