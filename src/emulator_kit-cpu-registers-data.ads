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

end Emulator_Kit.CPU.Registers.Data;
