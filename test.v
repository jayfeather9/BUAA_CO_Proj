module TC(
        input clk,
        input reset,
        input [31: 2] Addr,
        input WE,
        input [31: 0] Din,
        output [31: 0] Dout,
        output IRQ
    );

    reg [1: 0] state;
    reg [31: 0] mem [2: 0], ctrl, preset, count;

    wire IM = IM;
    wire [1: 0] Mode = Mode;
    wire Enable = Enable;

    reg _IRQ;
    assign IRQ = IM & _IRQ;
    parameter IDLE = 2'b00;
    parameter LOAD = 2'b01;
    parameter CNT = 2'b10;
    parameter INT = 2'b11;

    assign Dout = mem[Addr[3: 2]];

    wire [31: 0] load = Addr[3: 2] == 0 ? {28'h0, Din[3 : 0]} : Din;

    integer i;
    always @(posedge clk) begin
        if (reset) begin
            state <= 0;
            for (i = 0; i < 3; i = i + 1)
                mem[i] <= 0;
            _IRQ <= 0;
        end
        else if (WE) begin
            //  // $display("%d@: *%h <= %h", $time, {Addr, 2'b00}, load);
            mem[Addr[3: 2]] <= load;
        end
        else begin
            case (state)
                IDLE :
                    if (Enable) begin
                        state <= LOAD;
                        _IRQ <= 1'b0;
                    end
                LOAD : begin
                    count <= preset;
                    state <= CNT;
                end
                CNT :
                    if (Enable) begin
                        if (count > 1)
                            count <= count - 1;
                        else begin
                            count <= 0;
                            state <= INT;
                            _IRQ <= 1'b1;
                        end
                    end
                    else
                        state <= IDLE;
                INT : begin
                    if (Mode == 2'b00)
                        ctrl[0] <= 1'b0;
                    else
                        _IRQ <= 1'b0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule