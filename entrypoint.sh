#!/bin/sh -l

compile_target()
{
  echo "::group::Compiling $1" ;
  ninja $1 -j $2;
  compile=$?;
  echo "::endgroup::" ;

  echo "$compile"
}

compile_targets()
{
  for i in `../cmake/toolchain/filter.sh $1 keys`;
  do
  result=`compile_target $i 3`;
  if [ "$result" -ne "0" ]
  then
    echo "::error $i can not be compiled!" ;
    echo "1";
  fi
  done;
}

test_target()
{
  echo "::group::Running $1 tests" ;
  ctest -R $1 -j $2;
  compile=$?;
  echo "::endgroup::" ;

  echo "$compile"
}

test_targets()
{
  for i in `../cmake/toolchain/filter.sh $1 values`;
  do
    result=`test_target $i 4`;
    if [ "$result" -ne "0" ]
    then
      echo "::error $i tests failed!" ;
      echo "1";
    fi
  done;
}

echo "::group::Checking out $1 @ $2"
git clone $1 project
cd project
git checkout $2
echo "::endgroup::"

echo "::group::Running: 'cmake .. -G Ninja -DCMAKE_CXX_FLAGS="$3" $4'"
mkdir build
cd build
cmake .. -G Ninja -DCMAKE_CXX_FLAGS="$3" $4
echo "::endgroup::"

ok=$(compile_targets ../cmake/toolchain/arch.targets.json)
if [ "$ok" -eq "1" ]
then
  exit 1;
fi

ok=$(test_targets    ../cmake/toolchain/arch.targets.json)
if [ "$ok" -eq "1" ]
then
  exit 1;
fi

ok=$(compile_targets ../cmake/toolchain/api.targets.json)
if [ "$ok" -eq "1" ]
then
  exit 1;
fi

ok=$(test_targets    ../cmake/toolchain/api.targets.json)
if [ "$ok" -eq "1" ]
then
  exit 1;
fi

ok=$(compile_targets ../cmake/toolchain/doc.targets.json)
if [ "$ok" -eq "1" ]
then
  exit 1;
fi

ok=$(test_targets    ../cmake/toolchain/doc.targets.json)
if [ "$ok" -eq "1" ]
then
  exit 1;
fi

ok=$(compile_targets ../cmake/toolchain/simd.targets.json)
if [ "$ok" -eq "1" ]
then
  exit 1;
fi

ok=$(test_targets    ../cmake/toolchain/simd.targets.json)
if [ "$ok" -eq "1" ]
then
  exit 1;
fi

exit 0