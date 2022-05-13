#!/bin/bash -x

export LKP_SRC=$(dirname $(dirname $(readlink -e -v $0)))
cd $LKP_SRC
make
make install
lkp install

cd $LKP_SRC/auto_task/
for jobname in `ls $LKP_SRC/jobs_docker`
do
	lkp split $LKP_SRC/jobs_docker/$jobname
done

for testname in `find . -name "*.yaml" -print`
do
	echo $testname
	lkp install $testname
	lkp run $testname
done

for filename in `ls .`
do
	if [ $filename != "auto_task.sh" ]
	then
		rm -rf $filename
	fi
done

echo `hostname` > /complete_signal/`hostname`
