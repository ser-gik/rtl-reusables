
#
# reusables
# A collection of miscellaneous, commonly used modules.
#

include $(DVB_BUNDLE_BEGIN)
DVB_BUNDLE := reusables
DVB_LIBDIRS := rtl/7segment \
				rtl/misc \
				rtl/uart_8n1 \
				rtl/vga
DVB_INCDIRS := rtl/uart_8n1
ifneq ($(WITH_OVL),)
DVB_DEFINES := REUSABLES_CHECKERS_ENABLED
DVB_REQUIRED := std_ovl
endif
include $(DVB_BUNDLE_END)

