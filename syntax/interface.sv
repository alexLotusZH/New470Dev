`timescale 1ns/100ps
`define DEBUG_OUT

/*
Ready-valid& Handshake, one producer one consumer, one connection interface
*/

interface ready_valid #(parameter D_WIDTH = 16);
    logic ready;
    logic valid;
    logic[D_WIDTH-1:0] payload;
    logic[7:0] address;

    modport producer(input ready, output valid, output payload, output address);
    modport consumer(output ready, input valid, input payload, input address);

        // procedural block or third modport to impl FIFO
endinterface

// Keeps giving data 'hABCD to addr 'h01
// input ready
// output valid, output payload, output address
module Producer#(
    parameter type Payload = logic[15:0],
    parameter type Address = logic[7:0]
)(
    input logic clk,
    input logic reset,
    ready_valid.producer _producer    //modport used
);

    logic [15:0] cnt;

    assign next_cnt = cnt + 1;

    always_ff @( posedge clk ) begin
        if(reset) begin
           _producer.valid <= 1'b0;
           _producer.payload <= 16'h0000; 
           _producer.address <= 'h00; 
           cnt               <= '0;
        end else begin
            cnt                 <= cnt + 1;
            _producer.valid     <= 1'b1;
            _producer.payload   <=  cnt; 
            _producer.address   <= 'h02; 
            $display("Producer.valid: %b, Producer.payload: %h", _producer.valid, _producer.payload);
        end
    end
endmodule

// output ready
// input valid, input payload, input address
module Consumer#(
    parameter type Payload = logic[15:0],
    parameter type Address = logic[7:0]
)(
    input logic clk,
    input logic reset,
    ready_valid.consumer _consumer     //modport used

    `ifdef DEBUG_OUT
        ,output logic[15:0] data,
        output logic[7:0]  addr
    `endif
);
    always_ff @( posedge clk ) begin 
        if(reset) begin
            _consumer.ready <= 1'b0;
            `ifdef DEBUG_OUT
                data              <= 16'h0000;
                addr              <=  8'h00;
            `endif 

        end else begin
            _consumer.ready <= 1'b1;
            $display("Consumer.valid: %b", _consumer.valid);
            if(_consumer.valid) begin
                // Process the payload and address
                `ifdef DEBUG_OUT
                    data              <= _consumer.payload;
                    addr              <= _consumer.address;
                    $display("Received data: %h at address: %h", data, addr);
                `endif 
            end
        end
    end
endmodule
