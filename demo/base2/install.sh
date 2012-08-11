id=$(grep "BASE_ID" ../demo.h | awk '{print $3;}')
echo $id
make z1 reinstall,$id bsl,/dev/ttyUSB$1
