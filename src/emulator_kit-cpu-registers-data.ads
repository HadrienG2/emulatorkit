-- Copyright 2015 Hadrien Grasland
--
-- This file is part of EmulatorKit.
--
-- EmulatorKit is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- EmulatorKit is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with EmulatorKit.  If not, see <http://www.gnu.org/licenses/>.

with System;

-- This package is used to analyze register contents
package Emulator_Kit.CPU.Registers.Data is

   -- Data from the FLAGS register can be analyzed using the following record
   type FLAGS_Data is
      record
         Carry_Flag : Boolean;
         Parity_Flag : Boolean;
         Auxiliary_Carry_Flag : Boolean;
         Zero_Flag : Boolean;
         Sign_Flag : Boolean;
         Direction_Flag : Boolean;
         Overflow_Flag : Boolean;
      end record;
   for FLAGS_Data'Size use 16;
   for FLAGS_Data'Bit_Order use System.Low_Order_First;
   for FLAGS_Data use
      record
         Carry_Flag at 0 range 0 .. 0;
         Parity_Flag at 0 range 2 .. 2;
         Auxiliary_Carry_Flag at 0 range 4 .. 4;
         Zero_Flag at 0 range 6 .. 6;
         Sign_Flag at 0 range 7 .. 7;
         Direction_Flag at 0 range 10 .. 10;
         Overflow_Flag at 0 range 11 .. 11;
      end record;

   -- All parts of the x86 floating-point stack (x87 and SSE) share the same floating-point rounding control
   type Floating_Point_Rounding is (Round_To_Nearest, Round_Down, Round_Up, Round_Towards_Zero);
   for Floating_Point_Rounding use (Round_To_Nearest => 0, Round_Down => 1, Round_Up => 2, Round_Towards_Zero => 3);

   -- Data from the FSW register can be analyzed using the following record
   type FSW_Stack_Pointer is mod 8;
   type FSW_Data is
      record
         -- Exception flags
         Invalid_Operation_Exception : Boolean;
         Denormalized_Operand_Exception : Boolean;
         Zero_Divide_Exception : Boolean;
         Overflow_Exception : Boolean;
         Underflow_Exception : Boolean;
         Precision_Exception : Boolean;
         -- Other flags
         Stack_Fault : Boolean;
         Exception_Status : Boolean;
         Condition_Code_C0 : Boolean;
         Condition_Code_C1 : Boolean;
         Condition_Code_C2 : Boolean;
         Top_Of_Stack_Pointer : FSW_Stack_Pointer;
         Condition_Code_C3 : Boolean;
         X87_FP_Unit_Busy : Boolean;
      end record;
   for FSW_Data'Size use 16;
   for FSW_Data'Bit_Order use System.Low_Order_First;
   for FSW_Data use
      record
         Invalid_Operation_Exception at 0 range 0 .. 0;
         Denormalized_Operand_Exception at 0 range 1 .. 1;
         Zero_Divide_Exception at 0 range 2 .. 2;
         Overflow_Exception at 0 range 3 .. 3;
         Underflow_Exception at 0 range 4 .. 4;
         Precision_Exception at 0 range 5 .. 5;
         Stack_Fault at 0 range 6 .. 6;
         Exception_Status at 0 range 7 .. 7;
         Condition_Code_C0 at 0 range 8 .. 8;
         Condition_Code_C1 at 0 range 9 .. 9;
         Condition_Code_C2 at 0 range 10 .. 10;
         Top_Of_Stack_Pointer at 0 range 11 .. 13;
         Condition_Code_C3 at 0 range 14 .. 14;
         X87_FP_Unit_Busy at 0 range 15 .. 15;
      end record;

   -- Data from the FCW register can be analyzed using the following record
   type FCW_Precision_Control is (Single_Precision, Double_Precision, Double_Extended_Precision);
   for FCW_Precision_Control use (Single_Precision => 0, Double_Precision => 2, Double_Extended_Precision => 3);
   type FCW_Data is
      record
         -- #MF exception masks
         Invalid_Operation_Exception_Mask : Boolean;
         Denormalized_Operand_Exception_Mask : Boolean;
         Zero_Divide_Exception_Mask : Boolean;
         Overflow_Exception_Mask : Boolean;
         Underflow_Exception_Mask : Boolean;
         Precision_Exception_Mask : Boolean;
         -- Other flags
         Precision_Control : FCW_Precision_Control;
         Rounding_Control : Floating_Point_Rounding;
         Infinity_Bit : Boolean;
      end record;
   for FCW_Data'Size use 16;
   for FCW_Data'Bit_Order use System.Low_Order_First;
   for FCW_Data use
      record
         Invalid_Operation_Exception_Mask at 0 range 0 .. 0;
         Denormalized_Operand_Exception_Mask at 0 range 1 .. 1;
         Zero_Divide_Exception_Mask at 0 range 2 .. 2;
         Overflow_Exception_Mask at 0 range 3 .. 3;
         Underflow_Exception_Mask at 0 range 4 .. 4;
         Precision_Exception_Mask at 0 range 5 .. 5;
         Precision_Control at 0 range 8 .. 9;
         Rounding_Control at 0 range 10 .. 11;
         Infinity_Bit at 0 range 12 .. 12;
      end record;

   -- Data from the FTW register can be analyzed using the following record
   type FTW_Tag is (Valid, Zero, Special, Empty);
   for FTW_Tag use (Valid => 0, Zero => 1, Special => 2, Empty => 3);
   type FTW_Data is array (0 .. 7) of FTW_Tag;
   for FTW_Data'Component_Size use 2;
   for FTW_Data'Size use 16;

   -- Data from the MXCSR register can be analyzed using the following record
   type MXCSR_Data is
      record
         -- Exception flags
         Invalid_Operation_Exception : Boolean;
         Denormalized_Operand_Exception : Boolean;
         Zero_Divide_Exception : Boolean;
         Overflow_Exception : Boolean;
         Underflow_Exception : Boolean;
         Precision_Exception : Boolean;
         -- Exception masks
         Denormals_Are_Zeros : Boolean;
         Invalid_Operation_Exception_Mask : Boolean;
         Denormalized_Operand_Exception_Mask : Boolean;
         Zero_Divide_Exception_Mask : Boolean;
         Overflow_Exception_Mask : Boolean;
         Underflow_Exception_Mask : Boolean;
         Precision_Exception_Mask : Boolean;
         -- Other flags
         Floating_Point_Rounding_Control : Floating_Point_Rounding;
         Flush_To_Zero_For_Masked_Underflow : Boolean;
         Misaligned_Exception_Mask : Boolean;
      end record;
   for MXCSR_Data'Size use 32;
   for MXCSR_Data'Bit_Order use System.Low_Order_First;
   for MXCSR_Data use
      record
         Invalid_Operation_Exception at 0 range 0 .. 0;
         Denormalized_Operand_Exception at 0 range 1 .. 1;
         Zero_Divide_Exception at 0 range 2 .. 2;
         Overflow_Exception at 0 range 3 .. 3;
         Underflow_Exception at 0 range 4 .. 4;
         Precision_Exception at 0 range 5 .. 5;
         Denormals_Are_Zeros at 0 range 6 .. 6;
         Invalid_Operation_Exception_Mask at 0 range 7 .. 7;
         Denormalized_Operand_Exception_Mask at 0 range 8 .. 8;
         Zero_Divide_Exception_Mask at 0 range 9 .. 9;
         Overflow_Exception_Mask at 0 range 10 .. 10;
         Underflow_Exception_Mask at 0 range 11 .. 11;
         Precision_Exception_Mask at 0 range 12 .. 12;
         Floating_Point_Rounding_Control at 0 range 13 .. 14;
         Flush_To_Zero_For_Masked_Underflow at 0 range 15 .. 15;
         Misaligned_Exception_Mask at 0 range 17 .. 17;
      end record;

end Emulator_Kit.CPU.Registers.Data;
