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

with Emulator_Kit.Data_Types;

-- This package hierarchy is used to manage emulated memory
package Emulator_Kit.Memory is

   -- This exception will be thrown when manipulating invalid memory addresses
   Illegal_Address : exception;

   -- The address and size of objects may be at most 2^64 - 1 on the AMD64 architecture.
   -- (Well, theoretically speaking, it's possible to envision an object of size 2^64, but then we couldn't count its size)
   type Universal_Address is new Data_Types.Quad_Word;
   type Universal_Size is new Data_Types.Quad_Word;

   -- We differentiate addresses and sizes, and use special operators to detect memory address overflows and negative sizes
   overriding function "+"(Left, Right : Universal_Address) return Universal_Address is abstract;
   function "-"(Left, Right : Universal_Address) return Universal_Size with Inline;
   function "+"(Left : Universal_Address; Right : Universal_Size) return Universal_Address with Inline;
   function "-"(Left : Universal_Address; Right : Universal_Size) return Universal_Address with Inline;

end Emulator_Kit.Memory;
