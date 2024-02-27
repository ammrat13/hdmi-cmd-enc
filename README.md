# HDMI Peripheral: Command Encoder

This is the "Command Encoder" component of an HDMI peripheral for the Zynq 7000.
A command consists of the data to be serialized over each of the three channels.
This component reads commands over an AXI4-Stream interface at a rate of one
command per pixel clock cycle. It serializes the commands and outputs them as
differential signals.

## Usage

This component is clocked with the pixel clock and another clock at five times
the pixel clock's speed. These two clocks must be phase aligned. So for example,
they can be generated by the same MMCM. In the case of 480p, the pixel clock
should be 25.175MHz and the faster clock should be 125.875MHz.

The reset signal for this component is active low and asynchronous. This means
it can be connected to the `locked` signal of the clock generator.

This component expects one command per cycle over the AXI4-Stream interface. The
commands should therefore be buffered in a FIFO to make sure this component is
never starved. The format for the commands are as shown below. The LSB for each
channel is the first to be serialized.

* `Channel0 = Command[ 9: 0]`
* `Channel1 = Command[19:10]`
* `Channel2 = Command[29:20]`

Finally, this component outputs the differential clock on the `hdmi_pulse_*`
outputs, and it outputs the data for channel `i` on `hdmi_data_*[i]`. These
ports should be connected directly to pads as they are connected to output
buffers internally.
