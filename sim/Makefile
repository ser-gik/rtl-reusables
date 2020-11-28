#
# All available tests.
# Each dir must follow next structure
# dir \
#     |- tb.v
#     |- wave.do
#     |- wave.gtkw
#
REUSABLES_TESTBENCHES := \
	7segment_display_driver \
	binary_to_bcd_transcoder \
	prbs_gen \
	switch_debouncer \
	group_mux \
	uart_8n1 \
	uart_8n1_clock_gen \
	uart_8n1_receiver \
	uart_8n1_transmitter \
	vga_sync_gen \
	vga_console_sync \


# Use DVB to manage simulation
include dvb/dvb.mk

$(call dvb_add_bundles, \
	../ \
	$(if $(WITH_OVL), ovl-dvb/) \
)

include $(DVB_PILE_BEGIN)
DVB_NAME := reusables-sim
DVB_REQUIRED := reusables
include $(DVB_PILE_END)

#
# function to define a simulation for test dir.
# $(1) - test directory
#
define reusables_pile
include $(DVB_SIMULATION_BEGIN)
DVB_NAME := $(1)
DVB_PILE := reusables-sim
DVB_TESTBENCH := $(1)/tb.v
ifeq ($(DVB_TOOLCHAIN),icarus)
DVB_WAVEFORM_VIEWER_CONFIG := $(1)/wave.gtkw
endif
ifeq ($(DVB_TOOLCHAIN),mentor)
DVB_WAVEFORM_VIEWER_CONFIG := $(1)/wave.do
endif
include $(DVB_SIMULATION_END)
endef

# Expand all
$(foreach tb,$(REUSABLES_TESTBENCHES), \
	$(eval $(call reusables_pile, $(tb))) \
)

