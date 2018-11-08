// Generator : SpinalHDL v1.2.2    git head : ec5e7e191d669ded826c34b7aaa74f2563574157
// Date      : 07/11/2018, 18:41:19
// Component : Up5kPerf


`define AluBitwiseCtrlEnum_defaultEncoding_type [1:0]
`define AluBitwiseCtrlEnum_defaultEncoding_XOR_1 2'b00
`define AluBitwiseCtrlEnum_defaultEncoding_OR_1 2'b01
`define AluBitwiseCtrlEnum_defaultEncoding_AND_1 2'b10
`define AluBitwiseCtrlEnum_defaultEncoding_SRC1 2'b11

`define BranchCtrlEnum_defaultEncoding_type [1:0]
`define BranchCtrlEnum_defaultEncoding_INC 2'b00
`define BranchCtrlEnum_defaultEncoding_B 2'b01
`define BranchCtrlEnum_defaultEncoding_JAL 2'b10
`define BranchCtrlEnum_defaultEncoding_JALR 2'b11

`define EnvCtrlEnum_defaultEncoding_type [1:0]
`define EnvCtrlEnum_defaultEncoding_NONE 2'b00
`define EnvCtrlEnum_defaultEncoding_XRET 2'b01
`define EnvCtrlEnum_defaultEncoding_ECALL 2'b10
`define EnvCtrlEnum_defaultEncoding_EBREAK 2'b11

`define Src1CtrlEnum_defaultEncoding_type [1:0]
`define Src1CtrlEnum_defaultEncoding_RS 2'b00
`define Src1CtrlEnum_defaultEncoding_IMU 2'b01
`define Src1CtrlEnum_defaultEncoding_PC_INCREMENT 2'b10
`define Src1CtrlEnum_defaultEncoding_URS1 2'b11

`define ShiftCtrlEnum_defaultEncoding_type [1:0]
`define ShiftCtrlEnum_defaultEncoding_DISABLE_1 2'b00
`define ShiftCtrlEnum_defaultEncoding_SLL_1 2'b01
`define ShiftCtrlEnum_defaultEncoding_SRL_1 2'b10
`define ShiftCtrlEnum_defaultEncoding_SRA_1 2'b11

`define AluCtrlEnum_defaultEncoding_type [1:0]
`define AluCtrlEnum_defaultEncoding_ADD_SUB 2'b00
`define AluCtrlEnum_defaultEncoding_SLT_SLTU 2'b01
`define AluCtrlEnum_defaultEncoding_BITWISE 2'b10

`define fsm_enumDefinition_defaultEncoding_type [2:0]
`define fsm_enumDefinition_defaultEncoding_boot 3'b000
`define fsm_enumDefinition_defaultEncoding_fsm_SETUP 3'b001
`define fsm_enumDefinition_defaultEncoding_fsm_IDLE 3'b010
`define fsm_enumDefinition_defaultEncoding_fsm_CMD 3'b011
`define fsm_enumDefinition_defaultEncoding_fsm_PAYLOAD 3'b100

`define Src2CtrlEnum_defaultEncoding_type [1:0]
`define Src2CtrlEnum_defaultEncoding_RS 2'b00
`define Src2CtrlEnum_defaultEncoding_IMI 2'b01
`define Src2CtrlEnum_defaultEncoding_IMS 2'b10
`define Src2CtrlEnum_defaultEncoding_PC 2'b11

module StreamFifoLowLatency (
      input   io_push_valid,
      output  io_push_ready,
      input   io_push_payload_error,
      input  [31:0] io_push_payload_inst,
      output reg  io_pop_valid,
      input   io_pop_ready,
      output reg  io_pop_payload_error,
      output reg [31:0] io_pop_payload_inst,
      input   io_flush,
      output [1:0] io_occupancy,
      input   io_clk,
      input   GLOBAL_BUFFER_OUTPUT);
  wire [32:0] _zz_3_;
  wire [0:0] _zz_4_;
  wire [32:0] _zz_5_;
  reg  _zz_1_;
  reg  pushPtr_willIncrement;
  reg  pushPtr_willClear;
  reg [0:0] pushPtr_valueNext;
  reg [0:0] pushPtr_value;
  wire  pushPtr_willOverflowIfInc;
  wire  pushPtr_willOverflow;
  reg  popPtr_willIncrement;
  reg  popPtr_willClear;
  reg [0:0] popPtr_valueNext;
  reg [0:0] popPtr_value;
  wire  popPtr_willOverflowIfInc;
  wire  popPtr_willOverflow;
  wire  ptrMatch;
  reg  risingOccupancy;
  wire  empty;
  wire  full;
  wire  pushing;
  wire  popping;
  wire [32:0] _zz_2_;
  wire [0:0] ptrDif;
  reg [32:0] ram [0:1];
  assign _zz_4_ = _zz_2_[0 : 0];
  assign _zz_5_ = {io_push_payload_inst,io_push_payload_error};
  always @ (posedge io_clk) begin
    if(_zz_1_) begin
      ram[pushPtr_value] <= _zz_5_;
    end
  end

  assign _zz_3_ = ram[popPtr_value];
  always @ (*) begin
    _zz_1_ = 1'b0;
    pushPtr_willIncrement = 1'b0;
    if(pushing)begin
      _zz_1_ = 1'b1;
      pushPtr_willIncrement = 1'b1;
    end
  end

  always @ (*) begin
    pushPtr_willClear = 1'b0;
    popPtr_willClear = 1'b0;
    if(io_flush)begin
      pushPtr_willClear = 1'b1;
      popPtr_willClear = 1'b1;
    end
  end

  assign pushPtr_willOverflowIfInc = (pushPtr_value == (1'b1));
  assign pushPtr_willOverflow = (pushPtr_willOverflowIfInc && pushPtr_willIncrement);
  always @ (*) begin
    pushPtr_valueNext = (pushPtr_value + pushPtr_willIncrement);
    if(pushPtr_willClear)begin
      pushPtr_valueNext = (1'b0);
    end
  end

  always @ (*) begin
    popPtr_willIncrement = 1'b0;
    if(popping)begin
      popPtr_willIncrement = 1'b1;
    end
  end

  assign popPtr_willOverflowIfInc = (popPtr_value == (1'b1));
  assign popPtr_willOverflow = (popPtr_willOverflowIfInc && popPtr_willIncrement);
  always @ (*) begin
    popPtr_valueNext = (popPtr_value + popPtr_willIncrement);
    if(popPtr_willClear)begin
      popPtr_valueNext = (1'b0);
    end
  end

  assign ptrMatch = (pushPtr_value == popPtr_value);
  assign empty = (ptrMatch && (! risingOccupancy));
  assign full = (ptrMatch && risingOccupancy);
  assign pushing = (io_push_valid && io_push_ready);
  assign popping = (io_pop_valid && io_pop_ready);
  assign io_push_ready = (! full);
  always @ (*) begin
    if((! empty))begin
      io_pop_valid = 1'b1;
      io_pop_payload_error = _zz_4_[0];
      io_pop_payload_inst = _zz_2_[32 : 1];
    end else begin
      io_pop_valid = io_push_valid;
      io_pop_payload_error = io_push_payload_error;
      io_pop_payload_inst = io_push_payload_inst;
    end
  end

  assign _zz_2_ = _zz_3_;
  assign ptrDif = (pushPtr_value - popPtr_value);
  assign io_occupancy = {(risingOccupancy && ptrMatch),ptrDif};
  always @ (posedge io_clk) begin
    if(GLOBAL_BUFFER_OUTPUT) begin
      pushPtr_value <= (1'b0);
      popPtr_value <= (1'b0);
      risingOccupancy <= 1'b0;
    end else begin
      pushPtr_value <= pushPtr_valueNext;
      popPtr_value <= popPtr_valueNext;
      if((pushing != popping))begin
        risingOccupancy <= pushing;
      end
      if(io_flush)begin
        risingOccupancy <= 1'b0;
      end
    end
  end

endmodule

module StreamArbiter (
      input   io_inputs_0_0,
      output  io_inputs_0_ready,
      input   io_inputs_0_0_wr,
      input  [15:0] io_inputs_0_0_address,
      input  [31:0] io_inputs_0_0_data,
      input  [3:0] io_inputs_0_0_mask,
      input   io_inputs_1_1,
      output  io_inputs_1_ready,
      input   io_inputs_1_1_wr,
      input  [15:0] io_inputs_1_1_address,
      input  [31:0] io_inputs_1_1_data,
      input  [3:0] io_inputs_1_1_mask,
      output  io_output_valid,
      input   io_output_ready,
      output  io_output_payload_wr,
      output [15:0] io_output_payload_address,
      output [31:0] io_output_payload_data,
      output [3:0] io_output_payload_mask,
      output [0:0] io_chosen,
      output [1:0] io_chosenOH,
      input   io_clk,
      input   GLOBAL_BUFFER_OUTPUT);
  reg  _zz_4_;
  reg [15:0] _zz_5_;
  reg [31:0] _zz_6_;
  reg [3:0] _zz_7_;
  wire [1:0] _zz_8_;
  wire [1:0] _zz_9_;
  reg  locked;
  wire  maskProposal_0;
  wire  maskProposal_1;
  reg  maskLocked_0;
  reg  maskLocked_1;
  wire  maskRouted_0;
  wire  maskRouted_1;
  wire [1:0] _zz_1_;
  wire [0:0] _zz_2_;
  wire  _zz_3_;
  assign _zz_8_ = (_zz_1_ & (~ _zz_9_));
  assign _zz_9_ = (_zz_1_ - (2'b01));
  always @(*) begin
    case(_zz_2_)
      1'b0 : begin
        _zz_4_ = io_inputs_0_0_wr;
        _zz_5_ = io_inputs_0_0_address;
        _zz_6_ = io_inputs_0_0_data;
        _zz_7_ = io_inputs_0_0_mask;
      end
      default : begin
        _zz_4_ = io_inputs_1_1_wr;
        _zz_5_ = io_inputs_1_1_address;
        _zz_6_ = io_inputs_1_1_data;
        _zz_7_ = io_inputs_1_1_mask;
      end
    endcase
  end

  assign maskRouted_0 = (locked ? maskLocked_0 : maskProposal_0);
  assign maskRouted_1 = (locked ? maskLocked_1 : maskProposal_1);
  assign _zz_1_ = {io_inputs_1_1,io_inputs_0_0};
  assign maskProposal_0 = io_inputs_0_0;
  assign maskProposal_1 = _zz_8_[1];
  assign io_output_valid = ((io_inputs_0_0 && maskRouted_0) || (io_inputs_1_1 && maskRouted_1));
  assign _zz_2_ = maskRouted_1;
  assign io_output_payload_wr = _zz_4_;
  assign io_output_payload_address = _zz_5_;
  assign io_output_payload_data = _zz_6_;
  assign io_output_payload_mask = _zz_7_;
  assign io_inputs_0_ready = (maskRouted_0 && io_output_ready);
  assign io_inputs_1_ready = (maskRouted_1 && io_output_ready);
  assign io_chosenOH = {maskRouted_1,maskRouted_0};
  assign _zz_3_ = io_chosenOH[1];
  assign io_chosen = _zz_3_;
  always @ (posedge io_clk) begin
    if(GLOBAL_BUFFER_OUTPUT) begin
      locked <= 1'b0;
    end else begin
      if(io_output_valid)begin
        locked <= 1'b1;
      end
      if((io_output_valid && io_output_ready))begin
        locked <= 1'b0;
      end
    end
  end

  always @ (posedge io_clk) begin
    if(io_output_valid)begin
      maskLocked_0 <= maskRouted_0;
      maskLocked_1 <= maskRouted_1;
    end
  end

endmodule


//StreamArbiter_1_ remplaced by StreamArbiter

module StreamArbiter_2_ (
      input   io_inputs_0_0,
      output  io_inputs_0_ready,
      input   io_inputs_0_0_wr,
      input  [19:0] io_inputs_0_0_address,
      input  [31:0] io_inputs_0_0_data,
      input  [3:0] io_inputs_0_0_mask,
      input   io_inputs_1_1,
      output  io_inputs_1_ready,
      input   io_inputs_1_1_wr,
      input  [19:0] io_inputs_1_1_address,
      input  [31:0] io_inputs_1_1_data,
      input  [3:0] io_inputs_1_1_mask,
      output  io_output_valid,
      input   io_output_ready,
      output  io_output_payload_wr,
      output [19:0] io_output_payload_address,
      output [31:0] io_output_payload_data,
      output [3:0] io_output_payload_mask,
      output [0:0] io_chosen,
      output [1:0] io_chosenOH,
      input   io_clk,
      input   GLOBAL_BUFFER_OUTPUT);
  reg  _zz_4_;
  reg [19:0] _zz_5_;
  reg [31:0] _zz_6_;
  reg [3:0] _zz_7_;
  wire [1:0] _zz_8_;
  wire [1:0] _zz_9_;
  reg  locked;
  wire  maskProposal_0;
  wire  maskProposal_1;
  reg  maskLocked_0;
  reg  maskLocked_1;
  wire  maskRouted_0;
  wire  maskRouted_1;
  wire [1:0] _zz_1_;
  wire [0:0] _zz_2_;
  wire  _zz_3_;
  assign _zz_8_ = (_zz_1_ & (~ _zz_9_));
  assign _zz_9_ = (_zz_1_ - (2'b01));
  always @(*) begin
    case(_zz_2_)
      1'b0 : begin
        _zz_4_ = io_inputs_0_0_wr;
        _zz_5_ = io_inputs_0_0_address;
        _zz_6_ = io_inputs_0_0_data;
        _zz_7_ = io_inputs_0_0_mask;
      end
      default : begin
        _zz_4_ = io_inputs_1_1_wr;
        _zz_5_ = io_inputs_1_1_address;
        _zz_6_ = io_inputs_1_1_data;
        _zz_7_ = io_inputs_1_1_mask;
      end
    endcase
  end

  assign maskRouted_0 = (locked ? maskLocked_0 : maskProposal_0);
  assign maskRouted_1 = (locked ? maskLocked_1 : maskProposal_1);
  assign _zz_1_ = {io_inputs_1_1,io_inputs_0_0};
  assign maskProposal_0 = io_inputs_0_0;
  assign maskProposal_1 = _zz_8_[1];
  assign io_output_valid = ((io_inputs_0_0 && maskRouted_0) || (io_inputs_1_1 && maskRouted_1));
  assign _zz_2_ = maskRouted_1;
  assign io_output_payload_wr = _zz_4_;
  assign io_output_payload_address = _zz_5_;
  assign io_output_payload_data = _zz_6_;
  assign io_output_payload_mask = _zz_7_;
  assign io_inputs_0_ready = (maskRouted_0 && io_output_ready);
  assign io_inputs_1_ready = (maskRouted_1 && io_output_ready);
  assign io_chosenOH = {maskRouted_1,maskRouted_0};
  assign _zz_3_ = io_chosenOH[1];
  assign io_chosen = _zz_3_;
  always @ (posedge io_clk) begin
    if(GLOBAL_BUFFER_OUTPUT) begin
      locked <= 1'b0;
    end else begin
      if(io_output_valid)begin
        locked <= 1'b1;
      end
      if((io_output_valid && io_output_ready))begin
        locked <= 1'b0;
      end
    end
  end

  always @ (posedge io_clk) begin
    if(io_output_valid)begin
      maskLocked_0 <= maskRouted_0;
      maskLocked_1 <= maskRouted_1;
    end
  end

endmodule

module BufferCC (
      input   io_dataIn,
      output  io_dataOut,
      input   io_clk);
  reg  buffers_0;
  reg  buffers_1;
  assign io_dataOut = buffers_1;
  always @ (posedge io_clk) begin
    buffers_0 <= io_dataIn;
    buffers_1 <= buffers_0;
  end

endmodule

module Spram (
      input   io_bus_cmd_valid,
      output  io_bus_cmd_ready,
      input   io_bus_cmd_payload_wr,
      input  [15:0] io_bus_cmd_payload_address,
      input  [31:0] io_bus_cmd_payload_data,
      input  [3:0] io_bus_cmd_payload_mask,
      output  io_bus_rsp_valid,
      output [31:0] io_bus_rsp_payload_data,
      input   io_clk,
      input   GLOBAL_BUFFER_OUTPUT);
  wire [15:0] _zz_1_;
  wire [13:0] _zz_2_;
  wire [3:0] _zz_3_;
  wire  _zz_4_;
  wire  _zz_5_;
  wire  _zz_6_;
  wire [15:0] _zz_7_;
  wire [13:0] _zz_8_;
  wire [3:0] _zz_9_;
  wire  _zz_10_;
  wire  _zz_11_;
  wire  _zz_12_;
  wire [15:0] _zz_13_;
  wire [15:0] _zz_14_;
  wire  cmd_valid;
  wire  cmd_payload_wr;
  wire [15:0] cmd_payload_address;
  wire [31:0] cmd_payload_data;
  wire [3:0] cmd_payload_mask;
  reg  rspPending;
  reg  rspTarget;
  wire [31:0] readData;
  SB_SPRAM256KA mems_0 ( 
    .DATAIN(_zz_1_),
    .ADDRESS(_zz_2_),
    .MASKWREN(_zz_3_),
    .WREN(cmd_payload_wr),
    .CHIPSELECT(cmd_valid),
    .CLOCK(io_clk),
    .DATAOUT(_zz_13_),
    .STANDBY(_zz_4_),
    .SLEEP(_zz_5_),
    .POWEROFF(_zz_6_) 
  );
  SB_SPRAM256KA mems_1 ( 
    .DATAIN(_zz_7_),
    .ADDRESS(_zz_8_),
    .MASKWREN(_zz_9_),
    .WREN(cmd_payload_wr),
    .CHIPSELECT(cmd_valid),
    .CLOCK(io_clk),
    .DATAOUT(_zz_14_),
    .STANDBY(_zz_10_),
    .SLEEP(_zz_11_),
    .POWEROFF(_zz_12_) 
  );
  assign io_bus_cmd_ready = 1'b1;
  assign cmd_valid = io_bus_cmd_valid;
  assign cmd_payload_wr = io_bus_cmd_payload_wr;
  assign cmd_payload_address = io_bus_cmd_payload_address;
  assign cmd_payload_data = io_bus_cmd_payload_data;
  assign cmd_payload_mask = io_bus_cmd_payload_mask;
  assign _zz_1_ = cmd_payload_data[15 : 0];
  assign _zz_3_ = {{{cmd_payload_mask[1],cmd_payload_mask[1]},cmd_payload_mask[0]},cmd_payload_mask[0]};
  assign _zz_7_ = cmd_payload_data[31 : 16];
  assign _zz_9_ = {{{cmd_payload_mask[3],cmd_payload_mask[3]},cmd_payload_mask[2]},cmd_payload_mask[2]};
  assign _zz_2_ = (cmd_payload_address >>> 2);
  assign _zz_4_ = 1'b0;
  assign _zz_5_ = 1'b0;
  assign _zz_6_ = 1'b1;
  assign _zz_8_ = (cmd_payload_address >>> 2);
  assign _zz_10_ = 1'b0;
  assign _zz_11_ = 1'b0;
  assign _zz_12_ = 1'b1;
  assign readData = {_zz_14_,_zz_13_};
  assign io_bus_rsp_valid = (rspPending && rspTarget);
  assign io_bus_rsp_payload_data = readData;
  always @ (posedge io_clk) begin
    if(GLOBAL_BUFFER_OUTPUT) begin
      rspPending <= 1'b0;
    end else begin
      rspPending <= (cmd_valid && (! cmd_payload_wr));
    end
  end

  always @ (posedge io_clk) begin
    rspTarget <= io_bus_cmd_valid;
  end

endmodule


//Spram_1_ remplaced by Spram

module Peripherals (
      input   io_bus_cmd_valid,
      output  io_bus_cmd_ready,
      input   io_bus_cmd_payload_wr,
      input  [5:0] io_bus_cmd_payload_address,
      input  [31:0] io_bus_cmd_payload_data,
      input  [3:0] io_bus_cmd_payload_mask,
      output  io_bus_rsp_valid,
      output [31:0] io_bus_rsp_payload_data,
      output  io_mTimeInterrupt,
      output [2:0] io_leds,
      output  io_serialTx,
      input   io_clk,
      input   GLOBAL_BUFFER_OUTPUT);
  wire [31:0] _zz_5_;
  wire [0:0] _zz_6_;
  wire [3:0] _zz_7_;
  wire [0:0] _zz_8_;
  wire [6:0] _zz_9_;
  wire  mapper_readAtCmd_valid;
  reg [31:0] mapper_readAtCmd_payload;
  reg  mapper_readAtRsp_valid;
  reg [31:0] mapper_readAtRsp_payload;
  wire  mapper_askWrite;
  wire  mapper_askRead;
  wire  mapper_doWrite;
  wire  mapper_doRead;
  reg [2:0] _zz_1_;
  reg [31:0] mTime_counter;
  reg [31:0] mTime_cmp;
  reg  mTime_interrupt;
  reg  _zz_2_;
  reg  serialTx_counter_willIncrement;
  wire  serialTx_counter_willClear;
  reg [3:0] serialTx_counter_valueNext;
  reg [3:0] serialTx_counter_value;
  wire  serialTx_counter_willOverflowIfInc;
  wire  serialTx_counter_willOverflow;
  reg [7:0] serialTx_buffer;
  wire [11:0] serialTx_bitstream;
  wire  serialTx_busy;
  reg  _zz_3_;
  wire  serialTx_timer_willIncrement;
  wire  serialTx_timer_willClear;
  reg [6:0] serialTx_timer_valueNext;
  reg [6:0] serialTx_timer_value;
  wire  serialTx_timer_willOverflowIfInc;
  wire  serialTx_timer_willOverflow;
  reg  _zz_4_;
  assign _zz_5_ = (mTime_counter - mTime_cmp);
  assign _zz_6_ = serialTx_counter_willIncrement;
  assign _zz_7_ = {3'd0, _zz_6_};
  assign _zz_8_ = serialTx_timer_willIncrement;
  assign _zz_9_ = {6'd0, _zz_8_};
  assign io_bus_cmd_ready = 1'b1;
  assign mapper_askWrite = (io_bus_cmd_valid && io_bus_cmd_payload_wr);
  assign mapper_askRead = (io_bus_cmd_valid && (! io_bus_cmd_payload_wr));
  assign mapper_doWrite = (mapper_askWrite && io_bus_cmd_ready);
  assign mapper_doRead = (mapper_askRead && io_bus_cmd_ready);
  assign io_bus_rsp_valid = mapper_readAtRsp_valid;
  assign io_bus_rsp_payload_data = mapper_readAtRsp_payload;
  assign mapper_readAtCmd_valid = mapper_doRead;
  always @ (*) begin
    mapper_readAtCmd_payload = (32'b00000000000000000000000000000000);
    _zz_2_ = 1'b0;
    _zz_4_ = 1'b0;
    case(io_bus_cmd_payload_address)
      6'b000100 : begin
        mapper_readAtCmd_payload[2 : 0] = _zz_1_;
      end
      6'b011000 : begin
        if(mapper_doWrite)begin
          _zz_2_ = 1'b1;
        end
      end
      6'b010000 : begin
        mapper_readAtCmd_payload[31 : 0] = mTime_counter;
      end
      6'b000000 : begin
        if(mapper_doWrite)begin
          _zz_4_ = 1'b1;
        end
        mapper_readAtCmd_payload[0 : 0] = serialTx_busy;
      end
      default : begin
      end
    endcase
  end

  assign io_leds = _zz_1_;
  assign io_mTimeInterrupt = mTime_interrupt;
  always @ (*) begin
    serialTx_counter_willIncrement = 1'b0;
    if(((serialTx_counter_value != (4'b0000)) && serialTx_timer_willOverflow))begin
      serialTx_counter_willIncrement = 1'b1;
    end
    if(_zz_4_)begin
      serialTx_counter_willIncrement = 1'b1;
    end
  end

  assign serialTx_counter_willClear = 1'b0;
  assign serialTx_counter_willOverflowIfInc = (serialTx_counter_value == (4'b1011));
  assign serialTx_counter_willOverflow = (serialTx_counter_willOverflowIfInc && serialTx_counter_willIncrement);
  always @ (*) begin
    if(serialTx_counter_willOverflow)begin
      serialTx_counter_valueNext = (4'b0000);
    end else begin
      serialTx_counter_valueNext = (serialTx_counter_value + _zz_7_);
    end
    if(serialTx_counter_willClear)begin
      serialTx_counter_valueNext = (4'b0000);
    end
  end

  assign serialTx_bitstream = {serialTx_buffer,(4'b0111)};
  assign serialTx_busy = (serialTx_counter_value != (4'b0000));
  assign io_serialTx = _zz_3_;
  assign serialTx_timer_willClear = 1'b0;
  assign serialTx_timer_willOverflowIfInc = (serialTx_timer_value == (7'b1100111));
  assign serialTx_timer_willOverflow = (serialTx_timer_willOverflowIfInc && serialTx_timer_willIncrement);
  always @ (*) begin
    if(serialTx_timer_willOverflow)begin
      serialTx_timer_valueNext = (7'b0000000);
    end else begin
      serialTx_timer_valueNext = (serialTx_timer_value + _zz_9_);
    end
    if(serialTx_timer_willClear)begin
      serialTx_timer_valueNext = (7'b0000000);
    end
  end

  assign serialTx_timer_willIncrement = 1'b1;
  always @ (posedge io_clk) begin
    if(GLOBAL_BUFFER_OUTPUT) begin
      mapper_readAtRsp_valid <= 1'b0;
      _zz_1_ <= (3'b000);
      mTime_counter <= (32'b00000000000000000000000000000000);
      mTime_cmp <= (32'b00000000000000000000000000000000);
      mTime_interrupt <= 1'b0;
      serialTx_counter_value <= (4'b0000);
      _zz_3_ <= 1'b1;
      serialTx_timer_value <= (7'b0000000);
    end else begin
      mapper_readAtRsp_valid <= mapper_readAtCmd_valid;
      if((! _zz_5_[31]))begin
        mTime_interrupt <= 1'b1;
      end
      if(_zz_2_)begin
        mTime_interrupt <= 1'b0;
      end
      mTime_counter <= (mTime_counter + (32'b00000000000000000000000000000001));
      serialTx_counter_value <= serialTx_counter_valueNext;
      _zz_3_ <= serialTx_bitstream[serialTx_counter_value];
      serialTx_timer_value <= serialTx_timer_valueNext;
      case(io_bus_cmd_payload_address)
        6'b000100 : begin
          if(mapper_doWrite)begin
            _zz_1_ <= io_bus_cmd_payload_data[2 : 0];
          end
        end
        6'b011000 : begin
          if(mapper_doWrite)begin
            mTime_cmp <= io_bus_cmd_payload_data[31 : 0];
          end
        end
        6'b010000 : begin
        end
        6'b000000 : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @ (posedge io_clk) begin
    mapper_readAtRsp_payload <= mapper_readAtCmd_payload;
    case(io_bus_cmd_payload_address)
      6'b000100 : begin
      end
      6'b011000 : begin
      end
      6'b010000 : begin
      end
      6'b000000 : begin
        if(mapper_doWrite)begin
          serialTx_buffer <= io_bus_cmd_payload_data[7 : 0];
        end
      end
      default : begin
      end
    endcase
  end

endmodule

module FlashXpi (
      input   io_bus_cmd_valid,
      output reg  io_bus_cmd_ready,
      input   io_bus_cmd_payload_wr,
      input  [19:0] io_bus_cmd_payload_address,
      input  [31:0] io_bus_cmd_payload_data,
      input  [3:0] io_bus_cmd_payload_mask,
      output  io_bus_rsp_valid,
      output [31:0] io_bus_rsp_payload_data,
      output reg [0:0] io_flash_ss,
      output reg  io_flash_sclk,
      output reg  io_flash_mosi,
      input   io_flash_miso,
      input   io_clk,
      input   GLOBAL_BUFFER_OUTPUT);
  reg  _zz_3_;
  reg  _zz_4_;
  wire [0:0] _zz_5_;
  wire [4:0] _zz_6_;
  wire [5:0] _zz_7_;
  wire [3:0] _zz_8_;
  wire [23:0] _zz_9_;
  wire [5:0] _zz_10_;
  reg  buffer_fill;
  reg [31:0] buffer_buffer;
  reg  buffer_counter_willIncrement;
  wire  buffer_counter_willClear;
  reg [4:0] buffer_counter_valueNext;
  reg [4:0] buffer_counter_value;
  wire  buffer_counter_willOverflowIfInc;
  wire  buffer_counter_willOverflow;
  reg  buffer_done;
  wire  fsm_wantExit;
  reg [6:0] fsm_counter;
  reg `fsm_enumDefinition_defaultEncoding_type fsm_stateReg;
  reg `fsm_enumDefinition_defaultEncoding_type fsm_stateNext;
  wire [15:0] _zz_1_;
  wire [39:0] _zz_2_;
  assign _zz_5_ = buffer_counter_willIncrement;
  assign _zz_6_ = {4'd0, _zz_5_};
  assign _zz_7_ = (fsm_counter >>> 1);
  assign _zz_8_ = _zz_7_[3:0];
  assign _zz_9_ = {4'd0, io_bus_cmd_payload_address};
  assign _zz_10_ = (fsm_counter >>> 1);
  always @(*) begin
    case(_zz_8_)
      4'b0000 : begin
        _zz_3_ = _zz_1_[15];
      end
      4'b0001 : begin
        _zz_3_ = _zz_1_[14];
      end
      4'b0010 : begin
        _zz_3_ = _zz_1_[13];
      end
      4'b0011 : begin
        _zz_3_ = _zz_1_[12];
      end
      4'b0100 : begin
        _zz_3_ = _zz_1_[11];
      end
      4'b0101 : begin
        _zz_3_ = _zz_1_[10];
      end
      4'b0110 : begin
        _zz_3_ = _zz_1_[9];
      end
      4'b0111 : begin
        _zz_3_ = _zz_1_[8];
      end
      4'b1000 : begin
        _zz_3_ = _zz_1_[7];
      end
      4'b1001 : begin
        _zz_3_ = _zz_1_[6];
      end
      4'b1010 : begin
        _zz_3_ = _zz_1_[5];
      end
      4'b1011 : begin
        _zz_3_ = _zz_1_[4];
      end
      4'b1100 : begin
        _zz_3_ = _zz_1_[3];
      end
      4'b1101 : begin
        _zz_3_ = _zz_1_[2];
      end
      4'b1110 : begin
        _zz_3_ = _zz_1_[1];
      end
      default : begin
        _zz_3_ = _zz_1_[0];
      end
    endcase
  end

  always @(*) begin
    case(_zz_10_)
      6'b000000 : begin
        _zz_4_ = _zz_2_[39];
      end
      6'b000001 : begin
        _zz_4_ = _zz_2_[38];
      end
      6'b000010 : begin
        _zz_4_ = _zz_2_[37];
      end
      6'b000011 : begin
        _zz_4_ = _zz_2_[36];
      end
      6'b000100 : begin
        _zz_4_ = _zz_2_[35];
      end
      6'b000101 : begin
        _zz_4_ = _zz_2_[34];
      end
      6'b000110 : begin
        _zz_4_ = _zz_2_[33];
      end
      6'b000111 : begin
        _zz_4_ = _zz_2_[32];
      end
      6'b001000 : begin
        _zz_4_ = _zz_2_[31];
      end
      6'b001001 : begin
        _zz_4_ = _zz_2_[30];
      end
      6'b001010 : begin
        _zz_4_ = _zz_2_[29];
      end
      6'b001011 : begin
        _zz_4_ = _zz_2_[28];
      end
      6'b001100 : begin
        _zz_4_ = _zz_2_[27];
      end
      6'b001101 : begin
        _zz_4_ = _zz_2_[26];
      end
      6'b001110 : begin
        _zz_4_ = _zz_2_[25];
      end
      6'b001111 : begin
        _zz_4_ = _zz_2_[24];
      end
      6'b010000 : begin
        _zz_4_ = _zz_2_[23];
      end
      6'b010001 : begin
        _zz_4_ = _zz_2_[22];
      end
      6'b010010 : begin
        _zz_4_ = _zz_2_[21];
      end
      6'b010011 : begin
        _zz_4_ = _zz_2_[20];
      end
      6'b010100 : begin
        _zz_4_ = _zz_2_[19];
      end
      6'b010101 : begin
        _zz_4_ = _zz_2_[18];
      end
      6'b010110 : begin
        _zz_4_ = _zz_2_[17];
      end
      6'b010111 : begin
        _zz_4_ = _zz_2_[16];
      end
      6'b011000 : begin
        _zz_4_ = _zz_2_[15];
      end
      6'b011001 : begin
        _zz_4_ = _zz_2_[14];
      end
      6'b011010 : begin
        _zz_4_ = _zz_2_[13];
      end
      6'b011011 : begin
        _zz_4_ = _zz_2_[12];
      end
      6'b011100 : begin
        _zz_4_ = _zz_2_[11];
      end
      6'b011101 : begin
        _zz_4_ = _zz_2_[10];
      end
      6'b011110 : begin
        _zz_4_ = _zz_2_[9];
      end
      6'b011111 : begin
        _zz_4_ = _zz_2_[8];
      end
      6'b100000 : begin
        _zz_4_ = _zz_2_[7];
      end
      6'b100001 : begin
        _zz_4_ = _zz_2_[6];
      end
      6'b100010 : begin
        _zz_4_ = _zz_2_[5];
      end
      6'b100011 : begin
        _zz_4_ = _zz_2_[4];
      end
      6'b100100 : begin
        _zz_4_ = _zz_2_[3];
      end
      6'b100101 : begin
        _zz_4_ = _zz_2_[2];
      end
      6'b100110 : begin
        _zz_4_ = _zz_2_[1];
      end
      default : begin
        _zz_4_ = _zz_2_[0];
      end
    endcase
  end

  always @ (*) begin
    io_bus_cmd_ready = 1'b0;
    io_flash_ss[0] = 1'b1;
    io_flash_sclk = 1'b0;
    io_flash_mosi = 1'b0;
    fsm_stateNext = fsm_stateReg;
    case(fsm_stateReg)
      `fsm_enumDefinition_defaultEncoding_fsm_SETUP : begin
        io_flash_ss[0] = 1'b0;
        io_flash_sclk = fsm_counter[0];
        io_flash_mosi = _zz_3_;
        if((fsm_counter == (7'b0011111)))begin
          fsm_stateNext = `fsm_enumDefinition_defaultEncoding_fsm_IDLE;
        end
      end
      `fsm_enumDefinition_defaultEncoding_fsm_IDLE : begin
        if(io_bus_cmd_valid)begin
          fsm_stateNext = `fsm_enumDefinition_defaultEncoding_fsm_CMD;
        end
      end
      `fsm_enumDefinition_defaultEncoding_fsm_CMD : begin
        io_flash_ss[0] = 1'b0;
        io_flash_sclk = fsm_counter[0];
        io_flash_mosi = _zz_4_;
        if((fsm_counter == (7'b1001111)))begin
          io_bus_cmd_ready = 1'b1;
          fsm_stateNext = `fsm_enumDefinition_defaultEncoding_fsm_PAYLOAD;
        end
      end
      `fsm_enumDefinition_defaultEncoding_fsm_PAYLOAD : begin
        io_flash_ss[0] = 1'b0;
        io_flash_sclk = fsm_counter[0];
        if((fsm_counter == (7'b0111111)))begin
          fsm_stateNext = `fsm_enumDefinition_defaultEncoding_fsm_IDLE;
        end
      end
      default : begin
        fsm_stateNext = `fsm_enumDefinition_defaultEncoding_fsm_SETUP;
      end
    endcase
  end

  always @ (*) begin
    buffer_counter_willIncrement = 1'b0;
    if(buffer_fill)begin
      buffer_counter_willIncrement = 1'b1;
    end
  end

  assign buffer_counter_willClear = 1'b0;
  assign buffer_counter_willOverflowIfInc = (buffer_counter_value == (5'b11111));
  assign buffer_counter_willOverflow = (buffer_counter_willOverflowIfInc && buffer_counter_willIncrement);
  always @ (*) begin
    buffer_counter_valueNext = (buffer_counter_value + _zz_6_);
    if(buffer_counter_willClear)begin
      buffer_counter_valueNext = (5'b00000);
    end
  end

  assign io_bus_rsp_valid = buffer_done;
  assign io_bus_rsp_payload_data = {buffer_buffer[7 : 0],{buffer_buffer[15 : 8],{buffer_buffer[23 : 16],buffer_buffer[31 : 24]}}};
  assign fsm_wantExit = 1'b0;
  assign _zz_1_ = (16'b1000000110000011);
  assign _zz_2_ = {{(8'b00001011),_zz_9_},(8'b00000000)};
  always @ (posedge io_clk) begin
    if(GLOBAL_BUFFER_OUTPUT) begin
      buffer_fill <= 1'b0;
      buffer_counter_value <= (5'b00000);
      buffer_done <= 1'b0;
      fsm_stateReg <= `fsm_enumDefinition_defaultEncoding_boot;
    end else begin
      buffer_fill <= 1'b0;
      buffer_counter_value <= buffer_counter_valueNext;
      buffer_done <= buffer_counter_willOverflow;
      fsm_stateReg <= fsm_stateNext;
      case(fsm_stateReg)
        `fsm_enumDefinition_defaultEncoding_fsm_SETUP : begin
        end
        `fsm_enumDefinition_defaultEncoding_fsm_IDLE : begin
        end
        `fsm_enumDefinition_defaultEncoding_fsm_CMD : begin
        end
        `fsm_enumDefinition_defaultEncoding_fsm_PAYLOAD : begin
          if((fsm_counter[0 : 0] == (1'b1)))begin
            buffer_fill <= 1'b1;
          end
        end
        default : begin
        end
      endcase
    end
  end

  always @ (posedge io_clk) begin
    if(buffer_fill)begin
      buffer_buffer <= {buffer_buffer[30 : 0],io_flash_miso};
    end
    fsm_counter <= (fsm_counter + (7'b0000001));
    if(((! (fsm_stateReg == `fsm_enumDefinition_defaultEncoding_fsm_SETUP)) && (fsm_stateNext == `fsm_enumDefinition_defaultEncoding_fsm_SETUP)))begin
      fsm_counter <= (7'b0000000);
    end
    if(((! (fsm_stateReg == `fsm_enumDefinition_defaultEncoding_fsm_CMD)) && (fsm_stateNext == `fsm_enumDefinition_defaultEncoding_fsm_CMD)))begin
      fsm_counter <= (7'b0000000);
    end
    if(((! (fsm_stateReg == `fsm_enumDefinition_defaultEncoding_fsm_PAYLOAD)) && (fsm_stateNext == `fsm_enumDefinition_defaultEncoding_fsm_PAYLOAD)))begin
      fsm_counter <= (7'b0000000);
    end
  end

endmodule

module VexRiscv (
      output  iBus_cmd_valid,
      input   iBus_cmd_ready,
      output [31:0] iBus_cmd_payload_pc,
      input   iBus_rsp_valid,
      input   iBus_rsp_payload_error,
      input  [31:0] iBus_rsp_payload_inst,
      input   timerInterrupt,
      input   externalInterrupt,
      output  dBus_cmd_valid,
      input   dBus_cmd_ready,
      output  dBus_cmd_payload_wr,
      output [31:0] dBus_cmd_payload_address,
      output [31:0] dBus_cmd_payload_data,
      output [1:0] dBus_cmd_payload_size,
      input   dBus_rsp_ready,
      input   dBus_rsp_error,
      input  [31:0] dBus_rsp_data,
      input   io_clk,
      input   GLOBAL_BUFFER_OUTPUT);
  wire  _zz_206_;
  wire  _zz_207_;
  reg [1:0] _zz_208_;
  reg [31:0] _zz_209_;
  reg [31:0] _zz_210_;
  reg [31:0] _zz_211_;
  wire  _zz_212_;
  wire  _zz_213_;
  wire  _zz_214_;
  wire [31:0] _zz_215_;
  wire [1:0] _zz_216_;
  wire  _zz_217_;
  wire  _zz_218_;
  wire  _zz_219_;
  wire  _zz_220_;
  wire  _zz_221_;
  wire  _zz_222_;
  wire  _zz_223_;
  wire  _zz_224_;
  wire [1:0] _zz_225_;
  wire [1:0] _zz_226_;
  wire  _zz_227_;
  wire [2:0] _zz_228_;
  wire [2:0] _zz_229_;
  wire [31:0] _zz_230_;
  wire [1:0] _zz_231_;
  wire [1:0] _zz_232_;
  wire [1:0] _zz_233_;
  wire [1:0] _zz_234_;
  wire [7:0] _zz_235_;
  wire [29:0] _zz_236_;
  wire [7:0] _zz_237_;
  wire [1:0] _zz_238_;
  wire [1:0] _zz_239_;
  wire [1:0] _zz_240_;
  wire [19:0] _zz_241_;
  wire [11:0] _zz_242_;
  wire [2:0] _zz_243_;
  wire [0:0] _zz_244_;
  wire [2:0] _zz_245_;
  wire [0:0] _zz_246_;
  wire [2:0] _zz_247_;
  wire [0:0] _zz_248_;
  wire [2:0] _zz_249_;
  wire [2:0] _zz_250_;
  wire [0:0] _zz_251_;
  wire [2:0] _zz_252_;
  wire [0:0] _zz_253_;
  wire [2:0] _zz_254_;
  wire [2:0] _zz_255_;
  wire [0:0] _zz_256_;
  wire [0:0] _zz_257_;
  wire [0:0] _zz_258_;
  wire [0:0] _zz_259_;
  wire [0:0] _zz_260_;
  wire [0:0] _zz_261_;
  wire [0:0] _zz_262_;
  wire [0:0] _zz_263_;
  wire [0:0] _zz_264_;
  wire [0:0] _zz_265_;
  wire [0:0] _zz_266_;
  wire [0:0] _zz_267_;
  wire [0:0] _zz_268_;
  wire [0:0] _zz_269_;
  wire [0:0] _zz_270_;
  wire [3:0] _zz_271_;
  wire [36:0] _zz_272_;
  wire [36:0] _zz_273_;
  wire [36:0] _zz_274_;
  wire [32:0] _zz_275_;
  wire [36:0] _zz_276_;
  wire [33:0] _zz_277_;
  wire [36:0] _zz_278_;
  wire [33:0] _zz_279_;
  wire [36:0] _zz_280_;
  wire [34:0] _zz_281_;
  wire [36:0] _zz_282_;
  wire [34:0] _zz_283_;
  wire [35:0] _zz_284_;
  wire [36:0] _zz_285_;
  wire [35:0] _zz_286_;
  wire [32:0] _zz_287_;
  wire [36:0] _zz_288_;
  wire [32:0] _zz_289_;
  wire [0:0] _zz_290_;
  wire [5:0] _zz_291_;
  wire [32:0] _zz_292_;
  wire [32:0] _zz_293_;
  wire [31:0] _zz_294_;
  wire [31:0] _zz_295_;
  wire [32:0] _zz_296_;
  wire [32:0] _zz_297_;
  wire [32:0] _zz_298_;
  wire [0:0] _zz_299_;
  wire [32:0] _zz_300_;
  wire [0:0] _zz_301_;
  wire [32:0] _zz_302_;
  wire [0:0] _zz_303_;
  wire [31:0] _zz_304_;
  wire [0:0] _zz_305_;
  wire [2:0] _zz_306_;
  wire [4:0] _zz_307_;
  wire [11:0] _zz_308_;
  wire [11:0] _zz_309_;
  wire [31:0] _zz_310_;
  wire [31:0] _zz_311_;
  wire [32:0] _zz_312_;
  wire [31:0] _zz_313_;
  wire [32:0] _zz_314_;
  wire [11:0] _zz_315_;
  wire [19:0] _zz_316_;
  wire [11:0] _zz_317_;
  wire [31:0] _zz_318_;
  wire [31:0] _zz_319_;
  wire [31:0] _zz_320_;
  wire [11:0] _zz_321_;
  wire [19:0] _zz_322_;
  wire [11:0] _zz_323_;
  wire [2:0] _zz_324_;
  wire [0:0] _zz_325_;
  wire [0:0] _zz_326_;
  wire [0:0] _zz_327_;
  wire [0:0] _zz_328_;
  wire [0:0] _zz_329_;
  wire [0:0] _zz_330_;
  wire [1:0] _zz_331_;
  wire  _zz_332_;
  wire  _zz_333_;
  wire [1:0] _zz_334_;
  wire [0:0] _zz_335_;
  wire [7:0] _zz_336_;
  wire  _zz_337_;
  wire [0:0] _zz_338_;
  wire [0:0] _zz_339_;
  wire [31:0] _zz_340_;
  wire [31:0] _zz_341_;
  wire [31:0] _zz_342_;
  wire [31:0] _zz_343_;
  wire [31:0] _zz_344_;
  wire [31:0] _zz_345_;
  wire [0:0] _zz_346_;
  wire [0:0] _zz_347_;
  wire [1:0] _zz_348_;
  wire [1:0] _zz_349_;
  wire  _zz_350_;
  wire [0:0] _zz_351_;
  wire [22:0] _zz_352_;
  wire [31:0] _zz_353_;
  wire [31:0] _zz_354_;
  wire [31:0] _zz_355_;
  wire  _zz_356_;
  wire [0:0] _zz_357_;
  wire [3:0] _zz_358_;
  wire [0:0] _zz_359_;
  wire [1:0] _zz_360_;
  wire [0:0] _zz_361_;
  wire [0:0] _zz_362_;
  wire  _zz_363_;
  wire [0:0] _zz_364_;
  wire [19:0] _zz_365_;
  wire [31:0] _zz_366_;
  wire [31:0] _zz_367_;
  wire [31:0] _zz_368_;
  wire  _zz_369_;
  wire [0:0] _zz_370_;
  wire [0:0] _zz_371_;
  wire [31:0] _zz_372_;
  wire [31:0] _zz_373_;
  wire [31:0] _zz_374_;
  wire  _zz_375_;
  wire [1:0] _zz_376_;
  wire [1:0] _zz_377_;
  wire  _zz_378_;
  wire [0:0] _zz_379_;
  wire [16:0] _zz_380_;
  wire [31:0] _zz_381_;
  wire [31:0] _zz_382_;
  wire [31:0] _zz_383_;
  wire [31:0] _zz_384_;
  wire [31:0] _zz_385_;
  wire [31:0] _zz_386_;
  wire [0:0] _zz_387_;
  wire [2:0] _zz_388_;
  wire [0:0] _zz_389_;
  wire [0:0] _zz_390_;
  wire [1:0] _zz_391_;
  wire [1:0] _zz_392_;
  wire  _zz_393_;
  wire [0:0] _zz_394_;
  wire [13:0] _zz_395_;
  wire [31:0] _zz_396_;
  wire [31:0] _zz_397_;
  wire [31:0] _zz_398_;
  wire  _zz_399_;
  wire  _zz_400_;
  wire [31:0] _zz_401_;
  wire  _zz_402_;
  wire  _zz_403_;
  wire [0:0] _zz_404_;
  wire [0:0] _zz_405_;
  wire [1:0] _zz_406_;
  wire [1:0] _zz_407_;
  wire  _zz_408_;
  wire [0:0] _zz_409_;
  wire [10:0] _zz_410_;
  wire [31:0] _zz_411_;
  wire [31:0] _zz_412_;
  wire [31:0] _zz_413_;
  wire [31:0] _zz_414_;
  wire [0:0] _zz_415_;
  wire [2:0] _zz_416_;
  wire [1:0] _zz_417_;
  wire [1:0] _zz_418_;
  wire  _zz_419_;
  wire [0:0] _zz_420_;
  wire [7:0] _zz_421_;
  wire [31:0] _zz_422_;
  wire [31:0] _zz_423_;
  wire [31:0] _zz_424_;
  wire  _zz_425_;
  wire  _zz_426_;
  wire  _zz_427_;
  wire [1:0] _zz_428_;
  wire [1:0] _zz_429_;
  wire  _zz_430_;
  wire [0:0] _zz_431_;
  wire [4:0] _zz_432_;
  wire [31:0] _zz_433_;
  wire [31:0] _zz_434_;
  wire [31:0] _zz_435_;
  wire [31:0] _zz_436_;
  wire  _zz_437_;
  wire  _zz_438_;
  wire [0:0] _zz_439_;
  wire [1:0] _zz_440_;
  wire [2:0] _zz_441_;
  wire [2:0] _zz_442_;
  wire  _zz_443_;
  wire [0:0] _zz_444_;
  wire [1:0] _zz_445_;
  wire [31:0] _zz_446_;
  wire [31:0] _zz_447_;
  wire [31:0] _zz_448_;
  wire [31:0] _zz_449_;
  wire [31:0] _zz_450_;
  wire [31:0] _zz_451_;
  wire [31:0] _zz_452_;
  wire  _zz_453_;
  wire  _zz_454_;
  wire [31:0] _zz_455_;
  wire [31:0] _zz_456_;
  wire [0:0] _zz_457_;
  wire [0:0] _zz_458_;
  wire [2:0] _zz_459_;
  wire [2:0] _zz_460_;
  wire [0:0] _zz_461_;
  wire [0:0] _zz_462_;
  wire [31:0] _zz_463_;
  wire [31:0] _zz_464_;
  wire [31:0] _zz_465_;
  wire [31:0] _zz_466_;
  wire [31:0] _zz_467_;
  wire  _zz_468_;
  wire  _zz_469_;
  wire  _zz_470_;
  wire  decode_IS_MUL;
  wire  decode_PREDICTION_HAD_BRANCHED2;
  wire  decode_SRC_USE_SUB_LESS;
  wire  decode_IS_RS2_SIGNED;
  wire [31:0] writeBack_FORMAL_PC_NEXT;
  wire [31:0] memory_FORMAL_PC_NEXT;
  wire [31:0] execute_FORMAL_PC_NEXT;
  wire [31:0] decode_FORMAL_PC_NEXT;
  wire [1:0] memory_MEMORY_ADDRESS_LOW;
  wire  execute_BYPASSABLE_MEMORY_STAGE;
  wire  decode_BYPASSABLE_MEMORY_STAGE;
  wire [31:0] execute_BRANCH_CALC;
  wire  execute_BRANCH_DO;
  wire  execute_MEMORY_ENABLE;
  wire  decode_MEMORY_ENABLE;
  wire  execute_PREDICTION_CONTEXT_hazard;
  wire [1:0] execute_PREDICTION_CONTEXT_line_history;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_1_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_2_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_3_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_4_;
  wire `EnvCtrlEnum_defaultEncoding_type decode_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_5_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_6_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_7_;
  wire  decode_IS_RS1_SIGNED;
  wire `AluCtrlEnum_defaultEncoding_type decode_ALU_CTRL;
  wire `AluCtrlEnum_defaultEncoding_type _zz_8_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_9_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_10_;
  wire  decode_CSR_WRITE_OPCODE;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_11_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_12_;
  wire `ShiftCtrlEnum_defaultEncoding_type decode_SHIFT_CTRL;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_13_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_14_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_15_;
  wire  decode_IS_CSR;
  wire  decode_IS_DIV;
  wire [31:0] execute_SHIFT_RIGHT;
  wire  decode_CSR_READ_OPCODE;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_16_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_17_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_18_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_19_;
  wire [31:0] memory_REGFILE_WRITE_DATA;
  wire [31:0] execute_REGFILE_WRITE_DATA;
  wire [31:0] decode_SRC2;
  wire  decode_BYPASSABLE_EXECUTE_STAGE;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type decode_ALU_BITWISE_CTRL;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_20_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_21_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_22_;
  wire [31:0] decode_SRC1;
  wire  decode_SRC_LESS_UNSIGNED;
  wire [31:0] execute_SRC_ADD;
  wire  execute_IS_FENCEI;
  reg [31:0] _zz_23_;
  wire [31:0] memory_BRANCH_CALC;
  wire  memory_BRANCH_DO;
  wire [31:0] _zz_24_;
  wire [31:0] execute_PC;
  wire  execute_PREDICTION_HAD_BRANCHED2;
  wire  _zz_25_;
  wire  execute_BRANCH_COND_RESULT;
  wire `BranchCtrlEnum_defaultEncoding_type execute_BRANCH_CTRL;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_26_;
  wire  _zz_27_;
  wire  decode_IS_FENCEI;
  wire  _zz_28_;
  wire  decode_RS2_USE;
  wire  decode_RS1_USE;
  wire  execute_REGFILE_WRITE_VALID;
  wire  execute_BYPASSABLE_EXECUTE_STAGE;
  wire  memory_REGFILE_WRITE_VALID;
  wire  memory_BYPASSABLE_MEMORY_STAGE;
  wire  writeBack_REGFILE_WRITE_VALID;
  reg [31:0] decode_RS2;
  reg [31:0] decode_RS1;
  wire [31:0] memory_SHIFT_RIGHT;
  wire `ShiftCtrlEnum_defaultEncoding_type memory_SHIFT_CTRL;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_29_;
  wire [31:0] _zz_30_;
  wire `ShiftCtrlEnum_defaultEncoding_type execute_SHIFT_CTRL;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_31_;
  wire  _zz_32_;
  wire [31:0] _zz_33_;
  wire  execute_SRC_USE_SUB_LESS;
  wire [31:0] _zz_34_;
  wire  execute_SRC_LESS_UNSIGNED;
  wire [31:0] _zz_35_;
  wire [31:0] _zz_36_;
  wire `Src2CtrlEnum_defaultEncoding_type decode_SRC2_CTRL;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_37_;
  wire [31:0] _zz_38_;
  wire [31:0] _zz_39_;
  wire `Src1CtrlEnum_defaultEncoding_type decode_SRC1_CTRL;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_40_;
  wire [31:0] _zz_41_;
  wire [31:0] execute_SRC_ADD_SUB;
  wire  execute_SRC_LESS;
  wire `AluCtrlEnum_defaultEncoding_type execute_ALU_CTRL;
  wire `AluCtrlEnum_defaultEncoding_type _zz_42_;
  wire [31:0] _zz_43_;
  wire [31:0] execute_SRC2;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type execute_ALU_BITWISE_CTRL;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_44_;
  wire  execute_IS_RS1_SIGNED;
  wire [31:0] execute_RS1;
  wire  execute_IS_DIV;
  wire  execute_IS_MUL;
  wire  execute_IS_RS2_SIGNED;
  wire [31:0] execute_RS2;
  wire  memory_IS_DIV;
  reg [31:0] _zz_45_;
  wire  memory_IS_MUL;
  wire [31:0] _zz_46_;
  wire  _zz_47_;
  reg  _zz_48_;
  wire [31:0] _zz_49_;
  wire [31:0] _zz_50_;
  wire [31:0] decode_INSTRUCTION_ANTICIPATED;
  reg  decode_REGFILE_WRITE_VALID;
  wire `AluCtrlEnum_defaultEncoding_type _zz_51_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_52_;
  wire  _zz_53_;
  wire  _zz_54_;
  wire  _zz_55_;
  wire  _zz_56_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_57_;
  wire  _zz_58_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_59_;
  wire  _zz_60_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_61_;
  wire  _zz_62_;
  wire  _zz_63_;
  wire  _zz_64_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_65_;
  wire  _zz_66_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_67_;
  wire  _zz_68_;
  wire  _zz_69_;
  wire  _zz_70_;
  wire  _zz_71_;
  reg [31:0] _zz_72_;
  wire [31:0] execute_SRC1;
  wire  execute_CSR_READ_OPCODE;
  wire  execute_CSR_WRITE_OPCODE;
  wire [31:0] execute_INSTRUCTION;
  wire  execute_IS_CSR;
  wire `EnvCtrlEnum_defaultEncoding_type memory_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_73_;
  wire `EnvCtrlEnum_defaultEncoding_type execute_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_74_;
  wire  _zz_75_;
  wire  _zz_76_;
  wire `EnvCtrlEnum_defaultEncoding_type writeBack_ENV_CTRL;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_77_;
  reg [31:0] _zz_78_;
  wire [1:0] writeBack_MEMORY_ADDRESS_LOW;
  wire [31:0] writeBack_MEMORY_READ_DATA;
  wire [31:0] writeBack_REGFILE_WRITE_DATA;
  wire  writeBack_ALIGNEMENT_FAULT;
  wire  writeBack_MEMORY_ENABLE;
  wire [31:0] _zz_79_;
  wire [1:0] _zz_80_;
  wire [31:0] memory_RS2;
  wire [31:0] memory_SRC_ADD;
  wire [31:0] memory_INSTRUCTION;
  wire  memory_ALIGNEMENT_FAULT;
  wire  memory_MEMORY_ENABLE;
  wire  _zz_81_;
  wire `BranchCtrlEnum_defaultEncoding_type decode_BRANCH_CTRL;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_82_;
  wire `BranchCtrlEnum_defaultEncoding_type memory_BRANCH_CTRL;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_83_;
  wire [31:0] memory_PC;
  wire  memory_PREDICTION_CONTEXT_hazard;
  wire [1:0] memory_PREDICTION_CONTEXT_line_history;
  wire  decode_PREDICTION_CONTEXT_hazard;
  wire [1:0] decode_PREDICTION_CONTEXT_line_history;
  wire  _zz_84_;
  wire [1:0] _zz_85_;
  reg  _zz_86_;
  reg [31:0] _zz_87_;
  reg [31:0] _zz_88_;
  wire [31:0] _zz_89_;
  wire [31:0] _zz_90_;
  wire [31:0] _zz_91_;
  wire [31:0] _zz_92_;
  wire [31:0] writeBack_PC /* verilator public */ ;
  wire [31:0] writeBack_INSTRUCTION /* verilator public */ ;
  wire [31:0] decode_PC /* verilator public */ ;
  wire [31:0] decode_INSTRUCTION /* verilator public */ ;
  reg  decode_arbitration_haltItself /* verilator public */ ;
  reg  decode_arbitration_haltByOther;
  reg  decode_arbitration_removeIt;
  reg  decode_arbitration_flushAll /* verilator public */ ;
  wire  decode_arbitration_redoIt;
  wire  decode_arbitration_isValid /* verilator public */ ;
  wire  decode_arbitration_isStuck;
  wire  decode_arbitration_isStuckByOthers;
  wire  decode_arbitration_isFlushed;
  wire  decode_arbitration_isMoving;
  wire  decode_arbitration_isFiring;
  reg  execute_arbitration_haltItself;
  reg  execute_arbitration_haltByOther;
  reg  execute_arbitration_removeIt;
  reg  execute_arbitration_flushAll;
  wire  execute_arbitration_redoIt;
  reg  execute_arbitration_isValid;
  wire  execute_arbitration_isStuck;
  wire  execute_arbitration_isStuckByOthers;
  wire  execute_arbitration_isFlushed;
  wire  execute_arbitration_isMoving;
  wire  execute_arbitration_isFiring;
  reg  memory_arbitration_haltItself;
  wire  memory_arbitration_haltByOther;
  reg  memory_arbitration_removeIt;
  reg  memory_arbitration_flushAll;
  wire  memory_arbitration_redoIt;
  reg  memory_arbitration_isValid;
  wire  memory_arbitration_isStuck;
  wire  memory_arbitration_isStuckByOthers;
  wire  memory_arbitration_isFlushed;
  wire  memory_arbitration_isMoving;
  wire  memory_arbitration_isFiring;
  reg  writeBack_arbitration_haltItself;
  wire  writeBack_arbitration_haltByOther;
  reg  writeBack_arbitration_removeIt;
  wire  writeBack_arbitration_flushAll;
  wire  writeBack_arbitration_redoIt;
  reg  writeBack_arbitration_isValid /* verilator public */ ;
  wire  writeBack_arbitration_isStuck;
  wire  writeBack_arbitration_isStuckByOthers;
  wire  writeBack_arbitration_isFlushed;
  wire  writeBack_arbitration_isMoving;
  wire  writeBack_arbitration_isFiring /* verilator public */ ;
  reg  _zz_93_;
  wire  _zz_94_;
  wire  _zz_95_;
  wire [31:0] _zz_96_;
  wire  _zz_97_;
  reg  writeBack_exception_agregat_valid;
  wire [3:0] writeBack_exception_agregat_payload_code;
  wire [31:0] writeBack_exception_agregat_payload_badAddr;
  reg  _zz_98_;
  reg [31:0] _zz_99_;
  wire  contextSwitching;
  reg [1:0] CsrPlugin_privilege;
  reg  execute_exception_agregat_valid;
  reg [3:0] execute_exception_agregat_payload_code;
  wire [31:0] execute_exception_agregat_payload_badAddr;
  wire  _zz_100_;
  wire [31:0] _zz_101_;
  wire  memory_exception_agregat_valid;
  wire [3:0] memory_exception_agregat_payload_code;
  wire [31:0] memory_exception_agregat_payload_badAddr;
  wire  IBusSimplePlugin_jump_pcLoad_valid;
  wire [31:0] IBusSimplePlugin_jump_pcLoad_payload;
  wire [2:0] _zz_102_;
  wire [2:0] _zz_103_;
  wire  _zz_104_;
  wire  _zz_105_;
  wire  IBusSimplePlugin_fetchPc_preOutput_valid;
  wire  IBusSimplePlugin_fetchPc_preOutput_ready;
  wire [31:0] IBusSimplePlugin_fetchPc_preOutput_payload;
  wire  _zz_106_;
  wire  IBusSimplePlugin_fetchPc_output_valid;
  wire  IBusSimplePlugin_fetchPc_output_ready;
  wire [31:0] IBusSimplePlugin_fetchPc_output_payload;
  reg [31:0] IBusSimplePlugin_fetchPc_pcReg /* verilator public */ ;
  reg  IBusSimplePlugin_fetchPc_inc;
  wire  IBusSimplePlugin_fetchPc_propagatePc;
  reg [31:0] IBusSimplePlugin_fetchPc_pc;
  reg  IBusSimplePlugin_fetchPc_samplePcNext;
  reg  _zz_107_;
  wire  IBusSimplePlugin_iBusRsp_stages_0_input_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_0_input_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_0_input_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_0_output_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_0_output_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_0_output_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_0_halt;
  wire  IBusSimplePlugin_iBusRsp_stages_0_inputSample;
  wire  IBusSimplePlugin_iBusRsp_stages_1_input_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_1_input_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_1_input_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_1_output_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_1_output_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_1_output_payload;
  reg  IBusSimplePlugin_iBusRsp_stages_1_halt;
  wire  IBusSimplePlugin_iBusRsp_stages_1_inputSample;
  wire  IBusSimplePlugin_iBusRsp_stages_2_input_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_2_input_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_2_input_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_2_output_valid;
  wire  IBusSimplePlugin_iBusRsp_stages_2_output_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_stages_2_output_payload;
  wire  IBusSimplePlugin_iBusRsp_stages_2_halt;
  wire  IBusSimplePlugin_iBusRsp_stages_2_inputSample;
  wire  _zz_108_;
  wire  _zz_109_;
  wire  _zz_110_;
  wire  _zz_111_;
  reg  _zz_112_;
  reg [31:0] _zz_113_;
  wire  _zz_114_;
  reg  _zz_115_;
  reg [31:0] _zz_116_;
  reg  IBusSimplePlugin_iBusRsp_readyForError;
  wire  IBusSimplePlugin_iBusRsp_inputBeforeStage_valid;
  wire  IBusSimplePlugin_iBusRsp_inputBeforeStage_ready;
  wire [31:0] IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_pc;
  wire  IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_error;
  wire [31:0] IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_raw;
  wire  IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_isRvc;
  wire  IBusSimplePlugin_injector_decodeInput_valid;
  wire  IBusSimplePlugin_injector_decodeInput_ready;
  wire [31:0] IBusSimplePlugin_injector_decodeInput_payload_pc;
  wire  IBusSimplePlugin_injector_decodeInput_payload_rsp_error;
  wire [31:0] IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
  wire  IBusSimplePlugin_injector_decodeInput_payload_isRvc;
  reg  _zz_117_;
  reg [31:0] _zz_118_;
  reg  _zz_119_;
  reg [31:0] _zz_120_;
  reg  _zz_121_;
  reg  IBusSimplePlugin_injector_nextPcCalc_valids_0;
  reg  IBusSimplePlugin_injector_nextPcCalc_valids_1;
  reg  IBusSimplePlugin_injector_nextPcCalc_0;
  reg  IBusSimplePlugin_injector_nextPcCalc_1;
  reg  IBusSimplePlugin_injector_nextPcCalc_2;
  reg  IBusSimplePlugin_injector_nextPcCalc_3;
  reg  IBusSimplePlugin_injector_decodeRemoved;
  reg [31:0] IBusSimplePlugin_injector_formal_rawInDecode;
  wire  _zz_123_;
  wire [7:0] _zz_124_;
  reg  _zz_125_;
  reg [7:0] _zz_126_;
  wire [29:0] _zz_127_;
  wire  _zz_128_;
  reg  _zz_129_;
  reg [1:0] _zz_130_;
  reg  _zz_131_;
  reg [1:0] _zz_132_;
  wire  _zz_133_;
  wire  _zz_134_;
  reg [10:0] _zz_135_;
  wire  _zz_136_;
  reg [18:0] _zz_137_;
  wire  IBusSimplePlugin_cmd_valid;
  wire  IBusSimplePlugin_cmd_ready;
  wire [31:0] IBusSimplePlugin_cmd_payload_pc;
  reg [2:0] IBusSimplePlugin_pendingCmd;
  wire [2:0] IBusSimplePlugin_pendingCmdNext;
  wire  IBusSimplePlugin_cmdFork_pendingFull;
  reg  IBusSimplePlugin_cmdFork_cmdKeep;
  reg  IBusSimplePlugin_cmdFork_cmdFired;
  reg [2:0] IBusSimplePlugin_rspJoin_discardCounter;
  wire  IBusSimplePlugin_rspJoin_rspBufferOutput_valid;
  wire  IBusSimplePlugin_rspJoin_rspBufferOutput_ready;
  wire  IBusSimplePlugin_rspJoin_rspBufferOutput_payload_error;
  wire [31:0] IBusSimplePlugin_rspJoin_rspBufferOutput_payload_inst;
  wire [31:0] IBusSimplePlugin_rspJoin_fetchRsp_pc;
  reg  IBusSimplePlugin_rspJoin_fetchRsp_rsp_error;
  wire [31:0] IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst;
  wire  IBusSimplePlugin_rspJoin_fetchRsp_isRvc;
  wire  IBusSimplePlugin_rspJoin_issueDetected;
  wire  IBusSimplePlugin_rspJoin_join_valid;
  wire  IBusSimplePlugin_rspJoin_join_ready;
  wire [31:0] IBusSimplePlugin_rspJoin_join_payload_pc;
  wire  IBusSimplePlugin_rspJoin_join_payload_rsp_error;
  wire [31:0] IBusSimplePlugin_rspJoin_join_payload_rsp_inst;
  wire  IBusSimplePlugin_rspJoin_join_payload_isRvc;
  wire  _zz_138_;
  reg [31:0] _zz_139_;
  reg [3:0] _zz_140_;
  wire [3:0] memory_DBusSimplePlugin_formalMask;
  reg [31:0] writeBack_DBusSimplePlugin_rspShifted;
  wire  _zz_141_;
  reg [31:0] _zz_142_;
  wire  _zz_143_;
  reg [31:0] _zz_144_;
  reg [31:0] writeBack_DBusSimplePlugin_rspFormated;
  wire [1:0] CsrPlugin_misa_base;
  wire [25:0] CsrPlugin_misa_extensions;
  reg [1:0] CsrPlugin_mtvec_mode;
  reg [29:0] CsrPlugin_mtvec_base;
  reg [31:0] CsrPlugin_mepc;
  reg  CsrPlugin_mstatus_MIE;
  reg  CsrPlugin_mstatus_MPIE;
  reg [1:0] CsrPlugin_mstatus_MPP;
  reg  CsrPlugin_mip_MEIP;
  reg  CsrPlugin_mip_MTIP;
  reg  CsrPlugin_mip_MSIP;
  reg  CsrPlugin_mie_MEIE;
  reg  CsrPlugin_mie_MTIE;
  reg  CsrPlugin_mie_MSIE;
  reg [31:0] CsrPlugin_mscratch;
  reg  CsrPlugin_mcause_interrupt;
  reg [3:0] CsrPlugin_mcause_exceptionCode;
  reg [31:0] CsrPlugin_mtval;
  reg [63:0] CsrPlugin_mcycle = 64'b0000000000000000000000000000000000000000000000000000000000000000;
  reg [63:0] CsrPlugin_minstret = 64'b0000000000000000000000000000000000000000000000000000000000000000;
  wire [31:0] CsrPlugin_medeleg;
  wire [31:0] CsrPlugin_mideleg;
  wire  _zz_145_;
  wire  _zz_146_;
  wire  _zz_147_;
  wire  CsrPlugin_exceptionPortCtrl_exceptionValids_decode;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValids_memory;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack;
  wire  CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
  reg  CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
  reg [3:0] CsrPlugin_exceptionPortCtrl_exceptionContext_code;
  reg [31:0] CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
  wire [1:0] CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
  reg  CsrPlugin_interrupt;
  reg [3:0] CsrPlugin_interruptCode /* verilator public */ ;
  reg [1:0] CsrPlugin_interruptTargetPrivilege;
  wire  CsrPlugin_exception;
  wire  CsrPlugin_writeBackWasWfi;
  reg  CsrPlugin_pipelineLiberator_done;
  wire  CsrPlugin_interruptJump /* verilator public */ ;
  reg  CsrPlugin_hadException;
  reg [1:0] CsrPlugin_targetPrivilege;
  reg [3:0] CsrPlugin_trapCause;
  wire  execute_CsrPlugin_blockedBySideEffects;
  reg  execute_CsrPlugin_illegalAccess;
  reg  execute_CsrPlugin_illegalInstruction;
  reg [31:0] execute_CsrPlugin_readData;
  wire  execute_CsrPlugin_writeInstruction;
  wire  execute_CsrPlugin_readInstruction;
  wire  execute_CsrPlugin_writeEnable;
  wire  execute_CsrPlugin_readEnable;
  reg [31:0] execute_CsrPlugin_writeData;
  wire [11:0] execute_CsrPlugin_csrAddress;
  wire [28:0] _zz_148_;
  wire  _zz_149_;
  wire  _zz_150_;
  wire  _zz_151_;
  wire  _zz_152_;
  wire  _zz_153_;
  wire  _zz_154_;
  wire `ShiftCtrlEnum_defaultEncoding_type _zz_155_;
  wire `BranchCtrlEnum_defaultEncoding_type _zz_156_;
  wire `Src1CtrlEnum_defaultEncoding_type _zz_157_;
  wire `AluBitwiseCtrlEnum_defaultEncoding_type _zz_158_;
  wire `EnvCtrlEnum_defaultEncoding_type _zz_159_;
  wire `Src2CtrlEnum_defaultEncoding_type _zz_160_;
  wire `AluCtrlEnum_defaultEncoding_type _zz_161_;
  wire [4:0] decode_RegFilePlugin_regFileReadAddress1;
  wire [4:0] decode_RegFilePlugin_regFileReadAddress2;
  wire [31:0] decode_RegFilePlugin_rs1Data;
  wire [31:0] decode_RegFilePlugin_rs2Data;
  reg  writeBack_RegFilePlugin_regFileWrite_valid /* verilator public */ ;
  wire [4:0] writeBack_RegFilePlugin_regFileWrite_payload_address /* verilator public */ ;
  wire [31:0] writeBack_RegFilePlugin_regFileWrite_payload_data /* verilator public */ ;
  reg  _zz_162_;
  reg [32:0] memory_MulDivIterativePlugin_rs1;
  reg [31:0] memory_MulDivIterativePlugin_rs2;
  reg [64:0] memory_MulDivIterativePlugin_accumulator;
  reg  memory_MulDivIterativePlugin_mul_counter_willIncrement;
  reg  memory_MulDivIterativePlugin_mul_counter_willClear;
  reg [3:0] memory_MulDivIterativePlugin_mul_counter_valueNext;
  reg [3:0] memory_MulDivIterativePlugin_mul_counter_value;
  wire  memory_MulDivIterativePlugin_mul_willOverflowIfInc;
  wire  memory_MulDivIterativePlugin_mul_counter_willOverflow;
  reg  memory_MulDivIterativePlugin_div_needRevert;
  reg  memory_MulDivIterativePlugin_div_counter_willIncrement;
  reg  memory_MulDivIterativePlugin_div_counter_willClear;
  reg [5:0] memory_MulDivIterativePlugin_div_counter_valueNext;
  reg [5:0] memory_MulDivIterativePlugin_div_counter_value;
  wire  memory_MulDivIterativePlugin_div_counter_willOverflowIfInc;
  wire  memory_MulDivIterativePlugin_div_counter_willOverflow;
  reg  memory_MulDivIterativePlugin_div_done;
  reg [31:0] memory_MulDivIterativePlugin_div_result;
  wire [31:0] _zz_163_;
  wire [32:0] _zz_164_;
  wire [32:0] _zz_165_;
  wire [31:0] _zz_166_;
  wire  _zz_167_;
  wire  _zz_168_;
  reg [32:0] _zz_169_;
  reg [31:0] execute_IntAluPlugin_bitwise;
  reg [31:0] _zz_170_;
  reg [31:0] _zz_171_;
  wire  _zz_172_;
  reg [19:0] _zz_173_;
  wire  _zz_174_;
  reg [19:0] _zz_175_;
  reg [31:0] _zz_176_;
  (* keep *) wire [31:0] execute_SrcPlugin_add;
  (* keep *) wire [31:0] execute_SrcPlugin_sub;
  wire  execute_SrcPlugin_less;
  wire [4:0] execute_FullBarrelShifterPlugin_amplitude;
  reg [31:0] _zz_177_;
  wire [31:0] execute_FullBarrelShifterPlugin_reversed;
  reg [31:0] _zz_178_;
  reg  _zz_179_;
  reg  _zz_180_;
  reg  _zz_181_;
  reg [4:0] _zz_182_;
  reg [31:0] _zz_183_;
  wire  _zz_184_;
  wire  _zz_185_;
  wire  _zz_186_;
  wire  _zz_187_;
  wire  _zz_188_;
  wire  _zz_189_;
  wire  execute_BranchPlugin_eq;
  wire [2:0] _zz_190_;
  reg  _zz_191_;
  reg  _zz_192_;
  wire  _zz_193_;
  reg [19:0] _zz_194_;
  wire  _zz_195_;
  reg [10:0] _zz_196_;
  wire  _zz_197_;
  reg [18:0] _zz_198_;
  reg  _zz_199_;
  wire  execute_BranchPlugin_missAlignedTarget;
  reg [31:0] execute_BranchPlugin_branch_src1;
  reg [31:0] execute_BranchPlugin_branch_src2;
  wire  _zz_200_;
  reg [19:0] _zz_201_;
  wire  _zz_202_;
  reg [10:0] _zz_203_;
  wire  _zz_204_;
  reg [18:0] _zz_205_;
  wire [31:0] execute_BranchPlugin_branchAdder;
  reg  decode_to_execute_IS_FENCEI;
  reg [31:0] execute_to_memory_SRC_ADD;
  reg  decode_to_execute_SRC_LESS_UNSIGNED;
  reg [31:0] decode_to_execute_SRC1;
  reg `AluBitwiseCtrlEnum_defaultEncoding_type decode_to_execute_ALU_BITWISE_CTRL;
  reg  decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
  reg [31:0] decode_to_execute_SRC2;
  reg [31:0] execute_to_memory_REGFILE_WRITE_DATA;
  reg [31:0] memory_to_writeBack_REGFILE_WRITE_DATA;
  reg `BranchCtrlEnum_defaultEncoding_type decode_to_execute_BRANCH_CTRL;
  reg `BranchCtrlEnum_defaultEncoding_type execute_to_memory_BRANCH_CTRL;
  reg  decode_to_execute_CSR_READ_OPCODE;
  reg [31:0] decode_to_execute_INSTRUCTION;
  reg [31:0] execute_to_memory_INSTRUCTION;
  reg [31:0] memory_to_writeBack_INSTRUCTION;
  reg [31:0] execute_to_memory_SHIFT_RIGHT;
  reg  decode_to_execute_IS_DIV;
  reg  execute_to_memory_IS_DIV;
  reg  decode_to_execute_IS_CSR;
  reg `ShiftCtrlEnum_defaultEncoding_type decode_to_execute_SHIFT_CTRL;
  reg `ShiftCtrlEnum_defaultEncoding_type execute_to_memory_SHIFT_CTRL;
  reg [31:0] decode_to_execute_RS1;
  reg  decode_to_execute_REGFILE_WRITE_VALID;
  reg  execute_to_memory_REGFILE_WRITE_VALID;
  reg  memory_to_writeBack_REGFILE_WRITE_VALID;
  reg  decode_to_execute_CSR_WRITE_OPCODE;
  reg `AluCtrlEnum_defaultEncoding_type decode_to_execute_ALU_CTRL;
  reg  decode_to_execute_IS_RS1_SIGNED;
  reg `EnvCtrlEnum_defaultEncoding_type decode_to_execute_ENV_CTRL;
  reg `EnvCtrlEnum_defaultEncoding_type execute_to_memory_ENV_CTRL;
  reg `EnvCtrlEnum_defaultEncoding_type memory_to_writeBack_ENV_CTRL;
  reg [31:0] decode_to_execute_PC;
  reg [31:0] execute_to_memory_PC;
  reg [31:0] memory_to_writeBack_PC;
  reg  decode_to_execute_PREDICTION_CONTEXT_hazard;
  reg [1:0] decode_to_execute_PREDICTION_CONTEXT_line_history;
  reg  execute_to_memory_PREDICTION_CONTEXT_hazard;
  reg [1:0] execute_to_memory_PREDICTION_CONTEXT_line_history;
  reg  decode_to_execute_MEMORY_ENABLE;
  reg  execute_to_memory_MEMORY_ENABLE;
  reg  memory_to_writeBack_MEMORY_ENABLE;
  reg  execute_to_memory_BRANCH_DO;
  reg [31:0] execute_to_memory_BRANCH_CALC;
  reg  memory_to_writeBack_ALIGNEMENT_FAULT;
  reg  decode_to_execute_BYPASSABLE_MEMORY_STAGE;
  reg  execute_to_memory_BYPASSABLE_MEMORY_STAGE;
  reg [1:0] memory_to_writeBack_MEMORY_ADDRESS_LOW;
  reg [31:0] decode_to_execute_FORMAL_PC_NEXT;
  reg [31:0] execute_to_memory_FORMAL_PC_NEXT;
  reg [31:0] memory_to_writeBack_FORMAL_PC_NEXT;
  reg  decode_to_execute_IS_RS2_SIGNED;
  reg  decode_to_execute_SRC_USE_SUB_LESS;
  reg [31:0] decode_to_execute_RS2;
  reg [31:0] execute_to_memory_RS2;
  reg  decode_to_execute_PREDICTION_HAD_BRANCHED2;
  reg  decode_to_execute_IS_MUL;
  reg  execute_to_memory_IS_MUL;
  reg [1:0] _zz_122_ [0:255];
  reg [31:0] RegFilePlugin_regFile [0:31] /* verilator public */ ;
  assign _zz_217_ = (memory_arbitration_isValid && memory_IS_MUL);
  assign _zz_218_ = (! memory_MulDivIterativePlugin_mul_willOverflowIfInc);
  assign _zz_219_ = (memory_arbitration_isValid && memory_IS_DIV);
  assign _zz_220_ = (! memory_MulDivIterativePlugin_div_done);
  assign _zz_221_ = (CsrPlugin_hadException || CsrPlugin_interruptJump);
  assign _zz_222_ = (writeBack_arbitration_isValid && (writeBack_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET));
  assign _zz_223_ = (IBusSimplePlugin_fetchPc_preOutput_valid && IBusSimplePlugin_fetchPc_preOutput_ready);
  assign _zz_224_ = (! memory_arbitration_isStuck);
  assign _zz_225_ = writeBack_INSTRUCTION[13 : 12];
  assign _zz_226_ = writeBack_INSTRUCTION[29 : 28];
  assign _zz_227_ = execute_INSTRUCTION[13];
  assign _zz_228_ = (_zz_102_ - (3'b001));
  assign _zz_229_ = {IBusSimplePlugin_fetchPc_inc,(2'b00)};
  assign _zz_230_ = {29'd0, _zz_229_};
  assign _zz_231_ = ($signed(memory_PREDICTION_CONTEXT_line_history) + $signed(_zz_232_));
  assign _zz_232_ = (_zz_133_ ? _zz_233_ : _zz_234_);
  assign _zz_233_ = (2'b11);
  assign _zz_234_ = (2'b01);
  assign _zz_235_ = _zz_127_[7:0];
  assign _zz_236_ = (IBusSimplePlugin_iBusRsp_stages_0_input_payload >>> 2);
  assign _zz_237_ = _zz_236_[7:0];
  assign _zz_238_ = (_zz_133_ ? _zz_239_ : _zz_240_);
  assign _zz_239_ = (2'b10);
  assign _zz_240_ = (2'b01);
  assign _zz_241_ = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[19 : 12]},decode_INSTRUCTION[20]},decode_INSTRUCTION[30 : 21]};
  assign _zz_242_ = {{{decode_INSTRUCTION[31],decode_INSTRUCTION[7]},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]};
  assign _zz_243_ = (IBusSimplePlugin_pendingCmd + _zz_245_);
  assign _zz_244_ = (IBusSimplePlugin_cmd_valid && IBusSimplePlugin_cmd_ready);
  assign _zz_245_ = {2'd0, _zz_244_};
  assign _zz_246_ = iBus_rsp_valid;
  assign _zz_247_ = {2'd0, _zz_246_};
  assign _zz_248_ = (iBus_rsp_valid && (IBusSimplePlugin_rspJoin_discardCounter != (3'b000)));
  assign _zz_249_ = {2'd0, _zz_248_};
  assign _zz_250_ = (IBusSimplePlugin_pendingCmd + _zz_252_);
  assign _zz_251_ = IBusSimplePlugin_cmd_valid;
  assign _zz_252_ = {2'd0, _zz_251_};
  assign _zz_253_ = iBus_rsp_valid;
  assign _zz_254_ = {2'd0, _zz_253_};
  assign _zz_255_ = (writeBack_INSTRUCTION[5] ? (3'b110) : (3'b100));
  assign _zz_256_ = _zz_148_[0 : 0];
  assign _zz_257_ = _zz_148_[1 : 1];
  assign _zz_258_ = _zz_148_[2 : 2];
  assign _zz_259_ = _zz_148_[3 : 3];
  assign _zz_260_ = _zz_148_[7 : 7];
  assign _zz_261_ = _zz_148_[10 : 10];
  assign _zz_262_ = _zz_148_[11 : 11];
  assign _zz_263_ = _zz_148_[12 : 12];
  assign _zz_264_ = _zz_148_[15 : 15];
  assign _zz_265_ = _zz_148_[18 : 18];
  assign _zz_266_ = _zz_148_[21 : 21];
  assign _zz_267_ = _zz_148_[22 : 22];
  assign _zz_268_ = _zz_148_[23 : 23];
  assign _zz_269_ = _zz_148_[24 : 24];
  assign _zz_270_ = memory_MulDivIterativePlugin_mul_counter_willIncrement;
  assign _zz_271_ = {3'd0, _zz_270_};
  assign _zz_272_ = (_zz_273_ + _zz_288_);
  assign _zz_273_ = (_zz_274_ + _zz_280_);
  assign _zz_274_ = (_zz_276_ + _zz_278_);
  assign _zz_275_ = (memory_MulDivIterativePlugin_rs2[0] ? memory_MulDivIterativePlugin_rs1 : (33'b000000000000000000000000000000000));
  assign _zz_276_ = {{4{_zz_275_[32]}}, _zz_275_};
  assign _zz_277_ = (memory_MulDivIterativePlugin_rs2[1] ? _zz_279_ : (34'b0000000000000000000000000000000000));
  assign _zz_278_ = {{3{_zz_277_[33]}}, _zz_277_};
  assign _zz_279_ = ({1'd0,memory_MulDivIterativePlugin_rs1} <<< 1);
  assign _zz_280_ = (_zz_282_ + _zz_285_);
  assign _zz_281_ = (memory_MulDivIterativePlugin_rs2[2] ? _zz_283_ : (35'b00000000000000000000000000000000000));
  assign _zz_282_ = {{2{_zz_281_[34]}}, _zz_281_};
  assign _zz_283_ = ({2'd0,memory_MulDivIterativePlugin_rs1} <<< 2);
  assign _zz_284_ = (memory_MulDivIterativePlugin_rs2[3] ? _zz_286_ : (36'b000000000000000000000000000000000000));
  assign _zz_285_ = {{1{_zz_284_[35]}}, _zz_284_};
  assign _zz_286_ = ({3'd0,memory_MulDivIterativePlugin_rs1} <<< 3);
  assign _zz_287_ = _zz_289_;
  assign _zz_288_ = {{4{_zz_287_[32]}}, _zz_287_};
  assign _zz_289_ = (memory_MulDivIterativePlugin_accumulator >>> 32);
  assign _zz_290_ = memory_MulDivIterativePlugin_div_counter_willIncrement;
  assign _zz_291_ = {5'd0, _zz_290_};
  assign _zz_292_ = {1'd0, memory_MulDivIterativePlugin_rs2};
  assign _zz_293_ = {_zz_163_,(! _zz_165_[32])};
  assign _zz_294_ = _zz_165_[31:0];
  assign _zz_295_ = _zz_164_[31:0];
  assign _zz_296_ = _zz_297_;
  assign _zz_297_ = _zz_298_;
  assign _zz_298_ = ({1'b0,(memory_MulDivIterativePlugin_div_needRevert ? (~ _zz_166_) : _zz_166_)} + _zz_300_);
  assign _zz_299_ = memory_MulDivIterativePlugin_div_needRevert;
  assign _zz_300_ = {32'd0, _zz_299_};
  assign _zz_301_ = _zz_168_;
  assign _zz_302_ = {32'd0, _zz_301_};
  assign _zz_303_ = _zz_167_;
  assign _zz_304_ = {31'd0, _zz_303_};
  assign _zz_305_ = execute_SRC_LESS;
  assign _zz_306_ = (3'b100);
  assign _zz_307_ = decode_INSTRUCTION[19 : 15];
  assign _zz_308_ = decode_INSTRUCTION[31 : 20];
  assign _zz_309_ = {decode_INSTRUCTION[31 : 25],decode_INSTRUCTION[11 : 7]};
  assign _zz_310_ = (execute_SRC1 + execute_SRC2);
  assign _zz_311_ = (execute_SRC1 - execute_SRC2);
  assign _zz_312_ = ($signed(_zz_314_) >>> execute_FullBarrelShifterPlugin_amplitude);
  assign _zz_313_ = _zz_312_[31 : 0];
  assign _zz_314_ = {((execute_SHIFT_CTRL == `ShiftCtrlEnum_defaultEncoding_SRA_1) && execute_FullBarrelShifterPlugin_reversed[31]),execute_FullBarrelShifterPlugin_reversed};
  assign _zz_315_ = execute_INSTRUCTION[31 : 20];
  assign _zz_316_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]};
  assign _zz_317_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]};
  assign _zz_318_ = {_zz_194_,execute_INSTRUCTION[31 : 20]};
  assign _zz_319_ = {{_zz_196_,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]}},1'b0};
  assign _zz_320_ = {{_zz_198_,{{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0};
  assign _zz_321_ = execute_INSTRUCTION[31 : 20];
  assign _zz_322_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]};
  assign _zz_323_ = {{{execute_INSTRUCTION[31],execute_INSTRUCTION[7]},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]};
  assign _zz_324_ = (3'b100);
  assign _zz_325_ = execute_CsrPlugin_writeData[7 : 7];
  assign _zz_326_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_327_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_328_ = execute_CsrPlugin_writeData[11 : 11];
  assign _zz_329_ = execute_CsrPlugin_writeData[7 : 7];
  assign _zz_330_ = execute_CsrPlugin_writeData[3 : 3];
  assign _zz_331_ = _zz_231_;
  assign _zz_332_ = 1'b1;
  assign _zz_333_ = 1'b1;
  assign _zz_334_ = {_zz_105_,_zz_104_};
  assign _zz_335_ = decode_INSTRUCTION[31];
  assign _zz_336_ = decode_INSTRUCTION[19 : 12];
  assign _zz_337_ = decode_INSTRUCTION[20];
  assign _zz_338_ = decode_INSTRUCTION[31];
  assign _zz_339_ = decode_INSTRUCTION[7];
  assign _zz_340_ = (decode_INSTRUCTION & (32'b00000000000000000000000001100100));
  assign _zz_341_ = (32'b00000000000000000000000000100100);
  assign _zz_342_ = (decode_INSTRUCTION & (32'b00000000000000000100000000010100));
  assign _zz_343_ = (32'b00000000000000000100000000010000);
  assign _zz_344_ = (decode_INSTRUCTION & (32'b00000000000000000110000000010100));
  assign _zz_345_ = (32'b00000000000000000010000000010000);
  assign _zz_346_ = _zz_154_;
  assign _zz_347_ = ((decode_INSTRUCTION & _zz_353_) == (32'b00000000000000000000000000100000));
  assign _zz_348_ = {_zz_154_,(_zz_354_ == _zz_355_)};
  assign _zz_349_ = (2'b00);
  assign _zz_350_ = ({_zz_356_,{_zz_357_,_zz_358_}} != (6'b000000));
  assign _zz_351_ = ({_zz_359_,_zz_360_} != (3'b000));
  assign _zz_352_ = {(_zz_361_ != _zz_362_),{_zz_363_,{_zz_364_,_zz_365_}}};
  assign _zz_353_ = (32'b00000000000000000000000001110000);
  assign _zz_354_ = (decode_INSTRUCTION & (32'b00000000000000000000000000100000));
  assign _zz_355_ = (32'b00000000000000000000000000000000);
  assign _zz_356_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001001000)) == (32'b00000000000000000000000001001000));
  assign _zz_357_ = ((decode_INSTRUCTION & _zz_366_) == (32'b00000000000000000001000000010000));
  assign _zz_358_ = {(_zz_367_ == _zz_368_),{_zz_369_,{_zz_370_,_zz_371_}}};
  assign _zz_359_ = _zz_151_;
  assign _zz_360_ = {_zz_153_,_zz_150_};
  assign _zz_361_ = ((decode_INSTRUCTION & _zz_372_) == (32'b00000010000000000000000000110000));
  assign _zz_362_ = (1'b0);
  assign _zz_363_ = ((_zz_373_ == _zz_374_) != (1'b0));
  assign _zz_364_ = (_zz_375_ != (1'b0));
  assign _zz_365_ = {(_zz_376_ != _zz_377_),{_zz_378_,{_zz_379_,_zz_380_}}};
  assign _zz_366_ = (32'b00000000000000000001000000010000);
  assign _zz_367_ = (decode_INSTRUCTION & (32'b00000000000000000010000000010000));
  assign _zz_368_ = (32'b00000000000000000010000000010000);
  assign _zz_369_ = ((decode_INSTRUCTION & (32'b00000000000000000001000000000100)) == (32'b00000000000000000000000000000100));
  assign _zz_370_ = ((decode_INSTRUCTION & _zz_381_) == (32'b00000000000000000000000000010000));
  assign _zz_371_ = ((decode_INSTRUCTION & _zz_382_) == (32'b00000000000000000000000000000000));
  assign _zz_372_ = (32'b00000010000000000100000001110100);
  assign _zz_373_ = (decode_INSTRUCTION & (32'b00000010000000000100000001100100));
  assign _zz_374_ = (32'b00000010000000000100000000100000);
  assign _zz_375_ = ((decode_INSTRUCTION & (32'b00010000000000000011000001010000)) == (32'b00000000000000000000000001010000));
  assign _zz_376_ = {(_zz_383_ == _zz_384_),(_zz_385_ == _zz_386_)};
  assign _zz_377_ = (2'b00);
  assign _zz_378_ = ({_zz_154_,{_zz_387_,_zz_388_}} != (5'b00000));
  assign _zz_379_ = ({_zz_389_,_zz_390_} != (2'b00));
  assign _zz_380_ = {(_zz_391_ != _zz_392_),{_zz_393_,{_zz_394_,_zz_395_}}};
  assign _zz_381_ = (32'b00000000000000000000000001010000);
  assign _zz_382_ = (32'b00000000000000000000000000101000);
  assign _zz_383_ = (decode_INSTRUCTION & (32'b00010000000100000011000001010000));
  assign _zz_384_ = (32'b00000000000100000000000001010000);
  assign _zz_385_ = (decode_INSTRUCTION & (32'b00010000010000000011000001010000));
  assign _zz_386_ = (32'b00010000000000000000000001010000);
  assign _zz_387_ = ((decode_INSTRUCTION & _zz_396_) == (32'b00000000000000000010000000010000));
  assign _zz_388_ = {(_zz_397_ == _zz_398_),{_zz_399_,_zz_400_}};
  assign _zz_389_ = ((decode_INSTRUCTION & _zz_401_) == (32'b00000000000000000001000000000000));
  assign _zz_390_ = _zz_154_;
  assign _zz_391_ = {_zz_154_,_zz_153_};
  assign _zz_392_ = (2'b00);
  assign _zz_393_ = ({_zz_402_,_zz_403_} != (2'b00));
  assign _zz_394_ = ({_zz_404_,_zz_405_} != (2'b00));
  assign _zz_395_ = {(_zz_406_ != _zz_407_),{_zz_408_,{_zz_409_,_zz_410_}}};
  assign _zz_396_ = (32'b00000000000000000010000000110000);
  assign _zz_397_ = (decode_INSTRUCTION & (32'b00000000000000000001000000110000));
  assign _zz_398_ = (32'b00000000000000000000000000010000);
  assign _zz_399_ = ((decode_INSTRUCTION & (32'b00000010000000000010000001100000)) == (32'b00000000000000000010000000100000));
  assign _zz_400_ = ((decode_INSTRUCTION & (32'b00000010000000000011000000100000)) == (32'b00000000000000000000000000100000));
  assign _zz_401_ = (32'b00000000000000000001000000000000);
  assign _zz_402_ = ((decode_INSTRUCTION & (32'b00000000000000000010000000010000)) == (32'b00000000000000000010000000000000));
  assign _zz_403_ = ((decode_INSTRUCTION & (32'b00000000000000000101000000000000)) == (32'b00000000000000000001000000000000));
  assign _zz_404_ = _zz_149_;
  assign _zz_405_ = _zz_152_;
  assign _zz_406_ = {(_zz_411_ == _zz_412_),_zz_152_};
  assign _zz_407_ = (2'b00);
  assign _zz_408_ = ((_zz_413_ == _zz_414_) != (1'b0));
  assign _zz_409_ = ({_zz_415_,_zz_416_} != (4'b0000));
  assign _zz_410_ = {(_zz_417_ != _zz_418_),{_zz_419_,{_zz_420_,_zz_421_}}};
  assign _zz_411_ = (decode_INSTRUCTION & (32'b00000000000000000000000001000100));
  assign _zz_412_ = (32'b00000000000000000000000000000100);
  assign _zz_413_ = (decode_INSTRUCTION & (32'b00000000000000000000000001001000));
  assign _zz_414_ = (32'b00000000000000000000000000001000);
  assign _zz_415_ = ((decode_INSTRUCTION & _zz_422_) == (32'b00000000000000000000000000000000));
  assign _zz_416_ = {(_zz_423_ == _zz_424_),{_zz_425_,_zz_426_}};
  assign _zz_417_ = {_zz_151_,_zz_150_};
  assign _zz_418_ = (2'b00);
  assign _zz_419_ = (_zz_149_ != (1'b0));
  assign _zz_420_ = (_zz_427_ != (1'b0));
  assign _zz_421_ = {(_zz_428_ != _zz_429_),{_zz_430_,{_zz_431_,_zz_432_}}};
  assign _zz_422_ = (32'b00000000000000000000000001000100);
  assign _zz_423_ = (decode_INSTRUCTION & (32'b00000000000000000000000000011000));
  assign _zz_424_ = (32'b00000000000000000000000000000000);
  assign _zz_425_ = ((decode_INSTRUCTION & (32'b00000000000000000110000000000100)) == (32'b00000000000000000010000000000000));
  assign _zz_426_ = ((decode_INSTRUCTION & (32'b00000000000000000101000000000100)) == (32'b00000000000000000001000000000000));
  assign _zz_427_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001011000)) == (32'b00000000000000000000000001000000));
  assign _zz_428_ = {(_zz_433_ == _zz_434_),(_zz_435_ == _zz_436_)};
  assign _zz_429_ = (2'b00);
  assign _zz_430_ = ({_zz_437_,_zz_438_} != (2'b00));
  assign _zz_431_ = ({_zz_439_,_zz_440_} != (3'b000));
  assign _zz_432_ = {(_zz_441_ != _zz_442_),{_zz_443_,{_zz_444_,_zz_445_}}};
  assign _zz_433_ = (decode_INSTRUCTION & (32'b00000000000000000001000001010000));
  assign _zz_434_ = (32'b00000000000000000001000001010000);
  assign _zz_435_ = (decode_INSTRUCTION & (32'b00000000000000000010000001010000));
  assign _zz_436_ = (32'b00000000000000000010000001010000);
  assign _zz_437_ = ((decode_INSTRUCTION & (32'b00000000000000000111000000110100)) == (32'b00000000000000000101000000010000));
  assign _zz_438_ = ((decode_INSTRUCTION & (32'b00000010000000000111000001100100)) == (32'b00000000000000000101000000100000));
  assign _zz_439_ = ((decode_INSTRUCTION & _zz_446_) == (32'b01000000000000000001000000010000));
  assign _zz_440_ = {(_zz_447_ == _zz_448_),(_zz_449_ == _zz_450_)};
  assign _zz_441_ = {(_zz_451_ == _zz_452_),{_zz_453_,_zz_454_}};
  assign _zz_442_ = (3'b000);
  assign _zz_443_ = ((_zz_455_ == _zz_456_) != (1'b0));
  assign _zz_444_ = ({_zz_457_,_zz_458_} != (2'b00));
  assign _zz_445_ = {(_zz_459_ != _zz_460_),(_zz_461_ != _zz_462_)};
  assign _zz_446_ = (32'b01000000000000000011000001010100);
  assign _zz_447_ = (decode_INSTRUCTION & (32'b00000000000000000111000000110100));
  assign _zz_448_ = (32'b00000000000000000001000000010000);
  assign _zz_449_ = (decode_INSTRUCTION & (32'b00000010000000000111000001010100));
  assign _zz_450_ = (32'b00000000000000000001000000010000);
  assign _zz_451_ = (decode_INSTRUCTION & (32'b00000000000000000000000001010000));
  assign _zz_452_ = (32'b00000000000000000000000001000000);
  assign _zz_453_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000110000)) == (32'b00000000000000000000000000000000));
  assign _zz_454_ = ((decode_INSTRUCTION & (32'b00000000010000000011000001000000)) == (32'b00000000000000000000000001000000));
  assign _zz_455_ = (decode_INSTRUCTION & (32'b00000000000000000000000001011000));
  assign _zz_456_ = (32'b00000000000000000000000000000000);
  assign _zz_457_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000110100)) == (32'b00000000000000000000000000100000));
  assign _zz_458_ = ((decode_INSTRUCTION & (32'b00000000000000000000000001100100)) == (32'b00000000000000000000000000100000));
  assign _zz_459_ = {((decode_INSTRUCTION & _zz_463_) == (32'b00000000000000000000000001000000)),{(_zz_464_ == _zz_465_),(_zz_466_ == _zz_467_)}};
  assign _zz_460_ = (3'b000);
  assign _zz_461_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000010000)) == (32'b00000000000000000000000000010000));
  assign _zz_462_ = (1'b0);
  assign _zz_463_ = (32'b00000000000000000000000001000100);
  assign _zz_464_ = (decode_INSTRUCTION & (32'b01000000000000000000000000110000));
  assign _zz_465_ = (32'b01000000000000000000000000110000);
  assign _zz_466_ = (decode_INSTRUCTION & (32'b00000000000000000010000000010100));
  assign _zz_467_ = (32'b00000000000000000010000000010000);
  assign _zz_468_ = execute_INSTRUCTION[31];
  assign _zz_469_ = execute_INSTRUCTION[31];
  assign _zz_470_ = execute_INSTRUCTION[7];
  always @ (posedge io_clk) begin
    if(_zz_86_) begin
      _zz_122_[_zz_124_] <= _zz_331_;
    end
  end

  always @ (posedge io_clk) begin
    if(_zz_128_) begin
      _zz_208_ <= _zz_122_[_zz_235_];
    end
  end

  always @ (posedge io_clk) begin
    if(_zz_48_) begin
      RegFilePlugin_regFile[writeBack_RegFilePlugin_regFileWrite_payload_address] <= writeBack_RegFilePlugin_regFileWrite_payload_data;
    end
  end

  always @ (posedge io_clk) begin
    if(_zz_332_) begin
      _zz_209_ <= RegFilePlugin_regFile[decode_RegFilePlugin_regFileReadAddress1];
    end
  end

  always @ (posedge io_clk) begin
    if(_zz_333_) begin
      _zz_210_ <= RegFilePlugin_regFile[decode_RegFilePlugin_regFileReadAddress2];
    end
  end

  StreamFifoLowLatency IBusSimplePlugin_rspJoin_rspBuffer_c ( 
    .io_push_valid(_zz_206_),
    .io_push_ready(_zz_212_),
    .io_push_payload_error(iBus_rsp_payload_error),
    .io_push_payload_inst(iBus_rsp_payload_inst),
    .io_pop_valid(_zz_213_),
    .io_pop_ready(IBusSimplePlugin_rspJoin_rspBufferOutput_ready),
    .io_pop_payload_error(_zz_214_),
    .io_pop_payload_inst(_zz_215_),
    .io_flush(_zz_207_),
    .io_occupancy(_zz_216_),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(GLOBAL_BUFFER_OUTPUT) 
  );
  always @(*) begin
    case(_zz_334_)
      2'b00 : begin
        _zz_211_ = _zz_99_;
      end
      2'b01 : begin
        _zz_211_ = _zz_101_;
      end
      default : begin
        _zz_211_ = _zz_96_;
      end
    endcase
  end

  assign decode_IS_MUL = _zz_55_;
  assign decode_PREDICTION_HAD_BRANCHED2 = _zz_28_;
  assign decode_SRC_USE_SUB_LESS = _zz_70_;
  assign decode_IS_RS2_SIGNED = _zz_64_;
  assign writeBack_FORMAL_PC_NEXT = memory_to_writeBack_FORMAL_PC_NEXT;
  assign memory_FORMAL_PC_NEXT = execute_to_memory_FORMAL_PC_NEXT;
  assign execute_FORMAL_PC_NEXT = decode_to_execute_FORMAL_PC_NEXT;
  assign decode_FORMAL_PC_NEXT = _zz_89_;
  assign memory_MEMORY_ADDRESS_LOW = _zz_80_;
  assign execute_BYPASSABLE_MEMORY_STAGE = decode_to_execute_BYPASSABLE_MEMORY_STAGE;
  assign decode_BYPASSABLE_MEMORY_STAGE = _zz_71_;
  assign execute_BRANCH_CALC = _zz_24_;
  assign execute_BRANCH_DO = _zz_25_;
  assign execute_MEMORY_ENABLE = decode_to_execute_MEMORY_ENABLE;
  assign decode_MEMORY_ENABLE = _zz_68_;
  assign execute_PREDICTION_CONTEXT_hazard = decode_to_execute_PREDICTION_CONTEXT_hazard;
  assign execute_PREDICTION_CONTEXT_line_history = decode_to_execute_PREDICTION_CONTEXT_line_history;
  assign _zz_1_ = _zz_2_;
  assign _zz_3_ = _zz_4_;
  assign decode_ENV_CTRL = _zz_5_;
  assign _zz_6_ = _zz_7_;
  assign decode_IS_RS1_SIGNED = _zz_54_;
  assign decode_ALU_CTRL = _zz_8_;
  assign _zz_9_ = _zz_10_;
  assign decode_CSR_WRITE_OPCODE = _zz_76_;
  assign _zz_11_ = _zz_12_;
  assign decode_SHIFT_CTRL = _zz_13_;
  assign _zz_14_ = _zz_15_;
  assign decode_IS_CSR = _zz_66_;
  assign decode_IS_DIV = _zz_56_;
  assign execute_SHIFT_RIGHT = _zz_30_;
  assign decode_CSR_READ_OPCODE = _zz_75_;
  assign _zz_16_ = _zz_17_;
  assign _zz_18_ = _zz_19_;
  assign memory_REGFILE_WRITE_DATA = execute_to_memory_REGFILE_WRITE_DATA;
  assign execute_REGFILE_WRITE_DATA = _zz_43_;
  assign decode_SRC2 = _zz_38_;
  assign decode_BYPASSABLE_EXECUTE_STAGE = _zz_58_;
  assign decode_ALU_BITWISE_CTRL = _zz_20_;
  assign _zz_21_ = _zz_22_;
  assign decode_SRC1 = _zz_41_;
  assign decode_SRC_LESS_UNSIGNED = _zz_60_;
  assign execute_SRC_ADD = _zz_33_;
  assign execute_IS_FENCEI = decode_to_execute_IS_FENCEI;
  always @ (*) begin
    _zz_23_ = decode_INSTRUCTION;
    if(decode_IS_FENCEI)begin
      _zz_23_[12] = 1'b0;
      _zz_23_[22] = 1'b1;
    end
  end

  assign memory_BRANCH_CALC = execute_to_memory_BRANCH_CALC;
  assign memory_BRANCH_DO = execute_to_memory_BRANCH_DO;
  assign execute_PC = decode_to_execute_PC;
  assign execute_PREDICTION_HAD_BRANCHED2 = decode_to_execute_PREDICTION_HAD_BRANCHED2;
  assign execute_BRANCH_COND_RESULT = _zz_27_;
  assign execute_BRANCH_CTRL = _zz_26_;
  assign decode_IS_FENCEI = _zz_62_;
  assign decode_RS2_USE = _zz_69_;
  assign decode_RS1_USE = _zz_63_;
  assign execute_REGFILE_WRITE_VALID = decode_to_execute_REGFILE_WRITE_VALID;
  assign execute_BYPASSABLE_EXECUTE_STAGE = decode_to_execute_BYPASSABLE_EXECUTE_STAGE;
  assign memory_REGFILE_WRITE_VALID = execute_to_memory_REGFILE_WRITE_VALID;
  assign memory_BYPASSABLE_MEMORY_STAGE = execute_to_memory_BYPASSABLE_MEMORY_STAGE;
  assign writeBack_REGFILE_WRITE_VALID = memory_to_writeBack_REGFILE_WRITE_VALID;
  always @ (*) begin
    decode_RS2 = _zz_49_;
    decode_RS1 = _zz_50_;
    if(_zz_181_)begin
      if((_zz_182_ == decode_INSTRUCTION[19 : 15]))begin
        decode_RS1 = _zz_183_;
      end
      if((_zz_182_ == decode_INSTRUCTION[24 : 20]))begin
        decode_RS2 = _zz_183_;
      end
    end
    if((writeBack_arbitration_isValid && writeBack_REGFILE_WRITE_VALID))begin
      if(1'b1)begin
        if(_zz_184_)begin
          decode_RS1 = _zz_78_;
        end
        if(_zz_185_)begin
          decode_RS2 = _zz_78_;
        end
      end
    end
    if((memory_arbitration_isValid && memory_REGFILE_WRITE_VALID))begin
      if(memory_BYPASSABLE_MEMORY_STAGE)begin
        if(_zz_186_)begin
          decode_RS1 = _zz_45_;
        end
        if(_zz_187_)begin
          decode_RS2 = _zz_45_;
        end
      end
    end
    if((execute_arbitration_isValid && execute_REGFILE_WRITE_VALID))begin
      if(execute_BYPASSABLE_EXECUTE_STAGE)begin
        if(_zz_188_)begin
          decode_RS1 = _zz_72_;
        end
        if(_zz_189_)begin
          decode_RS2 = _zz_72_;
        end
      end
    end
  end

  assign memory_SHIFT_RIGHT = execute_to_memory_SHIFT_RIGHT;
  assign memory_SHIFT_CTRL = _zz_29_;
  assign execute_SHIFT_CTRL = _zz_31_;
  assign execute_SRC_USE_SUB_LESS = decode_to_execute_SRC_USE_SUB_LESS;
  assign execute_SRC_LESS_UNSIGNED = decode_to_execute_SRC_LESS_UNSIGNED;
  assign _zz_35_ = decode_PC;
  assign _zz_36_ = decode_RS2;
  assign decode_SRC2_CTRL = _zz_37_;
  assign _zz_39_ = decode_RS1;
  assign decode_SRC1_CTRL = _zz_40_;
  assign execute_SRC_ADD_SUB = _zz_34_;
  assign execute_SRC_LESS = _zz_32_;
  assign execute_ALU_CTRL = _zz_42_;
  assign execute_SRC2 = decode_to_execute_SRC2;
  assign execute_ALU_BITWISE_CTRL = _zz_44_;
  assign execute_IS_RS1_SIGNED = decode_to_execute_IS_RS1_SIGNED;
  assign execute_RS1 = decode_to_execute_RS1;
  assign execute_IS_DIV = decode_to_execute_IS_DIV;
  assign execute_IS_MUL = decode_to_execute_IS_MUL;
  assign execute_IS_RS2_SIGNED = decode_to_execute_IS_RS2_SIGNED;
  assign execute_RS2 = decode_to_execute_RS2;
  assign memory_IS_DIV = execute_to_memory_IS_DIV;
  always @ (*) begin
    _zz_45_ = memory_REGFILE_WRITE_DATA;
    memory_arbitration_haltItself = 1'b0;
    if((((memory_arbitration_isValid && memory_MEMORY_ENABLE) && (! dBus_cmd_ready)) && (! memory_ALIGNEMENT_FAULT)))begin
      memory_arbitration_haltItself = 1'b1;
    end
    memory_MulDivIterativePlugin_mul_counter_willIncrement = 1'b0;
    if(_zz_217_)begin
      if(_zz_218_)begin
        memory_arbitration_haltItself = 1'b1;
        memory_MulDivIterativePlugin_mul_counter_willIncrement = 1'b1;
      end
      _zz_45_ = ((memory_INSTRUCTION[13 : 12] == (2'b00)) ? memory_MulDivIterativePlugin_accumulator[31 : 0] : memory_MulDivIterativePlugin_accumulator[63 : 32]);
    end
    memory_MulDivIterativePlugin_div_counter_willIncrement = 1'b0;
    if(_zz_219_)begin
      if(_zz_220_)begin
        memory_arbitration_haltItself = 1'b1;
        memory_MulDivIterativePlugin_div_counter_willIncrement = 1'b1;
      end
      _zz_45_ = memory_MulDivIterativePlugin_div_result;
    end
    case(memory_SHIFT_CTRL)
      `ShiftCtrlEnum_defaultEncoding_SLL_1 : begin
        _zz_45_ = _zz_178_;
      end
      `ShiftCtrlEnum_defaultEncoding_SRL_1, `ShiftCtrlEnum_defaultEncoding_SRA_1 : begin
        _zz_45_ = memory_SHIFT_RIGHT;
      end
      default : begin
      end
    endcase
  end

  assign memory_IS_MUL = execute_to_memory_IS_MUL;
  assign _zz_46_ = writeBack_INSTRUCTION;
  assign _zz_47_ = writeBack_REGFILE_WRITE_VALID;
  always @ (*) begin
    _zz_48_ = 1'b0;
    if(writeBack_RegFilePlugin_regFileWrite_valid)begin
      _zz_48_ = 1'b1;
    end
  end

  assign decode_INSTRUCTION_ANTICIPATED = _zz_92_;
  always @ (*) begin
    decode_REGFILE_WRITE_VALID = _zz_53_;
    if((decode_INSTRUCTION[11 : 7] == (5'b00000)))begin
      decode_REGFILE_WRITE_VALID = 1'b0;
    end
  end

  always @ (*) begin
    _zz_72_ = execute_REGFILE_WRITE_DATA;
    execute_arbitration_haltItself = 1'b0;
    if((execute_arbitration_isValid && execute_IS_CSR))begin
      _zz_72_ = execute_CsrPlugin_readData;
      if(execute_CsrPlugin_blockedBySideEffects)begin
        execute_arbitration_haltItself = 1'b1;
      end
    end
  end

  assign execute_SRC1 = decode_to_execute_SRC1;
  assign execute_CSR_READ_OPCODE = decode_to_execute_CSR_READ_OPCODE;
  assign execute_CSR_WRITE_OPCODE = decode_to_execute_CSR_WRITE_OPCODE;
  assign execute_INSTRUCTION = decode_to_execute_INSTRUCTION;
  assign execute_IS_CSR = decode_to_execute_IS_CSR;
  assign memory_ENV_CTRL = _zz_73_;
  assign execute_ENV_CTRL = _zz_74_;
  assign writeBack_ENV_CTRL = _zz_77_;
  always @ (*) begin
    _zz_78_ = writeBack_REGFILE_WRITE_DATA;
    if((writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE))begin
      _zz_78_ = writeBack_DBusSimplePlugin_rspFormated;
    end
  end

  assign writeBack_MEMORY_ADDRESS_LOW = memory_to_writeBack_MEMORY_ADDRESS_LOW;
  assign writeBack_MEMORY_READ_DATA = _zz_79_;
  assign writeBack_REGFILE_WRITE_DATA = memory_to_writeBack_REGFILE_WRITE_DATA;
  assign writeBack_ALIGNEMENT_FAULT = memory_to_writeBack_ALIGNEMENT_FAULT;
  assign writeBack_MEMORY_ENABLE = memory_to_writeBack_MEMORY_ENABLE;
  assign memory_RS2 = execute_to_memory_RS2;
  assign memory_SRC_ADD = execute_to_memory_SRC_ADD;
  assign memory_INSTRUCTION = execute_to_memory_INSTRUCTION;
  assign memory_ALIGNEMENT_FAULT = _zz_81_;
  assign memory_MEMORY_ENABLE = execute_to_memory_MEMORY_ENABLE;
  assign decode_BRANCH_CTRL = _zz_82_;
  assign memory_BRANCH_CTRL = _zz_83_;
  assign memory_PC = execute_to_memory_PC;
  assign memory_PREDICTION_CONTEXT_hazard = execute_to_memory_PREDICTION_CONTEXT_hazard;
  assign memory_PREDICTION_CONTEXT_line_history = execute_to_memory_PREDICTION_CONTEXT_line_history;
  assign decode_PREDICTION_CONTEXT_hazard = _zz_84_;
  assign decode_PREDICTION_CONTEXT_line_history = _zz_85_;
  always @ (*) begin
    _zz_86_ = 1'b0;
    if(_zz_123_)begin
      _zz_86_ = 1'b1;
    end
  end

  always @ (*) begin
    _zz_87_ = memory_FORMAL_PC_NEXT;
    if(_zz_100_)begin
      _zz_87_ = _zz_101_;
    end
  end

  always @ (*) begin
    _zz_88_ = decode_FORMAL_PC_NEXT;
    if(_zz_95_)begin
      _zz_88_ = _zz_96_;
    end
  end

  assign writeBack_PC = memory_to_writeBack_PC;
  assign writeBack_INSTRUCTION = memory_to_writeBack_INSTRUCTION;
  assign decode_PC = _zz_91_;
  assign decode_INSTRUCTION = _zz_90_;
  always @ (*) begin
    decode_arbitration_haltItself = 1'b0;
    if((decode_arbitration_isValid && (_zz_179_ || _zz_180_)))begin
      decode_arbitration_haltItself = 1'b1;
    end
  end

  always @ (*) begin
    decode_arbitration_haltByOther = 1'b0;
    if((CsrPlugin_interrupt && decode_arbitration_isValid))begin
      decode_arbitration_haltByOther = 1'b1;
    end
    if(((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET)) || (memory_arbitration_isValid && (memory_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET))))begin
      decode_arbitration_haltByOther = 1'b1;
    end
  end

  always @ (*) begin
    decode_arbitration_removeIt = 1'b0;
    if(decode_arbitration_isFlushed)begin
      decode_arbitration_removeIt = 1'b1;
    end
  end

  always @ (*) begin
    decode_arbitration_flushAll = 1'b0;
    execute_arbitration_removeIt = 1'b0;
    CsrPlugin_exceptionPortCtrl_exceptionValids_execute = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute;
    if(execute_exception_agregat_valid)begin
      decode_arbitration_flushAll = 1'b1;
      execute_arbitration_removeIt = 1'b1;
      CsrPlugin_exceptionPortCtrl_exceptionValids_execute = 1'b1;
    end
    if(execute_arbitration_isFlushed)begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_execute = 1'b0;
    end
    if(execute_arbitration_isFlushed)begin
      execute_arbitration_removeIt = 1'b1;
    end
  end

  assign decode_arbitration_redoIt = 1'b0;
  always @ (*) begin
    execute_arbitration_haltByOther = 1'b0;
    if(((execute_arbitration_isValid && execute_IS_FENCEI) && (memory_arbitration_isValid || writeBack_arbitration_isValid)))begin
      execute_arbitration_haltByOther = 1'b1;
    end
  end

  always @ (*) begin
    execute_arbitration_flushAll = 1'b0;
    if(memory_exception_agregat_valid)begin
      execute_arbitration_flushAll = 1'b1;
    end
    if(_zz_100_)begin
      execute_arbitration_flushAll = 1'b1;
    end
  end

  assign execute_arbitration_redoIt = 1'b0;
  assign memory_arbitration_haltByOther = 1'b0;
  always @ (*) begin
    memory_arbitration_removeIt = 1'b0;
    if(memory_exception_agregat_valid)begin
      memory_arbitration_removeIt = 1'b1;
    end
    if(memory_arbitration_isFlushed)begin
      memory_arbitration_removeIt = 1'b1;
    end
  end

  always @ (*) begin
    memory_arbitration_flushAll = 1'b0;
    writeBack_arbitration_removeIt = 1'b0;
    _zz_98_ = 1'b0;
    _zz_99_ = (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
    CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack;
    if(writeBack_exception_agregat_valid)begin
      memory_arbitration_flushAll = 1'b1;
      writeBack_arbitration_removeIt = 1'b1;
      CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack = 1'b1;
    end
    if(_zz_221_)begin
      _zz_98_ = 1'b1;
      _zz_99_ = {CsrPlugin_mtvec_base,(2'b00)};
      memory_arbitration_flushAll = 1'b1;
    end
    if(_zz_222_)begin
      _zz_99_ = CsrPlugin_mepc;
      _zz_98_ = 1'b1;
      memory_arbitration_flushAll = 1'b1;
    end
    if(writeBack_arbitration_isFlushed)begin
      writeBack_arbitration_removeIt = 1'b1;
    end
  end

  assign memory_arbitration_redoIt = 1'b0;
  always @ (*) begin
    writeBack_arbitration_haltItself = 1'b0;
    if((((writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE) && (! writeBack_INSTRUCTION[5])) && (! dBus_rsp_ready)))begin
      writeBack_arbitration_haltItself = 1'b1;
    end
  end

  assign writeBack_arbitration_haltByOther = 1'b0;
  assign writeBack_arbitration_flushAll = 1'b0;
  assign writeBack_arbitration_redoIt = 1'b0;
  always @ (*) begin
    _zz_93_ = 1'b0;
    if((((CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode || CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute) || CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory) || CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack))begin
      _zz_93_ = 1'b1;
    end
  end

  assign _zz_94_ = 1'b0;
  assign IBusSimplePlugin_jump_pcLoad_valid = ((_zz_95_ || _zz_98_) || _zz_100_);
  assign _zz_102_ = {_zz_95_,{_zz_100_,_zz_98_}};
  assign _zz_103_ = (_zz_102_ & (~ _zz_228_));
  assign _zz_104_ = _zz_103_[1];
  assign _zz_105_ = _zz_103_[2];
  assign IBusSimplePlugin_jump_pcLoad_payload = _zz_211_;
  assign _zz_106_ = (! _zz_93_);
  assign IBusSimplePlugin_fetchPc_output_valid = (IBusSimplePlugin_fetchPc_preOutput_valid && _zz_106_);
  assign IBusSimplePlugin_fetchPc_preOutput_ready = (IBusSimplePlugin_fetchPc_output_ready && _zz_106_);
  assign IBusSimplePlugin_fetchPc_output_payload = IBusSimplePlugin_fetchPc_preOutput_payload;
  assign IBusSimplePlugin_fetchPc_propagatePc = 1'b0;
  always @ (*) begin
    IBusSimplePlugin_fetchPc_pc = (IBusSimplePlugin_fetchPc_pcReg + _zz_230_);
    IBusSimplePlugin_fetchPc_samplePcNext = 1'b0;
    if(IBusSimplePlugin_fetchPc_propagatePc)begin
      IBusSimplePlugin_fetchPc_samplePcNext = 1'b1;
    end
    if(IBusSimplePlugin_jump_pcLoad_valid)begin
      IBusSimplePlugin_fetchPc_samplePcNext = 1'b1;
      IBusSimplePlugin_fetchPc_pc = IBusSimplePlugin_jump_pcLoad_payload;
    end
    if(_zz_223_)begin
      IBusSimplePlugin_fetchPc_samplePcNext = 1'b1;
    end
    IBusSimplePlugin_fetchPc_pc[0] = 1'b0;
    IBusSimplePlugin_fetchPc_pc[1] = 1'b0;
  end

  assign IBusSimplePlugin_fetchPc_preOutput_valid = _zz_107_;
  assign IBusSimplePlugin_fetchPc_preOutput_payload = IBusSimplePlugin_fetchPc_pc;
  assign IBusSimplePlugin_iBusRsp_stages_0_input_valid = IBusSimplePlugin_fetchPc_output_valid;
  assign IBusSimplePlugin_fetchPc_output_ready = IBusSimplePlugin_iBusRsp_stages_0_input_ready;
  assign IBusSimplePlugin_iBusRsp_stages_0_input_payload = IBusSimplePlugin_fetchPc_output_payload;
  assign IBusSimplePlugin_iBusRsp_stages_0_inputSample = 1'b1;
  assign IBusSimplePlugin_iBusRsp_stages_0_halt = 1'b0;
  assign _zz_108_ = (! IBusSimplePlugin_iBusRsp_stages_0_halt);
  assign IBusSimplePlugin_iBusRsp_stages_0_input_ready = (IBusSimplePlugin_iBusRsp_stages_0_output_ready && _zz_108_);
  assign IBusSimplePlugin_iBusRsp_stages_0_output_valid = (IBusSimplePlugin_iBusRsp_stages_0_input_valid && _zz_108_);
  assign IBusSimplePlugin_iBusRsp_stages_0_output_payload = IBusSimplePlugin_iBusRsp_stages_0_input_payload;
  always @ (*) begin
    IBusSimplePlugin_iBusRsp_stages_1_halt = 1'b0;
    if(((IBusSimplePlugin_cmd_valid && (! IBusSimplePlugin_cmd_ready)) || (IBusSimplePlugin_cmdFork_pendingFull && (! IBusSimplePlugin_cmdFork_cmdFired))))begin
      IBusSimplePlugin_iBusRsp_stages_1_halt = 1'b1;
    end
  end

  assign _zz_109_ = (! IBusSimplePlugin_iBusRsp_stages_1_halt);
  assign IBusSimplePlugin_iBusRsp_stages_1_input_ready = (IBusSimplePlugin_iBusRsp_stages_1_output_ready && _zz_109_);
  assign IBusSimplePlugin_iBusRsp_stages_1_output_valid = (IBusSimplePlugin_iBusRsp_stages_1_input_valid && _zz_109_);
  assign IBusSimplePlugin_iBusRsp_stages_1_output_payload = IBusSimplePlugin_iBusRsp_stages_1_input_payload;
  assign IBusSimplePlugin_iBusRsp_stages_2_halt = 1'b0;
  assign _zz_110_ = (! IBusSimplePlugin_iBusRsp_stages_2_halt);
  assign IBusSimplePlugin_iBusRsp_stages_2_input_ready = (IBusSimplePlugin_iBusRsp_stages_2_output_ready && _zz_110_);
  assign IBusSimplePlugin_iBusRsp_stages_2_output_valid = (IBusSimplePlugin_iBusRsp_stages_2_input_valid && _zz_110_);
  assign IBusSimplePlugin_iBusRsp_stages_2_output_payload = IBusSimplePlugin_iBusRsp_stages_2_input_payload;
  assign IBusSimplePlugin_iBusRsp_stages_0_output_ready = ((1'b0 && (! _zz_111_)) || IBusSimplePlugin_iBusRsp_stages_1_input_ready);
  assign _zz_111_ = _zz_112_;
  assign IBusSimplePlugin_iBusRsp_stages_1_input_valid = _zz_111_;
  assign IBusSimplePlugin_iBusRsp_stages_1_input_payload = _zz_113_;
  assign IBusSimplePlugin_iBusRsp_stages_1_output_ready = ((1'b0 && (! _zz_114_)) || IBusSimplePlugin_iBusRsp_stages_2_input_ready);
  assign _zz_114_ = _zz_115_;
  assign IBusSimplePlugin_iBusRsp_stages_2_input_valid = _zz_114_;
  assign IBusSimplePlugin_iBusRsp_stages_2_input_payload = _zz_116_;
  always @ (*) begin
    IBusSimplePlugin_iBusRsp_readyForError = 1'b1;
    if(IBusSimplePlugin_injector_decodeInput_valid)begin
      IBusSimplePlugin_iBusRsp_readyForError = 1'b0;
    end
  end

  assign IBusSimplePlugin_iBusRsp_inputBeforeStage_ready = ((1'b0 && (! IBusSimplePlugin_injector_decodeInput_valid)) || IBusSimplePlugin_injector_decodeInput_ready);
  assign IBusSimplePlugin_injector_decodeInput_valid = _zz_117_;
  assign IBusSimplePlugin_injector_decodeInput_payload_pc = _zz_118_;
  assign IBusSimplePlugin_injector_decodeInput_payload_rsp_error = _zz_119_;
  assign IBusSimplePlugin_injector_decodeInput_payload_rsp_inst = _zz_120_;
  assign IBusSimplePlugin_injector_decodeInput_payload_isRvc = _zz_121_;
  assign _zz_92_ = (decode_arbitration_isStuck ? decode_INSTRUCTION : IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_raw);
  assign IBusSimplePlugin_injector_decodeInput_ready = (! decode_arbitration_isStuck);
  assign decode_arbitration_isValid = (IBusSimplePlugin_injector_decodeInput_valid && (! IBusSimplePlugin_injector_decodeRemoved));
  assign _zz_91_ = IBusSimplePlugin_injector_decodeInput_payload_pc;
  assign _zz_90_ = IBusSimplePlugin_injector_decodeInput_payload_rsp_inst;
  assign _zz_89_ = (decode_PC + (32'b00000000000000000000000000000100));
  assign _zz_127_ = (IBusSimplePlugin_fetchPc_output_payload >>> 2);
  assign _zz_128_ = (IBusSimplePlugin_iBusRsp_stages_0_output_ready || (IBusSimplePlugin_jump_pcLoad_valid || _zz_94_));
  assign _zz_84_ = _zz_131_;
  assign _zz_85_ = _zz_132_;
  assign _zz_133_ = (_zz_100_ ^ memory_PREDICTION_CONTEXT_line_history[1]);
  assign _zz_124_ = (memory_PC[9 : 2] + (8'b00000000));
  assign _zz_123_ = ((((! memory_PREDICTION_CONTEXT_hazard) && memory_arbitration_isFiring) && (memory_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_B)) && (! ($signed(memory_PREDICTION_CONTEXT_line_history) == $signed(_zz_238_))));
  assign _zz_97_ = ((decode_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_JAL) || ((decode_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_B) && decode_PREDICTION_CONTEXT_line_history[1]));
  assign _zz_95_ = (_zz_97_ && decode_arbitration_isFiring);
  assign _zz_134_ = _zz_241_[19];
  always @ (*) begin
    _zz_135_[10] = _zz_134_;
    _zz_135_[9] = _zz_134_;
    _zz_135_[8] = _zz_134_;
    _zz_135_[7] = _zz_134_;
    _zz_135_[6] = _zz_134_;
    _zz_135_[5] = _zz_134_;
    _zz_135_[4] = _zz_134_;
    _zz_135_[3] = _zz_134_;
    _zz_135_[2] = _zz_134_;
    _zz_135_[1] = _zz_134_;
    _zz_135_[0] = _zz_134_;
  end

  assign _zz_136_ = _zz_242_[11];
  always @ (*) begin
    _zz_137_[18] = _zz_136_;
    _zz_137_[17] = _zz_136_;
    _zz_137_[16] = _zz_136_;
    _zz_137_[15] = _zz_136_;
    _zz_137_[14] = _zz_136_;
    _zz_137_[13] = _zz_136_;
    _zz_137_[12] = _zz_136_;
    _zz_137_[11] = _zz_136_;
    _zz_137_[10] = _zz_136_;
    _zz_137_[9] = _zz_136_;
    _zz_137_[8] = _zz_136_;
    _zz_137_[7] = _zz_136_;
    _zz_137_[6] = _zz_136_;
    _zz_137_[5] = _zz_136_;
    _zz_137_[4] = _zz_136_;
    _zz_137_[3] = _zz_136_;
    _zz_137_[2] = _zz_136_;
    _zz_137_[1] = _zz_136_;
    _zz_137_[0] = _zz_136_;
  end

  assign _zz_96_ = (decode_PC + ((decode_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_JAL) ? {{_zz_135_,{{{_zz_335_,_zz_336_},_zz_337_},decode_INSTRUCTION[30 : 21]}},1'b0} : {{_zz_137_,{{{_zz_338_,_zz_339_},decode_INSTRUCTION[30 : 25]},decode_INSTRUCTION[11 : 8]}},1'b0}));
  assign iBus_cmd_valid = IBusSimplePlugin_cmd_valid;
  assign IBusSimplePlugin_cmd_ready = iBus_cmd_ready;
  assign iBus_cmd_payload_pc = IBusSimplePlugin_cmd_payload_pc;
  assign IBusSimplePlugin_pendingCmdNext = (_zz_243_ - _zz_247_);
  assign IBusSimplePlugin_cmdFork_pendingFull = (IBusSimplePlugin_pendingCmd == (3'b111));
  assign IBusSimplePlugin_cmd_valid = (((IBusSimplePlugin_iBusRsp_stages_1_input_valid || IBusSimplePlugin_cmdFork_cmdKeep) && (! IBusSimplePlugin_cmdFork_pendingFull)) && (! IBusSimplePlugin_cmdFork_cmdFired));
  assign IBusSimplePlugin_cmd_payload_pc = {IBusSimplePlugin_iBusRsp_stages_1_input_payload[31 : 2],(2'b00)};
  assign _zz_206_ = (iBus_rsp_valid && (! (IBusSimplePlugin_rspJoin_discardCounter != (3'b000))));
  assign _zz_207_ = (IBusSimplePlugin_jump_pcLoad_valid || _zz_94_);
  assign IBusSimplePlugin_rspJoin_rspBufferOutput_valid = _zz_213_;
  assign IBusSimplePlugin_rspJoin_rspBufferOutput_payload_error = _zz_214_;
  assign IBusSimplePlugin_rspJoin_rspBufferOutput_payload_inst = _zz_215_;
  assign IBusSimplePlugin_rspJoin_fetchRsp_pc = IBusSimplePlugin_iBusRsp_stages_2_output_payload;
  always @ (*) begin
    IBusSimplePlugin_rspJoin_fetchRsp_rsp_error = IBusSimplePlugin_rspJoin_rspBufferOutput_payload_error;
    if((! IBusSimplePlugin_rspJoin_rspBufferOutput_valid))begin
      IBusSimplePlugin_rspJoin_fetchRsp_rsp_error = 1'b0;
    end
  end

  assign IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst = IBusSimplePlugin_rspJoin_rspBufferOutput_payload_inst;
  assign IBusSimplePlugin_rspJoin_issueDetected = 1'b0;
  assign IBusSimplePlugin_rspJoin_join_valid = (IBusSimplePlugin_iBusRsp_stages_2_output_valid && IBusSimplePlugin_rspJoin_rspBufferOutput_valid);
  assign IBusSimplePlugin_rspJoin_join_payload_pc = IBusSimplePlugin_rspJoin_fetchRsp_pc;
  assign IBusSimplePlugin_rspJoin_join_payload_rsp_error = IBusSimplePlugin_rspJoin_fetchRsp_rsp_error;
  assign IBusSimplePlugin_rspJoin_join_payload_rsp_inst = IBusSimplePlugin_rspJoin_fetchRsp_rsp_inst;
  assign IBusSimplePlugin_rspJoin_join_payload_isRvc = IBusSimplePlugin_rspJoin_fetchRsp_isRvc;
  assign IBusSimplePlugin_iBusRsp_stages_2_output_ready = (IBusSimplePlugin_iBusRsp_stages_2_output_valid ? (IBusSimplePlugin_rspJoin_join_valid && IBusSimplePlugin_rspJoin_join_ready) : IBusSimplePlugin_rspJoin_join_ready);
  assign IBusSimplePlugin_rspJoin_rspBufferOutput_ready = (IBusSimplePlugin_rspJoin_join_valid && IBusSimplePlugin_rspJoin_join_ready);
  assign _zz_138_ = (! IBusSimplePlugin_rspJoin_issueDetected);
  assign IBusSimplePlugin_rspJoin_join_ready = (IBusSimplePlugin_iBusRsp_inputBeforeStage_ready && _zz_138_);
  assign IBusSimplePlugin_iBusRsp_inputBeforeStage_valid = (IBusSimplePlugin_rspJoin_join_valid && _zz_138_);
  assign IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_pc = IBusSimplePlugin_rspJoin_join_payload_pc;
  assign IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_error = IBusSimplePlugin_rspJoin_join_payload_rsp_error;
  assign IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_raw = IBusSimplePlugin_rspJoin_join_payload_rsp_inst;
  assign IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_isRvc = IBusSimplePlugin_rspJoin_join_payload_isRvc;
  assign _zz_81_ = (((dBus_cmd_payload_size == (2'b10)) && (dBus_cmd_payload_address[1 : 0] != (2'b00))) || ((dBus_cmd_payload_size == (2'b01)) && (dBus_cmd_payload_address[0 : 0] != (1'b0))));
  assign dBus_cmd_valid = ((((memory_arbitration_isValid && memory_MEMORY_ENABLE) && (! memory_arbitration_isStuckByOthers)) && (! memory_arbitration_isFlushed)) && (! memory_ALIGNEMENT_FAULT));
  assign dBus_cmd_payload_wr = memory_INSTRUCTION[5];
  assign dBus_cmd_payload_address = memory_SRC_ADD;
  assign dBus_cmd_payload_size = memory_INSTRUCTION[13 : 12];
  always @ (*) begin
    case(dBus_cmd_payload_size)
      2'b00 : begin
        _zz_139_ = {{{memory_RS2[7 : 0],memory_RS2[7 : 0]},memory_RS2[7 : 0]},memory_RS2[7 : 0]};
      end
      2'b01 : begin
        _zz_139_ = {memory_RS2[15 : 0],memory_RS2[15 : 0]};
      end
      default : begin
        _zz_139_ = memory_RS2[31 : 0];
      end
    endcase
  end

  assign dBus_cmd_payload_data = _zz_139_;
  assign _zz_80_ = dBus_cmd_payload_address[1 : 0];
  always @ (*) begin
    case(dBus_cmd_payload_size)
      2'b00 : begin
        _zz_140_ = (4'b0001);
      end
      2'b01 : begin
        _zz_140_ = (4'b0011);
      end
      default : begin
        _zz_140_ = (4'b1111);
      end
    endcase
  end

  assign memory_DBusSimplePlugin_formalMask = (_zz_140_ <<< dBus_cmd_payload_address[1 : 0]);
  assign _zz_79_ = dBus_rsp_data;
  assign writeBack_exception_agregat_payload_code = {1'd0, _zz_255_};
  always @ (*) begin
    writeBack_exception_agregat_valid = writeBack_ALIGNEMENT_FAULT;
    if((! (writeBack_arbitration_isValid && writeBack_MEMORY_ENABLE)))begin
      writeBack_exception_agregat_valid = 1'b0;
    end
  end

  assign writeBack_exception_agregat_payload_badAddr = writeBack_REGFILE_WRITE_DATA;
  always @ (*) begin
    writeBack_DBusSimplePlugin_rspShifted = writeBack_MEMORY_READ_DATA;
    case(writeBack_MEMORY_ADDRESS_LOW)
      2'b01 : begin
        writeBack_DBusSimplePlugin_rspShifted[7 : 0] = writeBack_MEMORY_READ_DATA[15 : 8];
      end
      2'b10 : begin
        writeBack_DBusSimplePlugin_rspShifted[15 : 0] = writeBack_MEMORY_READ_DATA[31 : 16];
      end
      2'b11 : begin
        writeBack_DBusSimplePlugin_rspShifted[7 : 0] = writeBack_MEMORY_READ_DATA[31 : 24];
      end
      default : begin
      end
    endcase
  end

  assign _zz_141_ = (writeBack_DBusSimplePlugin_rspShifted[7] && (! writeBack_INSTRUCTION[14]));
  always @ (*) begin
    _zz_142_[31] = _zz_141_;
    _zz_142_[30] = _zz_141_;
    _zz_142_[29] = _zz_141_;
    _zz_142_[28] = _zz_141_;
    _zz_142_[27] = _zz_141_;
    _zz_142_[26] = _zz_141_;
    _zz_142_[25] = _zz_141_;
    _zz_142_[24] = _zz_141_;
    _zz_142_[23] = _zz_141_;
    _zz_142_[22] = _zz_141_;
    _zz_142_[21] = _zz_141_;
    _zz_142_[20] = _zz_141_;
    _zz_142_[19] = _zz_141_;
    _zz_142_[18] = _zz_141_;
    _zz_142_[17] = _zz_141_;
    _zz_142_[16] = _zz_141_;
    _zz_142_[15] = _zz_141_;
    _zz_142_[14] = _zz_141_;
    _zz_142_[13] = _zz_141_;
    _zz_142_[12] = _zz_141_;
    _zz_142_[11] = _zz_141_;
    _zz_142_[10] = _zz_141_;
    _zz_142_[9] = _zz_141_;
    _zz_142_[8] = _zz_141_;
    _zz_142_[7 : 0] = writeBack_DBusSimplePlugin_rspShifted[7 : 0];
  end

  assign _zz_143_ = (writeBack_DBusSimplePlugin_rspShifted[15] && (! writeBack_INSTRUCTION[14]));
  always @ (*) begin
    _zz_144_[31] = _zz_143_;
    _zz_144_[30] = _zz_143_;
    _zz_144_[29] = _zz_143_;
    _zz_144_[28] = _zz_143_;
    _zz_144_[27] = _zz_143_;
    _zz_144_[26] = _zz_143_;
    _zz_144_[25] = _zz_143_;
    _zz_144_[24] = _zz_143_;
    _zz_144_[23] = _zz_143_;
    _zz_144_[22] = _zz_143_;
    _zz_144_[21] = _zz_143_;
    _zz_144_[20] = _zz_143_;
    _zz_144_[19] = _zz_143_;
    _zz_144_[18] = _zz_143_;
    _zz_144_[17] = _zz_143_;
    _zz_144_[16] = _zz_143_;
    _zz_144_[15 : 0] = writeBack_DBusSimplePlugin_rspShifted[15 : 0];
  end

  always @ (*) begin
    case(_zz_225_)
      2'b00 : begin
        writeBack_DBusSimplePlugin_rspFormated = _zz_142_;
      end
      2'b01 : begin
        writeBack_DBusSimplePlugin_rspFormated = _zz_144_;
      end
      default : begin
        writeBack_DBusSimplePlugin_rspFormated = writeBack_DBusSimplePlugin_rspShifted;
      end
    endcase
  end

  assign CsrPlugin_misa_base = (2'b01);
  assign CsrPlugin_misa_extensions = (26'b00000000000000000000000000);
  assign CsrPlugin_medeleg = (32'b00000000000000000000000000000000);
  assign CsrPlugin_mideleg = (32'b00000000000000000000000000000000);
  assign _zz_145_ = (CsrPlugin_mip_MTIP && CsrPlugin_mie_MTIE);
  assign _zz_146_ = (CsrPlugin_mip_MSIP && CsrPlugin_mie_MSIE);
  assign _zz_147_ = (CsrPlugin_mip_MEIP && CsrPlugin_mie_MEIE);
  assign CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode = 1'b0;
  assign CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege = CsrPlugin_privilege;
  assign CsrPlugin_exceptionPortCtrl_exceptionValids_decode = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_decode;
  always @ (*) begin
    CsrPlugin_exceptionPortCtrl_exceptionValids_memory = CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory;
    if(memory_exception_agregat_valid)begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_memory = 1'b1;
    end
    if(memory_arbitration_isFlushed)begin
      CsrPlugin_exceptionPortCtrl_exceptionValids_memory = 1'b0;
    end
  end

  always @ (*) begin
    CsrPlugin_interrupt = 1'b0;
    CsrPlugin_interruptCode = (4'bxxxx);
    CsrPlugin_interruptTargetPrivilege = (2'bxx);
    if(CsrPlugin_mstatus_MIE)begin
      if(((_zz_145_ || _zz_146_) || _zz_147_))begin
        CsrPlugin_interrupt = 1'b1;
      end
      if(_zz_145_)begin
        CsrPlugin_interruptCode = (4'b0111);
        CsrPlugin_interruptTargetPrivilege = (2'b11);
      end
      if(_zz_146_)begin
        CsrPlugin_interruptCode = (4'b0011);
        CsrPlugin_interruptTargetPrivilege = (2'b11);
      end
      if(_zz_147_)begin
        CsrPlugin_interruptCode = (4'b1011);
        CsrPlugin_interruptTargetPrivilege = (2'b11);
      end
    end
    if((! 1'b1))begin
      CsrPlugin_interrupt = 1'b0;
    end
  end

  assign CsrPlugin_exception = (CsrPlugin_exceptionPortCtrl_exceptionValids_writeBack && 1'b1);
  assign CsrPlugin_writeBackWasWfi = 1'b0;
  always @ (*) begin
    CsrPlugin_pipelineLiberator_done = ((! ((execute_arbitration_isValid || memory_arbitration_isValid) || writeBack_arbitration_isValid)) && IBusSimplePlugin_injector_nextPcCalc_3);
    if(((CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute || CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory) || CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack))begin
      CsrPlugin_pipelineLiberator_done = 1'b0;
    end
    if(CsrPlugin_hadException)begin
      CsrPlugin_pipelineLiberator_done = 1'b0;
    end
  end

  assign CsrPlugin_interruptJump = (CsrPlugin_interrupt && CsrPlugin_pipelineLiberator_done);
  always @ (*) begin
    CsrPlugin_targetPrivilege = CsrPlugin_interruptTargetPrivilege;
    if(CsrPlugin_hadException)begin
      CsrPlugin_targetPrivilege = CsrPlugin_exceptionPortCtrl_exceptionTargetPrivilege;
    end
  end

  always @ (*) begin
    CsrPlugin_trapCause = CsrPlugin_interruptCode;
    if(CsrPlugin_hadException)begin
      CsrPlugin_trapCause = CsrPlugin_exceptionPortCtrl_exceptionContext_code;
    end
  end

  assign contextSwitching = _zz_98_;
  assign _zz_76_ = (! (((decode_INSTRUCTION[14 : 13] == (2'b01)) && (decode_INSTRUCTION[19 : 15] == (5'b00000))) || ((decode_INSTRUCTION[14 : 13] == (2'b11)) && (decode_INSTRUCTION[19 : 15] == (5'b00000)))));
  assign _zz_75_ = (decode_INSTRUCTION[13 : 7] != (7'b0100000));
  assign execute_CsrPlugin_blockedBySideEffects = (memory_arbitration_isValid || writeBack_arbitration_isValid);
  always @ (*) begin
    execute_CsrPlugin_illegalAccess = (execute_arbitration_isValid && execute_IS_CSR);
    execute_CsrPlugin_readData = (32'b00000000000000000000000000000000);
    case(execute_CsrPlugin_csrAddress)
      12'b001100000000 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[12 : 11] = CsrPlugin_mstatus_MPP;
        execute_CsrPlugin_readData[7 : 7] = CsrPlugin_mstatus_MPIE;
        execute_CsrPlugin_readData[3 : 3] = CsrPlugin_mstatus_MIE;
      end
      12'b001101000001 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[31 : 0] = CsrPlugin_mepc;
      end
      12'b001100000101 : begin
        if(execute_CSR_WRITE_OPCODE)begin
          execute_CsrPlugin_illegalAccess = 1'b0;
        end
      end
      12'b001101000100 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[11 : 11] = CsrPlugin_mip_MEIP;
        execute_CsrPlugin_readData[7 : 7] = CsrPlugin_mip_MTIP;
        execute_CsrPlugin_readData[3 : 3] = CsrPlugin_mip_MSIP;
      end
      12'b001101000011 : begin
        if(execute_CSR_READ_OPCODE)begin
          execute_CsrPlugin_illegalAccess = 1'b0;
        end
        execute_CsrPlugin_readData[31 : 0] = CsrPlugin_mtval;
      end
      12'b001101000000 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[31 : 0] = CsrPlugin_mscratch;
      end
      12'b001100000001 : begin
        if(execute_CSR_READ_OPCODE)begin
          execute_CsrPlugin_illegalAccess = 1'b0;
        end
        execute_CsrPlugin_readData[31 : 30] = CsrPlugin_misa_base;
        execute_CsrPlugin_readData[25 : 0] = CsrPlugin_misa_extensions;
      end
      12'b001100000100 : begin
        execute_CsrPlugin_illegalAccess = 1'b0;
        execute_CsrPlugin_readData[11 : 11] = CsrPlugin_mie_MEIE;
        execute_CsrPlugin_readData[7 : 7] = CsrPlugin_mie_MTIE;
        execute_CsrPlugin_readData[3 : 3] = CsrPlugin_mie_MSIE;
      end
      12'b001101000010 : begin
        if(execute_CSR_READ_OPCODE)begin
          execute_CsrPlugin_illegalAccess = 1'b0;
        end
        execute_CsrPlugin_readData[31 : 31] = CsrPlugin_mcause_interrupt;
        execute_CsrPlugin_readData[3 : 0] = CsrPlugin_mcause_exceptionCode;
      end
      default : begin
      end
    endcase
    if((CsrPlugin_privilege < execute_CsrPlugin_csrAddress[9 : 8]))begin
      execute_CsrPlugin_illegalAccess = 1'b1;
    end
  end

  always @ (*) begin
    execute_CsrPlugin_illegalInstruction = 1'b0;
    if((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_XRET)))begin
      if((execute_INSTRUCTION[29 : 28] != CsrPlugin_privilege))begin
        execute_CsrPlugin_illegalInstruction = 1'b1;
      end
    end
  end

  always @ (*) begin
    execute_exception_agregat_valid = (execute_CsrPlugin_illegalAccess || execute_CsrPlugin_illegalInstruction);
    execute_exception_agregat_payload_code = (4'b0010);
    if((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_ECALL)))begin
      execute_exception_agregat_valid = 1'b1;
      execute_exception_agregat_payload_code = (4'b1011);
    end
    if((execute_arbitration_isValid && (execute_ENV_CTRL == `EnvCtrlEnum_defaultEncoding_EBREAK)))begin
      execute_exception_agregat_valid = 1'b1;
      execute_exception_agregat_payload_code = (4'b0011);
    end
  end

  assign execute_exception_agregat_payload_badAddr = (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
  assign execute_CsrPlugin_writeInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_WRITE_OPCODE);
  assign execute_CsrPlugin_readInstruction = ((execute_arbitration_isValid && execute_IS_CSR) && execute_CSR_READ_OPCODE);
  assign execute_CsrPlugin_writeEnable = (execute_CsrPlugin_writeInstruction && (! execute_CsrPlugin_blockedBySideEffects));
  assign execute_CsrPlugin_readEnable = (execute_CsrPlugin_readInstruction && (! execute_CsrPlugin_blockedBySideEffects));
  always @ (*) begin
    case(_zz_227_)
      1'b0 : begin
        execute_CsrPlugin_writeData = execute_SRC1;
      end
      default : begin
        execute_CsrPlugin_writeData = (execute_INSTRUCTION[12] ? (execute_CsrPlugin_readData & (~ execute_SRC1)) : (execute_CsrPlugin_readData | execute_SRC1));
      end
    endcase
  end

  assign execute_CsrPlugin_csrAddress = execute_INSTRUCTION[31 : 20];
  assign _zz_149_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000010100)) == (32'b00000000000000000000000000000100));
  assign _zz_150_ = ((decode_INSTRUCTION & (32'b00000000000000000111000000000000)) == (32'b00000000000000000001000000000000));
  assign _zz_151_ = ((decode_INSTRUCTION & (32'b00000000000000000101000000000000)) == (32'b00000000000000000100000000000000));
  assign _zz_152_ = ((decode_INSTRUCTION & (32'b00000000000000000100000001010000)) == (32'b00000000000000000100000001010000));
  assign _zz_153_ = ((decode_INSTRUCTION & (32'b00000000000000000011000000000000)) == (32'b00000000000000000010000000000000));
  assign _zz_154_ = ((decode_INSTRUCTION & (32'b00000000000000000000000000000100)) == (32'b00000000000000000000000000000100));
  assign _zz_148_ = {({(_zz_340_ == _zz_341_),(_zz_342_ == _zz_343_)} != (2'b00)),{((_zz_344_ == _zz_345_) != (1'b0)),{({_zz_346_,_zz_347_} != (2'b00)),{(_zz_348_ != _zz_349_),{_zz_350_,{_zz_351_,_zz_352_}}}}}};
  assign _zz_71_ = _zz_256_[0];
  assign _zz_70_ = _zz_257_[0];
  assign _zz_69_ = _zz_258_[0];
  assign _zz_68_ = _zz_259_[0];
  assign _zz_155_ = _zz_148_[6 : 5];
  assign _zz_67_ = _zz_155_;
  assign _zz_66_ = _zz_260_[0];
  assign _zz_156_ = _zz_148_[9 : 8];
  assign _zz_65_ = _zz_156_;
  assign _zz_64_ = _zz_261_[0];
  assign _zz_63_ = _zz_262_[0];
  assign _zz_62_ = _zz_263_[0];
  assign _zz_157_ = _zz_148_[14 : 13];
  assign _zz_61_ = _zz_157_;
  assign _zz_60_ = _zz_264_[0];
  assign _zz_158_ = _zz_148_[17 : 16];
  assign _zz_59_ = _zz_158_;
  assign _zz_58_ = _zz_265_[0];
  assign _zz_159_ = _zz_148_[20 : 19];
  assign _zz_57_ = _zz_159_;
  assign _zz_56_ = _zz_266_[0];
  assign _zz_55_ = _zz_267_[0];
  assign _zz_54_ = _zz_268_[0];
  assign _zz_53_ = _zz_269_[0];
  assign _zz_160_ = _zz_148_[26 : 25];
  assign _zz_52_ = _zz_160_;
  assign _zz_161_ = _zz_148_[28 : 27];
  assign _zz_51_ = _zz_161_;
  assign decode_RegFilePlugin_regFileReadAddress1 = decode_INSTRUCTION_ANTICIPATED[19 : 15];
  assign decode_RegFilePlugin_regFileReadAddress2 = decode_INSTRUCTION_ANTICIPATED[24 : 20];
  assign decode_RegFilePlugin_rs1Data = _zz_209_;
  assign decode_RegFilePlugin_rs2Data = _zz_210_;
  assign _zz_50_ = decode_RegFilePlugin_rs1Data;
  assign _zz_49_ = decode_RegFilePlugin_rs2Data;
  always @ (*) begin
    writeBack_RegFilePlugin_regFileWrite_valid = (_zz_47_ && writeBack_arbitration_isFiring);
    if(_zz_162_)begin
      writeBack_RegFilePlugin_regFileWrite_valid = 1'b1;
    end
  end

  assign writeBack_RegFilePlugin_regFileWrite_payload_address = _zz_46_[11 : 7];
  assign writeBack_RegFilePlugin_regFileWrite_payload_data = _zz_78_;
  always @ (*) begin
    memory_MulDivIterativePlugin_mul_counter_willClear = 1'b0;
    if((! memory_arbitration_isStuck))begin
      memory_MulDivIterativePlugin_mul_counter_willClear = 1'b1;
    end
  end

  assign memory_MulDivIterativePlugin_mul_willOverflowIfInc = (memory_MulDivIterativePlugin_mul_counter_value == (4'b1000));
  assign memory_MulDivIterativePlugin_mul_counter_willOverflow = (memory_MulDivIterativePlugin_mul_willOverflowIfInc && memory_MulDivIterativePlugin_mul_counter_willIncrement);
  always @ (*) begin
    if(memory_MulDivIterativePlugin_mul_counter_willOverflow)begin
      memory_MulDivIterativePlugin_mul_counter_valueNext = (4'b0000);
    end else begin
      memory_MulDivIterativePlugin_mul_counter_valueNext = (memory_MulDivIterativePlugin_mul_counter_value + _zz_271_);
    end
    if(memory_MulDivIterativePlugin_mul_counter_willClear)begin
      memory_MulDivIterativePlugin_mul_counter_valueNext = (4'b0000);
    end
  end

  always @ (*) begin
    memory_MulDivIterativePlugin_div_counter_willClear = 1'b0;
    if(_zz_224_)begin
      memory_MulDivIterativePlugin_div_counter_willClear = 1'b1;
    end
  end

  assign memory_MulDivIterativePlugin_div_counter_willOverflowIfInc = (memory_MulDivIterativePlugin_div_counter_value == (6'b100001));
  assign memory_MulDivIterativePlugin_div_counter_willOverflow = (memory_MulDivIterativePlugin_div_counter_willOverflowIfInc && memory_MulDivIterativePlugin_div_counter_willIncrement);
  always @ (*) begin
    if(memory_MulDivIterativePlugin_div_counter_willOverflow)begin
      memory_MulDivIterativePlugin_div_counter_valueNext = (6'b000000);
    end else begin
      memory_MulDivIterativePlugin_div_counter_valueNext = (memory_MulDivIterativePlugin_div_counter_value + _zz_291_);
    end
    if(memory_MulDivIterativePlugin_div_counter_willClear)begin
      memory_MulDivIterativePlugin_div_counter_valueNext = (6'b000000);
    end
  end

  assign _zz_163_ = memory_MulDivIterativePlugin_rs1[31 : 0];
  assign _zz_164_ = {memory_MulDivIterativePlugin_accumulator[31 : 0],_zz_163_[31]};
  assign _zz_165_ = (_zz_164_ - _zz_292_);
  assign _zz_166_ = (memory_INSTRUCTION[13] ? memory_MulDivIterativePlugin_accumulator[31 : 0] : memory_MulDivIterativePlugin_rs1[31 : 0]);
  assign _zz_167_ = (execute_RS2[31] && execute_IS_RS2_SIGNED);
  assign _zz_168_ = ((execute_IS_MUL && _zz_167_) || ((execute_IS_DIV && execute_RS1[31]) && execute_IS_RS1_SIGNED));
  always @ (*) begin
    _zz_169_[32] = (execute_IS_RS1_SIGNED && execute_RS1[31]);
    _zz_169_[31 : 0] = execute_RS1;
  end

  always @ (*) begin
    case(execute_ALU_BITWISE_CTRL)
      `AluBitwiseCtrlEnum_defaultEncoding_AND_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 & execute_SRC2);
      end
      `AluBitwiseCtrlEnum_defaultEncoding_OR_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 | execute_SRC2);
      end
      `AluBitwiseCtrlEnum_defaultEncoding_XOR_1 : begin
        execute_IntAluPlugin_bitwise = (execute_SRC1 ^ execute_SRC2);
      end
      default : begin
        execute_IntAluPlugin_bitwise = execute_SRC1;
      end
    endcase
  end

  always @ (*) begin
    case(execute_ALU_CTRL)
      `AluCtrlEnum_defaultEncoding_BITWISE : begin
        _zz_170_ = execute_IntAluPlugin_bitwise;
      end
      `AluCtrlEnum_defaultEncoding_SLT_SLTU : begin
        _zz_170_ = {31'd0, _zz_305_};
      end
      default : begin
        _zz_170_ = execute_SRC_ADD_SUB;
      end
    endcase
  end

  assign _zz_43_ = _zz_170_;
  always @ (*) begin
    case(decode_SRC1_CTRL)
      `Src1CtrlEnum_defaultEncoding_RS : begin
        _zz_171_ = _zz_39_;
      end
      `Src1CtrlEnum_defaultEncoding_PC_INCREMENT : begin
        _zz_171_ = {29'd0, _zz_306_};
      end
      `Src1CtrlEnum_defaultEncoding_IMU : begin
        _zz_171_ = {decode_INSTRUCTION[31 : 12],(12'b000000000000)};
      end
      default : begin
        _zz_171_ = {27'd0, _zz_307_};
      end
    endcase
  end

  assign _zz_41_ = _zz_171_;
  assign _zz_172_ = _zz_308_[11];
  always @ (*) begin
    _zz_173_[19] = _zz_172_;
    _zz_173_[18] = _zz_172_;
    _zz_173_[17] = _zz_172_;
    _zz_173_[16] = _zz_172_;
    _zz_173_[15] = _zz_172_;
    _zz_173_[14] = _zz_172_;
    _zz_173_[13] = _zz_172_;
    _zz_173_[12] = _zz_172_;
    _zz_173_[11] = _zz_172_;
    _zz_173_[10] = _zz_172_;
    _zz_173_[9] = _zz_172_;
    _zz_173_[8] = _zz_172_;
    _zz_173_[7] = _zz_172_;
    _zz_173_[6] = _zz_172_;
    _zz_173_[5] = _zz_172_;
    _zz_173_[4] = _zz_172_;
    _zz_173_[3] = _zz_172_;
    _zz_173_[2] = _zz_172_;
    _zz_173_[1] = _zz_172_;
    _zz_173_[0] = _zz_172_;
  end

  assign _zz_174_ = _zz_309_[11];
  always @ (*) begin
    _zz_175_[19] = _zz_174_;
    _zz_175_[18] = _zz_174_;
    _zz_175_[17] = _zz_174_;
    _zz_175_[16] = _zz_174_;
    _zz_175_[15] = _zz_174_;
    _zz_175_[14] = _zz_174_;
    _zz_175_[13] = _zz_174_;
    _zz_175_[12] = _zz_174_;
    _zz_175_[11] = _zz_174_;
    _zz_175_[10] = _zz_174_;
    _zz_175_[9] = _zz_174_;
    _zz_175_[8] = _zz_174_;
    _zz_175_[7] = _zz_174_;
    _zz_175_[6] = _zz_174_;
    _zz_175_[5] = _zz_174_;
    _zz_175_[4] = _zz_174_;
    _zz_175_[3] = _zz_174_;
    _zz_175_[2] = _zz_174_;
    _zz_175_[1] = _zz_174_;
    _zz_175_[0] = _zz_174_;
  end

  always @ (*) begin
    case(decode_SRC2_CTRL)
      `Src2CtrlEnum_defaultEncoding_RS : begin
        _zz_176_ = _zz_36_;
      end
      `Src2CtrlEnum_defaultEncoding_IMI : begin
        _zz_176_ = {_zz_173_,decode_INSTRUCTION[31 : 20]};
      end
      `Src2CtrlEnum_defaultEncoding_IMS : begin
        _zz_176_ = {_zz_175_,{decode_INSTRUCTION[31 : 25],decode_INSTRUCTION[11 : 7]}};
      end
      default : begin
        _zz_176_ = _zz_35_;
      end
    endcase
  end

  assign _zz_38_ = _zz_176_;
  assign execute_SrcPlugin_add = _zz_310_;
  assign execute_SrcPlugin_sub = _zz_311_;
  assign execute_SrcPlugin_less = ((execute_SRC1[31] == execute_SRC2[31]) ? execute_SrcPlugin_sub[31] : (execute_SRC_LESS_UNSIGNED ? execute_SRC2[31] : execute_SRC1[31]));
  assign _zz_34_ = (execute_SRC_USE_SUB_LESS ? execute_SrcPlugin_sub : execute_SrcPlugin_add);
  assign _zz_33_ = execute_SrcPlugin_add;
  assign _zz_32_ = execute_SrcPlugin_less;
  assign execute_FullBarrelShifterPlugin_amplitude = execute_SRC2[4 : 0];
  always @ (*) begin
    _zz_177_[0] = execute_SRC1[31];
    _zz_177_[1] = execute_SRC1[30];
    _zz_177_[2] = execute_SRC1[29];
    _zz_177_[3] = execute_SRC1[28];
    _zz_177_[4] = execute_SRC1[27];
    _zz_177_[5] = execute_SRC1[26];
    _zz_177_[6] = execute_SRC1[25];
    _zz_177_[7] = execute_SRC1[24];
    _zz_177_[8] = execute_SRC1[23];
    _zz_177_[9] = execute_SRC1[22];
    _zz_177_[10] = execute_SRC1[21];
    _zz_177_[11] = execute_SRC1[20];
    _zz_177_[12] = execute_SRC1[19];
    _zz_177_[13] = execute_SRC1[18];
    _zz_177_[14] = execute_SRC1[17];
    _zz_177_[15] = execute_SRC1[16];
    _zz_177_[16] = execute_SRC1[15];
    _zz_177_[17] = execute_SRC1[14];
    _zz_177_[18] = execute_SRC1[13];
    _zz_177_[19] = execute_SRC1[12];
    _zz_177_[20] = execute_SRC1[11];
    _zz_177_[21] = execute_SRC1[10];
    _zz_177_[22] = execute_SRC1[9];
    _zz_177_[23] = execute_SRC1[8];
    _zz_177_[24] = execute_SRC1[7];
    _zz_177_[25] = execute_SRC1[6];
    _zz_177_[26] = execute_SRC1[5];
    _zz_177_[27] = execute_SRC1[4];
    _zz_177_[28] = execute_SRC1[3];
    _zz_177_[29] = execute_SRC1[2];
    _zz_177_[30] = execute_SRC1[1];
    _zz_177_[31] = execute_SRC1[0];
  end

  assign execute_FullBarrelShifterPlugin_reversed = ((execute_SHIFT_CTRL == `ShiftCtrlEnum_defaultEncoding_SLL_1) ? _zz_177_ : execute_SRC1);
  assign _zz_30_ = _zz_313_;
  always @ (*) begin
    _zz_178_[0] = memory_SHIFT_RIGHT[31];
    _zz_178_[1] = memory_SHIFT_RIGHT[30];
    _zz_178_[2] = memory_SHIFT_RIGHT[29];
    _zz_178_[3] = memory_SHIFT_RIGHT[28];
    _zz_178_[4] = memory_SHIFT_RIGHT[27];
    _zz_178_[5] = memory_SHIFT_RIGHT[26];
    _zz_178_[6] = memory_SHIFT_RIGHT[25];
    _zz_178_[7] = memory_SHIFT_RIGHT[24];
    _zz_178_[8] = memory_SHIFT_RIGHT[23];
    _zz_178_[9] = memory_SHIFT_RIGHT[22];
    _zz_178_[10] = memory_SHIFT_RIGHT[21];
    _zz_178_[11] = memory_SHIFT_RIGHT[20];
    _zz_178_[12] = memory_SHIFT_RIGHT[19];
    _zz_178_[13] = memory_SHIFT_RIGHT[18];
    _zz_178_[14] = memory_SHIFT_RIGHT[17];
    _zz_178_[15] = memory_SHIFT_RIGHT[16];
    _zz_178_[16] = memory_SHIFT_RIGHT[15];
    _zz_178_[17] = memory_SHIFT_RIGHT[14];
    _zz_178_[18] = memory_SHIFT_RIGHT[13];
    _zz_178_[19] = memory_SHIFT_RIGHT[12];
    _zz_178_[20] = memory_SHIFT_RIGHT[11];
    _zz_178_[21] = memory_SHIFT_RIGHT[10];
    _zz_178_[22] = memory_SHIFT_RIGHT[9];
    _zz_178_[23] = memory_SHIFT_RIGHT[8];
    _zz_178_[24] = memory_SHIFT_RIGHT[7];
    _zz_178_[25] = memory_SHIFT_RIGHT[6];
    _zz_178_[26] = memory_SHIFT_RIGHT[5];
    _zz_178_[27] = memory_SHIFT_RIGHT[4];
    _zz_178_[28] = memory_SHIFT_RIGHT[3];
    _zz_178_[29] = memory_SHIFT_RIGHT[2];
    _zz_178_[30] = memory_SHIFT_RIGHT[1];
    _zz_178_[31] = memory_SHIFT_RIGHT[0];
  end

  always @ (*) begin
    _zz_179_ = 1'b0;
    _zz_180_ = 1'b0;
    if((writeBack_arbitration_isValid && writeBack_REGFILE_WRITE_VALID))begin
      if((1'b0 || (! 1'b1)))begin
        if(_zz_184_)begin
          _zz_179_ = 1'b1;
        end
        if(_zz_185_)begin
          _zz_180_ = 1'b1;
        end
      end
    end
    if((memory_arbitration_isValid && memory_REGFILE_WRITE_VALID))begin
      if((1'b0 || (! memory_BYPASSABLE_MEMORY_STAGE)))begin
        if(_zz_186_)begin
          _zz_179_ = 1'b1;
        end
        if(_zz_187_)begin
          _zz_180_ = 1'b1;
        end
      end
    end
    if((execute_arbitration_isValid && execute_REGFILE_WRITE_VALID))begin
      if((1'b0 || (! execute_BYPASSABLE_EXECUTE_STAGE)))begin
        if(_zz_188_)begin
          _zz_179_ = 1'b1;
        end
        if(_zz_189_)begin
          _zz_180_ = 1'b1;
        end
      end
    end
    if((! decode_RS1_USE))begin
      _zz_179_ = 1'b0;
    end
    if((! decode_RS2_USE))begin
      _zz_180_ = 1'b0;
    end
  end

  assign _zz_184_ = (writeBack_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]);
  assign _zz_185_ = (writeBack_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]);
  assign _zz_186_ = (memory_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]);
  assign _zz_187_ = (memory_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]);
  assign _zz_188_ = (execute_INSTRUCTION[11 : 7] == decode_INSTRUCTION[19 : 15]);
  assign _zz_189_ = (execute_INSTRUCTION[11 : 7] == decode_INSTRUCTION[24 : 20]);
  assign _zz_28_ = (_zz_97_ && (! decode_IS_FENCEI));
  assign execute_BranchPlugin_eq = (execute_SRC1 == execute_SRC2);
  assign _zz_190_ = execute_INSTRUCTION[14 : 12];
  always @ (*) begin
    if((_zz_190_ == (3'b000))) begin
        _zz_191_ = execute_BranchPlugin_eq;
    end else if((_zz_190_ == (3'b001))) begin
        _zz_191_ = (! execute_BranchPlugin_eq);
    end else if((((_zz_190_ & (3'b101)) == (3'b101)))) begin
        _zz_191_ = (! execute_SRC_LESS);
    end else begin
        _zz_191_ = execute_SRC_LESS;
    end
  end

  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_INC : begin
        _zz_192_ = 1'b0;
      end
      `BranchCtrlEnum_defaultEncoding_JAL : begin
        _zz_192_ = 1'b1;
      end
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        _zz_192_ = 1'b1;
      end
      default : begin
        _zz_192_ = _zz_191_;
      end
    endcase
  end

  assign _zz_27_ = _zz_192_;
  assign _zz_193_ = _zz_315_[11];
  always @ (*) begin
    _zz_194_[19] = _zz_193_;
    _zz_194_[18] = _zz_193_;
    _zz_194_[17] = _zz_193_;
    _zz_194_[16] = _zz_193_;
    _zz_194_[15] = _zz_193_;
    _zz_194_[14] = _zz_193_;
    _zz_194_[13] = _zz_193_;
    _zz_194_[12] = _zz_193_;
    _zz_194_[11] = _zz_193_;
    _zz_194_[10] = _zz_193_;
    _zz_194_[9] = _zz_193_;
    _zz_194_[8] = _zz_193_;
    _zz_194_[7] = _zz_193_;
    _zz_194_[6] = _zz_193_;
    _zz_194_[5] = _zz_193_;
    _zz_194_[4] = _zz_193_;
    _zz_194_[3] = _zz_193_;
    _zz_194_[2] = _zz_193_;
    _zz_194_[1] = _zz_193_;
    _zz_194_[0] = _zz_193_;
  end

  assign _zz_195_ = _zz_316_[19];
  always @ (*) begin
    _zz_196_[10] = _zz_195_;
    _zz_196_[9] = _zz_195_;
    _zz_196_[8] = _zz_195_;
    _zz_196_[7] = _zz_195_;
    _zz_196_[6] = _zz_195_;
    _zz_196_[5] = _zz_195_;
    _zz_196_[4] = _zz_195_;
    _zz_196_[3] = _zz_195_;
    _zz_196_[2] = _zz_195_;
    _zz_196_[1] = _zz_195_;
    _zz_196_[0] = _zz_195_;
  end

  assign _zz_197_ = _zz_317_[11];
  always @ (*) begin
    _zz_198_[18] = _zz_197_;
    _zz_198_[17] = _zz_197_;
    _zz_198_[16] = _zz_197_;
    _zz_198_[15] = _zz_197_;
    _zz_198_[14] = _zz_197_;
    _zz_198_[13] = _zz_197_;
    _zz_198_[12] = _zz_197_;
    _zz_198_[11] = _zz_197_;
    _zz_198_[10] = _zz_197_;
    _zz_198_[9] = _zz_197_;
    _zz_198_[8] = _zz_197_;
    _zz_198_[7] = _zz_197_;
    _zz_198_[6] = _zz_197_;
    _zz_198_[5] = _zz_197_;
    _zz_198_[4] = _zz_197_;
    _zz_198_[3] = _zz_197_;
    _zz_198_[2] = _zz_197_;
    _zz_198_[1] = _zz_197_;
    _zz_198_[0] = _zz_197_;
  end

  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        _zz_199_ = (_zz_318_[1] ^ execute_RS1[1]);
      end
      `BranchCtrlEnum_defaultEncoding_JAL : begin
        _zz_199_ = _zz_319_[1];
      end
      default : begin
        _zz_199_ = _zz_320_[1];
      end
    endcase
  end

  assign execute_BranchPlugin_missAlignedTarget = (execute_BRANCH_COND_RESULT && _zz_199_);
  assign _zz_25_ = ((execute_PREDICTION_HAD_BRANCHED2 != execute_BRANCH_COND_RESULT) || execute_BranchPlugin_missAlignedTarget);
  always @ (*) begin
    case(execute_BRANCH_CTRL)
      `BranchCtrlEnum_defaultEncoding_JALR : begin
        execute_BranchPlugin_branch_src1 = execute_RS1;
        execute_BranchPlugin_branch_src2 = {_zz_201_,execute_INSTRUCTION[31 : 20]};
      end
      default : begin
        execute_BranchPlugin_branch_src1 = execute_PC;
        execute_BranchPlugin_branch_src2 = ((execute_BRANCH_CTRL == `BranchCtrlEnum_defaultEncoding_JAL) ? {{_zz_203_,{{{_zz_468_,execute_INSTRUCTION[19 : 12]},execute_INSTRUCTION[20]},execute_INSTRUCTION[30 : 21]}},1'b0} : {{_zz_205_,{{{_zz_469_,_zz_470_},execute_INSTRUCTION[30 : 25]},execute_INSTRUCTION[11 : 8]}},1'b0});
        if((execute_PREDICTION_HAD_BRANCHED2 && (! execute_BranchPlugin_missAlignedTarget)))begin
          execute_BranchPlugin_branch_src2 = {29'd0, _zz_324_};
        end
      end
    endcase
  end

  assign _zz_200_ = _zz_321_[11];
  always @ (*) begin
    _zz_201_[19] = _zz_200_;
    _zz_201_[18] = _zz_200_;
    _zz_201_[17] = _zz_200_;
    _zz_201_[16] = _zz_200_;
    _zz_201_[15] = _zz_200_;
    _zz_201_[14] = _zz_200_;
    _zz_201_[13] = _zz_200_;
    _zz_201_[12] = _zz_200_;
    _zz_201_[11] = _zz_200_;
    _zz_201_[10] = _zz_200_;
    _zz_201_[9] = _zz_200_;
    _zz_201_[8] = _zz_200_;
    _zz_201_[7] = _zz_200_;
    _zz_201_[6] = _zz_200_;
    _zz_201_[5] = _zz_200_;
    _zz_201_[4] = _zz_200_;
    _zz_201_[3] = _zz_200_;
    _zz_201_[2] = _zz_200_;
    _zz_201_[1] = _zz_200_;
    _zz_201_[0] = _zz_200_;
  end

  assign _zz_202_ = _zz_322_[19];
  always @ (*) begin
    _zz_203_[10] = _zz_202_;
    _zz_203_[9] = _zz_202_;
    _zz_203_[8] = _zz_202_;
    _zz_203_[7] = _zz_202_;
    _zz_203_[6] = _zz_202_;
    _zz_203_[5] = _zz_202_;
    _zz_203_[4] = _zz_202_;
    _zz_203_[3] = _zz_202_;
    _zz_203_[2] = _zz_202_;
    _zz_203_[1] = _zz_202_;
    _zz_203_[0] = _zz_202_;
  end

  assign _zz_204_ = _zz_323_[11];
  always @ (*) begin
    _zz_205_[18] = _zz_204_;
    _zz_205_[17] = _zz_204_;
    _zz_205_[16] = _zz_204_;
    _zz_205_[15] = _zz_204_;
    _zz_205_[14] = _zz_204_;
    _zz_205_[13] = _zz_204_;
    _zz_205_[12] = _zz_204_;
    _zz_205_[11] = _zz_204_;
    _zz_205_[10] = _zz_204_;
    _zz_205_[9] = _zz_204_;
    _zz_205_[8] = _zz_204_;
    _zz_205_[7] = _zz_204_;
    _zz_205_[6] = _zz_204_;
    _zz_205_[5] = _zz_204_;
    _zz_205_[4] = _zz_204_;
    _zz_205_[3] = _zz_204_;
    _zz_205_[2] = _zz_204_;
    _zz_205_[1] = _zz_204_;
    _zz_205_[0] = _zz_204_;
  end

  assign execute_BranchPlugin_branchAdder = (execute_BranchPlugin_branch_src1 + execute_BranchPlugin_branch_src2);
  assign _zz_24_ = {execute_BranchPlugin_branchAdder[31 : 1],(1'b0)};
  assign _zz_100_ = (memory_BRANCH_DO && memory_arbitration_isFiring);
  assign _zz_101_ = memory_BRANCH_CALC;
  assign memory_exception_agregat_valid = (memory_arbitration_isValid && (memory_BRANCH_DO && memory_BRANCH_CALC[1]));
  assign memory_exception_agregat_payload_code = (4'b0000);
  assign memory_exception_agregat_payload_badAddr = memory_BRANCH_CALC;
  assign _zz_22_ = decode_ALU_BITWISE_CTRL;
  assign _zz_20_ = _zz_59_;
  assign _zz_44_ = decode_to_execute_ALU_BITWISE_CTRL;
  assign _zz_19_ = decode_BRANCH_CTRL;
  assign _zz_17_ = execute_BRANCH_CTRL;
  assign _zz_82_ = _zz_65_;
  assign _zz_26_ = decode_to_execute_BRANCH_CTRL;
  assign _zz_83_ = execute_to_memory_BRANCH_CTRL;
  assign _zz_40_ = _zz_61_;
  assign _zz_15_ = decode_SHIFT_CTRL;
  assign _zz_12_ = execute_SHIFT_CTRL;
  assign _zz_13_ = _zz_67_;
  assign _zz_31_ = decode_to_execute_SHIFT_CTRL;
  assign _zz_29_ = execute_to_memory_SHIFT_CTRL;
  assign _zz_10_ = decode_ALU_CTRL;
  assign _zz_8_ = _zz_51_;
  assign _zz_42_ = decode_to_execute_ALU_CTRL;
  assign _zz_7_ = decode_ENV_CTRL;
  assign _zz_4_ = execute_ENV_CTRL;
  assign _zz_2_ = memory_ENV_CTRL;
  assign _zz_5_ = _zz_57_;
  assign _zz_74_ = decode_to_execute_ENV_CTRL;
  assign _zz_73_ = execute_to_memory_ENV_CTRL;
  assign _zz_77_ = memory_to_writeBack_ENV_CTRL;
  assign _zz_37_ = _zz_52_;
  assign decode_arbitration_isFlushed = (((decode_arbitration_flushAll || execute_arbitration_flushAll) || memory_arbitration_flushAll) || writeBack_arbitration_flushAll);
  assign execute_arbitration_isFlushed = ((execute_arbitration_flushAll || memory_arbitration_flushAll) || writeBack_arbitration_flushAll);
  assign memory_arbitration_isFlushed = (memory_arbitration_flushAll || writeBack_arbitration_flushAll);
  assign writeBack_arbitration_isFlushed = writeBack_arbitration_flushAll;
  assign decode_arbitration_isStuckByOthers = (decode_arbitration_haltByOther || (((1'b0 || execute_arbitration_isStuck) || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
  assign decode_arbitration_isStuck = (decode_arbitration_haltItself || decode_arbitration_isStuckByOthers);
  assign decode_arbitration_isMoving = ((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt));
  assign decode_arbitration_isFiring = ((decode_arbitration_isValid && (! decode_arbitration_isStuck)) && (! decode_arbitration_removeIt));
  assign execute_arbitration_isStuckByOthers = (execute_arbitration_haltByOther || ((1'b0 || memory_arbitration_isStuck) || writeBack_arbitration_isStuck));
  assign execute_arbitration_isStuck = (execute_arbitration_haltItself || execute_arbitration_isStuckByOthers);
  assign execute_arbitration_isMoving = ((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt));
  assign execute_arbitration_isFiring = ((execute_arbitration_isValid && (! execute_arbitration_isStuck)) && (! execute_arbitration_removeIt));
  assign memory_arbitration_isStuckByOthers = (memory_arbitration_haltByOther || (1'b0 || writeBack_arbitration_isStuck));
  assign memory_arbitration_isStuck = (memory_arbitration_haltItself || memory_arbitration_isStuckByOthers);
  assign memory_arbitration_isMoving = ((! memory_arbitration_isStuck) && (! memory_arbitration_removeIt));
  assign memory_arbitration_isFiring = ((memory_arbitration_isValid && (! memory_arbitration_isStuck)) && (! memory_arbitration_removeIt));
  assign writeBack_arbitration_isStuckByOthers = (writeBack_arbitration_haltByOther || 1'b0);
  assign writeBack_arbitration_isStuck = (writeBack_arbitration_haltItself || writeBack_arbitration_isStuckByOthers);
  assign writeBack_arbitration_isMoving = ((! writeBack_arbitration_isStuck) && (! writeBack_arbitration_removeIt));
  assign writeBack_arbitration_isFiring = ((writeBack_arbitration_isValid && (! writeBack_arbitration_isStuck)) && (! writeBack_arbitration_removeIt));
  always @ (posedge io_clk) begin
    if(GLOBAL_BUFFER_OUTPUT) begin
      CsrPlugin_privilege <= (2'b11);
      IBusSimplePlugin_fetchPc_pcReg <= (32'b00000000000000100000000000000000);
      IBusSimplePlugin_fetchPc_inc <= 1'b0;
      _zz_107_ <= 1'b0;
      _zz_112_ <= 1'b0;
      _zz_115_ <= 1'b0;
      _zz_117_ <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_0 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_1 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_2 <= 1'b0;
      IBusSimplePlugin_injector_nextPcCalc_3 <= 1'b0;
      IBusSimplePlugin_injector_decodeRemoved <= 1'b0;
      IBusSimplePlugin_pendingCmd <= (3'b000);
      IBusSimplePlugin_cmdFork_cmdKeep <= 1'b0;
      IBusSimplePlugin_cmdFork_cmdFired <= 1'b0;
      IBusSimplePlugin_rspJoin_discardCounter <= (3'b000);
      CsrPlugin_mtvec_mode <= (2'b00);
      CsrPlugin_mtvec_base <= (30'b100000000000000000000000001000);
      CsrPlugin_mstatus_MIE <= 1'b0;
      CsrPlugin_mstatus_MPIE <= 1'b0;
      CsrPlugin_mstatus_MPP <= (2'b11);
      CsrPlugin_mip_MEIP <= 1'b0;
      CsrPlugin_mip_MTIP <= 1'b0;
      CsrPlugin_mip_MSIP <= 1'b0;
      CsrPlugin_mie_MEIE <= 1'b0;
      CsrPlugin_mie_MTIE <= 1'b0;
      CsrPlugin_mie_MSIE <= 1'b0;
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= 1'b0;
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= 1'b0;
      CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= 1'b0;
      CsrPlugin_hadException <= 1'b0;
      _zz_162_ <= 1'b1;
      memory_MulDivIterativePlugin_mul_counter_value <= (4'b0000);
      memory_MulDivIterativePlugin_div_counter_value <= (6'b000000);
      _zz_181_ <= 1'b0;
      execute_arbitration_isValid <= 1'b0;
      memory_arbitration_isValid <= 1'b0;
      writeBack_arbitration_isValid <= 1'b0;
      memory_to_writeBack_REGFILE_WRITE_DATA <= (32'b00000000000000000000000000000000);
      memory_to_writeBack_INSTRUCTION <= (32'b00000000000000000000000000000000);
    end else begin
      if(IBusSimplePlugin_fetchPc_propagatePc)begin
        IBusSimplePlugin_fetchPc_inc <= 1'b0;
      end
      if(IBusSimplePlugin_jump_pcLoad_valid)begin
        IBusSimplePlugin_fetchPc_inc <= 1'b0;
      end
      if(_zz_223_)begin
        IBusSimplePlugin_fetchPc_inc <= 1'b1;
      end
      if(IBusSimplePlugin_fetchPc_samplePcNext)begin
        IBusSimplePlugin_fetchPc_pcReg <= IBusSimplePlugin_fetchPc_pc;
      end
      _zz_107_ <= 1'b1;
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        _zz_112_ <= 1'b0;
      end
      if(IBusSimplePlugin_iBusRsp_stages_0_output_ready)begin
        _zz_112_ <= IBusSimplePlugin_iBusRsp_stages_0_output_valid;
      end
      if(IBusSimplePlugin_iBusRsp_stages_1_output_ready)begin
        _zz_115_ <= IBusSimplePlugin_iBusRsp_stages_1_output_valid;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        _zz_115_ <= 1'b0;
      end
      if(IBusSimplePlugin_iBusRsp_inputBeforeStage_ready)begin
        _zz_117_ <= IBusSimplePlugin_iBusRsp_inputBeforeStage_valid;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        _zz_117_ <= 1'b0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b0;
      end
      if((! (! IBusSimplePlugin_iBusRsp_stages_1_input_ready)))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_0 <= 1'b1;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if((! (! IBusSimplePlugin_iBusRsp_stages_2_input_ready)))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_1 <= IBusSimplePlugin_injector_nextPcCalc_valids_0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_injector_nextPcCalc_valids_1 <= 1'b0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_injector_nextPcCalc_0 <= 1'b0;
      end
      if((! (! IBusSimplePlugin_injector_decodeInput_ready)))begin
        IBusSimplePlugin_injector_nextPcCalc_0 <= IBusSimplePlugin_injector_nextPcCalc_valids_1;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_injector_nextPcCalc_0 <= 1'b0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_injector_nextPcCalc_1 <= 1'b0;
      end
      if((! execute_arbitration_isStuck))begin
        IBusSimplePlugin_injector_nextPcCalc_1 <= IBusSimplePlugin_injector_nextPcCalc_0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_injector_nextPcCalc_1 <= 1'b0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_injector_nextPcCalc_2 <= 1'b0;
      end
      if((! memory_arbitration_isStuck))begin
        IBusSimplePlugin_injector_nextPcCalc_2 <= IBusSimplePlugin_injector_nextPcCalc_1;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_injector_nextPcCalc_2 <= 1'b0;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_injector_nextPcCalc_3 <= 1'b0;
      end
      if((! writeBack_arbitration_isStuck))begin
        IBusSimplePlugin_injector_nextPcCalc_3 <= IBusSimplePlugin_injector_nextPcCalc_2;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_injector_nextPcCalc_3 <= 1'b0;
      end
      if(decode_arbitration_removeIt)begin
        IBusSimplePlugin_injector_decodeRemoved <= 1'b1;
      end
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_injector_decodeRemoved <= 1'b0;
      end
      IBusSimplePlugin_pendingCmd <= IBusSimplePlugin_pendingCmdNext;
      if(IBusSimplePlugin_cmd_valid)begin
        IBusSimplePlugin_cmdFork_cmdKeep <= 1'b1;
      end
      if(IBusSimplePlugin_cmd_ready)begin
        IBusSimplePlugin_cmdFork_cmdKeep <= 1'b0;
      end
      if((IBusSimplePlugin_cmd_valid && IBusSimplePlugin_cmd_ready))begin
        IBusSimplePlugin_cmdFork_cmdFired <= 1'b1;
      end
      if(IBusSimplePlugin_iBusRsp_stages_1_input_ready)begin
        IBusSimplePlugin_cmdFork_cmdFired <= 1'b0;
      end
      IBusSimplePlugin_rspJoin_discardCounter <= (IBusSimplePlugin_rspJoin_discardCounter - _zz_249_);
      if((IBusSimplePlugin_jump_pcLoad_valid || _zz_94_))begin
        IBusSimplePlugin_rspJoin_discardCounter <= (_zz_250_ - _zz_254_);
      end
      CsrPlugin_mip_MEIP <= externalInterrupt;
      CsrPlugin_mip_MTIP <= timerInterrupt;
      if((! execute_arbitration_isStuck))begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= 1'b0;
      end else begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_execute <= CsrPlugin_exceptionPortCtrl_exceptionValids_execute;
      end
      if((! memory_arbitration_isStuck))begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= (CsrPlugin_exceptionPortCtrl_exceptionValids_execute && (! execute_arbitration_isStuck));
      end else begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_memory <= CsrPlugin_exceptionPortCtrl_exceptionValids_memory;
      end
      if((! writeBack_arbitration_isStuck))begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= (CsrPlugin_exceptionPortCtrl_exceptionValids_memory && (! memory_arbitration_isStuck));
      end else begin
        CsrPlugin_exceptionPortCtrl_exceptionValidsRegs_writeBack <= 1'b0;
      end
      CsrPlugin_hadException <= CsrPlugin_exception;
      if(_zz_221_)begin
        case(CsrPlugin_targetPrivilege)
          2'b11 : begin
            CsrPlugin_mstatus_MIE <= 1'b0;
            CsrPlugin_mstatus_MPIE <= CsrPlugin_mstatus_MIE;
            CsrPlugin_mstatus_MPP <= CsrPlugin_privilege;
          end
          default : begin
          end
        endcase
      end
      if(_zz_222_)begin
        case(_zz_226_)
          2'b11 : begin
            CsrPlugin_mstatus_MIE <= CsrPlugin_mstatus_MPIE;
            CsrPlugin_mstatus_MPP <= (2'b00);
            CsrPlugin_mstatus_MPIE <= 1'b1;
            CsrPlugin_privilege <= CsrPlugin_mstatus_MPP;
          end
          default : begin
          end
        endcase
      end
      _zz_162_ <= 1'b0;
      memory_MulDivIterativePlugin_mul_counter_value <= memory_MulDivIterativePlugin_mul_counter_valueNext;
      memory_MulDivIterativePlugin_div_counter_value <= memory_MulDivIterativePlugin_div_counter_valueNext;
      _zz_181_ <= (_zz_47_ && writeBack_arbitration_isFiring);
      if((! writeBack_arbitration_isStuck))begin
        memory_to_writeBack_REGFILE_WRITE_DATA <= _zz_45_;
      end
      if((! writeBack_arbitration_isStuck))begin
        memory_to_writeBack_INSTRUCTION <= memory_INSTRUCTION;
      end
      if(((! execute_arbitration_isStuck) || execute_arbitration_removeIt))begin
        execute_arbitration_isValid <= 1'b0;
      end
      if(((! decode_arbitration_isStuck) && (! decode_arbitration_removeIt)))begin
        execute_arbitration_isValid <= decode_arbitration_isValid;
      end
      if(((! memory_arbitration_isStuck) || memory_arbitration_removeIt))begin
        memory_arbitration_isValid <= 1'b0;
      end
      if(((! execute_arbitration_isStuck) && (! execute_arbitration_removeIt)))begin
        memory_arbitration_isValid <= execute_arbitration_isValid;
      end
      if(((! writeBack_arbitration_isStuck) || writeBack_arbitration_removeIt))begin
        writeBack_arbitration_isValid <= 1'b0;
      end
      if(((! memory_arbitration_isStuck) && (! memory_arbitration_removeIt)))begin
        writeBack_arbitration_isValid <= memory_arbitration_isValid;
      end
      case(execute_CsrPlugin_csrAddress)
        12'b001100000000 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mstatus_MPP <= execute_CsrPlugin_writeData[12 : 11];
            CsrPlugin_mstatus_MPIE <= _zz_325_[0];
            CsrPlugin_mstatus_MIE <= _zz_326_[0];
          end
        end
        12'b001101000001 : begin
        end
        12'b001100000101 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mtvec_base <= execute_CsrPlugin_writeData[31 : 2];
            CsrPlugin_mtvec_mode <= execute_CsrPlugin_writeData[1 : 0];
          end
        end
        12'b001101000100 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mip_MSIP <= _zz_327_[0];
          end
        end
        12'b001101000011 : begin
        end
        12'b001101000000 : begin
        end
        12'b001100000001 : begin
        end
        12'b001100000100 : begin
          if(execute_CsrPlugin_writeEnable)begin
            CsrPlugin_mie_MEIE <= _zz_328_[0];
            CsrPlugin_mie_MTIE <= _zz_329_[0];
            CsrPlugin_mie_MSIE <= _zz_330_[0];
          end
        end
        12'b001101000010 : begin
        end
        default : begin
        end
      endcase
    end
  end

  always @ (posedge io_clk) begin
    if(IBusSimplePlugin_iBusRsp_stages_0_output_ready)begin
      _zz_113_ <= IBusSimplePlugin_iBusRsp_stages_0_output_payload;
    end
    if(IBusSimplePlugin_iBusRsp_stages_1_output_ready)begin
      _zz_116_ <= IBusSimplePlugin_iBusRsp_stages_1_output_payload;
    end
    if(IBusSimplePlugin_iBusRsp_inputBeforeStage_ready)begin
      _zz_118_ <= IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_pc;
      _zz_119_ <= IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_error;
      _zz_120_ <= IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_raw;
      _zz_121_ <= IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_isRvc;
    end
    if(IBusSimplePlugin_injector_decodeInput_ready)begin
      IBusSimplePlugin_injector_formal_rawInDecode <= IBusSimplePlugin_iBusRsp_inputBeforeStage_payload_rsp_raw;
    end
    if(IBusSimplePlugin_iBusRsp_stages_0_output_ready)begin
      _zz_125_ <= _zz_123_;
      _zz_126_ <= _zz_124_;
    end
    if(IBusSimplePlugin_iBusRsp_stages_1_output_ready)begin
      _zz_129_ <= (_zz_125_ && (_zz_126_ == _zz_237_));
      _zz_130_ <= _zz_208_[1 : 0];
    end
    if(IBusSimplePlugin_injector_decodeInput_ready)begin
      _zz_131_ <= _zz_129_;
      _zz_132_ <= _zz_130_;
    end
    if(!(! (((dBus_rsp_ready && writeBack_MEMORY_ENABLE) && writeBack_arbitration_isValid) && writeBack_arbitration_isStuck))) begin
      $display("ERROR DBusSimplePlugin doesn't allow memory stage stall when read happend");
    end
    CsrPlugin_mcycle <= (CsrPlugin_mcycle + (64'b0000000000000000000000000000000000000000000000000000000000000001));
    if(writeBack_arbitration_isFiring)begin
      CsrPlugin_minstret <= (CsrPlugin_minstret + (64'b0000000000000000000000000000000000000000000000000000000000000001));
    end
    if(execute_exception_agregat_valid)begin
      CsrPlugin_exceptionPortCtrl_exceptionContext_code <= execute_exception_agregat_payload_code;
      CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= execute_exception_agregat_payload_badAddr;
    end
    if(memory_exception_agregat_valid)begin
      CsrPlugin_exceptionPortCtrl_exceptionContext_code <= memory_exception_agregat_payload_code;
      CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= memory_exception_agregat_payload_badAddr;
    end
    if(writeBack_exception_agregat_valid)begin
      CsrPlugin_exceptionPortCtrl_exceptionContext_code <= writeBack_exception_agregat_payload_code;
      CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr <= writeBack_exception_agregat_payload_badAddr;
    end
    if((CsrPlugin_exception || CsrPlugin_interruptJump))begin
      case(CsrPlugin_privilege)
        2'b11 : begin
          CsrPlugin_mepc <= writeBack_PC;
        end
        default : begin
        end
      endcase
    end
    if(_zz_221_)begin
      case(CsrPlugin_targetPrivilege)
        2'b11 : begin
          CsrPlugin_mcause_interrupt <= (! CsrPlugin_hadException);
          CsrPlugin_mcause_exceptionCode <= CsrPlugin_trapCause;
          CsrPlugin_mtval <= CsrPlugin_exceptionPortCtrl_exceptionContext_badAddr;
        end
        default : begin
        end
      endcase
    end
    if(_zz_217_)begin
      if(_zz_218_)begin
        memory_MulDivIterativePlugin_rs2 <= (memory_MulDivIterativePlugin_rs2 >>> 4);
        memory_MulDivIterativePlugin_accumulator <= ({_zz_272_,memory_MulDivIterativePlugin_accumulator[31 : 0]} >>> 4);
      end
    end
    if((memory_MulDivIterativePlugin_div_counter_value == (6'b100000)))begin
      memory_MulDivIterativePlugin_div_done <= 1'b1;
    end
    if((! memory_arbitration_isStuck))begin
      memory_MulDivIterativePlugin_div_done <= 1'b0;
    end
    if(_zz_219_)begin
      if(_zz_220_)begin
        memory_MulDivIterativePlugin_rs1[31 : 0] <= _zz_293_[31:0];
        memory_MulDivIterativePlugin_accumulator[31 : 0] <= ((! _zz_165_[32]) ? _zz_294_ : _zz_295_);
        if((memory_MulDivIterativePlugin_div_counter_value == (6'b100000)))begin
          memory_MulDivIterativePlugin_div_result <= _zz_296_[31:0];
        end
      end
    end
    if(_zz_224_)begin
      memory_MulDivIterativePlugin_accumulator <= (65'b00000000000000000000000000000000000000000000000000000000000000000);
      memory_MulDivIterativePlugin_rs1 <= ((_zz_168_ ? (~ _zz_169_) : _zz_169_) + _zz_302_);
      memory_MulDivIterativePlugin_rs2 <= ((_zz_167_ ? (~ execute_RS2) : execute_RS2) + _zz_304_);
      memory_MulDivIterativePlugin_div_needRevert <= ((_zz_168_ ^ (_zz_167_ && (! execute_INSTRUCTION[13]))) && (! (((execute_RS2 == (32'b00000000000000000000000000000000)) && execute_IS_RS2_SIGNED) && (! execute_INSTRUCTION[13]))));
    end
    _zz_182_ <= _zz_46_[11 : 7];
    _zz_183_ <= _zz_78_;
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_IS_FENCEI <= decode_IS_FENCEI;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_SRC_ADD <= execute_SRC_ADD;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC_LESS_UNSIGNED <= decode_SRC_LESS_UNSIGNED;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC1 <= decode_SRC1;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ALU_BITWISE_CTRL <= _zz_21_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_BYPASSABLE_EXECUTE_STAGE <= decode_BYPASSABLE_EXECUTE_STAGE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC2 <= decode_SRC2;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_REGFILE_WRITE_DATA <= _zz_72_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_BRANCH_CTRL <= _zz_18_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_BRANCH_CTRL <= _zz_16_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_CSR_READ_OPCODE <= decode_CSR_READ_OPCODE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_INSTRUCTION <= _zz_23_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_INSTRUCTION <= execute_INSTRUCTION;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_SHIFT_RIGHT <= execute_SHIFT_RIGHT;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_IS_DIV <= decode_IS_DIV;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_IS_DIV <= execute_IS_DIV;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_IS_CSR <= decode_IS_CSR;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SHIFT_CTRL <= _zz_14_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_SHIFT_CTRL <= _zz_11_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_RS1 <= _zz_39_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_REGFILE_WRITE_VALID <= decode_REGFILE_WRITE_VALID;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_REGFILE_WRITE_VALID <= execute_REGFILE_WRITE_VALID;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_REGFILE_WRITE_VALID <= memory_REGFILE_WRITE_VALID;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_CSR_WRITE_OPCODE <= decode_CSR_WRITE_OPCODE;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ALU_CTRL <= _zz_9_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_IS_RS1_SIGNED <= decode_IS_RS1_SIGNED;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_ENV_CTRL <= _zz_6_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_ENV_CTRL <= _zz_3_;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_ENV_CTRL <= _zz_1_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_PC <= _zz_35_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_PC <= execute_PC;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_PC <= memory_PC;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_PREDICTION_CONTEXT_hazard <= decode_PREDICTION_CONTEXT_hazard;
      decode_to_execute_PREDICTION_CONTEXT_line_history <= decode_PREDICTION_CONTEXT_line_history;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_PREDICTION_CONTEXT_hazard <= execute_PREDICTION_CONTEXT_hazard;
      execute_to_memory_PREDICTION_CONTEXT_line_history <= execute_PREDICTION_CONTEXT_line_history;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_MEMORY_ENABLE <= decode_MEMORY_ENABLE;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_MEMORY_ENABLE <= execute_MEMORY_ENABLE;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_MEMORY_ENABLE <= memory_MEMORY_ENABLE;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_BRANCH_DO <= execute_BRANCH_DO;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_BRANCH_CALC <= execute_BRANCH_CALC;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_ALIGNEMENT_FAULT <= memory_ALIGNEMENT_FAULT;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_BYPASSABLE_MEMORY_STAGE <= decode_BYPASSABLE_MEMORY_STAGE;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_BYPASSABLE_MEMORY_STAGE <= execute_BYPASSABLE_MEMORY_STAGE;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_MEMORY_ADDRESS_LOW <= memory_MEMORY_ADDRESS_LOW;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_FORMAL_PC_NEXT <= _zz_88_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_FORMAL_PC_NEXT <= execute_FORMAL_PC_NEXT;
    end
    if((! writeBack_arbitration_isStuck))begin
      memory_to_writeBack_FORMAL_PC_NEXT <= _zz_87_;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_IS_RS2_SIGNED <= decode_IS_RS2_SIGNED;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_SRC_USE_SUB_LESS <= decode_SRC_USE_SUB_LESS;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_RS2 <= _zz_36_;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_RS2 <= execute_RS2;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_PREDICTION_HAD_BRANCHED2 <= decode_PREDICTION_HAD_BRANCHED2;
    end
    if((! execute_arbitration_isStuck))begin
      decode_to_execute_IS_MUL <= decode_IS_MUL;
    end
    if((! memory_arbitration_isStuck))begin
      execute_to_memory_IS_MUL <= execute_IS_MUL;
    end
    case(execute_CsrPlugin_csrAddress)
      12'b001100000000 : begin
      end
      12'b001101000001 : begin
        if(execute_CsrPlugin_writeEnable)begin
          CsrPlugin_mepc <= execute_CsrPlugin_writeData[31 : 0];
        end
      end
      12'b001100000101 : begin
      end
      12'b001101000100 : begin
      end
      12'b001101000011 : begin
      end
      12'b001101000000 : begin
        if(execute_CsrPlugin_writeEnable)begin
          CsrPlugin_mscratch <= execute_CsrPlugin_writeData[31 : 0];
        end
      end
      12'b001100000001 : begin
      end
      12'b001100000100 : begin
      end
      12'b001101000010 : begin
      end
      default : begin
      end
    endcase
  end

endmodule

module SimpleBusDecoder (
      input   io_input_cmd_valid,
      output reg  io_input_cmd_ready,
      input   io_input_cmd_payload_wr,
      input  [19:0] io_input_cmd_payload_address,
      input  [31:0] io_input_cmd_payload_data,
      input  [3:0] io_input_cmd_payload_mask,
      output  io_input_rsp_valid,
      output [31:0] io_input_rsp_payload_data,
      output reg  io_outputs_0_cmd_valid,
      input   io_outputs_0_cmd_ready,
      output  io_outputs_0_cmd_payload_wr,
      output [19:0] io_outputs_0_cmd_payload_address,
      output [31:0] io_outputs_0_cmd_payload_data,
      output [3:0] io_outputs_0_cmd_payload_mask,
      input   io_outputs_0_rsp_valid,
      input  [31:0] io_outputs_0_rsp_0_data,
      output reg  io_outputs_1_cmd_valid,
      input   io_outputs_1_cmd_ready,
      output  io_outputs_1_cmd_payload_wr,
      output [19:0] io_outputs_1_cmd_payload_address,
      output [31:0] io_outputs_1_cmd_payload_data,
      output [3:0] io_outputs_1_cmd_payload_mask,
      input   io_outputs_1_rsp_valid,
      input  [31:0] io_outputs_1_rsp_1_data,
      input   io_clk,
      input   GLOBAL_BUFFER_OUTPUT);
  reg [31:0] _zz_3_;
  wire [19:0] _zz_4_;
  wire [1:0] _zz_5_;
  wire [0:0] _zz_6_;
  wire [1:0] _zz_7_;
  wire [0:0] _zz_8_;
  wire [1:0] _zz_9_;
  wire [0:0] _zz_10_;
  wire  logic_hits_0;
  wire  logic_hits_1;
  wire  _zz_1_;
  wire  _zz_2_;
  wire  logic_noHit;
  reg [1:0] logic_rspPendingCounter;
  reg  logic_rspHits_0;
  reg  logic_rspHits_1;
  wire  logic_rspPending;
  wire  logic_rspNoHit;
  wire  logic_cmdWait;
  assign _zz_4_ = (20'b11110000000000000000);
  assign _zz_5_ = (logic_rspPendingCounter + _zz_7_);
  assign _zz_6_ = ((io_input_cmd_valid && io_input_cmd_ready) && (! io_input_cmd_payload_wr));
  assign _zz_7_ = {1'd0, _zz_6_};
  assign _zz_8_ = io_input_rsp_valid;
  assign _zz_9_ = {1'd0, _zz_8_};
  assign _zz_10_ = logic_rspHits_1;
  always @(*) begin
    case(_zz_10_)
      1'b0 : begin
        _zz_3_ = io_outputs_0_rsp_0_data;
      end
      default : begin
        _zz_3_ = io_outputs_1_rsp_1_data;
      end
    endcase
  end

  assign logic_hits_0 = ((io_input_cmd_payload_address & _zz_4_) == (20'b10010000000000000000));
  always @ (*) begin
    io_outputs_0_cmd_valid = (io_input_cmd_valid && logic_hits_0);
    io_outputs_1_cmd_valid = (io_input_cmd_valid && logic_hits_1);
    io_input_cmd_ready = (((logic_hits_0 && io_outputs_0_cmd_ready) || (logic_hits_1 && io_outputs_1_cmd_ready)) || logic_noHit);
    if(logic_cmdWait)begin
      io_input_cmd_ready = 1'b0;
      io_outputs_0_cmd_valid = 1'b0;
      io_outputs_1_cmd_valid = 1'b0;
    end
  end

  assign _zz_1_ = io_input_cmd_payload_wr;
  assign io_outputs_0_cmd_payload_wr = _zz_1_;
  assign io_outputs_0_cmd_payload_address = io_input_cmd_payload_address;
  assign io_outputs_0_cmd_payload_data = io_input_cmd_payload_data;
  assign io_outputs_0_cmd_payload_mask = io_input_cmd_payload_mask;
  assign logic_hits_1 = (! logic_hits_0);
  assign _zz_2_ = io_input_cmd_payload_wr;
  assign io_outputs_1_cmd_payload_wr = _zz_2_;
  assign io_outputs_1_cmd_payload_address = io_input_cmd_payload_address;
  assign io_outputs_1_cmd_payload_data = io_input_cmd_payload_data;
  assign io_outputs_1_cmd_payload_mask = io_input_cmd_payload_mask;
  assign logic_noHit = 1'b0;
  assign logic_rspPending = (logic_rspPendingCounter != (2'b00));
  assign logic_rspNoHit = 1'b0;
  assign io_input_rsp_valid = ((io_outputs_0_rsp_valid || io_outputs_1_rsp_valid) || (logic_rspPending && logic_rspNoHit));
  assign io_input_rsp_payload_data = _zz_3_;
  assign logic_cmdWait = (((io_input_cmd_valid && logic_rspPending) && ((logic_hits_0 != logic_rspHits_0) || (logic_hits_1 != logic_rspHits_1))) || (logic_rspPendingCounter == (2'b11)));
  always @ (posedge io_clk) begin
    if(GLOBAL_BUFFER_OUTPUT) begin
      logic_rspPendingCounter <= (2'b00);
    end else begin
      logic_rspPendingCounter <= (_zz_5_ - _zz_9_);
    end
  end

  always @ (posedge io_clk) begin
    if((io_input_cmd_valid && io_input_cmd_ready))begin
      logic_rspHits_0 <= logic_hits_0;
      logic_rspHits_1 <= logic_hits_1;
    end
  end

endmodule

module SimpleBusDecoder_1_ (
      input   io_input_cmd_valid,
      output reg  io_input_cmd_ready,
      input   io_input_cmd_payload_wr,
      input  [19:0] io_input_cmd_payload_address,
      input  [31:0] io_input_cmd_payload_data,
      input  [3:0] io_input_cmd_payload_mask,
      output  io_input_rsp_valid,
      output [31:0] io_input_rsp_payload_data,
      output reg  io_outputs_0_cmd_valid,
      input   io_outputs_0_cmd_ready,
      output  io_outputs_0_cmd_payload_wr,
      output [19:0] io_outputs_0_cmd_payload_address,
      output [31:0] io_outputs_0_cmd_payload_data,
      output [3:0] io_outputs_0_cmd_payload_mask,
      input   io_outputs_0_rsp_valid,
      input  [31:0] io_outputs_0_rsp_0_data,
      output reg  io_outputs_1_cmd_valid,
      input   io_outputs_1_cmd_ready,
      output  io_outputs_1_cmd_payload_wr,
      output [19:0] io_outputs_1_cmd_payload_address,
      output [31:0] io_outputs_1_cmd_payload_data,
      output [3:0] io_outputs_1_cmd_payload_mask,
      input   io_outputs_1_rsp_valid,
      input  [31:0] io_outputs_1_rsp_1_data,
      input   io_clk,
      input   GLOBAL_BUFFER_OUTPUT);
  reg [31:0] _zz_3_;
  wire [19:0] _zz_4_;
  wire [1:0] _zz_5_;
  wire [0:0] _zz_6_;
  wire [1:0] _zz_7_;
  wire [0:0] _zz_8_;
  wire [1:0] _zz_9_;
  wire [0:0] _zz_10_;
  wire  logic_hits_0;
  wire  logic_hits_1;
  wire  _zz_1_;
  wire  _zz_2_;
  wire  logic_noHit;
  reg [1:0] logic_rspPendingCounter;
  reg  logic_rspHits_0;
  reg  logic_rspHits_1;
  wire  logic_rspPending;
  wire  logic_rspNoHit;
  wire  logic_cmdWait;
  assign _zz_4_ = (20'b11110000000000000000);
  assign _zz_5_ = (logic_rspPendingCounter + _zz_7_);
  assign _zz_6_ = ((io_input_cmd_valid && io_input_cmd_ready) && (! io_input_cmd_payload_wr));
  assign _zz_7_ = {1'd0, _zz_6_};
  assign _zz_8_ = io_input_rsp_valid;
  assign _zz_9_ = {1'd0, _zz_8_};
  assign _zz_10_ = logic_rspHits_1;
  always @(*) begin
    case(_zz_10_)
      1'b0 : begin
        _zz_3_ = io_outputs_0_rsp_0_data;
      end
      default : begin
        _zz_3_ = io_outputs_1_rsp_1_data;
      end
    endcase
  end

  assign logic_hits_0 = ((io_input_cmd_payload_address & _zz_4_) == (20'b10000000000000000000));
  always @ (*) begin
    io_outputs_0_cmd_valid = (io_input_cmd_valid && logic_hits_0);
    io_outputs_1_cmd_valid = (io_input_cmd_valid && logic_hits_1);
    io_input_cmd_ready = (((logic_hits_0 && io_outputs_0_cmd_ready) || (logic_hits_1 && io_outputs_1_cmd_ready)) || logic_noHit);
    if(logic_cmdWait)begin
      io_input_cmd_ready = 1'b0;
      io_outputs_0_cmd_valid = 1'b0;
      io_outputs_1_cmd_valid = 1'b0;
    end
  end

  assign _zz_1_ = io_input_cmd_payload_wr;
  assign io_outputs_0_cmd_payload_wr = _zz_1_;
  assign io_outputs_0_cmd_payload_address = io_input_cmd_payload_address;
  assign io_outputs_0_cmd_payload_data = io_input_cmd_payload_data;
  assign io_outputs_0_cmd_payload_mask = io_input_cmd_payload_mask;
  assign logic_hits_1 = (! logic_hits_0);
  assign _zz_2_ = io_input_cmd_payload_wr;
  assign io_outputs_1_cmd_payload_wr = _zz_2_;
  assign io_outputs_1_cmd_payload_address = io_input_cmd_payload_address;
  assign io_outputs_1_cmd_payload_data = io_input_cmd_payload_data;
  assign io_outputs_1_cmd_payload_mask = io_input_cmd_payload_mask;
  assign logic_noHit = 1'b0;
  assign logic_rspPending = (logic_rspPendingCounter != (2'b00));
  assign logic_rspNoHit = 1'b0;
  assign io_input_rsp_valid = ((io_outputs_0_rsp_valid || io_outputs_1_rsp_valid) || (logic_rspPending && logic_rspNoHit));
  assign io_input_rsp_payload_data = _zz_3_;
  assign logic_cmdWait = (((io_input_cmd_valid && logic_rspPending) && ((logic_hits_0 != logic_rspHits_0) || (logic_hits_1 != logic_rspHits_1))) || (logic_rspPendingCounter == (2'b11)));
  always @ (posedge io_clk) begin
    if(GLOBAL_BUFFER_OUTPUT) begin
      logic_rspPendingCounter <= (2'b00);
    end else begin
      logic_rspPendingCounter <= (_zz_5_ - _zz_9_);
    end
  end

  always @ (posedge io_clk) begin
    if((io_input_cmd_valid && io_input_cmd_ready))begin
      logic_rspHits_0 <= logic_hits_0;
      logic_rspHits_1 <= logic_hits_1;
    end
  end

endmodule

module SimpleBusDecoder_2_ (
      input   io_input_cmd_valid,
      output reg  io_input_cmd_ready,
      input   io_input_cmd_payload_wr,
      input  [19:0] io_input_cmd_payload_address,
      input  [31:0] io_input_cmd_payload_data,
      input  [3:0] io_input_cmd_payload_mask,
      output  io_input_rsp_valid,
      output [31:0] io_input_rsp_payload_data,
      output reg  io_outputs_0_cmd_valid,
      input   io_outputs_0_cmd_ready,
      output  io_outputs_0_cmd_payload_wr,
      output [19:0] io_outputs_0_cmd_payload_address,
      output [31:0] io_outputs_0_cmd_payload_data,
      output [3:0] io_outputs_0_cmd_payload_mask,
      input   io_outputs_0_rsp_valid,
      input  [31:0] io_outputs_0_rsp_0_data,
      output reg  io_outputs_1_cmd_valid,
      input   io_outputs_1_cmd_ready,
      output  io_outputs_1_cmd_payload_wr,
      output [19:0] io_outputs_1_cmd_payload_address,
      output [31:0] io_outputs_1_cmd_payload_data,
      output [3:0] io_outputs_1_cmd_payload_mask,
      input   io_outputs_1_rsp_valid,
      input  [31:0] io_outputs_1_rsp_1_data,
      output reg  io_outputs_2_cmd_valid,
      input   io_outputs_2_cmd_ready,
      output  io_outputs_2_cmd_payload_wr,
      output [19:0] io_outputs_2_cmd_payload_address,
      output [31:0] io_outputs_2_cmd_payload_data,
      output [3:0] io_outputs_2_cmd_payload_mask,
      input   io_outputs_2_rsp_valid,
      input  [31:0] io_outputs_2_rsp_2_data,
      output reg  io_outputs_3_cmd_valid,
      input   io_outputs_3_cmd_ready,
      output  io_outputs_3_cmd_payload_wr,
      output [19:0] io_outputs_3_cmd_payload_address,
      output [31:0] io_outputs_3_cmd_payload_data,
      output [3:0] io_outputs_3_cmd_payload_mask,
      input   io_outputs_3_rsp_valid,
      input  [31:0] io_outputs_3_rsp_3_data,
      input   io_clk,
      input   GLOBAL_BUFFER_OUTPUT);
  reg [31:0] _zz_7_;
  wire [19:0] _zz_8_;
  wire [19:0] _zz_9_;
  wire [19:0] _zz_10_;
  wire [19:0] _zz_11_;
  wire [1:0] _zz_12_;
  wire [0:0] _zz_13_;
  wire [1:0] _zz_14_;
  wire [0:0] _zz_15_;
  wire [1:0] _zz_16_;
  wire [1:0] _zz_17_;
  wire  logic_hits_0;
  wire  logic_hits_1;
  wire  logic_hits_2;
  wire  logic_hits_3;
  wire  _zz_1_;
  wire  _zz_2_;
  wire  _zz_3_;
  wire  _zz_4_;
  wire  logic_noHit;
  reg [1:0] logic_rspPendingCounter;
  reg  logic_rspHits_0;
  reg  logic_rspHits_1;
  reg  logic_rspHits_2;
  reg  logic_rspHits_3;
  wire  logic_rspPending;
  wire  logic_rspNoHit;
  wire  _zz_5_;
  wire  _zz_6_;
  wire  logic_cmdWait;
  assign _zz_8_ = (20'b11110000000000000000);
  assign _zz_9_ = (20'b11110000000000000000);
  assign _zz_10_ = (20'b11111111111100000000);
  assign _zz_11_ = (20'b10000000000000000000);
  assign _zz_12_ = (logic_rspPendingCounter + _zz_14_);
  assign _zz_13_ = ((io_input_cmd_valid && io_input_cmd_ready) && (! io_input_cmd_payload_wr));
  assign _zz_14_ = {1'd0, _zz_13_};
  assign _zz_15_ = io_input_rsp_valid;
  assign _zz_16_ = {1'd0, _zz_15_};
  assign _zz_17_ = {_zz_6_,_zz_5_};
  always @(*) begin
    case(_zz_17_)
      2'b00 : begin
        _zz_7_ = io_outputs_0_rsp_0_data;
      end
      2'b01 : begin
        _zz_7_ = io_outputs_1_rsp_1_data;
      end
      2'b10 : begin
        _zz_7_ = io_outputs_2_rsp_2_data;
      end
      default : begin
        _zz_7_ = io_outputs_3_rsp_3_data;
      end
    endcase
  end

  assign logic_hits_0 = ((io_input_cmd_payload_address & _zz_8_) == (20'b10000000000000000000));
  always @ (*) begin
    io_outputs_0_cmd_valid = (io_input_cmd_valid && logic_hits_0);
    io_outputs_1_cmd_valid = (io_input_cmd_valid && logic_hits_1);
    io_outputs_2_cmd_valid = (io_input_cmd_valid && logic_hits_2);
    io_outputs_3_cmd_valid = (io_input_cmd_valid && logic_hits_3);
    io_input_cmd_ready = (((((logic_hits_0 && io_outputs_0_cmd_ready) || (logic_hits_1 && io_outputs_1_cmd_ready)) || (logic_hits_2 && io_outputs_2_cmd_ready)) || (logic_hits_3 && io_outputs_3_cmd_ready)) || logic_noHit);
    if(logic_cmdWait)begin
      io_input_cmd_ready = 1'b0;
      io_outputs_0_cmd_valid = 1'b0;
      io_outputs_1_cmd_valid = 1'b0;
      io_outputs_2_cmd_valid = 1'b0;
      io_outputs_3_cmd_valid = 1'b0;
    end
  end

  assign _zz_1_ = io_input_cmd_payload_wr;
  assign io_outputs_0_cmd_payload_wr = _zz_1_;
  assign io_outputs_0_cmd_payload_address = io_input_cmd_payload_address;
  assign io_outputs_0_cmd_payload_data = io_input_cmd_payload_data;
  assign io_outputs_0_cmd_payload_mask = io_input_cmd_payload_mask;
  assign logic_hits_1 = ((io_input_cmd_payload_address & _zz_9_) == (20'b10010000000000000000));
  assign _zz_2_ = io_input_cmd_payload_wr;
  assign io_outputs_1_cmd_payload_wr = _zz_2_;
  assign io_outputs_1_cmd_payload_address = io_input_cmd_payload_address;
  assign io_outputs_1_cmd_payload_data = io_input_cmd_payload_data;
  assign io_outputs_1_cmd_payload_mask = io_input_cmd_payload_mask;
  assign logic_hits_2 = ((io_input_cmd_payload_address & _zz_10_) == (20'b11110000000000000000));
  assign _zz_3_ = io_input_cmd_payload_wr;
  assign io_outputs_2_cmd_payload_wr = _zz_3_;
  assign io_outputs_2_cmd_payload_address = io_input_cmd_payload_address;
  assign io_outputs_2_cmd_payload_data = io_input_cmd_payload_data;
  assign io_outputs_2_cmd_payload_mask = io_input_cmd_payload_mask;
  assign logic_hits_3 = ((io_input_cmd_payload_address & _zz_11_) == (20'b00000000000000000000));
  assign _zz_4_ = io_input_cmd_payload_wr;
  assign io_outputs_3_cmd_payload_wr = _zz_4_;
  assign io_outputs_3_cmd_payload_address = io_input_cmd_payload_address;
  assign io_outputs_3_cmd_payload_data = io_input_cmd_payload_data;
  assign io_outputs_3_cmd_payload_mask = io_input_cmd_payload_mask;
  assign logic_noHit = (! (((logic_hits_0 || logic_hits_1) || logic_hits_2) || logic_hits_3));
  assign logic_rspPending = (logic_rspPendingCounter != (2'b00));
  assign logic_rspNoHit = (! (((logic_rspHits_0 || logic_rspHits_1) || logic_rspHits_2) || logic_rspHits_3));
  assign io_input_rsp_valid = ((((io_outputs_0_rsp_valid || io_outputs_1_rsp_valid) || io_outputs_2_rsp_valid) || io_outputs_3_rsp_valid) || (logic_rspPending && logic_rspNoHit));
  assign _zz_5_ = (logic_rspHits_1 || logic_rspHits_3);
  assign _zz_6_ = (logic_rspHits_2 || logic_rspHits_3);
  assign io_input_rsp_payload_data = _zz_7_;
  assign logic_cmdWait = (((io_input_cmd_valid && logic_rspPending) && ((((logic_hits_0 != logic_rspHits_0) || (logic_hits_1 != logic_rspHits_1)) || (logic_hits_2 != logic_rspHits_2)) || (logic_hits_3 != logic_rspHits_3))) || (logic_rspPendingCounter == (2'b11)));
  always @ (posedge io_clk) begin
    if(GLOBAL_BUFFER_OUTPUT) begin
      logic_rspPendingCounter <= (2'b00);
    end else begin
      logic_rspPendingCounter <= (_zz_12_ - _zz_16_);
    end
  end

  always @ (posedge io_clk) begin
    if((io_input_cmd_valid && io_input_cmd_ready))begin
      logic_rspHits_0 <= logic_hits_0;
      logic_rspHits_1 <= logic_hits_1;
      logic_rspHits_2 <= logic_hits_2;
      logic_rspHits_3 <= logic_hits_3;
    end
  end

endmodule

module SimpleBusArbiter (
      input   io_inputs_0_cmd_valid,
      output  io_inputs_0_cmd_ready,
      input   io_inputs_0_cmd_payload_wr,
      input  [15:0] io_inputs_0_cmd_payload_address,
      input  [31:0] io_inputs_0_cmd_payload_data,
      input  [3:0] io_inputs_0_cmd_payload_mask,
      output  io_inputs_0_rsp_valid,
      output [31:0] io_inputs_0_rsp_payload_data,
      input   io_inputs_1_cmd_valid,
      output  io_inputs_1_cmd_ready,
      input   io_inputs_1_cmd_payload_wr,
      input  [15:0] io_inputs_1_cmd_payload_address,
      input  [31:0] io_inputs_1_cmd_payload_data,
      input  [3:0] io_inputs_1_cmd_payload_mask,
      output  io_inputs_1_rsp_valid,
      output [31:0] io_inputs_1_rsp_payload_data,
      output  io_output_cmd_valid,
      input   io_output_cmd_ready,
      output  io_output_cmd_payload_wr,
      output [15:0] io_output_cmd_payload_address,
      output [31:0] io_output_cmd_payload_data,
      output [3:0] io_output_cmd_payload_mask,
      input   io_output_rsp_valid,
      input  [31:0] io_output_rsp_payload_data,
      input   io_clk,
      input   GLOBAL_BUFFER_OUTPUT);
  wire  _zz_2_;
  wire  _zz_3_;
  wire  _zz_4_;
  wire  _zz_5_;
  wire  _zz_6_;
  wire [15:0] _zz_7_;
  wire [31:0] _zz_8_;
  wire [3:0] _zz_9_;
  wire [0:0] _zz_10_;
  wire [1:0] _zz_11_;
  wire  _zz_12_;
  wire [1:0] logic_rspRouteOh;
  reg  logic_rsp_pending;
  reg [1:0] logic_rsp_target;
  wire  _zz_1_;
  assign _zz_12_ = ((io_output_cmd_valid && io_output_cmd_ready) && (! io_output_cmd_payload_wr));
  StreamArbiter logic_arbiter ( 
    .io_inputs_0_0(io_inputs_0_cmd_valid),
    .io_inputs_0_ready(_zz_3_),
    .io_inputs_0_0_wr(io_inputs_0_cmd_payload_wr),
    .io_inputs_0_0_address(io_inputs_0_cmd_payload_address),
    .io_inputs_0_0_data(io_inputs_0_cmd_payload_data),
    .io_inputs_0_0_mask(io_inputs_0_cmd_payload_mask),
    .io_inputs_1_1(io_inputs_1_cmd_valid),
    .io_inputs_1_ready(_zz_4_),
    .io_inputs_1_1_wr(io_inputs_1_cmd_payload_wr),
    .io_inputs_1_1_address(io_inputs_1_cmd_payload_address),
    .io_inputs_1_1_data(io_inputs_1_cmd_payload_data),
    .io_inputs_1_1_mask(io_inputs_1_cmd_payload_mask),
    .io_output_valid(_zz_5_),
    .io_output_ready(_zz_2_),
    .io_output_payload_wr(_zz_6_),
    .io_output_payload_address(_zz_7_),
    .io_output_payload_data(_zz_8_),
    .io_output_payload_mask(_zz_9_),
    .io_chosen(_zz_10_),
    .io_chosenOH(_zz_11_),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(GLOBAL_BUFFER_OUTPUT) 
  );
  assign io_inputs_0_cmd_ready = _zz_3_;
  assign io_inputs_1_cmd_ready = _zz_4_;
  assign logic_rspRouteOh = logic_rsp_target;
  assign _zz_1_ = (! (logic_rsp_pending && (! io_output_rsp_valid)));
  assign _zz_2_ = (io_output_cmd_ready && _zz_1_);
  assign io_output_cmd_valid = (_zz_5_ && _zz_1_);
  assign io_output_cmd_payload_wr = _zz_6_;
  assign io_output_cmd_payload_address = _zz_7_;
  assign io_output_cmd_payload_data = _zz_8_;
  assign io_output_cmd_payload_mask = _zz_9_;
  assign io_inputs_0_rsp_valid = (io_output_rsp_valid && logic_rspRouteOh[0]);
  assign io_inputs_0_rsp_payload_data = io_output_rsp_payload_data;
  assign io_inputs_1_rsp_valid = (io_output_rsp_valid && logic_rspRouteOh[1]);
  assign io_inputs_1_rsp_payload_data = io_output_rsp_payload_data;
  always @ (posedge io_clk) begin
    if(GLOBAL_BUFFER_OUTPUT) begin
      logic_rsp_pending <= 1'b0;
    end else begin
      if(io_output_rsp_valid)begin
        logic_rsp_pending <= 1'b0;
      end
      if(_zz_12_)begin
        logic_rsp_pending <= 1'b1;
      end
    end
  end

  always @ (posedge io_clk) begin
    if(_zz_12_)begin
      logic_rsp_target <= _zz_11_;
    end
  end

endmodule


//SimpleBusArbiter_1_ remplaced by SimpleBusArbiter

module SimpleBusArbiter_2_ (
      input   io_inputs_0_cmd_valid,
      output  io_inputs_0_cmd_ready,
      input   io_inputs_0_cmd_payload_wr,
      input  [5:0] io_inputs_0_cmd_payload_address,
      input  [31:0] io_inputs_0_cmd_payload_data,
      input  [3:0] io_inputs_0_cmd_payload_mask,
      output  io_inputs_0_rsp_valid,
      output [31:0] io_inputs_0_rsp_payload_data,
      output  io_output_cmd_valid,
      input   io_output_cmd_ready,
      output  io_output_cmd_payload_wr,
      output [5:0] io_output_cmd_payload_address,
      output [31:0] io_output_cmd_payload_data,
      output [3:0] io_output_cmd_payload_mask,
      input   io_output_rsp_valid,
      input  [31:0] io_output_rsp_payload_data);
  assign io_output_cmd_valid = io_inputs_0_cmd_valid;
  assign io_output_cmd_payload_wr = io_inputs_0_cmd_payload_wr;
  assign io_output_cmd_payload_address = io_inputs_0_cmd_payload_address;
  assign io_output_cmd_payload_data = io_inputs_0_cmd_payload_data;
  assign io_output_cmd_payload_mask = io_inputs_0_cmd_payload_mask;
  assign io_inputs_0_cmd_ready = io_output_cmd_ready;
  assign io_inputs_0_rsp_valid = io_output_rsp_valid;
  assign io_inputs_0_rsp_payload_data = io_output_rsp_payload_data;
endmodule

module SimpleBusArbiter_3_ (
      input   io_inputs_0_cmd_valid,
      output  io_inputs_0_cmd_ready,
      input   io_inputs_0_cmd_payload_wr,
      input  [19:0] io_inputs_0_cmd_payload_address,
      input  [31:0] io_inputs_0_cmd_payload_data,
      input  [3:0] io_inputs_0_cmd_payload_mask,
      output  io_inputs_0_rsp_valid,
      output [31:0] io_inputs_0_rsp_payload_data,
      output  io_output_cmd_valid,
      input   io_output_cmd_ready,
      output  io_output_cmd_payload_wr,
      output [19:0] io_output_cmd_payload_address,
      output [31:0] io_output_cmd_payload_data,
      output [3:0] io_output_cmd_payload_mask,
      input   io_output_rsp_valid,
      input  [31:0] io_output_rsp_payload_data);
  assign io_output_cmd_valid = io_inputs_0_cmd_valid;
  assign io_output_cmd_payload_wr = io_inputs_0_cmd_payload_wr;
  assign io_output_cmd_payload_address = io_inputs_0_cmd_payload_address;
  assign io_output_cmd_payload_data = io_inputs_0_cmd_payload_data;
  assign io_output_cmd_payload_mask = io_inputs_0_cmd_payload_mask;
  assign io_inputs_0_cmd_ready = io_output_cmd_ready;
  assign io_inputs_0_rsp_valid = io_output_rsp_valid;
  assign io_inputs_0_rsp_payload_data = io_output_rsp_payload_data;
endmodule

module SimpleBusArbiter_4_ (
      input   io_inputs_0_cmd_valid,
      output  io_inputs_0_cmd_ready,
      input   io_inputs_0_cmd_payload_wr,
      input  [19:0] io_inputs_0_cmd_payload_address,
      input  [31:0] io_inputs_0_cmd_payload_data,
      input  [3:0] io_inputs_0_cmd_payload_mask,
      output  io_inputs_0_rsp_valid,
      output [31:0] io_inputs_0_rsp_payload_data,
      input   io_inputs_1_cmd_valid,
      output  io_inputs_1_cmd_ready,
      input   io_inputs_1_cmd_payload_wr,
      input  [19:0] io_inputs_1_cmd_payload_address,
      input  [31:0] io_inputs_1_cmd_payload_data,
      input  [3:0] io_inputs_1_cmd_payload_mask,
      output  io_inputs_1_rsp_valid,
      output [31:0] io_inputs_1_rsp_payload_data,
      output  io_output_cmd_valid,
      input   io_output_cmd_ready,
      output  io_output_cmd_payload_wr,
      output [19:0] io_output_cmd_payload_address,
      output [31:0] io_output_cmd_payload_data,
      output [3:0] io_output_cmd_payload_mask,
      input   io_output_rsp_valid,
      input  [31:0] io_output_rsp_payload_data,
      input   io_clk,
      input   GLOBAL_BUFFER_OUTPUT);
  wire  _zz_2_;
  wire  _zz_3_;
  wire  _zz_4_;
  wire  _zz_5_;
  wire  _zz_6_;
  wire [19:0] _zz_7_;
  wire [31:0] _zz_8_;
  wire [3:0] _zz_9_;
  wire [0:0] _zz_10_;
  wire [1:0] _zz_11_;
  wire  _zz_12_;
  wire [1:0] logic_rspRouteOh;
  reg  logic_rsp_pending;
  reg [1:0] logic_rsp_target;
  wire  _zz_1_;
  assign _zz_12_ = ((io_output_cmd_valid && io_output_cmd_ready) && (! io_output_cmd_payload_wr));
  StreamArbiter_2_ logic_arbiter ( 
    .io_inputs_0_0(io_inputs_0_cmd_valid),
    .io_inputs_0_ready(_zz_3_),
    .io_inputs_0_0_wr(io_inputs_0_cmd_payload_wr),
    .io_inputs_0_0_address(io_inputs_0_cmd_payload_address),
    .io_inputs_0_0_data(io_inputs_0_cmd_payload_data),
    .io_inputs_0_0_mask(io_inputs_0_cmd_payload_mask),
    .io_inputs_1_1(io_inputs_1_cmd_valid),
    .io_inputs_1_ready(_zz_4_),
    .io_inputs_1_1_wr(io_inputs_1_cmd_payload_wr),
    .io_inputs_1_1_address(io_inputs_1_cmd_payload_address),
    .io_inputs_1_1_data(io_inputs_1_cmd_payload_data),
    .io_inputs_1_1_mask(io_inputs_1_cmd_payload_mask),
    .io_output_valid(_zz_5_),
    .io_output_ready(_zz_2_),
    .io_output_payload_wr(_zz_6_),
    .io_output_payload_address(_zz_7_),
    .io_output_payload_data(_zz_8_),
    .io_output_payload_mask(_zz_9_),
    .io_chosen(_zz_10_),
    .io_chosenOH(_zz_11_),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(GLOBAL_BUFFER_OUTPUT) 
  );
  assign io_inputs_0_cmd_ready = _zz_3_;
  assign io_inputs_1_cmd_ready = _zz_4_;
  assign logic_rspRouteOh = logic_rsp_target;
  assign _zz_1_ = (! (logic_rsp_pending && (! io_output_rsp_valid)));
  assign _zz_2_ = (io_output_cmd_ready && _zz_1_);
  assign io_output_cmd_valid = (_zz_5_ && _zz_1_);
  assign io_output_cmd_payload_wr = _zz_6_;
  assign io_output_cmd_payload_address = _zz_7_;
  assign io_output_cmd_payload_data = _zz_8_;
  assign io_output_cmd_payload_mask = _zz_9_;
  assign io_inputs_0_rsp_valid = (io_output_rsp_valid && logic_rspRouteOh[0]);
  assign io_inputs_0_rsp_payload_data = io_output_rsp_payload_data;
  assign io_inputs_1_rsp_valid = (io_output_rsp_valid && logic_rspRouteOh[1]);
  assign io_inputs_1_rsp_payload_data = io_output_rsp_payload_data;
  always @ (posedge io_clk) begin
    if(GLOBAL_BUFFER_OUTPUT) begin
      logic_rsp_pending <= 1'b0;
    end else begin
      if(io_output_rsp_valid)begin
        logic_rsp_pending <= 1'b0;
      end
      if(_zz_12_)begin
        logic_rsp_pending <= 1'b1;
      end
    end
  end

  always @ (posedge io_clk) begin
    if(_zz_12_)begin
      logic_rsp_target <= _zz_11_;
    end
  end

endmodule

module Up5kPerf (
      input   io_clk,
      input   io_reset,
      output [2:0] io_leds,
      output  io_serialTx,
      output [0:0] io_flash_ss,
      output  io_flash_sclk,
      output  io_flash_mosi,
      input   io_flash_miso);
  wire  _zz_20_;
  wire  _zz_21_;
  wire  _zz_22_;
  wire [15:0] _zz_23_;
  wire [15:0] _zz_24_;
  wire [15:0] _zz_25_;
  wire [15:0] _zz_26_;
  wire [5:0] _zz_27_;
  wire  _zz_28_;
  wire  _zz_29_;
  wire  _zz_30_;
  wire  _zz_31_;
  wire [31:0] _zz_32_;
  wire  _zz_33_;
  wire  _zz_34_;
  wire [31:0] _zz_35_;
  wire  _zz_36_;
  wire  _zz_37_;
  wire [31:0] _zz_38_;
  wire  _zz_39_;
  wire [2:0] _zz_40_;
  wire  _zz_41_;
  wire  _zz_42_;
  wire  _zz_43_;
  wire [31:0] _zz_44_;
  wire  _zz_45_;
  wire  _zz_46_;
  wire [0:0] _zz_47_;
  wire  _zz_48_;
  wire [31:0] _zz_49_;
  wire  _zz_50_;
  wire  _zz_51_;
  wire [31:0] _zz_52_;
  wire [31:0] _zz_53_;
  wire [1:0] _zz_54_;
  wire  _zz_55_;
  wire  _zz_56_;
  wire [31:0] _zz_57_;
  wire  _zz_58_;
  wire  _zz_59_;
  wire [19:0] _zz_60_;
  wire [31:0] _zz_61_;
  wire [3:0] _zz_62_;
  wire  _zz_63_;
  wire  _zz_64_;
  wire [19:0] _zz_65_;
  wire [31:0] _zz_66_;
  wire [3:0] _zz_67_;
  wire  _zz_68_;
  wire  _zz_69_;
  wire [31:0] _zz_70_;
  wire  _zz_71_;
  wire  _zz_72_;
  wire [19:0] _zz_73_;
  wire [31:0] _zz_74_;
  wire [3:0] _zz_75_;
  wire  _zz_76_;
  wire  _zz_77_;
  wire [19:0] _zz_78_;
  wire [31:0] _zz_79_;
  wire [3:0] _zz_80_;
  wire  _zz_81_;
  wire  _zz_82_;
  wire [31:0] _zz_83_;
  wire  _zz_84_;
  wire  _zz_85_;
  wire [19:0] _zz_86_;
  wire [31:0] _zz_87_;
  wire [3:0] _zz_88_;
  wire  _zz_89_;
  wire  _zz_90_;
  wire [19:0] _zz_91_;
  wire [31:0] _zz_92_;
  wire [3:0] _zz_93_;
  wire  _zz_94_;
  wire  _zz_95_;
  wire [19:0] _zz_96_;
  wire [31:0] _zz_97_;
  wire [3:0] _zz_98_;
  wire  _zz_99_;
  wire  _zz_100_;
  wire [19:0] _zz_101_;
  wire [31:0] _zz_102_;
  wire [3:0] _zz_103_;
  wire  _zz_104_;
  wire  _zz_105_;
  wire [31:0] _zz_106_;
  wire  _zz_107_;
  wire  _zz_108_;
  wire [31:0] _zz_109_;
  wire  _zz_110_;
  wire  _zz_111_;
  wire [15:0] _zz_112_;
  wire [31:0] _zz_113_;
  wire [3:0] _zz_114_;
  wire  _zz_115_;
  wire  _zz_116_;
  wire [31:0] _zz_117_;
  wire  _zz_118_;
  wire  _zz_119_;
  wire [31:0] _zz_120_;
  wire  _zz_121_;
  wire  _zz_122_;
  wire [15:0] _zz_123_;
  wire [31:0] _zz_124_;
  wire [3:0] _zz_125_;
  wire  _zz_126_;
  wire  _zz_127_;
  wire [31:0] _zz_128_;
  wire  _zz_129_;
  wire  _zz_130_;
  wire [5:0] _zz_131_;
  wire [31:0] _zz_132_;
  wire [3:0] _zz_133_;
  wire  _zz_134_;
  wire  _zz_135_;
  wire [31:0] _zz_136_;
  wire  _zz_137_;
  wire  _zz_138_;
  wire [19:0] _zz_139_;
  wire [31:0] _zz_140_;
  wire [3:0] _zz_141_;
  wire  _zz_142_;
  wire  _zz_143_;
  wire [31:0] _zz_144_;
  wire  _zz_145_;
  wire  _zz_146_;
  wire [31:0] _zz_147_;
  wire  _zz_148_;
  wire  _zz_149_;
  wire [19:0] _zz_150_;
  wire [31:0] _zz_151_;
  wire [3:0] _zz_152_;
  wire  _zz_153_;
  wire  _zz_154_;
  wire  _zz_155_;
  wire  _zz_156_;
  reg  resetCtrl_mainClkResetUnbuffered;
  reg [5:0] resetCtrl_systemClkResetCounter = (6'b000000);
  wire [5:0] _zz_1_;
  reg  resetCtrl_systemResetBuffered;
  wire  system_dBus_cmd_valid;
  wire  system_dBus_cmd_ready;
  wire  system_dBus_cmd_payload_wr;
  wire [19:0] system_dBus_cmd_payload_address;
  wire [31:0] system_dBus_cmd_payload_data;
  wire [3:0] system_dBus_cmd_payload_mask;
  wire  system_dBus_rsp_valid;
  wire [31:0] system_dBus_rsp_payload_data;
  wire  system_iBus_cmd_valid;
  wire  system_iBus_cmd_ready;
  wire  system_iBus_cmd_payload_wr;
  wire [19:0] system_iBus_cmd_payload_address;
  wire [31:0] system_iBus_cmd_payload_data;
  wire [3:0] system_iBus_cmd_payload_mask;
  wire  system_iBus_rsp_valid;
  wire [31:0] system_iBus_rsp_payload_data;
  wire  system_slowBus_cmd_valid;
  wire  system_slowBus_cmd_ready;
  wire  system_slowBus_cmd_payload_wr;
  wire [19:0] system_slowBus_cmd_payload_address;
  wire [31:0] system_slowBus_cmd_payload_data;
  wire [3:0] system_slowBus_cmd_payload_mask;
  wire  system_slowBus_rsp_valid;
  wire [31:0] system_slowBus_rsp_payload_data;
  reg [0:0] io_flash_ss_regNext;
  reg  io_flash_sclk_regNext;
  reg  io_flash_mosi_regNext;
  reg [3:0] _zz_2_;
  wire  system_dBus_cmd_s2mPipe_valid;
  wire  system_dBus_cmd_s2mPipe_ready;
  wire  system_dBus_cmd_s2mPipe_payload_wr;
  wire [19:0] system_dBus_cmd_s2mPipe_payload_address;
  wire [31:0] system_dBus_cmd_s2mPipe_payload_data;
  wire [3:0] system_dBus_cmd_s2mPipe_payload_mask;
  reg  _zz_3_;
  reg  _zz_4_;
  reg [19:0] _zz_5_;
  reg [31:0] _zz_6_;
  reg [3:0] _zz_7_;
  reg  io_input_rsp_regNext_valid;
  reg [31:0] io_input_rsp_regNext_payload_data;
  wire  io_outputs_1_cmd_halfPipe_valid;
  wire  io_outputs_1_cmd_halfPipe_ready;
  wire  io_outputs_1_cmd_halfPipe_payload_wr;
  wire [19:0] io_outputs_1_cmd_halfPipe_payload_address;
  wire [31:0] io_outputs_1_cmd_halfPipe_payload_data;
  wire [3:0] io_outputs_1_cmd_halfPipe_payload_mask;
  reg  _zz_8_;
  reg  _zz_9_;
  reg  _zz_10_;
  reg [19:0] _zz_11_;
  reg [31:0] _zz_12_;
  reg [3:0] _zz_13_;
  wire  io_outputs_1_cmd_halfPipe_valid_1_;
  wire  io_outputs_1_cmd_halfPipe_ready_1_;
  wire  io_outputs_1_cmd_halfPipe_payload_wr_1_;
  wire [19:0] io_outputs_1_cmd_halfPipe_payload_address_1_;
  wire [31:0] io_outputs_1_cmd_halfPipe_payload_data_1_;
  wire [3:0] io_outputs_1_cmd_halfPipe_payload_mask_1_;
  reg  _zz_14_;
  reg  _zz_15_;
  reg  _zz_16_;
  reg [19:0] _zz_17_;
  reg [31:0] _zz_18_;
  reg [3:0] _zz_19_;
  assign _zz_153_ = (resetCtrl_systemClkResetCounter != _zz_1_);
  assign _zz_154_ = (system_dBus_cmd_ready && (! system_dBus_cmd_s2mPipe_ready));
  assign _zz_155_ = (! _zz_8_);
  assign _zz_156_ = (! _zz_14_);
  BufferCC bufferCC_1_ ( 
    .io_dataIn(io_reset),
    .io_dataOut(_zz_28_),
    .io_clk(io_clk) 
  );
  SB_GB resetCtrl_systemResetBuffered_SB_GB ( 
    .USER_SIGNAL_TO_GLOBAL_BUFFER(resetCtrl_systemResetBuffered),
    .GLOBAL_BUFFER_OUTPUT(_zz_29_) 
  );
  Spram system_iRam ( 
    .io_bus_cmd_valid(_zz_110_),
    .io_bus_cmd_ready(_zz_30_),
    .io_bus_cmd_payload_wr(_zz_111_),
    .io_bus_cmd_payload_address(_zz_112_),
    .io_bus_cmd_payload_data(_zz_113_),
    .io_bus_cmd_payload_mask(_zz_114_),
    .io_bus_rsp_valid(_zz_31_),
    .io_bus_rsp_payload_data(_zz_32_),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(_zz_29_) 
  );
  Spram system_dRam ( 
    .io_bus_cmd_valid(_zz_121_),
    .io_bus_cmd_ready(_zz_33_),
    .io_bus_cmd_payload_wr(_zz_122_),
    .io_bus_cmd_payload_address(_zz_123_),
    .io_bus_cmd_payload_data(_zz_124_),
    .io_bus_cmd_payload_mask(_zz_125_),
    .io_bus_rsp_valid(_zz_34_),
    .io_bus_rsp_payload_data(_zz_35_),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(_zz_29_) 
  );
  Peripherals system_peripherals ( 
    .io_bus_cmd_valid(_zz_129_),
    .io_bus_cmd_ready(_zz_36_),
    .io_bus_cmd_payload_wr(_zz_130_),
    .io_bus_cmd_payload_address(_zz_131_),
    .io_bus_cmd_payload_data(_zz_132_),
    .io_bus_cmd_payload_mask(_zz_133_),
    .io_bus_rsp_valid(_zz_37_),
    .io_bus_rsp_payload_data(_zz_38_),
    .io_mTimeInterrupt(_zz_39_),
    .io_leds(_zz_40_),
    .io_serialTx(_zz_41_),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(_zz_29_) 
  );
  FlashXpi system_flashXip ( 
    .io_bus_cmd_valid(_zz_137_),
    .io_bus_cmd_ready(_zz_42_),
    .io_bus_cmd_payload_wr(_zz_138_),
    .io_bus_cmd_payload_address(_zz_139_),
    .io_bus_cmd_payload_data(_zz_140_),
    .io_bus_cmd_payload_mask(_zz_141_),
    .io_bus_rsp_valid(_zz_43_),
    .io_bus_rsp_payload_data(_zz_44_),
    .io_flash_ss(_zz_47_),
    .io_flash_sclk(_zz_45_),
    .io_flash_mosi(_zz_46_),
    .io_flash_miso(io_flash_miso),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(_zz_29_) 
  );
  VexRiscv system_cpu ( 
    .iBus_cmd_valid(_zz_48_),
    .iBus_cmd_ready(system_iBus_cmd_ready),
    .iBus_cmd_payload_pc(_zz_49_),
    .iBus_rsp_valid(system_iBus_rsp_valid),
    .iBus_rsp_payload_error(_zz_20_),
    .iBus_rsp_payload_inst(system_iBus_rsp_payload_data),
    .timerInterrupt(_zz_39_),
    .externalInterrupt(_zz_21_),
    .dBus_cmd_valid(_zz_50_),
    .dBus_cmd_ready(system_dBus_cmd_ready),
    .dBus_cmd_payload_wr(_zz_51_),
    .dBus_cmd_payload_address(_zz_52_),
    .dBus_cmd_payload_data(_zz_53_),
    .dBus_cmd_payload_size(_zz_54_),
    .dBus_rsp_ready(system_dBus_rsp_valid),
    .dBus_rsp_error(_zz_22_),
    .dBus_rsp_data(system_dBus_rsp_payload_data),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(_zz_29_) 
  );
  SimpleBusDecoder system_dBus_decoder ( 
    .io_input_cmd_valid(system_dBus_cmd_s2mPipe_valid),
    .io_input_cmd_ready(_zz_55_),
    .io_input_cmd_payload_wr(system_dBus_cmd_s2mPipe_payload_wr),
    .io_input_cmd_payload_address(system_dBus_cmd_s2mPipe_payload_address),
    .io_input_cmd_payload_data(system_dBus_cmd_s2mPipe_payload_data),
    .io_input_cmd_payload_mask(system_dBus_cmd_s2mPipe_payload_mask),
    .io_input_rsp_valid(_zz_56_),
    .io_input_rsp_payload_data(_zz_57_),
    .io_outputs_0_cmd_valid(_zz_58_),
    .io_outputs_0_cmd_ready(_zz_115_),
    .io_outputs_0_cmd_payload_wr(_zz_59_),
    .io_outputs_0_cmd_payload_address(_zz_60_),
    .io_outputs_0_cmd_payload_data(_zz_61_),
    .io_outputs_0_cmd_payload_mask(_zz_62_),
    .io_outputs_0_rsp_valid(_zz_116_),
    .io_outputs_0_rsp_0_data(_zz_117_),
    .io_outputs_1_cmd_valid(_zz_63_),
    .io_outputs_1_cmd_ready(_zz_9_),
    .io_outputs_1_cmd_payload_wr(_zz_64_),
    .io_outputs_1_cmd_payload_address(_zz_65_),
    .io_outputs_1_cmd_payload_data(_zz_66_),
    .io_outputs_1_cmd_payload_mask(_zz_67_),
    .io_outputs_1_rsp_valid(_zz_143_),
    .io_outputs_1_rsp_1_data(_zz_144_),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(_zz_29_) 
  );
  SimpleBusDecoder_1_ system_iBus_decoder ( 
    .io_input_cmd_valid(system_iBus_cmd_valid),
    .io_input_cmd_ready(_zz_68_),
    .io_input_cmd_payload_wr(system_iBus_cmd_payload_wr),
    .io_input_cmd_payload_address(system_iBus_cmd_payload_address),
    .io_input_cmd_payload_data(system_iBus_cmd_payload_data),
    .io_input_cmd_payload_mask(system_iBus_cmd_payload_mask),
    .io_input_rsp_valid(_zz_69_),
    .io_input_rsp_payload_data(_zz_70_),
    .io_outputs_0_cmd_valid(_zz_71_),
    .io_outputs_0_cmd_ready(_zz_104_),
    .io_outputs_0_cmd_payload_wr(_zz_72_),
    .io_outputs_0_cmd_payload_address(_zz_73_),
    .io_outputs_0_cmd_payload_data(_zz_74_),
    .io_outputs_0_cmd_payload_mask(_zz_75_),
    .io_outputs_0_rsp_valid(_zz_105_),
    .io_outputs_0_rsp_0_data(_zz_106_),
    .io_outputs_1_cmd_valid(_zz_76_),
    .io_outputs_1_cmd_ready(_zz_15_),
    .io_outputs_1_cmd_payload_wr(_zz_77_),
    .io_outputs_1_cmd_payload_address(_zz_78_),
    .io_outputs_1_cmd_payload_data(_zz_79_),
    .io_outputs_1_cmd_payload_mask(_zz_80_),
    .io_outputs_1_rsp_valid(_zz_146_),
    .io_outputs_1_rsp_1_data(_zz_147_),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(_zz_29_) 
  );
  SimpleBusDecoder_2_ system_slowBus_decoder ( 
    .io_input_cmd_valid(system_slowBus_cmd_valid),
    .io_input_cmd_ready(_zz_81_),
    .io_input_cmd_payload_wr(system_slowBus_cmd_payload_wr),
    .io_input_cmd_payload_address(system_slowBus_cmd_payload_address),
    .io_input_cmd_payload_data(system_slowBus_cmd_payload_data),
    .io_input_cmd_payload_mask(system_slowBus_cmd_payload_mask),
    .io_input_rsp_valid(_zz_82_),
    .io_input_rsp_payload_data(_zz_83_),
    .io_outputs_0_cmd_valid(_zz_84_),
    .io_outputs_0_cmd_ready(_zz_107_),
    .io_outputs_0_cmd_payload_wr(_zz_85_),
    .io_outputs_0_cmd_payload_address(_zz_86_),
    .io_outputs_0_cmd_payload_data(_zz_87_),
    .io_outputs_0_cmd_payload_mask(_zz_88_),
    .io_outputs_0_rsp_valid(_zz_108_),
    .io_outputs_0_rsp_0_data(_zz_109_),
    .io_outputs_1_cmd_valid(_zz_89_),
    .io_outputs_1_cmd_ready(_zz_118_),
    .io_outputs_1_cmd_payload_wr(_zz_90_),
    .io_outputs_1_cmd_payload_address(_zz_91_),
    .io_outputs_1_cmd_payload_data(_zz_92_),
    .io_outputs_1_cmd_payload_mask(_zz_93_),
    .io_outputs_1_rsp_valid(_zz_119_),
    .io_outputs_1_rsp_1_data(_zz_120_),
    .io_outputs_2_cmd_valid(_zz_94_),
    .io_outputs_2_cmd_ready(_zz_126_),
    .io_outputs_2_cmd_payload_wr(_zz_95_),
    .io_outputs_2_cmd_payload_address(_zz_96_),
    .io_outputs_2_cmd_payload_data(_zz_97_),
    .io_outputs_2_cmd_payload_mask(_zz_98_),
    .io_outputs_2_rsp_valid(_zz_127_),
    .io_outputs_2_rsp_2_data(_zz_128_),
    .io_outputs_3_cmd_valid(_zz_99_),
    .io_outputs_3_cmd_ready(_zz_134_),
    .io_outputs_3_cmd_payload_wr(_zz_100_),
    .io_outputs_3_cmd_payload_address(_zz_101_),
    .io_outputs_3_cmd_payload_data(_zz_102_),
    .io_outputs_3_cmd_payload_mask(_zz_103_),
    .io_outputs_3_rsp_valid(_zz_135_),
    .io_outputs_3_rsp_3_data(_zz_136_),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(_zz_29_) 
  );
  SimpleBusArbiter system_iRam_io_bus_arbiter ( 
    .io_inputs_0_cmd_valid(_zz_71_),
    .io_inputs_0_cmd_ready(_zz_104_),
    .io_inputs_0_cmd_payload_wr(_zz_72_),
    .io_inputs_0_cmd_payload_address(_zz_23_),
    .io_inputs_0_cmd_payload_data(_zz_74_),
    .io_inputs_0_cmd_payload_mask(_zz_75_),
    .io_inputs_0_rsp_valid(_zz_105_),
    .io_inputs_0_rsp_payload_data(_zz_106_),
    .io_inputs_1_cmd_valid(_zz_84_),
    .io_inputs_1_cmd_ready(_zz_107_),
    .io_inputs_1_cmd_payload_wr(_zz_85_),
    .io_inputs_1_cmd_payload_address(_zz_24_),
    .io_inputs_1_cmd_payload_data(_zz_87_),
    .io_inputs_1_cmd_payload_mask(_zz_88_),
    .io_inputs_1_rsp_valid(_zz_108_),
    .io_inputs_1_rsp_payload_data(_zz_109_),
    .io_output_cmd_valid(_zz_110_),
    .io_output_cmd_ready(_zz_30_),
    .io_output_cmd_payload_wr(_zz_111_),
    .io_output_cmd_payload_address(_zz_112_),
    .io_output_cmd_payload_data(_zz_113_),
    .io_output_cmd_payload_mask(_zz_114_),
    .io_output_rsp_valid(_zz_31_),
    .io_output_rsp_payload_data(_zz_32_),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(_zz_29_) 
  );
  SimpleBusArbiter system_dRam_io_bus_arbiter ( 
    .io_inputs_0_cmd_valid(_zz_58_),
    .io_inputs_0_cmd_ready(_zz_115_),
    .io_inputs_0_cmd_payload_wr(_zz_59_),
    .io_inputs_0_cmd_payload_address(_zz_25_),
    .io_inputs_0_cmd_payload_data(_zz_61_),
    .io_inputs_0_cmd_payload_mask(_zz_62_),
    .io_inputs_0_rsp_valid(_zz_116_),
    .io_inputs_0_rsp_payload_data(_zz_117_),
    .io_inputs_1_cmd_valid(_zz_89_),
    .io_inputs_1_cmd_ready(_zz_118_),
    .io_inputs_1_cmd_payload_wr(_zz_90_),
    .io_inputs_1_cmd_payload_address(_zz_26_),
    .io_inputs_1_cmd_payload_data(_zz_92_),
    .io_inputs_1_cmd_payload_mask(_zz_93_),
    .io_inputs_1_rsp_valid(_zz_119_),
    .io_inputs_1_rsp_payload_data(_zz_120_),
    .io_output_cmd_valid(_zz_121_),
    .io_output_cmd_ready(_zz_33_),
    .io_output_cmd_payload_wr(_zz_122_),
    .io_output_cmd_payload_address(_zz_123_),
    .io_output_cmd_payload_data(_zz_124_),
    .io_output_cmd_payload_mask(_zz_125_),
    .io_output_rsp_valid(_zz_34_),
    .io_output_rsp_payload_data(_zz_35_),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(_zz_29_) 
  );
  SimpleBusArbiter_2_ system_peripherals_io_bus_arbiter ( 
    .io_inputs_0_cmd_valid(_zz_94_),
    .io_inputs_0_cmd_ready(_zz_126_),
    .io_inputs_0_cmd_payload_wr(_zz_95_),
    .io_inputs_0_cmd_payload_address(_zz_27_),
    .io_inputs_0_cmd_payload_data(_zz_97_),
    .io_inputs_0_cmd_payload_mask(_zz_98_),
    .io_inputs_0_rsp_valid(_zz_127_),
    .io_inputs_0_rsp_payload_data(_zz_128_),
    .io_output_cmd_valid(_zz_129_),
    .io_output_cmd_ready(_zz_36_),
    .io_output_cmd_payload_wr(_zz_130_),
    .io_output_cmd_payload_address(_zz_131_),
    .io_output_cmd_payload_data(_zz_132_),
    .io_output_cmd_payload_mask(_zz_133_),
    .io_output_rsp_valid(_zz_37_),
    .io_output_rsp_payload_data(_zz_38_) 
  );
  SimpleBusArbiter_3_ system_flashXip_io_bus_arbiter ( 
    .io_inputs_0_cmd_valid(_zz_99_),
    .io_inputs_0_cmd_ready(_zz_134_),
    .io_inputs_0_cmd_payload_wr(_zz_100_),
    .io_inputs_0_cmd_payload_address(_zz_101_),
    .io_inputs_0_cmd_payload_data(_zz_102_),
    .io_inputs_0_cmd_payload_mask(_zz_103_),
    .io_inputs_0_rsp_valid(_zz_135_),
    .io_inputs_0_rsp_payload_data(_zz_136_),
    .io_output_cmd_valid(_zz_137_),
    .io_output_cmd_ready(_zz_42_),
    .io_output_cmd_payload_wr(_zz_138_),
    .io_output_cmd_payload_address(_zz_139_),
    .io_output_cmd_payload_data(_zz_140_),
    .io_output_cmd_payload_mask(_zz_141_),
    .io_output_rsp_valid(_zz_43_),
    .io_output_rsp_payload_data(_zz_44_) 
  );
  SimpleBusArbiter_4_ system_slowBus_arbiter ( 
    .io_inputs_0_cmd_valid(io_outputs_1_cmd_halfPipe_valid),
    .io_inputs_0_cmd_ready(_zz_142_),
    .io_inputs_0_cmd_payload_wr(io_outputs_1_cmd_halfPipe_payload_wr),
    .io_inputs_0_cmd_payload_address(io_outputs_1_cmd_halfPipe_payload_address),
    .io_inputs_0_cmd_payload_data(io_outputs_1_cmd_halfPipe_payload_data),
    .io_inputs_0_cmd_payload_mask(io_outputs_1_cmd_halfPipe_payload_mask),
    .io_inputs_0_rsp_valid(_zz_143_),
    .io_inputs_0_rsp_payload_data(_zz_144_),
    .io_inputs_1_cmd_valid(io_outputs_1_cmd_halfPipe_valid_1_),
    .io_inputs_1_cmd_ready(_zz_145_),
    .io_inputs_1_cmd_payload_wr(io_outputs_1_cmd_halfPipe_payload_wr_1_),
    .io_inputs_1_cmd_payload_address(io_outputs_1_cmd_halfPipe_payload_address_1_),
    .io_inputs_1_cmd_payload_data(io_outputs_1_cmd_halfPipe_payload_data_1_),
    .io_inputs_1_cmd_payload_mask(io_outputs_1_cmd_halfPipe_payload_mask_1_),
    .io_inputs_1_rsp_valid(_zz_146_),
    .io_inputs_1_rsp_payload_data(_zz_147_),
    .io_output_cmd_valid(_zz_148_),
    .io_output_cmd_ready(system_slowBus_cmd_ready),
    .io_output_cmd_payload_wr(_zz_149_),
    .io_output_cmd_payload_address(_zz_150_),
    .io_output_cmd_payload_data(_zz_151_),
    .io_output_cmd_payload_mask(_zz_152_),
    .io_output_rsp_valid(system_slowBus_rsp_valid),
    .io_output_rsp_payload_data(system_slowBus_rsp_payload_data),
    .io_clk(io_clk),
    .GLOBAL_BUFFER_OUTPUT(_zz_29_) 
  );
  always @ (*) begin
    resetCtrl_mainClkResetUnbuffered = 1'b0;
    if(_zz_153_)begin
      resetCtrl_mainClkResetUnbuffered = 1'b1;
    end
  end

  assign _zz_1_[5 : 0] = (6'b111111);
  assign io_serialTx = _zz_41_;
  assign io_leds = _zz_40_;
  assign io_flash_ss = io_flash_ss_regNext;
  assign io_flash_sclk = io_flash_sclk_regNext;
  assign io_flash_mosi = io_flash_mosi_regNext;
  assign system_iBus_cmd_valid = _zz_48_;
  assign system_iBus_cmd_payload_wr = 1'b0;
  assign system_iBus_cmd_payload_address = _zz_49_[19:0];
  assign system_iBus_cmd_payload_data = (32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
  assign system_iBus_cmd_payload_mask = (4'bxxxx);
  assign _zz_20_ = 1'b0;
  assign system_dBus_cmd_valid = _zz_50_;
  assign system_dBus_cmd_payload_wr = _zz_51_;
  assign system_dBus_cmd_payload_address = _zz_52_[19:0];
  assign system_dBus_cmd_payload_data = _zz_53_;
  always @ (*) begin
    case(_zz_54_)
      2'b00 : begin
        _zz_2_ = (4'b0001);
      end
      2'b01 : begin
        _zz_2_ = (4'b0011);
      end
      default : begin
        _zz_2_ = (4'b1111);
      end
    endcase
  end

  assign system_dBus_cmd_payload_mask = (_zz_2_ <<< _zz_52_[1 : 0]);
  assign _zz_21_ = 1'b0;
  assign system_dBus_cmd_s2mPipe_valid = (system_dBus_cmd_valid || _zz_3_);
  assign system_dBus_cmd_ready = (! _zz_3_);
  assign system_dBus_cmd_s2mPipe_payload_wr = (_zz_3_ ? _zz_4_ : system_dBus_cmd_payload_wr);
  assign system_dBus_cmd_s2mPipe_payload_address = (_zz_3_ ? _zz_5_ : system_dBus_cmd_payload_address);
  assign system_dBus_cmd_s2mPipe_payload_data = (_zz_3_ ? _zz_6_ : system_dBus_cmd_payload_data);
  assign system_dBus_cmd_s2mPipe_payload_mask = (_zz_3_ ? _zz_7_ : system_dBus_cmd_payload_mask);
  assign system_dBus_cmd_s2mPipe_ready = _zz_55_;
  assign system_dBus_rsp_valid = _zz_56_;
  assign system_dBus_rsp_payload_data = _zz_57_;
  assign system_iBus_cmd_ready = _zz_68_;
  assign system_iBus_rsp_valid = _zz_69_;
  assign system_iBus_rsp_payload_data = _zz_70_;
  assign system_slowBus_cmd_ready = _zz_81_;
  assign system_slowBus_rsp_valid = io_input_rsp_regNext_valid;
  assign system_slowBus_rsp_payload_data = io_input_rsp_regNext_payload_data;
  assign system_slowBus_cmd_valid = _zz_148_;
  assign system_slowBus_cmd_payload_wr = _zz_149_;
  assign system_slowBus_cmd_payload_address = _zz_150_;
  assign system_slowBus_cmd_payload_data = _zz_151_;
  assign system_slowBus_cmd_payload_mask = _zz_152_;
  assign _zz_25_ = _zz_60_[15:0];
  assign io_outputs_1_cmd_halfPipe_valid = _zz_8_;
  assign io_outputs_1_cmd_halfPipe_payload_wr = _zz_10_;
  assign io_outputs_1_cmd_halfPipe_payload_address = _zz_11_;
  assign io_outputs_1_cmd_halfPipe_payload_data = _zz_12_;
  assign io_outputs_1_cmd_halfPipe_payload_mask = _zz_13_;
  assign io_outputs_1_cmd_halfPipe_ready = _zz_142_;
  assign _zz_23_ = _zz_73_[15:0];
  assign io_outputs_1_cmd_halfPipe_valid_1_ = _zz_14_;
  assign io_outputs_1_cmd_halfPipe_payload_wr_1_ = _zz_16_;
  assign io_outputs_1_cmd_halfPipe_payload_address_1_ = _zz_17_;
  assign io_outputs_1_cmd_halfPipe_payload_data_1_ = _zz_18_;
  assign io_outputs_1_cmd_halfPipe_payload_mask_1_ = _zz_19_;
  assign io_outputs_1_cmd_halfPipe_ready_1_ = _zz_145_;
  assign _zz_24_ = _zz_86_[15:0];
  assign _zz_26_ = _zz_91_[15:0];
  assign _zz_27_ = _zz_96_[5:0];
  always @ (posedge io_clk) begin
    if(_zz_153_)begin
      resetCtrl_systemClkResetCounter <= (resetCtrl_systemClkResetCounter + (6'b000001));
    end
    if(_zz_28_)begin
      resetCtrl_systemClkResetCounter <= (6'b000000);
    end
  end

  always @ (posedge io_clk) begin
    resetCtrl_systemResetBuffered <= resetCtrl_mainClkResetUnbuffered;
  end

  always @ (posedge io_clk) begin
    if(_zz_29_) begin
      io_flash_ss_regNext <= (1'b1);
      io_flash_sclk_regNext <= 1'b0;
      _zz_3_ <= 1'b0;
      io_input_rsp_regNext_valid <= 1'b0;
      _zz_8_ <= 1'b0;
      _zz_9_ <= 1'b1;
      _zz_14_ <= 1'b0;
      _zz_15_ <= 1'b1;
    end else begin
      io_flash_ss_regNext <= _zz_47_;
      io_flash_sclk_regNext <= _zz_45_;
      if(system_dBus_cmd_s2mPipe_ready)begin
        _zz_3_ <= 1'b0;
      end
      if(_zz_154_)begin
        _zz_3_ <= system_dBus_cmd_valid;
      end
      io_input_rsp_regNext_valid <= _zz_82_;
      if(_zz_155_)begin
        _zz_8_ <= _zz_63_;
        _zz_9_ <= (! _zz_63_);
      end else begin
        _zz_8_ <= (! io_outputs_1_cmd_halfPipe_ready);
        _zz_9_ <= io_outputs_1_cmd_halfPipe_ready;
      end
      if(_zz_156_)begin
        _zz_14_ <= _zz_76_;
        _zz_15_ <= (! _zz_76_);
      end else begin
        _zz_14_ <= (! io_outputs_1_cmd_halfPipe_ready_1_);
        _zz_15_ <= io_outputs_1_cmd_halfPipe_ready_1_;
      end
    end
  end

  always @ (posedge io_clk) begin
    io_flash_mosi_regNext <= _zz_46_;
    if(_zz_154_)begin
      _zz_4_ <= system_dBus_cmd_payload_wr;
      _zz_5_ <= system_dBus_cmd_payload_address;
      _zz_6_ <= system_dBus_cmd_payload_data;
      _zz_7_ <= system_dBus_cmd_payload_mask;
    end
    io_input_rsp_regNext_payload_data <= _zz_83_;
    if(_zz_155_)begin
      _zz_10_ <= _zz_64_;
      _zz_11_ <= _zz_65_;
      _zz_12_ <= _zz_66_;
      _zz_13_ <= _zz_67_;
    end
    if(_zz_156_)begin
      _zz_16_ <= _zz_77_;
      _zz_17_ <= _zz_78_;
      _zz_18_ <= _zz_79_;
      _zz_19_ <= _zz_80_;
    end
  end

endmodule
