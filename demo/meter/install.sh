 #!/bin/bash
for ((c = $1; c <= $2; c++))
do
	nohup make telosb reinstall,5$c bsl,/dev/ttyUSB$c &
done
