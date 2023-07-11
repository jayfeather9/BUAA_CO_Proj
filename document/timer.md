# Entity: timer 

- **File**: timer.v
## Diagram

![Diagram](timer.svg "Diagram")
## Ports

| Port name | Direction | Type   | Description |
| --------- | --------- | ------ | ----------- |
| clk       | input     |        |             |
| reset     | input     |        |             |
| Addr      | input     | [31:2] |             |
| WE        | input     |        |             |
| Din       | input     | [31:0] |             |
| Dout      | output    | [31:0] |             |
| IRQ       | output    |        |             |
## Signals

| Name  | Type        | Description |
| ----- | ----------- | ----------- |
| state | reg [1:0]   |             |
| mem   | reg [31:0]  |             |
| _IRQ  | reg         |             |
| load  | wire [31:0] |             |
| i     | integer     |             |
## Processes
- unnamed: ( @(posedge clk) )
  - **Type:** always
