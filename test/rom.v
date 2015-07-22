`timescale 1ns/1ps

module ROM(addr, data);
input [31:0] addr;
output [31:0] data;

localparam ROM_SIZE = 32;

reg [31:0] data;
reg [31:0] ROM_DATA[ROM_SIZE-1:0];

always@(*)
    case(addr[7:2])  // Address Must Be Word Aligned.
        0: data <= 32'h08000003;
        1: data <= 32'h08000032;
        2: data <= 32'h08000077;
        3: data <= 32'h20080040;
        4: data <= 32'hac080000;
        5: data <= 32'h20080079;
        6: data <= 32'hac080004;
        7: data <= 32'h20080024;
        8: data <= 32'hac080008;
        9: data <= 32'h20080030;
        10: data <= 32'hac08000c;
        11: data <= 32'h20080019;
        12: data <= 32'hac080010;
        13: data <= 32'h20080012;
        14: data <= 32'hac080014;
        15: data <= 32'h20080002;
        16: data <= 32'hac080018;
        17: data <= 32'h20080078;
        18: data <= 32'hac08001c;
        19: data <= 32'h20080000;
        20: data <= 32'hac080020;
        21: data <= 32'h20080010;
        22: data <= 32'hac080024;
        23: data <= 32'h20080008;
        24: data <= 32'hac080028;
        25: data <= 32'h20080003;
        26: data <= 32'hac08002c;
        27: data <= 32'h20080046;
        28: data <= 32'hac080030;
        29: data <= 32'h20080021;
        30: data <= 32'hac080034;
        31: data <= 32'h20080006;
        32: data <= 32'hac080038;
        33: data <= 32'h2008000e;
        34: data <= 32'hac08003c;
        35: data <= 32'h3c174000;
        36: data <= 32'haee00008;
        37: data <= 32'h20088000;
        38: data <= 32'haee80000;
        39: data <= 32'h2008ffff;
        40: data <= 32'haee80004;
        41: data <= 32'h0c00002a;
        42: data <= 32'h3c088000;
        43: data <= 32'h01004027;
        44: data <= 32'h011ff824;
        45: data <= 32'h23ff0014;
        46: data <= 32'h03e00008;
        47: data <= 32'h20080003;
        48: data <= 32'haee80008;
        49: data <= 32'h08000031;
        50: data <= 32'h3c174000;
        51: data <= 32'h8ee80008;
        52: data <= 32'h2009fff9;
        53: data <= 32'h01094024;
        54: data <= 32'haee80008;
        55: data <= 32'h8ee80020;
        56: data <= 32'h1100001d;
        57: data <= 32'h8ee40018;
        58: data <= 32'h00000000;
        59: data <= 32'h00000000;
        60: data <= 32'h8ee5001c;
        61: data <= 32'h00000000;
        62: data <= 32'h00000000;
        63: data <= 32'h10800015;
        64: data <= 32'h00000000;
        65: data <= 32'h00000000;
        66: data <= 32'h10a00012;
        67: data <= 32'h00000000;
        68: data <= 32'h00000000;
        69: data <= 32'h00808020;
        70: data <= 32'h00a08820;
        71: data <= 32'h0211402a;
        72: data <= 32'h15000002;
        73: data <= 32'h02118022;
        74: data <= 32'h08000047;
        75: data <= 32'h02004020;
        76: data <= 32'h02208020;
        77: data <= 32'h01008820;
        78: data <= 32'h1620fff8;
        79: data <= 32'h02001020;
        80: data <= 32'haee20024;
        81: data <= 32'h20080001;
        82: data <= 32'haee80028;
        83: data <= 32'haee00028;
        84: data <= 32'h08000056;
        85: data <= 32'h00001020;
        86: data <= 32'haee2000c;
        87: data <= 32'h8eec0014;
        88: data <= 32'h000c6202;
        89: data <= 32'h318c000f;
        90: data <= 32'h000c6040;
        91: data <= 32'h20080001;
        92: data <= 32'h20090002;
        93: data <= 32'h200a0004;
        94: data <= 32'h200b0008;
        95: data <= 32'h11880004;
        96: data <= 32'h11890005;
        97: data <= 32'h118a0006;
        98: data <= 32'h118b0007;
        99: data <= 32'h200c0001;
        100: data <= 32'h00046902;
        101: data <= 32'h0800006c;
        102: data <= 32'h00806820;
        103: data <= 32'h0800006c;
        104: data <= 32'h00056902;
        105: data <= 32'h0800006c;
        106: data <= 32'h00a06820;
        107: data <= 32'h0800006c;
        108: data <= 32'h31ad000f;
        109: data <= 32'h000d6880;
        110: data <= 32'h8dad0000;
        111: data <= 32'h000c6200;
        112: data <= 32'h018d4020;
        113: data <= 32'haee80014;
        114: data <= 32'h8ee80008;
        115: data <= 32'h20090002;
        116: data <= 32'h01094025;
        117: data <= 32'haee80008;
        118: data <= 32'h03400008;
        119: data <= 32'h03400008;
        default: data <= 32'h0800_0000;
    endcase
endmodule
