
#
# All available tests
#
REUSABLES_TESTBENCHES := \
	7segment_display_driver \
	binary_to_bcd_transcoder \
	prbs_gen \
	switch_debouncer \
	uart_8n1 \
	uart_8n1_clock_gen \
	uart_8n1_receiver \
	uart_8n1_transmitter


# Use DVB to manage simulation
include ../dvb/dvb.mk

# Import reusables
$(call dvb_add_bundles, \
	../ \
	ovl-dvb/ \
)

#
# Common test pile structure
# dir \
#     |- tb.v
#     |- wave.do
#     |- wave.gtkw
# $(1) - pile directory
#
define reusables_pile
include $(DVB_PILE_BEGIN)
DVB_PILE := $(1)
DVB_TOP_MODULE := $(1)/tb.v
DVB_REQUIRED := reusables
ifeq ($(DVB_TOOLCHAIN),icarus)
DVB_WAVEFORM_VIEWER_CONFIG := $(1)/wave.gtkw
endif
ifeq ($(DVB_TOOLCHAIN),mentor)
DVB_WAVEFORM_VIEWER_CONFIG := $(1)/wave.do
endif
include $(DVB_PILE_END)
endef

# Expand all
$(foreach tb,$(REUSABLES_TESTBENCHES), \
	$(eval $(call reusables_pile, $(tb))) \
)
