#!/usr/bin/env bash

set -e -x

VLOG_COMMON="\
    -lint
    "

VLOG_DEFINES="\
    +define+OVL_VERILOG \
    +define+OVL_ASSERT_ON \
    "

VLOG_INCDIRS="\
    +incdir+../rtl/7segment/ \
    "

VLOG_LIBS="\
    +libext+.v \
    -y ../rtl/7segment/ \
    "

VSIM_COMMON="\
    -wlfdeleteonquit \
    -nolog \
    "

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`

pushd $SCRIPT_DIR

TESTNAME=$1

if [ ! -f "$TESTNAME.v" ]; then
    >&2 echo Bad test name - $TESTNAME
    exit 1;
fi

if [ -f "$TESTNAME.wave.do" ]; then
    VSIM_WAVE="-do $TESTNAME.wave.do"
fi

if [ ! -d "work" ]; then
    vlib work
fi

vlog $VLOG_COMMON $VLOG_DEFINES $VLOG_INCDIRS $VLOG_LIBS $TESTNAME.v

vsim $VSIM_COMMON -gui $VSIM_WAVE $TESTNAME &

popd



