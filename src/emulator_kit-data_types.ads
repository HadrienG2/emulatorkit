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

-- This package specifies the primitive data types handled by AMD64 processors
package Emulator_Kit.Data_Types is

   -- In Ada, sizes are in bits and alignments are in bytes. This can be confusing, so better count sizes in bytes when mixing both.
   Byte_Size : constant := 8;

   -- Bytes, words, dwords and qwords are native on AMD64 hosts
   type Byte is mod 2 ** 8 with Size => Byte_Size, Alignment => 1;
   type Word is mod 2 ** 16 with Size => 2 * Byte_Size, Alignment => 2;
   type Double_Word is mod 2 ** 32 with Size => 4 * Byte_Size, Alignment => 4;
   type Quad_Word is mod 2 ** 64 with Size => 8 * Byte_Size, Alignment => 8;

   -- x86_64 SIMD types must be interpreted as arrays of quadwords (or something else).
   type SIMD_Type is array (Positive range <>) of aliased Quad_Word;
   type Two_Quad_Words is new SIMD_Type (1 .. 2) with Size => 16 * Byte_Size, Alignment => 16;
   type Four_Quad_Words is new SIMD_Type (1 .. 4) with Size => 32 * Byte_Size, Alignment => 32;

   -- Native floating-point types on hosts with double-precision IEEE 754 arithmetic
   type Float_Single is digits 6 with Size => 4 * Byte_Size, Alignment => 4;
   type Float_Double is digits 15 with Size => 8 * Byte_Size, Alignment => 8;

   -- x86_64's extended-precision floating point type must be interpreted as a record
   type Float_Extended_Fraction is mod 2 ** 63;
   type Float_Extended_Biased_Exponent is mod 2 ** 15;
   Float_Extended_Exponent_Bias : constant := -16383;
   type Float_Extended is
      record
         Fraction : Float_Extended_Fraction;
         Integer_Bit : Boolean;
         Exponent : Float_Extended_Biased_Exponent;
         Sign_Bit : Boolean;
      end record;
   for Float_Extended'Size use 16 * Byte_Size; -- An extended-precision float is 80 bits aka 10 bytes, but these are best 16 bytes aligned.
   for Float_Extended'Alignment use 16;
   for Float_Extended'Bit_Order use System.Low_Order_First;
   for Float_Extended use
      record
         Fraction at 0 range 0 .. 62;
         Integer_Bit at 0 range 63 .. 63;
         Exponent at 8 range 0 .. 14;
         Sign_Bit at 8 range 15 .. 15;
      end record;

end Emulator_Kit.Data_Types;
