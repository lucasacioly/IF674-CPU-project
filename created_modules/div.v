module div(  
   input [31:0] A, B,
   input [1:0]start,
   input clk, reset,  
   output flag, 
   output [31:0] hi, lo
   );  

   reg active;  
   reg [5:0] cycle;    
   reg [31:0] result;    
   reg [31:0] denom;   
   reg [31:0] work;   
   reg signed_x, signed_y, signed_ok;

   wire [32:0]   sub = { work[30:0], result[31] } - denom;  
   assign flag = !B;  
   assign lo = result;  
   assign hi = work;  
   
   
   always @(posedge clk) begin  
     if (reset || start == 2'd0 || start == 2'd2) begin  
       active <= 0;  
       cycle <= 6'd40;  
       result <= 0;  
       denom <= 0;  
       work <= 0;
       signed_x <= 0;
       signed_y <= 0;  
     end 

     else if(start == 2'd1) begin 

       if (cycle > 0 && cycle < 33) begin  
         if (sub[32] == 0) begin  
           work <= sub[31:0];  
           result <= {result[30:0], 1'b1};  
         end  
         else begin  
           work <= {work[30:0], result[31]};  
           result <= {result[30:0], 1'b0};  
         end  
         if (cycle == 6'd1) begin  
           active <= 0; 
           if ((~signed_x && ~signed_y) || (signed_x && signed_y))begin
             signed_ok <= 0; end 
         end 
         
         cycle <= cycle - 6'd1;  
       end 

       else if (cycle == 0)begin  
         if(signed_x && ~signed_y) begin
            result <= ~result + 1;
            work <= ~work + 1;
            signed_x <= 0;
            signed_y <= 0;
            signed_ok <= 0; 
         end else if (~signed_x && signed_y) begin
           result <= ~result + 1;
            signed_x <= 0;
            signed_y <= 0;
            signed_ok <= 0; 
         end  
       end 

       else begin
          if (A[31] == 1'b1) begin 
            result <= ~A + 1; 
            signed_x <= 1; 
          end else begin 
            result <= A; 
            signed_x <= 0; 
          end

          if (B[31]== 1'b1) begin 
            denom <= ~B + 1; 
            signed_y <= 1; 
          end else begin 
            denom <= B;  
            signed_y <= 0; 
          end

          cycle <= 6'd32;   
          work <= 32'b0;  
          active <= 1; 
          signed_ok <= 1;
       end


     end 

      
   end  
 endmodule 