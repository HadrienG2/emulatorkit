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

-- This package hierarchy regroups physical memory concepts and implementation
package Emulator_Kit.Memory.Physical is

   -- The AMD64 architecture mandates that physical memory addresses be at most 52 bit wide.
   Max_Physical_Memory_Size : constant := 2 ** 52;
   type Physical_Address is new Memory.Universal_Address range 0 .. Universal_Address'Pred (Max_Physical_Memory_Size);
   type Physical_Size is new Memory.Universal_Size range 0 .. Max_Physical_Memory_Size;

end Emulator_Kit.Memory.Physical;
