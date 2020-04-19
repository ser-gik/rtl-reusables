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
    +incdir+../../rtl/7segment/ \
    +incdir+../../rtl/uart_8n1/ \
    "

VLOG_LIBS="\
    +libext+.v \
    -y ../../rtl/7segment/ \
    -y ../../rtl/uart_8n1/ \
    "

VSIM_COMMON="\
    -wlfdeleteonquit \
    -nolog \
    "

SCRIPT_DIR=`dirname "$(readlink -f "$0")"`

pushd $SCRIPT_DIR

MODE=$1
TESTNAME=$2

if [ ! -d "$TESTNAME" ]; then
    >&2 echo Bad test name - $TESTNAME
    exit 1;
fi

pushd $TESTNAME

if [ ! -d "work" ]; then
    vlib work
fi

vlog $VLOG_COMMON $VLOG_DEFINES $VLOG_INCDIRS $VLOG_LIBS tb.v

case $MODE in
    gui)
        if [ -f "wave.do" ]; then
            VSIM_WAVE="-do wave.do"
        fi
        vsim $VSIM_COMMON -gui $VSIM_WAVE tb &
        ;;
    batch)
        vsim $VSIM_COMMON -batch -do "run -all;quit" tb
        ;;
    *)
        >&2 echo Bad mode - $MODE
        exit 1;
        ;;
esac

popd

popd

