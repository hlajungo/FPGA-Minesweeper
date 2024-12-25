module Mineswepper (
input CLK, //clock
input [5:0] inp,
output reg [7:0] mled_r, mled_g, mled_b, // matrix led
output reg [3:0] mled_COM, // matrix led COM
output reg [6:0] seg, // seg
output reg [3:0] seg_COM // seg COM
);

parameter logic [9:0][7:0][7:0] map_data  = 
'{
  { 
  8'b01111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111
  },
  { 
  8'b10111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111
  }, 
  { 
  8'b11011111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111
  }, 
  { 
  8'b11101111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111
  }, 
  { 
  8'b11110111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111
  }, 
  { 
  8'b11111011,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111
  }, 
  { 
  8'b11111101,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111
  }, 
  { 
  8'b11111110,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111
  }, 
  { 
  8'b11111111,
  8'b01111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111,
  8'b11111111
  }, 
  { 
  8'b00000000,
  8'b00000000,
  8'b00000000,
  8'b00000000,
  8'b00000000,
  8'b00000000,
  8'b00000000,
  8'b00000000
  }
};

// wire變量初始化
  reg [3:0] levelNum;
  reg [6:0] level_seg;
  reg [6:0] mineNum_seg;
  bit strFlag; // 遊戲開始 flag
  bit [2:0] cnt; // mled 繪製目標行
  integer player_x=3, player_y=4; // 玩家位置, 0 代表左上，範圍={0, 7}
  reg player_flag =0; // player 閃爍 flag
  bit lose_flag=0; // 1 代表輸
  bit win_flag=0; // 1 代表贏
  bit win_flag2=0; // 1 代表贏
  // 地雷, 0=地雷, 1=沒壓過, 2=壓過
  reg [2:0] mine_map [9:0][9:0]; // 儲存地雷的地圖, 有防觸發牆(1~8是有效數據)
  // 紅, 0=紅
  // 綠, 0=綠
  // 藍, 0=藍
  reg [7:0][7:0] r_map, g_map, b_map;
  reg [3:0] mineNum_map [9:0][9:0]; // 儲存地雷數量的地圖, 有防觸發牆(1~8是有效數據)
  integer i, j, k, l;  // 用於循環的索引變量
// 寄存器數據初始化


initial begin
  strFlag=0;

  // seg
  levelNum = 4'b0000;
  seg = 7'b1111111;
  seg_COM = 4'b0111;
  // mled
  mled_COM = 4'b1000;
  mled_r=8'b11111111;
  mled_g=8'b11111111;
  mled_b=8'b11111111;
  
  // mled 數據
  for (int i = 0; i < 8; i = i + 1) begin
    b_map[i] = 8'b11111111; // 初始全藍
	 r_map[i] = 8'b00000000;
	 g_map[i] = 8'b11111111;
  end
  
  
  
  // 地雷記數
  for (i =0; i<10; i=i+1) begin
	for (j=0; j<10; j=j+1)begin
	  mineNum_map[i][j] = 4'b0000;
	end
  end
  
end

// 各種 clock 初始化
  divfreq_1 Hz1(CLK, CLK_1Hz);
  divfreq_100 Hz100(CLK, CLK_100Hz);
  divfreq_1000 Hz1000(CLK, CLK_1000Hz);
  divfreq_10000 Hz10000(CLK, CLK_10000Hz);



 // win_flag2 1 代表贏
// lose_flag 1 代表輸掉
// strFlag 0 代表未開始
  // keyboard clock
always @(posedge CLK_1Hz) begin
case (inp)
  6'b0000001: begin// 選擇左邊地圖
    if (strFlag == 0 ) begin
      if (levelNum > 0)
        levelNum <= levelNum - 1'b1;
	 end else if (strFlag == 1 && win_flag2 == 0 && lose_flag == 0) begin // 玩家上
	   if (player_y >0)
		  player_y-=1;
    end
  end
  6'b000010: begin// 選擇右邊地圖
    if (strFlag == 0) begin
      if (levelNum < 9)
        levelNum <= levelNum + 1'b1;
    end else if (strFlag == 1 && win_flag2 == 0 && lose_flag == 0) begin
	   if (player_y < 7)
	     player_y+=1;
    end
  end
  6'b100000: begin // start/restart 按鈕
    if (strFlag == 0) begin // 開始遊戲
      strFlag=1;
		
		// 取得地圖
		for (i = 0; i < 8; i = i + 1) begin
        for (j = 0; j < 8; j = j + 1) begin
			mine_map[i+1][j+1] <= map_data[levelNum][i][j];
		  end
		end
		
		// 計算地雷
		for (i = 1; i < 9; i = i + 1) begin
        for (j = 1; j < 9; j = j + 1) begin
		    if (mine_map[i][j] == 0) begin // 那是地雷
				mineNum_map[i][j] <= 4'b0101; // 9代表地雷
				mineNum_map[i-1][j-1] <= mineNum_map[i-1][j-1] + 1'b1;
				mineNum_map[i-1][j] <= mineNum_map[i-1][j] + 1'b1;
				mineNum_map[i-1][j+1] <= mineNum_map[i-1][j+1] + 1'b1;
				mineNum_map[i][j-1] <= mineNum_map[i][j-1] + 1'b1;
				mineNum_map[i][j+1] <= mineNum_map[i][j+1] + 1'b1;
				mineNum_map[i+1][j-1] <= mineNum_map[i+1][j-1] + 1'b1;
				mineNum_map[i+1][j] <= mineNum_map[i+1][j] + 1'b1;
				mineNum_map[i+1][j+1] <= mineNum_map[i+1][j+1] + 1'b1;
			  end
        end
       end

    end else begin // 重置遊戲
      strFlag=0;
		lose_flag=0;
		win_flag2=0;
		player_x=3;
		player_y=4;
		
      // 清空 mled 數據
		for (int i = 0; i < 8; i = i + 1) begin
        b_map[i] = 8'b11111111; // 初始全藍
	     r_map[i] = 8'b00000000;
	     g_map[i] = 8'b11111111;
      end

		// 重置地雷計數
		for (i =0; i<10; i=i+1) begin
		  for (j=0; j<10; j=j+1)begin
	       mineNum_map[i][j] =1'b0;
		  end
		end
		
    end
  end

  // 玩家左
  6'b000100: begin
    if (strFlag == 1 && win_flag2 == 0 && lose_flag == 0) begin
	   if (player_x >0)
	     player_x-=1;
    end
  end
  // 玩家右
  6'b001000: begin
    if (strFlag == 1 && win_flag2 == 0 && lose_flag == 0) begin
		if (player_x < 7)
			player_x+=1;
    end
  end

  // 踩地雷
  6'b010000: begin
    if (strFlag == 1 && win_flag2 == 0 && lose_flag == 0) begin
		if (mine_map[1+player_y][1+player_x] == 2) begin // 踩到開啟的地塊
		
		end else if (mine_map[1+player_y][1+player_x] == 0) begin // 踩到地雷了
		  // 處理輸掉邏輯
		  lose_flag=1;
		end else begin // 沒踩到地雷
		  //mine_map player_x player_y
		  mine_map[1+player_y][1+player_x] = 2; //標示為踩過
		  
		  // 如果採的地塊的地雷數是0代表周圍也都不是地雷，踩一遍周圍
		  if (mineNum_map[1+player_y-1][1+player_x-1] == 0) begin
		  /*
		    if (mineNum_map[1+player_y-1][1+player_x-1] == 0)
		      mine_map[1+player_y-1][1+player_x-1] = 2;
		    if (mineNum_map[1+player_y-1][1+player_x] == 0)
		  	 mine_map[1+player_y-1][1+player_x] = 2;
		    if (mineNum_map[1+player_y-1][1+player_x+1] == 0)
		  	 mine_map[1+player_y-1][1+player_x+1] = 2;
		  	 
		    if (mineNum_map[1+player_y][1+player_x-1] == 0)
		  	 mine_map[1+player_y][1+player_x-1] = 2;
		    if (mineNum_map[1+player_y][1+player_x+1] == 0)
		  	 mine_map[1+player_y][1+player_x+1] = 2;
		  	 
		    if (mineNum_map[1+player_y+1][1+player_x-1] == 0)
		  	 mine_map[1+player_y+1][1+player_x-1] = 2;
		    if (mineNum_map[1+player_y+1][1+player_x] == 0)
		  	 mine_map[1+player_y+1][1+player_x] = 2;
		    if (mineNum_map[1+player_y+1][1+player_x+1] == 0)
		  	 mine_map[1+player_y+1][1+player_x+1] = 2;
			 */
			 /*
		    mine_map[1+player_y-1][1+player_x-1] = 2;
		  	 mine_map[1+player_y-1][1+player_x] = 2;
		  	 mine_map[1+player_y-1][1+player_x+1] = 2;
		  	 mine_map[1+player_y][1+player_x-1] = 2;
		  	 mine_map[1+player_y][1+player_x+1] = 2;
		  	 mine_map[1+player_y+1][1+player_x-1] = 2;
		  	 mine_map[1+player_y+1][1+player_x] = 2;
		  	 mine_map[1+player_y+1][1+player_x+1] = 2;
			*/
		  end
		  
			// 開始更新顏色
		  for (i = 0; i < 8; i = i + 1) begin
          for (j = 0; j < 8; j = j + 1) begin
		      if (mine_map[1+i][1+j] == 1) begin // 是沒開啟的區塊
			     r_map[i][j] = 0; // 藍色
				  g_map[i][j] = 1;
				  b_map[i][j] = 1;
			   end else if (mine_map[1+i][1+j] == 2) begin // 是開啟的區塊
				  if (mineNum_map[1+i][1+j] == 0) begin // 此格已開啟且周圍無地雷
					r_map[i][j] = 1; // 綠色
					g_map[i][j] = 0;
					b_map[i][j] = 1;
				  end else begin // 此格已開啟且周圍有地雷
					r_map[i][j] = 0; // 黃色
					g_map[i][j] = 0;
					b_map[i][j] = 1;
				  end
				end
		    end
		  end
		  
		  // 檢測是否除了地雷全踩過
		  begin : loop
		  for (i = 0; i < 8; i = i + 1) begin
          for (j = 0; j < 8; j = j + 1) begin
			   win_flag =1;
				if (mine_map[1+i][1+j] == 1) begin// 沒踩過
				  win_flag = 0;
				  disable loop; // 離開 loop
				end
			 end
		  end
		  end
		  
		  if (win_flag == 1) begin // 贏了
		    win_flag2 =1;
		  end
		end
    end
  end
endcase
end
  

  // mled clock
always @(posedge CLK_1000Hz) begin
  if (cnt >= 7) begin
    cnt <= 0;
  end else begin
    cnt <= cnt+1;
  end
  mled_COM <= {1'b1, cnt};
  
  // 玩家閃爍控制
  if (player_flag == 0) begin // 顯示原本顏色
    mled_r <= r_map[cnt];
	 mled_g <= g_map[cnt];
    mled_b <= b_map[cnt];
  end else begin // 顯示玩家所在位置無顏色
	if (cnt == player_y) begin // 當 cnt 走到 player_y
	  mled_r <= r_map[cnt];
	  mled_g <= g_map[cnt];
     mled_b <= b_map[cnt];
     mled_r[player_x] <= 1'b1; // 修改為無顏色
  	  mled_g[player_x] <= 1'b1;
  	  mled_b[player_x] <= 1'b1;
    end else begin
  	  mled_r <= r_map[cnt];
	  mled_g <= g_map[cnt];
     mled_b <= b_map[cnt];
    end
  end
end
  
  // seg clock
always @(posedge CLK_1000Hz) begin
  if (seg_COM == 4'b0111) begin // 3th seg
	 seg_COM <= 4'b1011;
	 if (strFlag == 0) begin
	   seg <= 7'b1111111;
	 end else begin
	   if (win_flag2 == 1) begin
		  seg <= 7'b0001000; // R
		end else if (lose_flag == 1) begin
		  seg <= 7'b0100100;// S
		end else begin
		  seg <= 7'b1111111;
		end
	 end
  end else if (seg_COM == 4'b1011) begin // 2th seg
	 seg_COM <= 4'b1101;
	 if (strFlag == 0) begin
	   seg <= 7'b1111111;
	 end else begin
	   if (win_flag2 == 1) begin
		  seg <= 7'b1110001; // L
		end else if (lose_flag == 1) begin
		  seg <= 7'b0000001; // O
		end else begin
		  seg <= 7'b1111111;
		end
	 end
  end else if (seg_COM == 4'b1101) begin  // 1th seg
    seg_COM <= 4'b1110;
	 if (strFlag == 0) begin
	   //levelNum <= 4'b0011;
	   seg <= level_seg;
	 end else begin
	   if (win_flag2 == 1) begin
		  seg <= 7'b0110001; // C
		end else if (lose_flag == 1) begin
		  seg <= 7'b1110001; // L
		end else begin
		  if (mine_map[1+player_y][1+player_x] == 2)
		    seg <= mineNum_seg; // 地雷數量顯示
		  else
		    seg <= 7'b1111111;
		end
	 end
  end else if (seg_COM == 4'b1110) begin // 4th seg
    seg_COM <= 4'b0111;
	 if (strFlag == 0) begin
	   seg <= 7'b1111111;
	 end else begin
	 	if (win_flag2 == 1) begin
		  seg <= 7'b1111111; // NULL
		end else if (lose_flag == 1) begin
		  seg <= 7'b0110000;// E
		end else begin
		  seg <= 7'b1111111;
		end
	 end
  end
end
  
// 玩家閃爍 Flag clock
always @(posedge CLK_1Hz) begin
  if (player_flag == 0) begin
    player_flag <= 1'b1;
  end else begin
    player_flag <= 1'b0;
  end
end

  BCD2Seg BCD2Seg_1(levelNum[3], levelNum[2], levelNum[1], levelNum[0], level_seg );
  BCD2Seg_2 BCD2Seg_2(mineNum_map[1+player_y][1+player_x], mineNum_seg );



endmodule





// BCD 轉 seg
module BCD2Seg(input A,B,C,D, output reg [6:0] seg);
always @(A,B,C,D) 
  case({A,B,C,D})
  4'b0000: seg=7'b0000001; // 0
  4'b0001: seg=7'b1001111; // 1
  4'b0010: seg=7'b0010010; // 2
  4'b0011: seg=7'b0000110; // 3
  4'b0100: seg=7'b1001100; // 4
  4'b0101: seg=7'b0100100; // 5
  4'b0110: seg=7'b0100000; // 6
  4'b0111: seg=7'b0001111; // 7
  4'b1000: seg=7'b0000000; // 8
  4'b1001: seg=7'b0000100; // 9
default: seg=7'b1111111; // NULL
endcase
endmodule


module BCD2Seg_2(input [3:0] A, output reg [6:0] seg);
always @(A) 
  case(A)
  4'b0000: seg=7'b0000001; // 0
  4'b0001: seg=7'b1001111; // 1
  4'b0010: seg=7'b0010010; // 2
  4'b0011: seg=7'b0000110; // 3
  4'b0100: seg=7'b1001100; // 4
  4'b0101: seg=7'b0100100; // 5
  4'b0110: seg=7'b0100000; // 6
  4'b0111: seg=7'b0001111; // 7
  4'b1000: seg=7'b0000000; // 8
  4'b1001: seg=7'b0000100; // 9
default: seg=7'b1111111; // NULL
endcase

endmodule
  