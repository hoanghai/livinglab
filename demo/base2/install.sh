id=$(grep "BASE_ID" ../demo.h | awk '{print $3;}')
echo $id
make $1 reinstall,$id bsl,/dev/ttyUSB$2
