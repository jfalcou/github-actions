#!/bin/sh -l

compile_target()
{
  echo "::group::Compiling $1" ;
  ninja $1 -j $2;
  compile=$?;
  echo "::endgroup::" ;

  return $compile
}

compile_targets()
{
  for i in `../cmake/toolchain/filter.sh $1 keys`;
  do
  compile_target $i 3 ;
  if [ -z $? ]
  then
    echo "::error $i can not be compiled!" ;
    return 1 ;
  fi
  done;
}

test_target()
{
  echo "::group::Running $1 tests" ;
  ctest -R $1 -j $2;
  compile=$?;
  echo "::endgroup::" ;

  return $compile
}

test_targets()
{
  for i in `../cmake/toolchain/filter.sh $1 values`;
  do
    test_target $i 4;
    if [ -z $? ]
    then
      echo "::error $i tests failed!" ;
      return 1 ;
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

compile_targets ../cmake/toolchain/arch.targets.json
if [ -z $? ]
then
  return -1 ;
fi

test_targets    ../cmake/toolchain/arch.targets.json
if [ -z $? ]
then
  return -1 ;
fi

compile_targets ../cmake/toolchain/api.targets.json
if [ -z $? ]
then
  return -1 ;
fi

test_targets    ../cmake/toolchain/api.targets.json
if [ -z $? ]
then
  return -1 ;
fi

compile_targets ../cmake/toolchain/doc.targets.json
if [ -z $? ]
then
  return -1 ;
fi

test_targets    ../cmake/toolchain/doc.targets.json
if [ -z $? ]
then
  return -1 ;
fi

compile_targets ../cmake/toolchain/simd.targets.json
if [ -z $? ]
then
  return -1 ;
fi

test_targets    ../cmake/toolchain/simd.targets.json
if [ -z $? ]
then
  return -1 ;
fi
